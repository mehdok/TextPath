//
//  TextPathGlyph.swift
//  TextPath
//
//  Created by Mateusz Malczak on 2022-10-09.
//

import CoreGraphics
import UIKit

/// Class represents single character representation - glyph
public final class TextPathGlyph {
    public typealias Index = String.UnicodeScalarView.Index

    /// Character index in source string unicode view
    public internal(set) var index: Index

    /// Glyph path defined in glyph coordinates
    public internal(set) var path: CGPath

    /// Glyph path position (top left corner) in line space
    public internal(set) var position: CGPoint

    /// Glyph line advance
    public internal(set) var advance = CGSize.zero

    /// Glyph origin offset (x component is a glyph origin offset, y component is an offset to baseline)
    public internal(set) var originOffset = CGPoint.zero

    /// Glyph line run index
    var lineRun: Int = 0

    /// Glyph line
    weak var line: TextPathLine?

    /// Get glyph attributes as defined in source string
    public var attributes: [NSAttributedString.Key: Any]? {
        return line?.attributes(ForGlyph: self)
    }

    init(index: Index, path: CGPath, position: CGPoint) {
        self.index = index
        self.path = path
        self.position = position
    }
}
