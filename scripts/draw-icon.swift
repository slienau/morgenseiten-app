// Draws the 1024×1024 master image of the app icon: a written page with a
// progress bar in front of a rising sun.
//
// Usage: draw-icon <output.png>   (invoked by scripts/make-icon.sh)

import CoreGraphics
import Foundation
import ImageIO
import UniformTypeIdentifiers

func color(_ hex: UInt32, alpha: CGFloat = 1) -> CGColor {
    CGColor(
        srgbRed: CGFloat((hex >> 16) & 0xFF) / 255,
        green: CGFloat((hex >> 8) & 0xFF) / 255,
        blue: CGFloat(hex & 0xFF) / 255,
        alpha: alpha
    )
}

func roundedRect(_ rect: CGRect, radius: CGFloat) -> CGPath {
    CGPath(roundedRect: rect, cornerWidth: radius, cornerHeight: radius, transform: nil)
}

@main
struct DrawIcon {
    static func main() {
        guard CommandLine.arguments.count == 2 else {
            FileHandle.standardError.write(Data("usage: draw-icon <output.png>\n".utf8))
            exit(2)
        }
        let output = URL(fileURLWithPath: CommandLine.arguments[1])

        let size = 1024
        let space = CGColorSpace(name: CGColorSpace.sRGB)!
        let ctx = CGContext(
            data: nil, width: size, height: size, bitsPerComponent: 8, bytesPerRow: 0,
            space: space, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        )!

        // macOS icon grid: an 824pt rounded square centred on the canvas.
        let tile = roundedRect(CGRect(x: 100, y: 100, width: 824, height: 824), radius: 185)

        // Drop shadow under the tile.
        ctx.saveGState()
        ctx.setShadow(offset: CGSize(width: 0, height: -10), blur: 24, color: color(0x000000, alpha: 0.3))
        ctx.addPath(tile)
        ctx.setFillColor(color(0x2B2A63))
        ctx.fillPath()
        ctx.restoreGState()

        ctx.saveGState()
        ctx.addPath(tile)
        ctx.clip()

        // Dawn sky, night at the top fading into morning light.
        let sky = CGGradient(
            colorsSpace: space,
            colors: [color(0x2B2A63), color(0x8E4A8C), color(0xF0706A), color(0xFFB45C)] as CFArray,
            locations: [0, 0.4, 0.72, 1]
        )!
        ctx.drawLinearGradient(sky, start: CGPoint(x: 512, y: 924), end: CGPoint(x: 512, y: 100), options: [])

        // Sun with a soft glow, peeking out behind the page.
        let sunCenter = CGPoint(x: 690, y: 700)
        let glow = CGGradient(
            colorsSpace: space,
            colors: [color(0xFFE08A, alpha: 0.55), color(0xFFE08A, alpha: 0)] as CFArray,
            locations: [0, 1]
        )!
        ctx.drawRadialGradient(glow, startCenter: sunCenter, startRadius: 130, endCenter: sunCenter, endRadius: 300, options: [])
        ctx.setFillColor(color(0xFFD768))
        ctx.fillEllipse(in: CGRect(x: sunCenter.x - 150, y: sunCenter.y - 150, width: 300, height: 300))

        // The page.
        let page = CGRect(x: 292, y: 212, width: 400, height: 520)
        ctx.saveGState()
        ctx.setShadow(offset: CGSize(width: 0, height: -14), blur: 36, color: color(0x1B1440, alpha: 0.45))
        ctx.addPath(roundedRect(page, radius: 30))
        ctx.setFillColor(color(0xFFFCF5))
        ctx.fillPath()
        ctx.restoreGState()

        // Lines of writing.
        let lineX = page.minX + 52
        let lineWidth = page.width - 104
        let widths: [CGFloat] = [1, 0.86, 1, 0.92, 0.55]
        for (index, fraction) in widths.enumerated() {
            let y = page.maxY - 86 - CGFloat(index) * 64
            ctx.addPath(roundedRect(CGRect(x: lineX, y: y, width: lineWidth * fraction, height: 22), radius: 11))
            ctx.setFillColor(color(0xB9B3CC))
            ctx.fillPath()
        }

        // Progress bar at the foot of the page.
        let bar = CGRect(x: lineX, y: page.minY + 58, width: lineWidth, height: 26)
        ctx.addPath(roundedRect(bar, radius: 13))
        ctx.setFillColor(color(0xECE7F2))
        ctx.fillPath()
        ctx.addPath(roundedRect(CGRect(x: bar.minX, y: bar.minY, width: bar.width * 0.7, height: bar.height), radius: 13))
        ctx.setFillColor(color(0xF28A3C))
        ctx.fillPath()

        ctx.restoreGState()

        let image = ctx.makeImage()!
        let destination = CGImageDestinationCreateWithURL(
            output as CFURL, UTType.png.identifier as CFString, 1, nil
        )!
        CGImageDestinationAddImage(destination, image, nil)
        guard CGImageDestinationFinalize(destination) else {
            FileHandle.standardError.write(Data("could not write \(output.path)\n".utf8))
            exit(1)
        }
    }
}
