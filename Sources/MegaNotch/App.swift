import AppKit
import SwiftUI

@main
struct MegaNotchMain {
    @MainActor
    static func main() {
        let app = NSApplication.shared
        let delegate = AppDelegate()
        app.delegate = delegate
        app.setActivationPolicy(.accessory)
        app.run()
    }
}

/// Borderless panel that can still receive clicks for the buttons inside the notch.
final class NotchPanel: NSPanel {
    override var canBecomeKey: Bool { true }
}

/// Lets buttons respond on the first click even when the panel isn't key.
final class FirstMouseHostingView<Content: View>: NSHostingView<Content> {
    override func acceptsFirstMouse(for event: NSEvent?) -> Bool { true }
}

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    private let model = NotchModel()
    private var panel: NotchPanel?
    private var timer: Timer?
    private var notchDwell: TimeInterval = 0
    private var notchArmed = false
    private let tickInterval: TimeInterval = 1.0 / 60.0

    func applicationDidFinishLaunching(_ notification: Notification) {
        let panel = NotchPanel(
            contentRect: NSScreen.screens.first?.frame ?? .zero,
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )
        panel.isOpaque = false
        panel.backgroundColor = .clear
        panel.hasShadow = false
        // Above the menu bar and the Dock. The notch answers to no one.
        panel.level = .screenSaver
        panel.collectionBehavior = [.canJoinAllSpaces, .stationary, .fullScreenAuxiliary, .ignoresCycle]
        panel.isMovable = false
        let hostingView = FirstMouseHostingView(rootView: MegaNotchView(model: model))
        // The window is sized by us, never by SwiftUI.
        hostingView.sizingOptions = []
        panel.contentView = hostingView
        self.panel = panel

        layoutForScreen()
        panel.orderFrontRegardless()

        NotificationCenter.default.addObserver(
            forName: NSApplication.didChangeScreenParametersNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            MainActor.assumeIsolated { self?.layoutForScreen() }
        }

        // Polling the cursor needs no Accessibility permission and lets us
        // toggle click-through depending on whether the cursor is over notch or desktop.
        let timer = Timer(timeInterval: tickInterval, repeats: true) { [weak self] _ in
            MainActor.assumeIsolated { self?.tick() }
        }
        RunLoop.main.add(timer, forMode: .common)
        self.timer = timer
    }

    private func layoutForScreen() {
        guard let panel, let screen = NSScreen.screens.first else { return }
        panel.setFrame(screen.frame, display: true)
        model.size = screen.frame.size

        model.topInset = max(screen.safeAreaInsets.top, 24)
    }

    private func tick() {
        guard let panel else { return }
        let mouse = NSEvent.mouseLocation
        let frame = panel.frame
        // SwiftUI coordinates: origin top-left.
        let p = CGPoint(x: mouse.x - frame.minX, y: frame.maxY - mouse.y)

        if !model.expanded {
            notchArmed = false
            let inPill = model.pillHoverRect.contains(p)
            panel.ignoresMouseEvents = inPill
            if inPill { model.expandDesktop() }
        } else {
            let inNotch = model.giantNotchRect.contains(p)
            panel.ignoresMouseEvents = !inNotch
            // The cursor has to leave the notch once before hovering it counts, so
            // "Expand Desktop (cheater)" from the context menu isn't undone instantly.
            if !inNotch { notchArmed = true }
            if inNotch && notchArmed {
                notchDwell += tickInterval
                if notchDwell > 0.25 {
                    notchDwell = 0
                    model.expandNotch()
                }
            } else {
                notchDwell = 0
            }
        }
    }
}
