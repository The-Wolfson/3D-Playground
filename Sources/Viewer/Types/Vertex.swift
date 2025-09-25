//
//  Vertex.swift
//  3D Playground
//
//  Created by Joshua Wolfson on 24/9/2025.
//

import Foundation
import ConsoleKitTerminal

struct Vertex {
    var x: Double
    var y: Double
    var z: Double
    
    init(x: Double, y: Double, z: Double) {
        self.x = x
        self.y = y
        self.z = z
    }
    
    init(_ x: Double, _ y: Double, _ z: Double) {
        self.x = x
        self.y = y
        self.z = z
    }
}

extension Vertex {
    func project(width: Int, height: Int) -> Coordinate {
        let f = 3.0 // needs to auto adjust to size
        let zOffset = z + 5
        guard zOffset != 0 else { return Coordinate(x: width / 2, y: height / 2) }
        let x2d = Int((x / zOffset) * f * Double(width) / 2 + Double(width) / 2)
        let y2d = Int((y / zOffset) * f * Double(height) / 2 + Double(height) / 2)
        return Coordinate(x: x2d, y: y2d)
    }

    func rotate(angleX: Double, angleY: Double) -> Vertex {
        // Rotate around X
        let sinX = sin(angleX)
        let cosX = cos(angleX)
        let y1 = y * cosX - z * sinX
        let z1 = y * sinX + z * cosX

        // Rotate around Y
        let sinY = sin(angleY)
        let cosY = cos(angleY)
        let x2 = x * cosY + z1 * sinY
        let z2 = -x * sinY + z1 * cosY

        return Vertex(x: x2, y: y1, z: z2)
    }
}

struct Edge: Hashable {
    let v0: Int
    let v1: Int

    init(_ v0: Int, _ v1: Int) {
        self.v0 = min(v0, v1)
        self.v1 = max(v0, v1)
    }
}

extension Edge {
    func consoleColour() -> ConsoleColor {
        let key = (UInt64(v0) << 32) | UInt64(v1)
        var hasher = Hasher()
        hasher.combine(key)
        let hashValue = hasher.finalize()
        return ConsoleColor.palette(UInt8(truncatingIfNeeded: hashValue))
    }
}

struct Face {
    let indices: [Int]
    init(_ indices: [Int]) {
        precondition(indices.count >= 3, "A face needs at least 3 vertices")
        self.indices = indices
    }
}

struct Coordinate {
    var x: Int
    var y: Int
}
