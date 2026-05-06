#!/usr/bin/env swift

import AppKit
import Foundation

let rootURL = URL(fileURLWithPath: #filePath)
    .deletingLastPathComponent()
    .deletingLastPathComponent()
let assetURL = rootURL.appendingPathComponent("Assets", isDirectory: true)
let iconsetURL = assetURL.appendingPathComponent("CodeClipper.iconset", isDirectory: true)
let icnsURL = assetURL.appendingPathComponent("CodeClipper.icns")

try FileManager.default.createDirectory(at: assetURL, withIntermediateDirectories: true)
if FileManager.default.fileExists(atPath: iconsetURL.path) {
    try FileManager.default.removeItem(at: iconsetURL)
}
try FileManager.default.createDirectory(at: iconsetURL, withIntermediateDirectories: true)

func drawIcon(size: Int) throws -> NSImage {
    let image = NSImage(size: NSSize(width: size, height: size))
    image.lockFocus()
    defer { image.unlockFocus() }

    NSColor.clear.setFill()
    NSRect(x: 0, y: 0, width: size, height: size).fill()

    let scale = CGFloat(size) / 1024
    let bounds = NSRect(x: 96 * scale, y: 96 * scale, width: 832 * scale, height: 832 * scale)
    let radius = 190 * scale

    NSColor.systemBlue.setFill()
    NSBezierPath(roundedRect: bounds, xRadius: radius, yRadius: radius).fill()

    guard let symbol = NSImage(systemSymbolName: "message.badge.waveform", accessibilityDescription: "CodeClipper") else {
        throw NSError(domain: "CodeClipperIcon", code: 1, userInfo: [NSLocalizedDescriptionKey: "SF Symbol not available"])
    }

    let configuration = NSImage.SymbolConfiguration(pointSize: 560 * scale, weight: .regular)
    let configuredSymbol = symbol.withSymbolConfiguration(configuration) ?? symbol
    configuredSymbol.isTemplate = false

    NSColor.white.set()
    let symbolSize = NSSize(width: 640 * scale, height: 640 * scale)
    let symbolRect = NSRect(
        x: (CGFloat(size) - symbolSize.width) / 2,
        y: (CGFloat(size) - symbolSize.height) / 2 - 10 * scale,
        width: symbolSize.width,
        height: symbolSize.height
    )
    configuredSymbol.draw(in: symbolRect, from: .zero, operation: .sourceOver, fraction: 1)

    return image
}

func writePNG(image: NSImage, to url: URL) throws {
    guard
        let tiff = image.tiffRepresentation,
        let bitmap = NSBitmapImageRep(data: tiff),
        let data = bitmap.representation(using: .png, properties: [:])
    else {
        throw NSError(domain: "CodeClipperIcon", code: 2, userInfo: [NSLocalizedDescriptionKey: "Could not render PNG"])
    }

    try data.write(to: url)
}

let variants: [(String, Int)] = [
    ("icon_16x16.png", 16),
    ("icon_16x16@2x.png", 32),
    ("icon_32x32.png", 32),
    ("icon_32x32@2x.png", 64),
    ("icon_128x128.png", 128),
    ("icon_128x128@2x.png", 256),
    ("icon_256x256.png", 256),
    ("icon_256x256@2x.png", 512),
    ("icon_512x512.png", 512),
    ("icon_512x512@2x.png", 1024),
]

for (filename, size) in variants {
    try writePNG(image: try drawIcon(size: size), to: iconsetURL.appendingPathComponent(filename))
}

let process = Process()
process.executableURL = URL(fileURLWithPath: "/usr/bin/iconutil")
process.arguments = ["-c", "icns", iconsetURL.path, "-o", icnsURL.path]
try process.run()
process.waitUntilExit()

if process.terminationStatus != 0 {
    throw NSError(domain: "CodeClipperIcon", code: Int(process.terminationStatus), userInfo: [NSLocalizedDescriptionKey: "iconutil failed"])
}

print(icnsURL.path)
