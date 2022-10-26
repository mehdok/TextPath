//
//  CGPath+SVG.swift
//  TextPath
//
//  Created by Mehdi Sohrabi on 2022-10-10.
//

import CoreGraphics
import UIKit

public extension CGPath {
    func svg() -> String {
        var data = Data()
        apply(info: &data) { userData, elementPtr in
            var data = userData!.assumingMemoryBound(to: Data.self).pointee
            let element = elementPtr.pointee
            switch element.type {
            case .moveToPoint:
                let point = element.points.pointee
                data.append(String(format: "M%.2f,%.2f", point.x, point.y).data(using: .utf8)!)
            case .addLineToPoint:
                let point = element.points.pointee
                data.append(String(format: "L%.2f,%.2f", point.x, point.y).data(using: .utf8)!)
            case .addQuadCurveToPoint:
                let ctrl = element.points.pointee
                let point = element.points.advanced(by: 1).pointee
                data.append(String(format: "Q%.2f,%.2f,%.2f,%.2f", ctrl.x, ctrl.y, point.x, point.y).data(using: .utf8)!)
            case .addCurveToPoint:
                let ctrl1 = element.points.pointee
                let ctrl2 = element.points.advanced(by: 1).pointee
                let point = element.points.advanced(by: 2).pointee
                data.append(String(format: "C%.2f,%.2f,%.2f,%.2f,%.2f,%.2f", ctrl1.x, ctrl1.y, ctrl2.x, ctrl2.y, point.x, point.y).data(using: .utf8)!)
            case .closeSubpath:
                data.append("Z".data(using: .utf8)!)
                break
            @unknown default:
                break
            }
            userData!.assumingMemoryBound(to: Data.self).pointee = data
        }

        return String(bytes: data, encoding: .utf8)!
    }
}

// MARK: - async representation

public extension CGPath {
    func svg() async -> String {
        await withCheckedContinuation { continuation in
            svg { svg in
                continuation.resume(returning: svg)
            }
        }
    }
}

// MARK: - Helpers

private extension CGPath {
    func svg(completion: @escaping (String) -> Void) {
        DispatchQueue.main.async { [weak self] in
            let svg = self?.svg()
            completion(svg ?? "")
        }
    }
}
