import AppKit
import Foundation

// Генератор иконки приложения Shortlinks.
// Рисует squircle с фирменным синим градиентом и белым символом «link»,
// экспортирует все размеры для macOS AppIcon в Assets.xcassets.

let outDir = "Sources/ShortlinksApp/Assets.xcassets/AppIcon.appiconset"
try? FileManager.default.createDirectory(atPath: outDir, withIntermediateDirectories: true)

func color(_ hex: UInt) -> NSColor {
    NSColor(srgbRed: CGFloat((hex >> 16) & 0xff) / 255,
            green: CGFloat((hex >> 8) & 0xff) / 255,
            blue: CGFloat(hex & 0xff) / 255, alpha: 1)
}
let top = color(0x4F8BF0)
let bottom = color(0x2360C0)

func render(_ px: Int) -> Data {
    let size = CGFloat(px)
    let rep = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: px, pixelsHigh: px,
                              bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true,
                              isPlanar: false, colorSpaceName: .deviceRGB,
                              bytesPerRow: 0, bitsPerPixel: 0)!
    rep.size = NSSize(width: size, height: size)
    let ctx = NSGraphicsContext(bitmapImageRep: rep)!
    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = ctx
    let cg = ctx.cgContext

    // squircle-фон с градиентом
    let inset = size * 0.085
    let rect = CGRect(x: inset, y: inset, width: size - 2 * inset, height: size - 2 * inset)
    let radius = rect.width * 0.2237
    cg.saveGState()
    NSBezierPath(roundedRect: rect, xRadius: radius, yRadius: radius).addClip()
    NSGradient(starting: top, ending: bottom)!.draw(in: rect, angle: 270)
    cg.restoreGState()

    // белый символ ссылки по центру
    let conf = NSImage.SymbolConfiguration(pointSize: size * 0.42, weight: .semibold)
        .applying(NSImage.SymbolConfiguration(paletteColors: [.white]))
    if let sym = NSImage(systemSymbolName: "link", accessibilityDescription: nil)?
        .withSymbolConfiguration(conf) {
        let g = sym.size
        let targetBox = size * 0.52
        let scale = min(targetBox / g.width, targetBox / g.height)
        let w = g.width * scale, h = g.height * scale
        sym.draw(in: CGRect(x: (size - w) / 2, y: (size - h) / 2, width: w, height: h))
    }

    NSGraphicsContext.restoreGraphicsState()
    return rep.representation(using: .png, properties: [:])!
}

// (filename, pixel size)
let entries: [(String, Int)] = [
    ("icon_16", 16), ("icon_16@2x", 32),
    ("icon_32", 32), ("icon_32@2x", 64),
    ("icon_128", 128), ("icon_128@2x", 256),
    ("icon_256", 256), ("icon_256@2x", 512),
    ("icon_512", 512), ("icon_512@2x", 1024),
]
for (name, px) in entries {
    let data = render(px)
    try! data.write(to: URL(fileURLWithPath: "\(outDir)/\(name).png"))
}

func imageJSON(_ size: Int, _ scale: Int, _ file: String) -> String {
    """
        {
          "size" : "\(size)x\(size)",
          "idiom" : "mac",
          "filename" : "\(file).png",
          "scale" : "\(scale)x"
        }
    """
}
let images = [
    imageJSON(16, 1, "icon_16"), imageJSON(16, 2, "icon_16@2x"),
    imageJSON(32, 1, "icon_32"), imageJSON(32, 2, "icon_32@2x"),
    imageJSON(128, 1, "icon_128"), imageJSON(128, 2, "icon_128@2x"),
    imageJSON(256, 1, "icon_256"), imageJSON(256, 2, "icon_256@2x"),
    imageJSON(512, 1, "icon_512"), imageJSON(512, 2, "icon_512@2x"),
].joined(separator: ",\n")
let contents = """
{
  "images" : [
\(images)
  ],
  "info" : { "version" : 1, "author" : "xcode" }
}
"""
try! contents.write(toFile: "\(outDir)/Contents.json", atomically: true, encoding: .utf8)

// верхнеуровневый Contents.json для каталога ассетов
let xcassets = "Sources/ShortlinksApp/Assets.xcassets"
let rootContents = """
{
  "info" : { "version" : 1, "author" : "xcode" }
}
"""
try! rootContents.write(toFile: "\(xcassets)/Contents.json", atomically: true, encoding: .utf8)

print("AppIcon generated in \(outDir)")
