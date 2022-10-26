//
//  TextPathFrame.swift
//  TextPath
//
//  Created by Mateusz Malczak on 2022-10-09.
//

import CoreGraphics
import UIKit

/// Text frame representation. This can represent a simple text rectangle (eq. UITextView text content),
/// as well as a complex frame defined by CGPath
public class TextPathFrame {
    /// Frame shape path (eq. textfield bounds rect)
    public internal(set) var path: CGPath

    /// Text frame lines
    public internal(set) var lines = [TextPathLine]()

    init(path: CGPath) {
        self.path = path
    }

    /// Enumerates over all glyphs in text frame
    /// - Parameter callback: Called for each glyph in text frame
    /// - Parameter line: Current text line
    /// - Parameter glyph: Current glyph
    public func enumerateGlyphs(_ callback: @escaping (_ line: TextPathLine, _ glyph: TextPathGlyph) -> Void) {
        for line in lines {
            line.enumerateGlyphs(callback)
        }
    }
}
