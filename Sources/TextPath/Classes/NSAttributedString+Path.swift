//
//  NSAttributedString+Path.swift
//  TextPath
//
//  Created by Mehdi Sohrabi on 2022-10-09.
//

import CoreGraphics
import UIKit

public extension NSAttributedString {
    /// Creates a text path and a collection of text lines and
    /// glyphs with additional typographic informations (ie. ascent, descent, bounds)
    ///
    /// - Parameter bounds: text bounding box
    /// - Parameter withAttributes: if _true_ glyph attributes are included in returned TextPath
    /// - Parameter withPath: if _true_ a composed text path is included
    /// - Returns: created text path or NULL if failed
    func getTextPath(InBounds bounds: CGSize, withAttributes: Bool = true, withPath: Bool = true) -> TextPath? {
        let clearText = string
        if clearText.isEmpty {
            return nil
        }

        let fontAttributeKey = NSAttributedString.Key.font
        let defaultAttributes: TextPathAttributes = [
            fontAttributeKey: UIFont.systemFont(ofSize: UIFont.systemFontSize),
            NSAttributedString.Key.foregroundColor: UIColor.black,
        ]

        var lineIndex = 0
        let unicodeScalars = clearText.unicodeScalars
        var unicodeIndex = unicodeScalars.startIndex

        let frameSetter = CTFramesetterCreateWithAttributedString(self)
        let textRange = CFRangeMake(0, length)
        let frameSize = CTFramesetterSuggestFrameSizeWithConstraints(frameSetter, textRange, nil, bounds, nil)
        let framePath = UIBezierPath(rect: CGRect(origin: .zero, size: frameSize)).cgPath
        let frame = CTFramesetterCreateFrame(frameSetter, textRange, framePath, nil)

        let tpFrame = TextPathFrame(path: framePath)
        let frames = [tpFrame]

        // 0. fetch all lines / glyphs + text path
        let ignoredCharsSet = CharacterSet.whitespacesAndNewlines
        let path = CGMutablePath()

        if let lines = CTFrameGetLines(frame) as? [CTLine] {
            var linesShift = CGFloat(0)
            var origins = [CGPoint](repeating: CGPoint.zero, count: lines.count)
            CTFrameGetLineOrigins(frame, CFRangeMake(0, lines.count), &origins)
            var originItr = origins.makeIterator()

            for line in lines {
                let lineOrigin = originItr.next() ?? CGPoint.zero
                let tpLine = TextPathLine(index: lineIndex)

                tpLine.lineBounds = CTLineGetBoundsWithOptions(line, .excludeTypographicLeading)
                tpLine.textBounds = CTLineGetBoundsWithOptions(line, .useGlyphPathBounds)

                _ = CTLineGetTypographicBounds(line, &tpLine.ascent, &tpLine.descent, &tpLine.leading)

                if let lineRuns = CTLineGetGlyphRuns(line) as? [CTRun] {
                    if withAttributes {
                        tpLine.attributes = [TextPathAttributes](repeating: defaultAttributes,
                                                                 count: lineRuns.count)
                    }

                    var effectiveDescent = CGFloat(0)
                    var effectiveAscent = CGFloat(0)

                    var lineRunIndex = 0
                    for lineRun in lineRuns {
                        let glyphsCount = CTRunGetGlyphCount(lineRun)
                        if glyphsCount == 0 {
                            continue
                        }

                        let attributes = (CTRunGetAttributes(lineRun) as? TextPathAttributes) ?? defaultAttributes
                        let font = (attributes[fontAttributeKey] as? UIFont) ?? (defaultAttributes[fontAttributeKey] as! UIFont)

                        if withAttributes {
                            tpLine.attributes![lineRunIndex] = attributes
                        }

                        var rt_ascent = CGFloat(0.0)
                        var rt_descent = CGFloat(0.0)
                        var rt_leading = CGFloat(0.0)
                        _ = CTRunGetTypographicBounds(lineRun, CFRangeMake(0, glyphsCount), &rt_ascent, &rt_descent, &rt_leading)

                        let advancePtr = CTRunGetAdvancesPtr(lineRun)
                        var mutableAdvancePtr: UnsafeMutablePointer<CGSize>?
                        if advancePtr == nil {
                            mutableAdvancePtr = UnsafeMutablePointer<CGSize>.allocate(capacity: length)
                            CTRunGetAdvances(lineRun, textRange, mutableAdvancePtr!)
                        }

                        let lineRunInfo = (CTRunGetGlyphsPtr(lineRun),
                                           CTRunGetPositionsPtr(lineRun),
                                           advancePtr ?? UnsafePointer(mutableAdvancePtr!))

                        switch lineRunInfo {
                        case let (glyphsPtr?, positionsPtr?, advancesPtr):
                            var glyphPtr = glyphsPtr
                            var positionPtr = positionsPtr
                            var advancePtr = advancesPtr

                            for _ in 0 ..< glyphsCount {
                                let glyphUnicodeIndex = unicodeIndex
                                unicodeIndex = unicodeScalars.index(after: unicodeIndex)

                                if !ignoredCharsSet.contains(unicodeScalars[glyphUnicodeIndex]) {
                                    effectiveAscent = max(effectiveAscent, abs(rt_ascent))
                                    effectiveDescent = max(effectiveDescent, abs(rt_descent))

                                    let glyph = glyphPtr.pointee
                                    let position = positionPtr.pointee

                                    var T = CGAffineTransform(scaleX: 1, y: 1)
                                    let ctFont = font as CTFont
                                    if let glyphPath = CTFontCreatePathForGlyph(ctFont, glyph, &T) {
                                        let pathBounds = glyphPath.boundingBoxOfPath
                                        var pathOffset = CGAffineTransform(translationX: -pathBounds.origin.x, y: -pathBounds.origin.y)
                                        let glyphPathRel = glyphPath.copy(using: &pathOffset) ?? glyphPath
                                        let originOffset = CGPoint(x: -pathBounds.origin.x, y: pathBounds.origin.y)
                                        let offset = CGPoint(x: lineOrigin.x + position.x + pathBounds.origin.x,
                                                             y: lineOrigin.y + position.y + pathBounds.origin.y)
                                        let tpGlyph = TextPathGlyph(index: glyphUnicodeIndex, path: glyphPathRel, position: offset)
                                        tpGlyph.lineRun = lineRunIndex
                                        tpGlyph.advance = advancePtr.pointee
                                        tpGlyph.originOffset = originOffset

                                        tpGlyph.line = tpLine
                                        tpLine.glyphs.append(tpGlyph)
                                    }
                                }
                                glyphPtr = glyphPtr.successor()
                                positionPtr = positionPtr.successor()
                                advancePtr = advancePtr.successor()
                            }
                        default:
                            return nil
                        }

                        lineRunIndex += 1
                    }

                    var lineOffsetY = 0.0
                    var startOffsetX: CGFloat?

                    if tpLine.glyphs.count != 0 {
                        tpLine.effectiveAscent = effectiveAscent
                        tpLine.effectiveDescent = effectiveDescent
                        for tpGlyph in tpLine.glyphs {
                            let position = tpGlyph.position
                            let offset = CGPoint(x: position.x, y: position.y + (tpLine.ascent - tpLine.effectiveAscent) + linesShift)

                            startOffsetX = startOffsetX ?? (offset.x + tpGlyph.originOffset.x) // save first char position
                            lineOffsetY = offset.y

                            let T = CGAffineTransform(translationX: offset.x, y: offset.y)
                            path.addPath(tpGlyph.path, transform: T)
                            tpGlyph.position = offset
                        }

                        tpFrame.lines.append(tpLine)
                        lineIndex += 1
                    }

                    // add strike trough if exists
                    if let strikePath = getStrikePath(tpLine) {
                        let offset = CGPoint(x: startOffsetX ?? tpLine.lineBounds.minX,
                                             y: lineOffsetY + (tpLine.lineBounds.midY * 2 / 3))
                        let translation = CGAffineTransform(translationX: offset.x, y: offset.y)
                        path.addPath(strikePath, transform: translation)
                    }

                    // add underline if exists
                    if let underlinePath = getUnderlinePath(tpLine) {
                        let lineHeight = underlinePath.boundingBoxOfPath.height * 2
                        let offset = CGPoint(x: startOffsetX ?? tpLine.lineBounds.minX, y: lineOffsetY - lineHeight)
                        let translation = CGAffineTransform(translationX: offset.x, y: offset.y)
                        path.addPath(underlinePath, transform: translation)
                    }

                    linesShift += (tpLine.ascent + tpLine.descent) - (effectiveAscent + effectiveDescent)
                }
            }
        }

        var finalPath = path as CGPath
        var pathBounds = CGRect.zero
        var matrix = CGAffineTransform.identity

        // 1. move path to (0,0) (and glyphs)
        pathBounds = path.boundingBoxOfPath
        let pathOffset = pathBounds.origin
        matrix = CGAffineTransform(translationX: -pathOffset.x, y: -pathOffset.y)
        if let copyPath = path.copy(using: &matrix) {
            finalPath = copyPath

            for tpFrame in frames {
                tpFrame.enumerateGlyphs { _, glyph in
                    glyph.position = glyph.position.applying(matrix)
                }
            }
        }

        // 2. flip path (and glyphs)
        pathBounds = path.boundingBoxOfPath
        matrix = CGAffineTransform(scaleX: 1, y: -1)
        matrix = matrix.translatedBy(x: 0, y: -pathBounds.size.height)
        if let copyPath = path.mutableCopy(using: &matrix) {
            finalPath = copyPath

            for tpFrame in frames {
                tpFrame.enumerateGlyphs { _, glyph in
                    let glyphPath = glyph.path
                    let glyphBounds = glyphPath.boundingBoxOfPath
                    let glyphHeight = glyphBounds.size.height
                    var flipMatrix = CGAffineTransform(scaleX: 1, y: -1)
                    flipMatrix = flipMatrix.translatedBy(x: 0, y: -glyphHeight)
                    if let copyPath = glyphPath.copy(using: &flipMatrix) {
                        glyph.path = copyPath
                        let position = glyph.position.applying(matrix).applying(CGAffineTransform(translationX: 0, y: -glyphHeight))
                        glyph.position = position
                    }
                }
            }
        }

        let tp = TextPath(text: self, path: withPath ? finalPath : nil)
        tp.composedBounds = CGRect(origin: pathOffset, size: finalPath.boundingBoxOfPath.size)
        tp.frames.append(contentsOf: frames)
        return tp
    }
}

