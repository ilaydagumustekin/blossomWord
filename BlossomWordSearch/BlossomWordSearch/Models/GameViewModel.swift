import Foundation
import Observation

struct FoundWord {
    let answer: String
    let cells: [GridPos]
    let colorIndex: Int
}

@Observable
final class GameViewModel {
    static let hintCost = 25
    static let revealCost = 75

    let level: Level
    private(set) var found: [String: FoundWord] = [:]
    private(set) var hintedCells: Set<GridPos> = []
    var selection: [GridPos] = []
    private(set) var isComplete = false
    /// Bumped on a wrong swipe so the view can shake.
    private(set) var wrongAttempts = 0

    init(level: Level) {
        self.level = level
    }

    var foundCount: Int { found.count }
    var totalCount: Int { level.targets.count }

    var selectionText: String {
        String(selection.map { level.grid[$0.r][$0.c] })
    }

    /// Bonus levels reveal the hidden word proportionally to found words.
    var revealedHiddenLetters: Int {
        guard let hidden = level.hiddenWord, totalCount > 0 else { return 0 }
        return Int((Double(foundCount) * Double(hidden.count) / Double(totalCount)).rounded(.up))
    }

    func isFound(_ target: TargetWord) -> Bool { found[target.answer] != nil }

    /// Cells on the straight line from start to end, or nil if not on one of the 8 directions.
    func line(from start: GridPos, to end: GridPos) -> [GridPos]? {
        let dr = end.r - start.r, dc = end.c - start.c
        guard dr == 0 || dc == 0 || abs(dr) == abs(dc) else { return nil }
        let steps = max(abs(dr), abs(dc))
        let sr = dr.signum(), sc = dc.signum()
        return (0...steps).map { GridPos(r: start.r + sr * $0, c: start.c + sc * $0) }
    }

    /// Checks the current selection; returns true if a new word was found.
    @discardableResult
    func submitSelection() -> Bool {
        defer { selection = [] }
        guard selection.count >= 2, !isComplete else { return false }
        let text = selectionText
        let reversed = String(text.reversed())
        guard let target = level.targets.first(where: { !isFound($0) && ($0.answer == text || $0.answer == reversed) }) else {
            wrongAttempts += 1
            return false
        }
        markFound(target, cells: selection)
        return true
    }

    private func markFound(_ target: TargetWord, cells: [GridPos]) {
        found[target.answer] = FoundWord(answer: target.answer, cells: cells, colorIndex: found.count)
        if found.count == totalCount { isComplete = true }
    }

    /// Reveals the first letter of a random unfound word. Returns false if nothing left to hint.
    func applyHint() -> Bool {
        let candidates = level.targets.filter { target in
            guard !isFound(target), let first = level.placements[target.answer]?.first else { return false }
            return !hintedCells.contains(first)
        }
        guard let target = candidates.randomElement(), let first = level.placements[target.answer]?.first else { return false }
        hintedCells.insert(first)
        return true
    }

    /// Finds a whole word for the player.
    func applyReveal() -> Bool {
        guard let target = level.targets.first(where: { !isFound($0) }),
              let cells = level.placements[target.answer] else { return false }
        markFound(target, cells: cells)
        return true
    }
}
