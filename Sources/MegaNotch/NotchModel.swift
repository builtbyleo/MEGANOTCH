import SwiftUI

@MainActor
final class NotchModel: ObservableObject {
    /// `true` when the desktop has been graciously allowed to exist.
    @Published var expanded = false
    @Published var size: CGSize = CGSize(width: 1512, height: 982)
    /// Height of the menu bar / hardware notch. Content stays below it.
    @Published var topInset: CGFloat = 38
    @Published var pillSize = CGSize(width: 180, height: 30)
    @Published var toast: String?
    @Published var pixelsPurchased = 0

    private var toastTask: Task<Void, Never>?
    private let pillBottomMargin: CGFloat = 14

    var pillRect: CGRect {
        CGRect(
            x: (size.width - pillSize.width) / 2,
            y: size.height - pillSize.height - pillBottomMargin,
            width: pillSize.width,
            height: pillSize.height
        )
    }

    /// Slightly generous hover zone that also reaches the bottom edge of the screen.
    var pillHoverRect: CGRect {
        let pill = pillRect
        return CGRect(
            x: pill.minX - 6,
            y: pill.minY - 6,
            width: pill.width + 12,
            height: size.height - pill.minY + 6
        )
    }

    /// The notch while the desktop is "expanded". We compromised: roughly 3/4 of the screen.
    var giantNotchRect: CGRect {
        let w = size.width * 0.88, h = size.height * 0.84
        return CGRect(x: (size.width - w) / 2, y: 0, width: w, height: h)
    }

    /// Where the widgets are laid out.
    var contentRect: CGRect {
        expanded ? giantNotchRect : CGRect(origin: .zero, size: size)
    }

    var coverage: Double {
        let screen = size.width * size.height
        guard screen > 0 else { return 1 }
        if expanded {
            // Rectangle, minus the rounded bottom corners, plus the ears.
            let notch = giantNotchRect
            let corner = 1 - Double.pi / 4
            let r = Double(MegaNotchShape.bottomRadius), e = Double(MegaNotchShape.earRadius)
            let area = Double(notch.width * notch.height) - 2 * r * r * corner + 2 * e * e * corner
            return area / Double(screen)
        }
        let pill = pillRect
        return 1 - Double(pill.width * pill.height) / Double(screen)
    }

    func expandDesktop() {
        guard !expanded else { return }
        withAnimation(.spring(response: 0.55, dampingFraction: 0.78)) { expanded = true }
    }

    func expandNotch() {
        guard expanded else { return }
        withAnimation(.spring(response: 0.6, dampingFraction: 0.85)) { expanded = false }
        showToast(Self.collapseToasts.randomElement()!)
    }

    func buyPixels() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
            pillSize.width += 4
            pixelsPurchased += 4
        }
        showToast("Thank you for purchasing 4 pixels.\nYour card has not been charged. Yet.")
    }

    func showToast(_ text: String) {
        toastTask?.cancel()
        withAnimation(.easeOut(duration: 0.2)) { toast = text }
        toastTask = Task { @MainActor [weak self] in
            try? await Task.sleep(for: .seconds(3.5))
            guard !Task.isCancelled else { return }
            withAnimation(.easeIn(duration: 0.3)) { self?.toast = nil }
        }
    }

    static let collapseToasts = [
        "You hovered the notch.\nSo the notch expanded.\nThat's how notch apps work.",
        "Welcome back to the notch.\nWe missed you.",
        "Desktop session ended.\nThank you for visiting your desktop.",
        "Did you want the menu bar?\nThe menu bar is notch now.",
        "The notch was only 74% of your screen.\nWe fixed that.",
    ]

    static let taglines = [
        "The only notch app brave enough to go all the way.",
        "Other notch apps: 200pt. MegaNotch: all of them.",
        "Why settle for a Dynamic Island when you can have a Dynamic Continent?",
        "Your notch, but it went to the gym.",
        "We put a notch in your notch so you can notch while you notch.",
        "Productivity apps hate this one weird trick.",
        "Zero distractions. Also zero windows.",
        "Designed in California. Notched everywhere.",
    ]
}
