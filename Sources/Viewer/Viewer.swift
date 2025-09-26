// The Swift Programming Language
// https://docs.swift.org/swift-book
import ConsoleKitTerminal
import Foundation
import ArgumentParser
import os

enum RenderType: String, ExpressibleByArgument {
    case wireframe, solid
}

@main
struct Viewer: ParsableCommand {
    @Option(name: .customShort("r")) var renderType: RenderType = .wireframe
    //Optionally add path to obj or specify shape to show, default cube
    
    mutating func run() throws {
        var screenBuffer = ScreenBuffer()
        
        var angleX = 0.5
        var angleY = 0.0
        
        let shape: Shape = Cube()
        let renderer = Renderer(renderType: renderType, shape: shape)
        
        while true {
            renderer.render(
                shape: shape,
                angleX: angleX,
                angleY: angleY,
                screenBuffer: &screenBuffer
            )

            angleY += 0.035
            usleep(35000)
        }
    }
}



struct Renderer {
    let renderType: RenderType
    let shape: Shape
    
    func render(shape: Shape, angleX: Double, angleY: Double, screenBuffer: inout ScreenBuffer) {
        switch renderType {
            case .wireframe:
                drawEdges(angleX: angleX, angleY: angleY, screenBuffer: &screenBuffer)
            case .solid:
                drawFaces(angleX: angleX, angleY: angleY, screenBuffer: &screenBuffer)
        }

        screenBuffer.output()
        screenBuffer.clear()
    }

    
    func drawEdges(angleX: Double, angleY: Double, screenBuffer: inout ScreenBuffer) {
        for edge in shape.edges {
            let colour = edge.consoleColour()
            
            let v0 = shape.vertices[edge.v0].rotate(angleX: angleX, angleY: angleY)
            let v1 = shape.vertices[edge.v1].rotate(angleX: angleX, angleY: angleY)
            
            let c0 = v0.project(width: screenBuffer.width, height: screenBuffer.height)
            let c1 = v1.project(width: screenBuffer.width, height: screenBuffer.height)
            
            let dx = c1.x - c0.x
            let dy = c1.y - c0.y
            let steps = max(abs(dx), abs(dy))
            if steps == 0 { continue }
            
            for i in 0...steps {
                let x = c0.x + i * dx / steps
                let y = c0.y + i * dy / steps
                screenBuffer.setPixel(x: x, y: y, to: "█".consoleText(color: .white))
            }
        }
    }
    
    func drawFaces(angleX: Double, angleY: Double, screenBuffer: inout ScreenBuffer) {
        // Rotate all vertices first
        let rotated = shape.vertices.map { $0.rotate(angleX: angleX, angleY: angleY) }
        
        // Build faces with depth
        var faceData: [(face: Face, projected: [Coordinate], avgZ: Double, color: ConsoleColor)] = []
        
        for (faceIndex, face) in shape.faces.enumerated() {
            let projected = face.indices.map { rotated[$0].project(width: screenBuffer.width, height: screenBuffer.height) }
            let avgZ = face.indices.map { rotated[$0].z }.reduce(0,+) / Double(face.indices.count)
            let color = ConsoleColor.palette(UInt8(truncatingIfNeeded: faceIndex))
            faceData.append((face, projected, avgZ, color))
        }
        
        // Sort by depth, farthest first
        faceData.sort { $0.avgZ > $1.avgZ }
        
        // Render polygons in order
        for (_, projected, _, color) in faceData {
            let xs = projected.map { $0.x }
            let ys = projected.map { $0.y }
            guard let minX = xs.min(), let maxX = xs.max(),
                  let minY = ys.min(), let maxY = ys.max() else { continue }
            
            for y in minY...maxY {
                for x in minX...maxX {
                    if pointInPolygon(x: x, y: y, poly: projected) {
                        let consoleText = "█".consoleText(color: color)
                        screenBuffer.setPixel(x: x, y: y, to: consoleText)
                    }
                }
            }
        }
    }
    
    private func pointInPolygon(x: Int, y: Int, poly: [Coordinate]) -> Bool {
        var inside = false
        var j = poly.count - 1
        for i in 0..<poly.count {
            let xi: Int = poly[i].x, yi: Int = poly[i].y
            let xj: Int = poly[j].x, yj: Int = poly[j].y
            
            let intersectsY = (yi > y) != (yj > y)
            let dx = xj - xi
            let dy = yj - yi
            let dyPoint = y - yi
            let slopeFraction = Double(dyPoint) / (Double(dy) + 0.0001)
            let slope = Double(dx) * slopeFraction
            let xOnEdge = Double(xi) + slope
            let isLeftOfEdge = Double(x) < xOnEdge

            if intersectsY && isLeftOfEdge {
                inside.toggle()
            }
            j = i
        }
        return inside
    }
}
