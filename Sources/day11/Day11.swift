import Foundation
import Shared
import BigInt

// MARK: - Model

private typealias Graph = [String: [String]]

private struct State: Hashable {
    let node: String
    let mask: Int
}

// MARK: - Parsing

private func parseGraph(_ input: String) -> Graph {
    input
        .split(whereSeparator: \.isNewline)
        .reduce(into: Graph()) { dict, lineSub in
            let line = lineSub.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !line.isEmpty else { return }

            // Format: "aaa: you hhh"
            let parts = line.split(separator: ":")
            guard parts.count == 2 else { return }

            let from = parts[0].trimmingCharacters(in: .whitespaces)
            let targets = parts[1]
                .split(whereSeparator: { $0 == " " || $0 == "\t" })
                .map(String.init)

            dict[from] = targets
        }
}

// MARK: - Part 1: count all paths from start to target

private func countPaths(from start: String,
                        to target: String,
                        in graph: Graph) -> BigInt {

    var memo: [String: BigInt] = [:]

    func dfs(_ node: String) -> BigInt {
        if let cached = memo[node] { return cached }
        if node == target {
            memo[node] = 1
            return 1
        }

        guard let neighbors = graph[node], !neighbors.isEmpty else {
            memo[node] = 0
            return 0
        }

        let total = neighbors
            .map(dfs)
            .reduce(0, +)

        memo[node] = total
        return total
    }

    return dfs(start)
}

func part1(input: String) -> BigInt {
    let graph = parseGraph(input)
    return countPaths(from: "you", to: "out", in: graph)
}

// MARK: - Part 2: paths from start to target that visit mustVisit ("dac" and "fft")

private func countPathsViaSpecial(from start: String,
                                  to target: String,
                                  mustVisit: (String, String),
                                  in graph: Graph) -> BigInt {
    let (dac, fft) = mustVisit

    // mask bit 0 => visited dac
    // mask bit 1 => visited fft
    var memo: [State: BigInt] = [:]

    func dfs(_ node: String, _ mask: Int) -> BigInt {
        let state = State(node: node, mask: mask)
        if let cached = memo[state] { return cached }

        // Reached target
        if node == target {
            let result: BigInt = (mask & 0b11) == 0b11 ? 1 : 0
            memo[state] = result
            return result
        }

        // Reached a dead end
        guard let neighbors = graph[node], !neighbors.isEmpty else {
            memo[state] = 0
            return 0
        }

        var total: BigInt = 0
        for next in neighbors {
            var newMask = mask
            if next == dac { newMask |= 0b01 }
            if next == fft { newMask |= 0b10 }
            total += dfs(next, newMask)
        }

        memo[state] = total
        return total
    }

    var startMask = 0
    if start == dac { startMask |= 0b01 }
    if start == fft { startMask |= 0b10 }

    return dfs(start, startMask)
}

func part2(input: String) -> BigInt {
    let graph = parseGraph(input)
    return countPathsViaSpecial(from: "svr",
                                to: "out",
                                mustVisit: ("dac", "fft"),
                                in: graph)
}

// MARK: - Main

@main
struct App {
    static func main() {
        let url = Bundle.module.url(forResource: "input", withExtension: "txt")!
        let input = try! String(contentsOf: url, encoding: .utf8)
        
            let (p1, p1ms) = Utils.measure("Part 1") { part1(input: input) }
            let (p2, p2ms) = Utils.measure("Part 2") { part2(input: input) }
            let p1Time = String(format: "%.2f ms", p1ms)
            let p2Time = String(format: "%.2f ms", p2ms)
            print("Part 1: \(p1) [\(p1Time)]")
            print("Part 2: \(p2) [\(p2Time)]")
        
    }
}
