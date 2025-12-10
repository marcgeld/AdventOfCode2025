import Foundation


// MARK: - Common Model / Parsing

private let BEAM_EMITTER: Character  = "S"
private let BEAM_SPLITTER: Character = "^"

private struct Coord: Hashable {
    let row: Int
    let col: Int
}

private func parseGridAndStart(_ input: String) -> ([[Character]], Coord?) {
    
    let grid: [[Character]] = input
        .split(whereSeparator: \.isNewline)
        .map(Array.init)

    let height = grid.count
    guard height > 0 else { return (grid, nil) }
    let width = grid[0].count

    var start: Coord? = nil
    outer: for r in 0..<height {
        for c in 0..<width {
            if grid[r][c] == BEAM_EMITTER {
                start = Coord(row: r, col: c)
                break outer
            }
        }
    }

    return (grid, start)
}

// MARK: - Part 1 single-timeline
func part1(input: String) -> Int {
    
    let (grid, startOpt) = parseGridAndStart(input)
    guard let startPos = startOpt else {
        print("No start position '\(BEAM_EMITTER)' found in grid!")
        return 0
    }

    let height = grid.count
    guard height > 0 else { return 0 }
    let width = grid[0].count

    var usedSplitters = Set<Coord>()

    func trace(_ row: Int, _ col: Int) -> Int {
        // Utanför grid → inga fler splits
        if row < 0 || row >= height || col < 0 || col >= width {
            return 0
        }

        let cell = grid[row][col]
        switch cell {
        case BEAM_SPLITTER:
            let pos = Coord(row: row, col: col)

            if usedSplitters.contains(pos) {
                return 0
            }

            usedSplitters.insert(pos)

            let left  = trace(row, col - 1)
            let right = trace(row, col + 1)
            return 1 + left + right
        default:
            return trace(row + 1, col)
        }
    }

    let totalSplits = trace(startPos.row + 1, startPos.col)
    return totalSplits
}

// MARK: - Part 2 quantum-timelines

func part2(input: String) -> Int {
    
    let (grid, startOpt) = parseGridAndStart(input)
    guard let startPos = startOpt else {
        print("No start position '\(BEAM_EMITTER)' found in grid!")
        return 0
    }

    let height = grid.count
    guard height > 0 else { return 0 }
    let width = grid[0].count

    // Number of timelines at each coordinate
    var timelinesAt: [Coord: Int] = [:]

    var queue: [Coord] = []
    var head = 0

    func enqueue(_ coord: Coord, _ addCount: Int) {
        // Går vi utanför gridden → tidslinjerna är "klara"
        if coord.row < 0 || coord.row >= height || coord.col < 0 || coord.col >= width {
            totalTimelines += addCount
            return
        }

        timelinesAt[coord, default: 0] += addCount
        queue.append(coord)
    }

    var totalTimelines = 0

    let startBelow = Coord(row: startPos.row + 1, col: startPos.col)
    enqueue(startBelow, 1)

    while head < queue.count {
        let coord = queue[head]
        head += 1

        guard let countHere = timelinesAt[coord], countHere > 0 else { continue }
        timelinesAt[coord] = 0

        let r = coord.row
        let c = coord.col

        // Safety check (should not be needed due to enqueue)
        if r < 0 || r >= height || c < 0 || c >= width {
            totalTimelines += countHere
            continue
        }

        let cell = grid[r][c]

        if cell == BEAM_SPLITTER {
            enqueue(Coord(row: r, col: c - 1), countHere)
            enqueue(Coord(row: r, col: c + 1), countHere)
        } else {
            enqueue(Coord(row: r + 1, col: c), countHere)
        }
    }

    return totalTimelines
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