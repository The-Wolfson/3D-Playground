//
//  Shape.swift
//  3D Playground
//
//  Created by Joshua Wolfson on 24/9/2025.
//

import Foundation

protocol Shape {
    var vertices: [Vertex] { get }
    var faces: [Face] { get }
    var edges: [Edge] { get }
}

extension Shape {
    var edges: [Edge] {
        var set = Set<Edge>()
        for face in faces {
            let n = face.indices.count
            for i in 0..<n {
                let v0 = face.indices[i]
                let v1 = face.indices[(i + 1) % n]
                set.insert(Edge(v0, v1))
            }
        }
        return Array(set)
    }
}

//MARK: - Shape Definitions

struct Custom: Shape {
    let vertices: [Vertex]
    let faces: [Face]
    
    init(data: String) {
        let lines = data.split(separator: "\n")
        var vertices: [Vertex] = []
        var faces: [Face] = []
        
        for line in lines {
            let components = line.split(separator: " ")
            if components.isEmpty { continue }

            let type = components[0]
            switch type {
            case "v":
                if components.count >= 4,
                   let x = Double(components[1]),
                   let y = Double(components[2]),
                   let z = Double(components[3]) {
                    vertices.append(Vertex(x: x, y: y, z: z))
                }
            case "f":
                if components.count >= 4 {
                    let indices = components.compactMap { Int($0) }.map { $0 - 1 }
                    faces.append(Face(indices))
                }
            default:
                continue
            }
        }
        
        self.vertices = vertices
        self.faces = faces
    }
}

// Cube
struct Cube: Shape {
    let vertices: [Vertex] = [
        Vertex(x: -1, y: -1, z: -1),
        Vertex(x:  1, y: -1, z: -1),
        Vertex(x:  1, y:  1, z: -1),
        Vertex(x: -1, y:  1, z: -1),
        Vertex(x: -1, y: -1, z:  1),
        Vertex(x:  1, y: -1, z:  1),
        Vertex(x:  1, y:  1, z:  1),
        Vertex(x: -1, y:  1, z:  1)
    ]

    let faces: [Face] = [
        Face([0, 1, 2, 3]), // back
        Face([4, 5, 6, 7]), // front
        Face([0, 1, 5, 4]), // bottom
        Face([2, 3, 7, 6]), // top
        Face([0, 3, 7, 4]), // left
        Face([1, 2, 6, 5])  // right
    ]
}

// Tetrahedron (variant 1)
struct Tetrahedron1: Shape {
    let vertices: [Vertex] = [
        Vertex( 1,  1,  1),
        Vertex( 1, -1, -1),
        Vertex(-1,  1, -1),
        Vertex(-1, -1,  1)
    ]

    let faces: [Face] = [
        Face([0, 1, 2]),
        Face([0, 1, 3]),
        Face([0, 2, 3]),
        Face([1, 2, 3])
    ]
}

// Tetrahedron (variant 2)
struct Tetrahedron2: Shape {
    let vertices: [Vertex] = [
        Vertex(-1, -1, -1),
        Vertex(-1,  1,  1),
        Vertex( 1, -1,  1),
        Vertex( 1,  1, -1)
    ]

    let faces: [Face] = [
        Face([0, 1, 2]),
        Face([0, 1, 3]),
        Face([0, 2, 3]),
        Face([1, 2, 3])
    ]
}

// Octahedron
struct Octahedron: Shape {
    let vertices: [Vertex] = [
        Vertex( 1,  0,  0),
        Vertex( 0,  1,  0),
        Vertex( 0,  0,  1),
        Vertex(-1,  0,  0),
        Vertex( 0, -1,  0),
        Vertex( 0,  0, -1)
    ]

    let faces: [Face] = [
        Face([0, 1, 2]),
        Face([1, 3, 2]),
        Face([3, 4, 2]),
        Face([4, 0, 2]),
        Face([0, 1, 5]),
        Face([1, 3, 5]),
        Face([3, 4, 5]),
        Face([4, 0, 5])
    ]
}
