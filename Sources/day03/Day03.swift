import Foundation
import Shared

@main
struct App {
    static func main() {
        let url = Bundle.module.url(forResource: "input", withExtension: "txt")!
        let input = try! String(contentsOf: url, encoding: .utf8)
        print("Part 1:", part1(input: input))
        print("Part 2:", part2(input: input))
    }
}

// MARK: - Part 1

private func part1(input: String) -> Int {

    // max two digits joltage per bank
    let maxPair: (String) -> Int = { s in
        var maxFirst = -1
        var best = 0

        for ch in s {
            guard let d = Int(String(ch)) else { continue }

            if maxFirst >= 0 {
                let value = maxFirst * 10 + d
                if value > best {
                    best = value
                }
            }
            if d > maxFirst {
                maxFirst = d
            }
        }

        return best
    }
    let rows = input
        .split(whereSeparator: \.isNewline)
        .map(String.init)

    // total output joltage
    return rows
        .filter { !$0.isEmpty }
        .map(maxPair)
        .reduce(0, +)
}

// MARK: - Part 2

private func part2(input: String) -> Int64 {
    func max12(_ s: String) -> Int64 {
        let digits = s.compactMap { Int(String($0)) }
        let keep = 12
        let drop = digits.count - keep
        var toDrop = drop
        var stack: [Int] = []

        for d in digits {
            while let last = stack.last,
                toDrop > 0,
                last < d {
                stack.removeLast()
                toDrop -= 1
            }
            stack.append(d)
        }

        if toDrop > 0 {
            stack.removeLast(toDrop)
        }

        let selected = stack.prefix(keep)
        return selected.reduce(0) { $0 * 10 + Int64($1) }
    }
    
    let rows = input
        .split(whereSeparator: \.isNewline)
        .map(String.init)

    return rows.map(max12).reduce(0 as Int64, +)
}
