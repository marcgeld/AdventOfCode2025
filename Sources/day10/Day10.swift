import Foundation
import Shared

// MARK: - Machine Model

struct Machine {
    let lightCount: Int
    let targetMask: Int
    let buttonMasks: [Int]
    let joltage: [Int]
}

// MARK: - Parsing

/// Parse one line into a Machine
private func parseMachine(_ line: String) -> Machine? {
    // Local regexes avoid global Sendable warnings
    let lightRegex = #/\[(.*?)\]/#
    let buttonRegex = #/\((.*?)\)/#
    let joltageRegex = #/\{(.*?)\}/#

    let trimmed = line.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !trimmed.isEmpty else { return nil }

    // --- Extract light pattern ---
    guard let m = trimmed.firstMatch(of: lightRegex) else { return nil }
    let pattern = String(m.1)
    let n = pattern.count

    // Build target bitmask
    let targetMask =
        pattern.enumerated().reduce(into: 0) { mask, pair in
            let (i, c) = pair
            if c == "#" { mask |= (1 << i) }
        }

    // --- Extract button masks ---
    let buttonMasks: [Int] =
        trimmed.matches(of: buttonRegex)
            .map { match in
                match.1.split(separator: ",").reduce(into: 0) { mask, s in
                    if let idx = Int(s), idx < n {
                        mask |= (1 << idx)
                    }
                }
            }

    // --- Extract joltage list (for Part 2) ---
    let joltage: [Int] =
        trimmed.firstMatch(of: joltageRegex)?
            .1.split(separator: ",")
            .compactMap { Int($0.trimmingCharacters(in: .whitespaces)) }
        ?? []

    return Machine(
        lightCount: n,
        targetMask: targetMask,
        buttonMasks: buttonMasks,
        joltage: joltage
    )
}

/// Parse entire input file into all machines
func parseMachines(_ input: String) -> [Machine] {
    input
        .split(whereSeparator: \.isNewline)
        .map(String.init)
        .compactMap(parseMachine)

}

// MARK: - Part 1

func minPresses(for machine: Machine) -> Int {
    let target = machine.targetMask
    let buttons = machine.buttonMasks

    // Fast exit
    if target == 0 { return 0 }

    let maxState = 1 << machine.lightCount
    var visited = Array(repeating: false, count: maxState)
    var queue: [(mask: Int, steps: Int)] = [(0, 0)]
    visited[0] = true

    var head = 0
    while head < queue.count {
        let (mask, steps) = queue[head]
        head += 1

        for b in buttons {
            let next = mask ^ b
            if !visited[next] {
                if next == target {
                    return steps + 1
                }
                visited[next] = true
                queue.append((next, steps + 1))
            }
        }
    }

    return .max // should never happen
}

/// Sum of min presses over all machines
func part1(input: String) -> Int {
    parseMachines(input)
        .map(minPresses(for:))
        .reduce(0, +)
}

// MARK: - Part 2: linjär algebra

private let EPS: Double = 1e-9
final class Matrix {
    var data: [[Double]]
    let rows: Int
    let cols: Int

    var dependents: [Int] = []    // pivot-kolumner
    var independents: [Int] = []  // fria variabler

    init(machine: Machine) {
        self.rows = machine.joltage.count
        self.cols = machine.buttonMasks.count
        self.data = Array(
            repeating: Array(repeating: 0.0, count: cols + 1),
            count: rows
        )

        // coefficients
        if rows > 0 && cols > 0 {
            for (c, mask) in machine.buttonMasks.enumerated() {
                // Mark which rows (lights) this button toggles
                for r in 0..<rows where (mask & (1 << r)) != 0 {
                    data[r][c] = 1.0
                }
            }
            // joltage
            for (r, val) in machine.joltage.enumerated() {
                data[r][cols] = Double(val)
            }
        }

        gaussianElimination()
    }

    private func gaussianElimination() {
        var pivotRow = 0
        var col = 0

        while pivotRow < rows && col < cols {
            var bestRow = pivotRow
            var bestVal = abs(data[pivotRow][col])

            if pivotRow + 1 < rows {
                for r in (pivotRow + 1)..<rows {
                    let v = abs(data[r][col])
                    if v > bestVal {
                        bestVal = v
                        bestRow = r
                    }
                }
            }

            if bestVal < EPS {
                independents.append(col)
                col += 1
                continue
            }

            if bestRow != pivotRow {
                data.swapAt(pivotRow, bestRow)
            }
            dependents.append(col)

            let pivotVal = data[pivotRow][col]
            if abs(pivotVal) > EPS {
                for j in col...cols {
                    data[pivotRow][j] /= pivotVal
                }
            }

            // eliminiate column
            for r in 0..<rows {
                if r == pivotRow { continue }
                let factor = data[r][col]
                if abs(factor) > EPS {
                    for j in col...cols {
                        data[r][j] -= factor * data[pivotRow][j]
                    }
                }
            }

            pivotRow += 1
            col += 1
        }

        if col < cols {
            for freeCol in col..<cols {
                independents.append(freeCol)
            }
        }
    }

    func valid(values: [Int]) -> Int? {
        var total = values.reduce(0, +)

        for row in 0..<dependents.count {
            var val = data[row][cols]
            for (i, col) in independents.enumerated() {
                val -= data[row][col] * Double(values[i])
            }

            if val < -EPS {
                return nil
            }
            let rounded = val.rounded()
            if abs(val - rounded) > EPS {
                return nil
            }

            total += Int(rounded)
        }

        return total
    }
}

private func dfs(
    _ matrix: Matrix,
    idx: Int,
    values: inout [Int],
    best: inout Int,
    maxPress: Int
) {
    if idx == matrix.independents.count {
        if let total = matrix.valid(values: values), total < best {
            best = total
        }
        return
    }

    let partial = values[0..<idx].reduce(0, +)

    for v in 0..<maxPress {
        if partial + v >= best { break }
        values[idx] = v
        dfs(matrix, idx: idx + 1, values: &values, best: &best, maxPress: maxPress)
    }
}

private func minPressesJoltage(for machine: Machine) -> Int {
    let matrix = Matrix(machine: machine)
    if matrix.rows == 0 { return 0 }

    let maxPress = (machine.joltage.max() ?? 0) + 1
    var best = Int.max
    var values = Array(repeating: 0, count: matrix.independents.count)

    dfs(matrix, idx: 0, values: &values, best: &best, maxPress: maxPress)
    return best
}

func part2(input: String) -> Int {
    parseMachines(input)
        .map(minPressesJoltage(for:))
        .reduce(0, +)
}


// MARK: - Main

@main
struct App {
    static func main() {
        let url = Bundle.module.url(forResource: "input", withExtension: "txt")!
        let input = try! String(contentsOf: url, encoding: .utf8)
        let (p1, p1ms) = Utils.measure("Part 1") { part1(input: input) }
        print(String(format: "Part 1: %d [%.2f ms]", p1, p1ms))
        let (p2, p2ms) = Utils.measure("Part 2") { part2(input: input) }
        print(String(format: "Part 2: %d [%.2f ms]", p2, p2ms))
    }
}
