// Renders the MegaNotch app icon as a 1024×1024 PNG.
// Usage: swift Scripts/make_icon.swift <out.png>
import AppKit

let size = 1024
let space = CGColorSpace(name: CGColorSpace.sRGB)!
let ctx = CGContext(
    data: nil, width: size, height: size, bitsPerComponent: 8, bytesPerRow: 0,
    space: space, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
)!
// Top-left origin, like everything else in this project.
ctx.translateBy(x: 0, y: CGFloat(size))
ctx.scaleBy(x: 1, y: -1)

func color(_ r: CGFloat, _ g: CGFloat, _ b: CGFloat, _ a: CGFloat = 1) -> CGColor {
    CGColor(colorSpace: space, components: [r, g, b, a])!
}

/// Same notch shape as the app: rounded bottom corners, ears flaring out at the top.
func notchPath(body b: CGRect, ear: CGFloat, radius r: CGFloat) -> CGPath {
    let p = CGMutablePath()
    p.move(to: CGPoint(x: b.minX - ear, y: b.minY))
    p.addArc(tangent1End: CGPoint(x: b.minX, y: b.minY), tangent2End: CGPoint(x: b.minX, y: b.maxY), radius: ear)
    p.addArc(tangent1End: CGPoint(x: b.minX, y: b.maxY), tangent2End: CGPoint(x: b.maxX, y: b.maxY), radius: r)
    p.addArc(tangent1End: CGPoint(x: b.maxX, y: b.maxY), tangent2End: CGPoint(x: b.maxX, y: b.minY), radius: r)
    p.addArc(tangent1End: CGPoint(x: b.maxX, y: b.minY), tangent2End: CGPoint(x: b.maxX + ear, y: b.minY), radius: ear)
    p.closeSubpath()
    return p
}

// macOS icon grid: 824pt tile centred in a 1024 canvas.
let tile = CGRect(x: 100, y: 100, width: 824, height: 824)
let tilePath = CGPath(roundedRect: tile, cornerWidth: 185, cornerHeight: 185, transform: nil)

// Drop shadow (y is flipped, so positive offset goes up; negate it).
ctx.saveGState()
ctx.setShadow(offset: CGSize(width: 0, height: -10), blur: 24, color: color(0, 0, 0, 0.4))
ctx.addPath(tilePath)
ctx.setFillColor(color(0, 0, 0))
ctx.fillPath()
ctx.restoreGState()

ctx.saveGState()
ctx.addPath(tilePath)
ctx.clip()

// The desktop wallpaper you will rarely see.
let wallpaper = CGGradient(
    colorsSpace: space,
    colors: [color(0.16, 0.36, 0.98), color(0.58, 0.28, 0.93), color(1.0, 0.45, 0.35), color(1.0, 0.75, 0.3)] as CFArray,
    locations: [0, 0.4, 0.75, 1]
)!
ctx.drawLinearGradient(wallpaper, start: CGPoint(x: tile.minX, y: tile.minY), end: CGPoint(x: tile.maxX, y: tile.maxY), options: [])

// The notch. Most of it.
let body = CGRect(x: tile.minX + 92, y: tile.minY - 1, width: tile.width - 184, height: tile.height * 0.8)
let notch = notchPath(body: body, ear: 40, radius: 130)
ctx.addPath(notch)
ctx.setFillColor(color(0, 0, 0))
ctx.fillPath()

// Faint rim so the notch reads as an object, not a hole.
ctx.addPath(notch)
ctx.setStrokeColor(color(1, 1, 1, 0.08))
ctx.setLineWidth(4)
ctx.strokePath()

// The webcam. It's in there somewhere.
let cam = CGPoint(x: tile.midX, y: tile.minY + 46)
ctx.setFillColor(color(0.11, 0.11, 0.13))
ctx.fillEllipse(in: CGRect(x: cam.x - 15, y: cam.y - 15, width: 30, height: 30))
ctx.setFillColor(color(0.16, 0.2, 0.36))
ctx.fillEllipse(in: CGRect(x: cam.x - 7, y: cam.y - 7, width: 14, height: 14))

// Glossy top highlight.
let gloss = CGGradient(
    colorsSpace: space,
    colors: [color(1, 1, 1, 0.1), color(1, 1, 1, 0)] as CFArray,
    locations: [0, 1]
)!
ctx.drawLinearGradient(gloss, start: CGPoint(x: 0, y: tile.minY), end: CGPoint(x: 0, y: tile.midY), options: [])
ctx.restoreGState()

let rep = NSBitmapImageRep(cgImage: ctx.makeImage()!)
let out = URL(fileURLWithPath: CommandLine.arguments[1])
try rep.representation(using: .png, properties: [:])!.write(to: out)
