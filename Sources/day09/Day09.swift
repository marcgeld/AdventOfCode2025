import Foundation

// MARK: - Model

struct Point: Hashable, CustomStringConvertible {
    let x: Int
    let y: Int
    var description: String { "(\(x), \(y))" }
}

// MARK: - Parsing

private func parsePoints(_ input: String) -> [Point] {
    input
        .split(whereSeparator: \.isNewline)
        .compactMap { line -> Point? in
            let trimmed = line.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmed.isEmpty else { return nil }

            let parts = trimmed.split(separator: ",")
            guard parts.count == 2,
                  let x = Int(parts[0]),
                  let y = Int(parts[1]) else {
                return nil
            }
            return Point(x: x, y: y)
        }
}

// MARK: - Part 1: unconstrained largest rectangle

func part1(input: [Point]) -> Int {
    let n = input.count
    guard n >= 2 else { return 0 }

    var best = 0

    for i in 0..<n {
        let pi = input[i]
        for j in (i + 1)..<n {
            let pj = input[j]

            let width  = abs(pi.x - pj.x) + 1
            let height = abs(pi.y - pj.y) + 1
            let area   = width * height

            if area > best {
                best = area
            }
        }
    }
    return best
}


// MARK: - PART 2
func part2(input points: [Point]) -> Int {

    let OUTSIDE: Int = 0
    let INSIDE:  Int = 1
    let UNKNOWN: Int = 2


    func shrink(points: [Point], axis: KeyPath<Point, Int>) -> [Int: Int] {
        var vals = points.map { $0[keyPath: axis] }
        vals.append(Int.min)
        vals.append(Int.max)

        vals.sort()
        vals = Array(Set(vals)).sorted()

        var map: [Int: Int] = [:]
        for (i, v) in vals.enumerated() {
            map[v] = i
        }
        return map
    }

    func minmax(_ a: (Int, Int), _ b: (Int, Int)) -> (Int, Int, Int, Int) {
        let (x1, y1) = a
        let (x2, y2) = b
        return (min(x1, x2), min(y1, y2), max(x1, x2), max(y1, y2))
    }


    let n = points.count
    guard n >= 2 else { return 0 }

    let shrinkX = shrink(points: points, axis: \.x)
    let shrinkY = shrink(points: points, axis: \.y)

    let shrunk: [(Int, Int)] = points.map { p in
        (shrinkX[p.x]!, shrinkY[p.y]!)
    }

    let W = shrinkX.count
    let H = shrinkY.count

    var grid = Array(
        repeating: Array(repeating: UNKNOWN, count: W),
        count: H
    )

    for i in 0..<n {
        let a = shrunk[i]
        let b = shrunk[(i + 1) % n]
        let (x1, y1, x2, y2) = minmax(a, b)

        for x in x1...x2 {
            for y in y1...y2 {
                grid[y][x] = INSIDE
            }
        }
    }

    // Flood-fill
    var queue: [(Int, Int)] = [(0, 0)]
    if grid[0][0] == UNKNOWN {
        grid[0][0] = OUTSIDE
    }

    let dirs = [(1,0), (-1,0), (0,1), (0,-1)]

    while !queue.isEmpty {
        let (x, y) = queue.removeFirst()

        for (dx, dy) in dirs {
            let nx = x + dx
            let ny = y + dy
            if nx >= 0, nx < W, ny >= 0, ny < H {
                if grid[ny][nx] == UNKNOWN {
                    grid[ny][nx] = OUTSIDE
                    queue.append((nx, ny))
                }
            }
        }
    }

    // Convert to prefix sums
    var prefix = Array(
        repeating: Array(repeating: 0, count: W),
        count: H
    )

    for y in 0..<H {
        for x in 0..<W {

            let val = (grid[y][x] != OUTSIDE) ? 1 : 0

            let up    = y > 0 ? prefix[y-1][x] : 0
            let left  = x > 0 ? prefix[y][x-1] : 0
            let diag  = (x > 0 && y > 0) ? prefix[y-1][x-1] : 0

            prefix[y][x] = val + up + left - diag
        }
    }

    func rectSum(x1: Int, y1: Int, x2: Int, y2: Int) -> Int {
        let A = prefix[y2][x2]
        let B = (x1 > 0 ? prefix[y2][x1 - 1] : 0)
        let C = (y1 > 0 ? prefix[y1 - 1][x2] : 0)
        let D = (x1 > 0 && y1 > 0 ? prefix[y1 - 1][x1 - 1] : 0)
        return A - B - C + D
    }

    var best = 0

    // Test all pairs of shrunk corners
    for i in 0..<n {
        for j in i+1..<n {

            let a = shrunk[i]
            let b = shrunk[j]
            let (x1, y1, x2, y2) = minmax(a, b)

            let expected = (x2 - x1 + 1) * (y2 - y1 + 1)
            let actual = rectSum(x1: x1, y1: y1, x2: x2, y2: y2)

            if expected == actual {
                let dx = abs(points[i].x - points[j].x) + 1
                let dy = abs(points[i].y - points[j].y) + 1
                best = max(best, dx * dy)
            }
        }
    }

    return best
}

// MARK: - Main

@main
struct App {
    static func main() {
        let url = Bundle.module.url(forResource: "input", withExtension: "txt")!
        let input = try! String(contentsOf: url, encoding: .utf8)
        let points = parsePoints(input)
        guard points.count >= 2 else { return }

        print("Part 1:", part1(input: points))
        print("Part 2:", part2(input: points))
    }
}
