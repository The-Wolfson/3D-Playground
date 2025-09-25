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
        let terminal = Terminal()
        
        var angleX = 0.5
        var angleY = 0.0

        let data = try! String(contentsOfFile: "/Users/joshuawolfson/Documents/Coding/3D Playground/Sources/cube.obj")
        
        let shape: Shape = Tetrahedron1()
        while true {
            render(
                shape: shape,
                angleX: angleX,
                angleY: angleY,
                terminal: terminal
            )

            angleY += 0.03
            usleep(35000)
        }
    }
}

func render(shape: Shape, angleX: Double, angleY: Double, terminal: Terminal) {
    let height = min(terminal.size.height, 50)
    let width = height * 2
    
    var screen: [[ConsoleText]] = Array(
        repeating: Array(repeating: " ".consoleText(color: .black), count: width),
        count: height
    )
    
    let renderType = RenderType.solid
    
    
    switch renderType {
        case .wireframe:
            renderEdges(shape: shape, angleX: angleX, angleY: angleY, width: width, height: height, screen: &screen)
        case .solid:
            renderFaces(shape: shape, angleX: angleX, angleY: angleY, width: width, height: height, screen: &screen)
    }

    
    terminal.clear(.screen)
    for row in screen {
        for column in row {
            terminal.output(column, newLine: false)
        }
        terminal.output("", newLine: true)
    }
}

func renderFaces(
    shape: Shape,
    angleX: Double,
    angleY: Double,
    width: Int,
    height: Int,
    screen: inout [[ConsoleText]]
) {
    // Rotate all vertices first
    let rotated = shape.vertices.map { $0.rotate(angleX: angleX, angleY: angleY) }
    
    // Build faces with depth
    var faceData: [(face: Face, projected: [Coordinate], avgZ: Double, color: ConsoleColor)] = []
    
    for (faceIndex, face) in shape.faces.enumerated() {
        let projected = face.indices.map { rotated[$0].project(width: width, height: height) }
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
                    if x >= 0 && x < width && y >= 0 && y < height {
                        screen[y][x] = "█".consoleText(color: color)
                    }
                }
            }
        }
    }
}

// Point-in-polygon test (ray casting)
func pointInPolygon(x: Int, y: Int, poly: [Coordinate]) -> Bool {
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

func renderEdges(shape: Shape, angleX: Double, angleY: Double, width: Int, height: Int, screen: inout [[ConsoleText]]) {
    for edge in shape.edges {
        let colour = edge.consoleColour()
        
        let v0 = shape.vertices[edge.v0].rotate(angleX: angleX, angleY: angleY)
        let v1 = shape.vertices[edge.v1].rotate(angleX: angleX, angleY: angleY)
        
        let c0 = v0.project(width: width, height: height)
        let c1 = v1.project(width: width, height: height)
        
        let dx = c1.x - c0.x
        let dy = c1.y - c0.y
        let steps = max(abs(dx), abs(dy))
        if steps == 0 { continue }
        
        for i in 0...steps {
            let x = c0.x + i * dx / steps
            let y = c0.y + i * dy / steps
            if x >= 0 && x < width && y >= 0 && y < height {
                screen[y][x] = "█".consoleText(color: colour)
            }
        }
    }
}
