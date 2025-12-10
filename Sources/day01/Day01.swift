import Foundation
import Shared

@main
struct App {
    static func main() {
        let url = Bundle.module.url(forResource: "input", withExtension: "txt")!
        let input = try! String(contentsOf: url, encoding: .utf8)
        print("Part 1:", part1(input: input))
        // password method 0x434C49434B = "CLICK" (ASCII)
        print("Part 2:", part2(input: input))
    }
}

// MARK: - Helpers

private extension Int {
    var mod100: Int {
        let r = self % 100
        return r < 0 ? r + 100 : r
    }
}

// MARK: - Part 1

private func part1(input: String) -> Int {
    var position = 50
    var hits = 0

    for line in input.split(whereSeparator: \.isNewline) {
        guard let dir = line.first,
              let amount = Int(line.dropFirst())
        else { continue }

        position = switch dir {
            case "L": (position - amount).mod100
            case "R": (position + amount).mod100
            default: fatalError("Unknown direction: \(dir)")
        }

        if position == 0 { hits += 1 }
    }

    return hits
}

// MARK: - Part 2

private func part2(input: String) -> Int {
    var position = 50
    var countZero = 0

    for line in input.split(whereSeparator: \.isNewline) {
        guard
            let dir = line.first,
            let amount = Int(line.dropFirst())
        else { continue }

        switch dir {
        case "L":
            for _ in 0..<amount {
                position = (position - 1).mod100
                if position == 0 { countZero += 1 }
            }

        case "R":
            for _ in 0..<amount {
                position = (position + 1).mod100
                if position == 0 { countZero += 1 }
            }

        default:
            fatalError("Unknown direction \(dir)")
        }
    }

    return countZero
}
