import Foundation

private struct Point {
    let x: Int
    let y: Int
    let z: Int
}

private func distance2(_ a: Point, _ b: Point) -> Int64 {
    let dx = Int64(a.x - b.x)
    let dy = Int64(a.y - b.y)
    let dz = Int64(a.z - b.z)
    return dx*dx + dy*dy + dz*dz
}

private struct Edge {
    let i: Int
    let j: Int
    let dist2: Int64
}

private struct DSU {
    private var parent: [Int]
    private var size: [Int]

    init(_ n: Int) {
        parent = Array(0..<n)
        size = Array(repeating: 1, count: n)
    }

    mutating func find(_ x: Int) -> Int {
        parent[x] == x ? x : {
            parent[x] = find(parent[x])
            return parent[x]
        }()
    }

    mutating func union(_ a: Int, _ b: Int) {
        let x = find(a)
        let y = find(b)
        if x == y { return }

        if size[x] >= size[y] {
            parent[y] = x
            size[x] += size[y]
        } else {
            parent[x] = y
            size[y] += size[x]
        }
    }

    mutating func componentSizes() -> [Int] {
        (0..<parent.count)
            .map { find($0) }
            .reduce(into: [:]) { acc, root in
                acc[root, default: 0] += 1
            }
            .values
            .map { $0 }
    }
}

private func parsePoints(_ input: String) -> [Point] {
    input
        .split(whereSeparator: \.isNewline)
        .compactMap { line in
            let parts = line.split(separator: ",")
            guard parts.count == 3,
                  let x = Int(parts[0]),
                  let y = Int(parts[1]),
                  let z = Int(parts[2]) else {
                return nil
            }
            return Point(x: x, y: y, z: z)
        }
}
// MARK: - Geometry

private func distanceSquared(_ a: Point, _ b: Point) -> Int64 {
    let dx = Int64(a.x - b.x)
    let dy = Int64(a.y - b.y)
    let dz = Int64(a.z - b.z)
    return dx * dx + dy * dy + dz * dz
}

private func buildEdges(points: [Point]) -> [Edge] {
    let n = points.count
    guard n >= 2 else { return [] }

    var edges = [Edge]()
    edges.reserveCapacity(n * (n - 1) / 2)

    for i in 0..<(n - 1) {
        let pi = points[i]
        for j in (i + 1)..<n {
            let pj = points[j]
            let d2 = distanceSquared(pi, pj)
            edges.append(Edge(i: i, j: j, dist2: d2))
        }
    }

    edges.sort { (a: Edge, b: Edge) in a.dist2 < b.dist2 }
    return edges
}

// MARK: - Disjoint Set (Union-Find)

private struct DisjointSet {
    private(set) var parent: [Int]
    private(set) var size: [Int]
    private(set) var components: Int

    init(_ n: Int) {
        parent = Array(0..<n)
        size = Array(repeating: 1, count: n)
        components = n
    }

    mutating func find(_ x: Int) -> Int {
        var x = x
        while parent[x] != x {
            parent[x] = parent[parent[x]] // path compression
            x = parent[x]
        }
        return x
    }

    /// Union two sets, return true if they were separate (and now merged)
    mutating func union(_ a: Int, _ b: Int) -> Bool {
        var ra = find(a)
        var rb = find(b)
        if ra == rb { return false }

        if size[ra] < size[rb] {
            swap(&ra, &rb)
        }
        parent[rb] = ra
        size[ra] += size[rb]
        components -= 1
        return true
    }

    /// Storleken på alla komponenter (kretsar)
    func componentSizes() -> [Int] {
        parent.indices.compactMap { i in
            parent[i] == i ? size[i] : nil
        }
    }
}

// MARK: - Functional Part 1

private func part1(input: String) -> Int {

    let points = input.split(whereSeparator: \.isNewline)
        .compactMap { line -> Point? in
            let parts = line.split(separator: ",")
            guard parts.count == 3,
                  let x = Int(parts[0]),
                  let y = Int(parts[1]),
                  let z = Int(parts[2]) else { return nil }
            return Point(x: x, y: y, z: z)
    }   

    let n = points.count
    guard n >= 2 else { return 0 }

    // All pairs
    let edges = (0..<n)
        .lazy
        .flatMap { i in
            (i+1..<n).lazy.map { j in
                Edge(i: i, j: j, dist2: distance2(points[i], points[j]))
            }
        }
        .sorted { $0.dist2 < $1.dist2 }

    let chosen = edges.prefix(1000)

    var dsu = DSU(n)
    chosen.forEach { dsu.union($0.i, $0.j) }

    return dsu
        .componentSizes()
        .sorted(by: >)
        .prefix(3)
        .reduce(1, *)
}

// MARK: - Part 2
private func part2(input: String) -> Int {
    let points = parsePoints(input)
    let edges = buildEdges(points: points)

    var dsu = DisjointSet(points.count)
    var lastMergeEdge: Edge?

    for e in edges {
        if dsu.union(e.i, e.j) {
            lastMergeEdge = e
            if dsu.components == 1 {
                break
            }
        }
    }

    guard let edge = lastMergeEdge else { return 0 }

    let p1 = points[edge.i]
    let p2 = points[edge.j]
    return p1.x * p2.x
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
