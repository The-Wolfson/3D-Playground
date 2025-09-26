//
//  ScreenBuffer.swift
//  3D Playground
//
//  Created by Joshua Wolfson on 25/9/2025.
//

import Foundation
import ConsoleKitTerminal

struct ScreenBuffer {
    private(set) var screen: [[ConsoleText]]
    let terminal: Terminal
    let width: Int
    let height: Int
    
    init() {
        self.terminal = Terminal()
        self.height = min(terminal.size.height, 50)
        self.width = height * 2
        self.screen = Array(
            repeating: Array(repeating: " ".consoleText(color: .black), count: width),
            count: height
        )
    }
    
    mutating func setPixel(x: Int, y: Int, to value: ConsoleText) {
        guard x >= 0 && x < width && y >= 0 && y < height else { return }
        screen[y][x] = value
    }
    
    mutating func clear() {
        for y in 0..<height {
            for x in 0..<width {
                screen[y][x] = " ".consoleText(color: .black)
            }
        }
    }
    
    func output() {
        terminal.clear(.screen)
        for row in screen {
            for column in row {
                terminal.output(column, newLine: false)
            }
            terminal.output("", newLine: true)
        }
    }
}
