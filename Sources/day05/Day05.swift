import Foundation

@main
struct App {
    static func main() {
        let url = Bundle.module.url(forResource: "input", withExtension: "txt")!
        let input = try! String(contentsOf: url, encoding: .utf8)
        print("Part 1:", part1(input: input))
        print("Part 2:", part2(input: input))}
}

// MARK: - Helpers

extension String {
    func split(regex: Regex<Substring>) -> [String] {
        var result: [String] = []
        var start = startIndex

        for match in self.matches(of: regex) {
            let r = match.range
            if start < r.lowerBound {
                result.append(String(self[start..<r.lowerBound]))
            }
            start = r.upperBound
        }

        if start < endIndex {
            result.append(String(self[start..<endIndex]))
        }

        return result
    }
}

enum ClosedRangeParseError: Error {
    case invalidFormat(String)
    case invalidNumber(String)
}

extension ClosedRange where Bound == Int {
    init(from string: String) throws {
        // Regex for start and end integers
        let regex = /^(\d+)-(\d+)$/
        guard let match = string.wholeMatch(of: regex) else {
            throw ClosedRangeParseError.invalidFormat(string)
        }

        guard let start = Int(match.1),
              let end   = Int(match.2) else
        {
            throw ClosedRangeParseError.invalidNumber(string)
        }

        self = start ... end
    }
}

struct SortedRangeSet {
    private(set) var ranges: [ClosedRange<Int>] = []

    mutating func insert(_ new: ClosedRange<Int>) {
        ranges.append(new)
        ranges.sort { $0.lowerBound < $1.lowerBound }

        var merged: [ClosedRange<Int>] = []
        var current = ranges[0]

        for r in ranges.dropFirst() {
            if r.lowerBound <= current.upperBound + 1 {
                current = current.lowerBound ... Swift.max(current.upperBound, r.upperBound)
            } else {
                merged.append(current)
                current = r
            }
        }
        merged.append(current)
        ranges = merged
    }

    var count: Int {
        ranges.reduce(0) { $0 + ($1.upperBound - $1.lowerBound + 1) }
    }
}

extension SortedRangeSet: Collection {
    typealias Element = ClosedRange<Int>
    typealias Index = Int

    var startIndex: Int { ranges.startIndex }
    var endIndex: Int { ranges.endIndex }

    subscript(i: Int) -> ClosedRange<Int> { ranges[i] }

    func index(after i: Int) -> Int {
        ranges.index(after: i)
    }
}

// MARK: - Part 1

private func part1(input: String) -> Int {
    let parts = input
        .split(regex: /\n\s*\n/)
        .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }

    guard parts.count == 2 else { return -1 }

    let ranges: [ClosedRange<Int>] = parts[0]
        .split(whereSeparator: \.isNewline)
        .compactMap { try? ClosedRange<Int>(from: String($0)) }

    let ids = parts[1]
        .split(whereSeparator: \.isNewline)
        .compactMap { Int($0) }

    return ids.filter { id in
        ranges.contains { $0.contains(id) }
    }.count
}

// MARK: - Part 2

private func part2(input: String) -> Int {
    let parts = input
        .split(regex: /\n\s*\n/)
        .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }

    guard parts.count == 2 else { return -1 }

    let ranges: [ClosedRange<Int>] = parts[0]
        .split(whereSeparator: \.isNewline)
        .compactMap { try? ClosedRange<Int>(from: String($0)) }

    var set = SortedRangeSet()
    for r in ranges { set.insert(r) }

    return set.count
}
