import Foundation

// MARK: - Model

enum ProblemColumnError: Error {
    case empty
    case unknownOperation(Character)
}

struct ProblemColumn: CustomStringConvertible {
    let numbers: [Int]
    let operation: Character

    var description: String {
        numbers.map(String.init).joined(separator: " \(operation) ")
    }

    func evaluate() throws -> Int {
        guard let first = numbers.first else {
            throw ProblemColumnError.empty
        }

        return try numbers.dropFirst().reduce(first) { acc, n in
            switch operation {
            case "+": return acc + n
            case "*": return acc * n
            case "-": return acc - n
            case "/": return acc / n
            default: throw ProblemColumnError.unknownOperation(operation)
            }
        }
    }
}

// MARK: - Parsing Errors

enum ParseError: Error {
    case raggedMatrix
    case invalidOp(String)
    case invalidNumber(String)
}

// MARK: - Part 1 Parser (simple column-based)

func makeProblemColumns(from rows: [[String]]) throws -> [ProblemColumn] {
    guard rows.count >= 2 else { return [] }

    let opRow = rows.last!
    let numberRows = rows.dropLast()
    let colCount = opRow.count

    guard numberRows.allSatisfy({ $0.count == colCount }) else {
        throw ParseError.raggedMatrix
    }

    return try (0..<colCount).map { col in
        guard let op = opRow[col].first, opRow[col].count == 1 else {
            throw ParseError.invalidOp(opRow[col])
        }

        let nums = try numberRows.map {
            guard let n = Int($0[col]) else {
                throw ParseError.invalidNumber($0[col])
            }
            return n
        }

        return ProblemColumn(numbers: nums, operation: op)
    }
}

// MARK: - Part 1

private func part1(input: String) -> Int {
    let rows = input
        .split(whereSeparator: \.isNewline)
        .map { $0.split(whereSeparator: \.isWhitespace).map(String.init) }

    let problems = try! makeProblemColumns(from: rows)

    return problems
        .map { try! $0.evaluate() }
        .reduce(0, +)
}

// MARK: - Part 2 (AoC-correct math)

private func part2(input: String) -> Int {

    var grid: [[Character]] = input
        .split(whereSeparator: \.isNewline)
        .map { Array($0) }

    let height = grid.count
    guard height >= 2 else { return 0 }

    // Säkerställ samma bredd på alla rader
    let width = grid.map(\.count).max() ?? 0
    grid = grid.map { row in
        if row.count < width {
            return row + Array(repeating: " ", count: width - row.count)
        } else {
            return row
        }
    }

    let opRow = grid[height - 1]
    let digitRows = Array(grid[0..<(height - 1)])

    var isSeparator = [Bool](repeating: false, count: width)
    for c in 0..<width {
        var sep = true
        for r in 0..<height {
            if grid[r][c] != " " {
                sep = false
                break
            }
        }
        isSeparator[c] = sep
    }

    var problems: [ProblemColumn] = []

    var c = 0
    while c < width {
        while c < width && isSeparator[c] { c += 1 }
        if c >= width { break }

        let start = c
        while c < width && !isSeparator[c] { c += 1 }
        let end = c - 1

        // Find the operator in the block [start...end] on the last row
        var opChar: Character? = nil
        if start <= end {
            for col in start...end {
                let ch = opRow[col]
                if ch == "+" || ch == "*" || ch == "-" || ch == "/" {
                    opChar = ch
                    break
                }
            }
        }

        guard let op = opChar else {
            continue
        }

        var numbers: [Int] = []

        for col in stride(from: end, through: start, by: -1) {
            var digits: [Character] = []

            for r in 0..<digitRows.count {
                let ch = digitRows[r][col]
                if ch.isNumber {
                    digits.append(ch)
                }
            }

            if !digits.isEmpty {
                if let value = Int(String(digits)) {
                    numbers.append(value)
                }
            }
        }

        if !numbers.isEmpty {
            problems.append(ProblemColumn(numbers: numbers, operation: op))
        }
    }

    return problems
        .map { try! $0.evaluate() }
        .reduce(0, +)
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