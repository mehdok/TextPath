//
//  NSAttributedString+Path+Tests.swift
//  EditorTextPath_Tests
//
//  Created by Mehdi Sohrabi on 2022-10-11.
//

import TextPath
import XCTest

final class NSAttributedStringPathTests: XCTestCase {
    let kBounds = CGSize(width: 160.66666666666666, height: 61.666666666666664)

    func testTextSimple() throws {
        let sample = samples[0]
        let path = sample.attributedText.getTextPath(InBounds: kBounds)
        let svg = path?.composedPath?.svg()

        XCTAssertNotNil(svg)
        XCTAssertEqual(svg, sample.svg)
    }

    func testTextStrike() throws {
        let sample = samples[1]
        let path = sample.attributedText.getTextPath(InBounds: kBounds)
        let svg = path?.composedPath?.svg()
        XCTAssertNotNil(svg)
        XCTAssertEqual(svg, sample.svg)
    }

    func testTextUnderline() throws {
        let sample = samples[2]
        let path = sample.attributedText.getTextPath(InBounds: kBounds)
        let svg = path?.composedPath?.svg()
        XCTAssertNotNil(svg)
        XCTAssertEqual(svg, sample.svg)
    }

    func testTextStrikeUnderline() throws {
        let sample = samples[3]
        let path = sample.attributedText.getTextPath(InBounds: kBounds)
        let svg = path?.composedPath?.svg()
        XCTAssertNotNil(svg)
        XCTAssertEqual(svg, sample.svg)
    }
}
