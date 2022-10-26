//
//  TextPath.swift
//  TextPath
//
//  Created by Mateusz Malczak on 2022-10-09.
//

import CoreGraphics
import UIKit

/// Text path represents a CGPath representation of text frame, glyphs and typographic properties
public class TextPath {
    /// Attributed text used to generate text path
    public internal(set) var attributedString: NSAttributedString

    /// Text path composed for input text
    public internal(set) var composedPath: CGPath?

    /// Composed text path bounding box
    public internal(set) var composedBounds: CGRect

    /// text frames
    public internal(set) var frames = [TextPathFrame]()

    init(text: NSAttributedString, path: CGPath? = nil) {
        attributedString = text
        composedPath = path
        composedBounds = path?.boundingBoxOfPath ?? CGRect.zero
    }
}
