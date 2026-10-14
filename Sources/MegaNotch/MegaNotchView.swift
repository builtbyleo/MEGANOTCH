import SwiftUI

struct MegaNotchView: View {
    @ObservedObject var model: NotchModel

    var body: some View {
        let notch = MegaNotchShape(
            progress: model.expanded ? 1 : 0,
            pill: model.pillRect,
            giant: model.giantNotchRect
        )
        let contentRect = model.contentRect

        ZStack(alignment: .topLeading) {
            notch.fill(Color.black)

            ZStack(alignment: .topLeading) {
                content
                    .frame(width: contentRect.width, height: contentRect.height)
                    .offset(x: contentRect.minX, y: contentRect.minY)
            }
            .frame(width: model.size.width, height: model.size.height, alignment: .topLeading)
            .mask(notch)

            pillHighlight
                .opacity(model.expanded ? 0 : 1)

            if let toast = model.toast {
                Text(toast)
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 22)
                    .padding(.vertical, 14)
                    .background(Capsule().fill(Color(white: 0.13)))
                    .overlay(Capsule().stroke(Color.white.opacity(0.12)))
                    .frame(width: model.size.width)
                    .offset(y: model.topInset + 24)
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .frame(width: model.size.width, height: model.size.height, alignment: .topLeading)
        .clipped()
        .ignoresSafeArea()
    }

    // MARK: - Mega content

    private var content: some View {
        ZStack {
            VStack(spacing: 28) {
                Spacer(minLength: model.topInset + 40)
                header
                widgetGrid
                Spacer()
                footer
            }
            .padding(.horizontal, 60)
            .padding(.bottom, model.expanded ? 32 : model.size.height - model.pillRect.minY + 16)

            topBar
        }
        .foregroundStyle(.white)
        .contextMenu {
            Button("Expand Desktop (cheater)") { model.expandDesktop() }
            Button("Buy 4 Pixels") { model.buyPixels() }
            Divider()
            Button("Quit MegaNotch") { NSApp.terminate(nil) }
        }
    }

    private var topBar: some View {
        VStack {
            HStack {
                TimelineView(.periodic(from: .now, by: 1)) { ctx in
                    Text(ctx.date, style: .time)
                        .font(.system(size: 13, weight: .medium, design: .monospaced))
                        .foregroundStyle(.white.opacity(0.5))
                }
                Spacer()
                Button {
                    NSApp.terminate(nil)
                } label: {
                    Text("Exit notch (coward)")
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Capsule().fill(Color.white.opacity(0.08)))
                }
                .buttonStyle(.plain)
                .foregroundStyle(.white.opacity(0.6))
                .keyboardShortcut("q", modifiers: .command)
            }
            .padding(.horizontal, 24)
            .padding(.top, max(10, (model.topInset - 24) / 2))
            Spacer()
        }
    }

