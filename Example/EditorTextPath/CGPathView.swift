//
//  CGPathView.swift
//  EditorTextPath_Example
//
//  Created by Mehdi Sohrabi on 2022-10-10.

import UIKit

final class CGPathView: UIView {
    var path: CGPath? {
        didSet {
            setNeedsDisplay()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.borderWidth = 1.0
        layer.borderColor = UIColor.red.cgColor
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func draw(_ rect: CGRect) {
        guard let path = path, let context = UIGraphicsGetCurrentContext() else { return }
        UIColor.white.setFill()
        context.fill(rect)

//        context.setBlendMode(.overlay)
        context.addPath(path)
        context.setFillColor(UIColor.black.cgColor)
        context.fillPath()
    }
}
