import SwiftUI

/// The notch, at whatever size it currently feels like being.
/// `progress` 0 = covers the whole screen with a pill-shaped hole for the desktop,
/// 1 = a giant but still classically notch-shaped notch (`giant`), desktop around the edges.
struct MegaNotchShape: Shape {
    var progress: CGFloat
    var pill: CGRect
    var giant: CGRect

    static let earRadius: CGFloat = 28
    static let bottomRadius: CGFloat = 96

    var animatableData: CGFloat {
        get { progress }
        set { progress = newValue }
    }

    func path(in rect: CGRect) -> Path {
        // At progress 0 the body overshoots the screen so the ears and bottom corners are hidden off-screen.
        let full = CGRect(
            x: rect.minX - 4,
            y: rect.minY,
            width: rect.width + 8,
            height: rect.height + Self.bottomRadius + 4
        )
        let t = progress
        let body = CGRect(
            x: lerp(full.minX, giant.minX, t),
            y: lerp(full.minY, giant.minY, t),
            width: max(0, lerp(full.width, giant.width, t)),
            height: max(0, lerp(full.height, giant.height, t))
        )
        let hole = Path(roundedRect: pill, cornerRadius: pill.height / 2)
        return notchPath(body: body, ear: Self.earRadius, radius: Self.bottomRadius).subtracting(hole)
    }

    private func lerp(_ a: CGFloat, _ b: CGFloat, _ t: CGFloat) -> CGFloat { a + (b - a) * t }
}

/// A notch: `body` with rounded bottom corners, plus top "ears" flaring outward by `ear`.
private func notchPath(body b: CGRect, ear: CGFloat, radius: CGFloat) -> Path {
    let r = max(0, min(radius, b.width / 2, b.height - ear))
    var p = Path()
    p.move(to: CGPoint(x: b.minX - ear, y: b.minY))
    p.addArc(tangent1End: CGPoint(x: b.minX, y: b.minY), tangent2End: CGPoint(x: b.minX, y: b.maxY), radius: ear)
    p.addArc(tangent1End: CGPoint(x: b.minX, y: b.maxY), tangent2End: CGPoint(x: b.maxX, y: b.maxY), radius: r)
    p.addArc(tangent1End: CGPoint(x: b.maxX, y: b.maxY), tangent2End: CGPoint(x: b.maxX, y: b.minY), radius: r)
    p.addArc(tangent1End: CGPoint(x: b.maxX, y: b.minY), tangent2End: CGPoint(x: b.maxX + ear, y: b.minY), radius: ear)
    p.closeSubpath()
    return p
}
