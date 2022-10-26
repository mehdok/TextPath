//
//  TextPathLine.swift
//  TextPath
//
//  Created by Mateusz Malczak on 2022-10-09.
//

import CoreGraphics
import UIKit

/// Single text line representation
public class TextPathLine {
    /// Line index
    public internal(set) var index: Int

    /// Line typographic bounds based on line ascent / descent
    /// Rectangle is based on typographic line properties (ie. ascent, descent)
    public internal(set) var lineBounds = CGRect.zero

    /// Line path bounds based on text path
    /// Rectangle defined by _textBounds_ is smaller than _lineBounds_ and is based only o text bounds
    public internal(set) var textBounds = CGRect.zero

    /// Line leading
    public internal(set) var leading = CGFloat(0.0)

    /// Line ascent
    public internal(set) var ascent = CGFloat(0.0)

    /// Line descent
    public internal(set) var descent = CGFloat(0.0)

    /**
     Line effective descent is calculated based on lineRuns typographic properties,
     in most cases is equal to _descent_.  In some rare cases this rect is smaller that _descent_ property.

     ## Example ##
     ````
     let str = NSMutableAttributedString(string: "First line".uppercased(), attributes: [
     NSFontAttributeName: UIFont.systemFont(ofSize: 22, weight: UIFontWeightUltraLight)
     ])
     str.append(NSAttributedString(string: "\nSecond line".uppercased(), attributes: [
     NSFontAttributeName: UIFont.systemFont(ofSize: 64, weight: UIFontWeightMedium)
     ]))
     ````
     In second line much larger font is used, it also applied to the 'line break' (\n)
     character. As a result typographic size of the first line is different that one used by TextKit to draw text
     in text components (UILabel, UITextView).
     In this case _effectiveDescent_ of the first line is smaller that _descent_ measured by CoreText, because it is calculated
     only based on visible characters (ie. not including '\n' metrics)
     */
    public internal(set) var effectiveDescent = CGFloat(0.0)

    /// Line effective ascent (read more above)
    public internal(set) var effectiveAscent = CGFloat(0.0)

    /// Line glyph to attributes mapping
    var attributes: [TextPathAttributes]?

    /// Collection of all glyphs in line
    var glyphs = [TextPathGlyph]()

    init(index: Int) {
        self.index = index
    }

    /// Enumerates over all glyphs in line
    /// - Parameter callback: Called for each glyph in line
    /// - Parameter line: Current text line
    /// - Parameter glyph: Current glyph
    public func enumerateGlyphs(_ callback: (_ line: TextPathLine, _ glyph: TextPathGlyph) -> Void) {
        for glyph in glyphs {
            callback(self, glyph)
        }
    }

    /// Get attributes for a line glyph
    /// - Parameter glyph: Glyph in line
    /// - Returns: Glyph attributes
    func attributes(ForGlyph glyph: TextPathGlyph) -> TextPathAttributes? {
        if let attributes = attributes {
            return attributes[glyph.lineRun]
        }
        return nil
    }
}
