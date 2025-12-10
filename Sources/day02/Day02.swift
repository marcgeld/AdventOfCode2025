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

// MARK: - Helpers

extension Array {
    var tuple2: (Element, Element)? {
        guard count == 2 else { return nil }
        return (self[0], self[1])
    }
}

// MARK: - Part 1

private func part1(input: String) -> Int {

    // Closure to check if an ID is invalid
    let isInvalidID: (Int) -> Bool = {
        let s = String($0)
        let mid = s.count / 2
        return s.count % 2 == 0 &&
           s.prefix(mid) == s.suffix(mid)
    }

    // Parse input into ranges
    let ranges: [(Int, Int)] = input
    .split(separator: ",")
    .compactMap { part in
        part
            .split(separator: "-")
            .compactMap { Int($0) }
            .prefix(2)
            .map { $0 }      // <-- Gör Slice → Array
            .tuple2
    }

    // Check IDs
    var sumOfInvalid = 0
    var invalidIDs: [Int] = []

    for (start, end) in ranges {
        for id in start...end {
            if isInvalidID(id) {
                sumOfInvalid += id
                invalidIDs.append(id)
            }
        }
    }

    print("Invalid ID:s", invalidIDs)
    print("Summa of invalid ID:s", sumOfInvalid)
    return sumOfInvalid
}

// MARK: - Part 2
    
private func part2(input: String) -> Int {

    let parseRange: (Substring) -> (Int, Int)? = {
        let v = $0.split(separator: "-").compactMap{ Int($0) }
        return v.count == 2 ? (v[0], v[1]) : nil
    }

    let isInvalidID: (Int) -> Bool = {
        let s = String($0)
        guard s.count >= 2 else { return false }
        let doubled = s + s
        let trimmed = doubled.dropFirst().dropLast()
        return trimmed.contains(s)
    }

    return input
        .split(separator: ",")
        .compactMap(parseRange)
        .flatMap { $0.0 ... $0.1 }
        .filter(isInvalidID)
        .reduce(0, +)
}

