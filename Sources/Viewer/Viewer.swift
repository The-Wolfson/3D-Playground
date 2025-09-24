// The Swift Programming Language
// https://docs.swift.org/swift-book
import ConsoleKit
import Foundation

@main
struct Portfolio {
    static func main() {
        let terminal = Terminal()

        var angleX = 0.5
        var angleY = 0.0

        while true {
            render(
                shape: Cube(),
                angleX: angleX,
                angleY: angleY,
                terminal: terminal
            )

            angleY += 0.03
            usleep(30000)
        }
    }
}

func render(shape: Shape, angleX: Double, angleY: Double, terminal: Terminal) {
    let height = min(terminal.size.height, 60)
    let width = height * 2
    
    var screen: [[ConsoleText]] = Array(
        repeating: Array(repeating: " ".consoleText(color: .black), count: width),
        count: height
    )
    
    // Draw edges
    for edge in shape.edges {
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
                screen[y][x] = "#".consoleText(color: .brightRed)
            }
        }
    }
    
    terminal.clear(.screen)
    for row in screen {
        for column in row {
            terminal.output(column, newLine: false)
        }
        terminal.output("", newLine: true)
    }
}
