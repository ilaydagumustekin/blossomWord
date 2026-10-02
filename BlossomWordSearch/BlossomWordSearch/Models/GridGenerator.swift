import Foundation

struct GridPos: Hashable, Codable {
    let r: Int
    let c: Int
}

struct Direction: Hashable {
    let dr: Int
    let dc: Int

    static let right = Direction(dr: 0, dc: 1)
    static let left = Direction(dr: 0, dc: -1)
    static let down = Direction(dr: 1, dc: 0)
    static let up = Direction(dr: -1, dc: 0)
    static let downRight = Direction(dr: 1, dc: 1)
    static let upLeft = Direction(dr: -1, dc: -1)
    static let upRight = Direction(dr: -1, dc: 1)
    static let downLeft = Direction(dr: 1, dc: -1)

    static let all: [Direction] = [.right, .left, .down, .up, .downRight, .upLeft, .upRight, .downLeft]
}

/// Deterministic RNG so a given level number always produces the same puzzle.
struct SeededRandom: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed &+ 0x9E37_79B9_7F4A_7C15
    }

    mutating func next() -> UInt64 {
        state &+= 0x9E37_79B9_7F4A_7C15
        var z = state
        z = (z ^ (z >> 30)) &* 0xBF58_476D_1CE4_E5B9
        z = (z ^ (z >> 27)) &* 0x94D0_49BB_1331_11EB
        return z ^ (z >> 31)
    }
}

enum GridGenerator {
    static let empty: Character = "."

    struct Result {
        let grid: [[Character]]
        let placements: [String: [GridPos]]
    }

    static func generate(words: [String], rows: Int, cols: Int, directions: [Direction], alphabet: [Character], rng: inout SeededRandom) -> Result? {
        let sorted = words.sorted { $0.count > $1.count }
        for _ in 0..<60 {
            var grid = Array(repeating: Array(repeating: empty, count: cols), count: rows)
            var placements: [String: [GridPos]] = [:]
            var success = true
            for word in sorted {
                guard let cells = place(word, in: &grid, directions: directions, rng: &rng) else {
                    success = false
                    break
                }
                placements[word] = cells
            }
            if success {
                fill(&grid, using: words, alphabet: alphabet, rng: &rng)
                return Result(grid: grid, placements: placements)
            }
        }
        return nil
    }

    private static func place(_ word: String, in grid: inout [[Character]], directions: [Direction], rng: inout SeededRandom) -> [GridPos]? {
        let letters = Array(word)
        let rows = grid.count, cols = grid[0].count
        var candidates: [(GridPos, Direction)] = []

        for r in 0..<rows {
            for c in 0..<cols {
                for d in directions {
                    let endR = r + d.dr * (letters.count - 1)
                    let endC = c + d.dc * (letters.count - 1)
                    guard endR >= 0, endR < rows, endC >= 0, endC < cols else { continue }
                    var fits = true
                    var overlap = 0
                    for i in 0..<letters.count {
                        let ch = grid[r + d.dr * i][c + d.dc * i]
                        if ch == empty { continue }
                        if ch == letters[i] { overlap += 1 } else { fits = false; break }
                    }
                    // Never let a word sit entirely on top of another one.
                    if fits && overlap < letters.count {
                        candidates.append((GridPos(r: r, c: c), d))
                    }
                }
            }
        }

        // Pick the direction first so diagonals (which fit in fewer spots) are as likely as straight lines.
        let byDirection = Dictionary(grouping: candidates, by: \.1)
        let available = directions.filter { byDirection[$0] != nil }
        guard let d = available.randomElement(using: &rng),
              let (start, _) = byDirection[d]?.randomElement(using: &rng) else { return nil }
        var cells: [GridPos] = []
        for i in 0..<letters.count {
            let pos = GridPos(r: start.r + d.dr * i, c: start.c + d.dc * i)
            grid[pos.r][pos.c] = letters[i]
            cells.append(pos)
        }
        return cells
    }

    private static func fill(_ grid: inout [[Character]], using words: [String], alphabet: [Character], rng: inout SeededRandom) {
        let wordLetters = Array(words.joined())
        for r in grid.indices {
            for c in grid[r].indices where grid[r][c] == empty {
                // Mixing in letters from the hidden words makes decoys more convincing.
                let pool = Bool.random(using: &rng) ? wordLetters : alphabet
                grid[r][c] = pool.randomElement(using: &rng) ?? "A"
            }
        }
    }
}