    private var header: some View {
        VStack(spacing: 10) {
            Text("MEGANOTCH")
                .font(.system(size: 76, weight: .black, design: .rounded))
                .tracking(6)
                .foregroundStyle(
                    LinearGradient(
                        colors: [.white, Color(white: 0.55)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            TimelineView(.periodic(from: .now, by: 4)) { ctx in
                let taglines = NotchModel.taglines
                let i = Int(ctx.date.timeIntervalSinceReferenceDate / 4) % taglines.count
                Text(taglines[i])
                    .font(.system(size: 20, weight: .medium, design: .rounded))
                    .foregroundStyle(.white.opacity(0.65))
                    .id(i)
                    .transition(.opacity)
                    .animation(.easeInOut(duration: 0.4), value: i)
            }
        }
    }

    private var widgetGrid: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(minimum: 180, maximum: 300), spacing: 16), count: 4), spacing: 16) {
            WidgetCard(icon: "music.note", title: "Now Playing") {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Fan Noise (Extended Mix)").font(.system(size: 14, weight: .semibold))
                    Text("Your MacBook").font(.system(size: 12)).foregroundStyle(.white.opacity(0.5))
                    TimelineView(.periodic(from: .now, by: 0.5)) { ctx in
                        let t = ctx.date.timeIntervalSinceReferenceDate.truncatingRemainder(dividingBy: 180) / 180
                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                Capsule().fill(Color.white.opacity(0.15))
                                Capsule().fill(Color.white).frame(width: geo.size.width * t)
                            }
                        }
                        .frame(height: 4)
                    }
                }
            }
            WidgetCard(icon: "tray.and.arrow.down", title: "File Shelf") {
                Text("Drop files here. We'll hold them. Forever.\n(You can't reach your files anyway.)")
            }
            WidgetCard(icon: "cloud.moon.fill", title: "Weather") {
                Text("Dark.\n100% chance of notch.")
            }
            WidgetCard(icon: "calendar", title: "Calendar") {
                Text("0 meetings today.\nYou couldn't find Zoom anyway.")
            }
            WidgetCard(icon: "battery.100.bolt", title: "Battery") {
                Text("Yes.")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
            }
            WidgetCard(icon: "camera.fill", title: "Camera") {
                Text("Your webcam is in here somewhere.\nProbably. We lost it.")
            }
            WidgetCard(icon: "sparkles", title: "Live Activity") {
                Text("You, staring at a black screen.\nStarted just now. Ongoing.")
            }
            WidgetCard(icon: "creditcard.fill", title: "MegaNotch Pro") {
                VStack(alignment: .leading, spacing: 8) {
                    Text("$9.99/mo unlocks 4 more pixels of desktop.")
                    HStack {
                        Button { model.buyPixels() } label: {
                            Text("Upgrade")
                                .font(.system(size: 12, weight: .semibold, design: .rounded))
                                .padding(.horizontal, 12)
                                .padding(.vertical, 5)
                                .background(Capsule().fill(Color.white.opacity(0.18)))
                        }
                        .buttonStyle(.plain)
                        if model.pixelsPurchased > 0 {
                            Text("\(model.pixelsPurchased)px owned")
                                .font(.system(size: 11))
                                .foregroundStyle(.white.opacity(0.5))
                        }
                    }
                }
            }
        }
        .frame(maxWidth: 1200)
    }

    private var footer: some View {
        VStack(spacing: 10) {
            Text(String(format: "Notch coverage: %.2f%%   ·   Industry average: 0.4%%", model.coverage * 100))
                .font(.system(size: 12, weight: .medium, design: .monospaced))
                .foregroundStyle(.white.opacity(0.35))
            BouncingArrowLabel(text: model.expanded ? "your desktop (somewhere down there)" : "your entire desktop")
        }
    }

    // MARK: - Pill

    private var pillHighlight: some View {
        PulsingPillOutline()
            .frame(width: model.pillRect.width, height: model.pillRect.height)
            .offset(x: model.pillRect.minX, y: model.pillRect.minY)
            .allowsHitTesting(false)
    }
}

private struct WidgetCard<Body: View>: View {
    let icon: String
    let title: String
    @ViewBuilder let body_: () -> Body

    init(icon: String, title: String, @ViewBuilder content: @escaping () -> Body) {
        self.icon = icon
        self.title = title
        self.body_ = content
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label(title, systemImage: icon)
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .textCase(.uppercase)
                .foregroundStyle(.white.opacity(0.45))
            body_()
                .font(.system(size: 13, weight: .regular, design: .rounded))
                .foregroundStyle(.white.opacity(0.85))
                .fixedSize(horizontal: false, vertical: true)
            Spacer(minLength: 0)
        }
        .padding(16)
        .frame(maxWidth: .infinity, minHeight: 130, alignment: .topLeading)
        .background(RoundedRectangle(cornerRadius: 20, style: .continuous).fill(Color(white: 0.08)))
        .overlay(RoundedRectangle(cornerRadius: 20, style: .continuous).stroke(Color.white.opacity(0.06)))
    }
}

/// 0...1 sine wave over `period` seconds. Looping animations are driven by the clock rather than
/// `withAnimation(.repeatForever)`, which would also loop any layout change in the same transaction.
private func wave(_ date: Date, period: Double) -> Double {
    (sin(date.timeIntervalSinceReferenceDate * 2 * .pi / period) + 1) / 2
}

private struct BouncingArrowLabel: View {
    let text: String

    var body: some View {
        VStack(spacing: 4) {
            Text(text)
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundStyle(.white.opacity(0.6))
            TimelineView(.animation) { ctx in
                Image(systemName: "chevron.down")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(.white.opacity(0.6))
                    .offset(y: -2 + 6 * wave(ctx.date, period: 1.4))
            }
        }
    }
}

private struct PulsingPillOutline: View {
    var body: some View {
        TimelineView(.animation) { ctx in
            let pulse = wave(ctx.date, period: 2.4)
            Capsule()
                .stroke(Color.white.opacity(0.15 + 0.35 * pulse), lineWidth: 1.5)
                .shadow(color: .white.opacity(0.35 * pulse), radius: 8)
        }
    }
}
