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

private func parse(_ input: String) -> [[Character]] {
    input
        .split(whereSeparator: \.isNewline)
        .map { Array($0) }
}

private let neighborOffsets = [
    (-1, -1), (-1, 0), (-1, 1),
    ( 0, -1),          ( 0, 1),
    ( 1, -1), ( 1, 0), ( 1, 1)
]

private func countNeighbors(_ grid: [[Character]], x: Int, y: Int) -> Int {
    let h = grid.count
    let w = grid[0].count
    var c = 0

    for (dy, dx) in neighborOffsets {
        let ny = y + dy
        let nx = x + dx
        if ny >= 0, ny < h, nx >= 0, nx < w, grid[ny][nx] == "@" {
            c += 1
        }
    }
    return c
}

// MARK: - Part 1

private func part1(input: String) -> Int {
    let rows = input
        .split(whereSeparator: \.isNewline)
        .map { Array($0) }

    let height = rows.count
    let width = rows.first?.count ?? 0

    // 8 grannar
    let neighbors = [
        (-1, -1), (-1, 0), (-1, 1),
        ( 0, -1),          ( 0, 1),
        ( 1, -1), ( 1, 0), ( 1, 1)
    ]

    func adjacentRolls(x: Int, y: Int) -> Int {
        var count = 0
        for (dy, dx) in neighbors {
            let nx = x + dx
            let ny = y + dy
            if nx >= 0, nx < width, ny >= 0, ny < height {
                if rows[ny][nx] == "@" {
                    count += 1
                }
            }
        }
        return count
    }

    var accessible = 0

    for y in 0..<height {
        for x in 0..<width {
            if rows[y][x] == "@" {
                if adjacentRolls(x: x, y: y) < 4 {
                    accessible += 1
                }
            }
        }
    }

    return accessible
}

// MARK: - Part 2

private func part2(input: String) -> Int {
    var grid = parse(input)
    let h = grid.count
    let w = grid[0].count

    // neighborCount[y][x] = antal @ runt denna cell
    var neighborCount = Array(
        repeating: Array(repeating: 0, count: w),
        count: h
    )

    // Räkna initiala grannar för alla rullar
    for y in 0..<h {
        for x in 0..<w {
            if grid[y][x] == "@" {
                neighborCount[y][x] = countNeighbors(grid, x: x, y: y)
            }
        }
    }

    // BFS-kö
    var queue: [(Int, Int)] = []
    queue.reserveCapacity(w * h / 2)

    // Lägg in alla initialt åtkomliga rullar
    for y in 0..<h {
        for x in 0..<w {
            if grid[y][x] == "@", neighborCount[y][x] < 4 {
                queue.append((x, y))
            }
        }
    }

    var removed = 0
    var head = 0

    while head < queue.count {
        let (x, y) = queue[head]
        head += 1

        // Kan ha blivit borttagen tidigare via annan väg
        if grid[y][x] != "@" { continue }

        // Ta bort rullen
        grid[y][x] = "."
        removed += 1

        // Uppdatera grannars neighborCount
        for (dy, dx) in neighborOffsets {
            let ny = y + dy
            let nx = x + dx

            guard ny >= 0, ny < h, nx >= 0, nx < w else { continue }
            guard grid[ny][nx] == "@" else { continue }

            neighborCount[ny][nx] -= 1

            // Den var tidigare >=4, nu blev den 3 → blir åtkomlig nu
            if neighborCount[ny][nx] == 3 {
                queue.append((nx, ny))
            }
        }
    }

    return removed
}