import Foundation


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

// MARK: - Optimized BFS Solver for Minimum Button Presses

/// BFS over bitmask state space.
/// For n lights, there are 2^n possible states.
/// Buttons toggle bits (xor).
///
/// We start from mask = 0 (all off)
/// We want mask = targetMask
///
/// Each BFS edge = pressing one button once.
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

// MARK: - Part 1

/// Sum of min presses over all machines
func part1(input: String) -> Int {
    parseMachines(input)
        .map(minPresses(for:))
        .reduce(0, +)
}


// MARK: - Part 2
private func part2(input: String) -> Int {
    return -1
}

// MARK: - Main

@main
struct App {
    static func main() {
        let url = Bundle.module.url(forResource: "input", withExtension: "txt")!
        let input = try! String(contentsOf: url, encoding: .utf8)
        print("Part 1:", part1(input: input))
        //print("Part 2:", part2(input: input))
    }
}
