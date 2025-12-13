import Foundation

// MARK: - Part 1

public func part1(input: String) -> Int {
    let presentsSize = 9
    return input
        .split(whereSeparator: \.isNewline)
        .filter { $0.contains("x") }
        .map { line -> Bool in
            let parts = line.split(whereSeparator: \.isWhitespace)
            
            // e.g. "12x5:"
            let size = parts[0].dropLast().split(separator: "x")
            let w = Int(size[0])!
            let h = Int(size[1])!
            
            let presentCount = parts
                .dropFirst()
                .compactMap { Int($0) }
                .reduce(0, +)
            
            return w * h >= presentCount * presentsSize
        }
        .filter { $0 }
        .count
}

// MARK: - Part 1

public func part2(input: String) -> Int {
    print("Day 12 has no Part 2 challenge. – Merry Christmas!")
    return -1
}



// MARK: - Main

@main
struct App {
    static func main() {
        let url = Bundle.module.url(forResource: "input", withExtension: "txt")!
        let input = try! String(contentsOf: url, encoding: .utf8)
        print("Part 1:", part1(input: input))
        print("Part 2:", part2(input: input))
    }
}