// MARK: - async representation

public extension NSAttributedString {
    func getTextPath(InBounds bounds: CGSize, withAttributes: Bool = true, withPath: Bool = true) async -> TextPath? {
        await withCheckedContinuation { continuation in
            getTextPath(InBounds: bounds, withAttributes: withAttributes, withPath: withPath) { path in
                continuation.resume(returning: path)
            }
        }
    }
}

// MARK: - Helpers

private extension NSAttributedString {
    func getTextPath(InBounds bounds: CGSize, withAttributes: Bool = true, withPath: Bool = true, completion: @escaping (TextPath?) -> Void) {
        DispatchQueue.main.async { [weak self] in
            let path = self?.getTextPath(InBounds: bounds, withAttributes: withAttributes, withPath: withPath)
            completion(path)
        }
    }
}

// MARK: - strike and underline functions

private extension NSAttributedString {
    func getDashHeight() -> CGFloat {
        guard let font = attribute(NSAttributedString.Key.font, at: 0, effectiveRange: nil) else {
            return 1
        }

        let text = NSMutableAttributedString(string: "-")
        text.addAttributes([NSAttributedString.Key.font: font], range: NSRange(location: 0, length: text.length))
        let path = text.getTextPath(InBounds: CGSize(width: 100, height: 100))
        return path?.frames.first?.lines.first?.textBounds.height ?? 1
    }

    func getStrikePath(_ tpLine: TextPathLine) -> CGPath? {
        if let strike = tpLine.attributes?[0][.strikethroughStyle] as? Int, strike == 1 {
            let lineHeight = getDashHeight() * 2 / 3
            return getLinePath(lineHeight: lineHeight, width: tpLine.lineBounds.width)
        }

        return nil
    }

    func getUnderlinePath(_ tpLine: TextPathLine) -> CGPath? {
        if let underline = tpLine.attributes?[0][.underlineStyle] as? Int, underline == 1 {
            let lineHeight = getDashHeight() * 2 / 3
            return getLinePath(lineHeight: lineHeight, width: tpLine.lineBounds.width)
        }

        return nil
    }

    func getLinePath(lineHeight: CGFloat, width: CGFloat) -> CGPath {
        let strikePath = CGMutablePath()
        strikePath.addRect(CGRect(x: 0, y: 0, width: width, height: lineHeight))
        return strikePath
    }
}
