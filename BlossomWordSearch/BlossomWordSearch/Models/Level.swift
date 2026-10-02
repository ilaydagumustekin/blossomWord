import Foundation

enum LevelKind: String, Codable {
    case normal, twister, bonus, daily
}

struct TargetWord: Identifiable, Hashable {
    let id: Int
    /// Twister levels show this instead of the answer (the answer is its opposite).
    let clue: String?
    let answer: String
}

struct Level {
    let number: Int
    let language: AppLanguage
    let kind: LevelKind
    let title: String
    let rows: Int
    let cols: Int
    let grid: [[Character]]
    let targets: [TargetWord]
    let placements: [String: [GridPos]]
    let hiddenWord: String?

    var reward: Int {
        switch kind {
        case .normal: return 10
        case .twister: return 20
        case .bonus: return 40
        case .daily: return 100
        }
    }
}

enum LevelFactory {
    static func kind(for n: Int) -> LevelKind {
        if n >= 5 && n % 5 == 0 { return .twister }
        if n >= 7 && n % 7 == 0 { return .bonus }
        return .normal
    }

    static let maxGridSize = 12
    static let maxWordCount = 12

    /// Grid size, word count and allowed directions grow with the level number.
    /// Size: 6×6 → +1 every 5 levels → 12×12. Words: 4 → +1 every 3 levels → 12.
    static func difficulty(for n: Int) -> (size: Int, count: Int, directions: [Direction]) {
        let level = max(1, n)
        let size = min(6 + (level - 1) / 5, maxGridSize)
        let count = min(4 + (level - 1) / 3, maxWordCount)
        let forward: [Direction] = [.right, .down, .downRight, .upRight]
        let directions: [Direction]
        switch level {
        case ..<11: directions = forward                    // diagonals from level 1
        case ..<21: directions = forward + [.left, .up]     // then backwards
        default: directions = Direction.all                 // then every direction
        }
        return (size, count, directions)
    }

    static func make(level n: Int, language: AppLanguage) -> Level {
        var rng = SeededRandom(seed: UInt64(n) &* 7919)
        let (size, count, directions) = difficulty(for: n)
        return build(number: n, kind: kind(for: n), language: language, size: size, count: count, directions: directions, rng: &rng)
    }

    static func makeDaily(language: AppLanguage, date: Date = .now) -> Level {
        let comps = Calendar.current.dateComponents([.year, .month, .day], from: date)
        let seed = UInt64(comps.year! * 10_000 + comps.month! * 100 + comps.day!)
        var rng = SeededRandom(seed: seed)
        return build(number: 0, kind: .daily, language: language, size: 10, count: 10, directions: Direction.all, rng: &rng)
    }

    private static func build(number: Int, kind: LevelKind, language lang: AppLanguage, size: Int, count: Int, directions: [Direction], rng: inout SeededRandom) -> Level {
        var wantedCount = count
        while true {
            let (title, targets, hidden) = pickTargets(kind: kind, language: lang, size: size, count: wantedCount, rng: &rng)
            let answers = targets.map(\.answer)
            if let result = GridGenerator.generate(words: answers, rows: size, cols: size, directions: directions, alphabet: WordBank.alphabet(lang), rng: &rng) {
                return Level(number: number, language: lang, kind: kind, title: title, rows: size, cols: size,
                             grid: result.grid, targets: targets, placements: result.placements, hiddenWord: hidden)
            }
            wantedCount = max(2, wantedCount - 1)
        }
    }

    private static func pickTargets(kind: LevelKind, language lang: AppLanguage, size: Int, count: Int, rng: inout SeededRandom) -> (String, [TargetWord], String?) {
        if kind == .twister {
            let pairs = WordBank.opposites(lang)
                .filter { $0.0.count <= size && $0.1.count <= size && $0.1.count >= 2 }
                .shuffled(using: &rng)
            var targets: [TargetWord] = []
            for (a, b) in pairs where targets.count < count {
                let (clue, answer) = Bool.random(using: &rng) ? (a, b) : (b, a)
                guard answer.count >= 2, isCompatible(answer, with: targets.map(\.answer)) else { continue }
                targets.append(TargetWord(id: targets.count, clue: clue, answer: answer))
            }
            return (lang.t("Twister: Opposites", "Twister: Zıt Anlamlar"), targets, nil)
        }

        let themes = WordBank.themes(lang)
        let theme = themes[Int(rng.next() % UInt64(themes.count))]
        var targets: [TargetWord] = []
        for word in theme.words.filter({ $0.count <= size && $0.count >= 3 }).shuffled(using: &rng) where targets.count < count {
            guard isCompatible(word, with: targets.map(\.answer)) else { continue }
            targets.append(TargetWord(id: targets.count, clue: nil, answer: word))
        }

        switch kind {
        case .bonus:
            let hidden = WordBank.hiddenWords(lang).randomElement(using: &rng)
            return ("Bonus · \(theme.title)", targets, hidden)
        case .daily:
            return (lang.t("Daily", "Günlük") + " · \(theme.title)", targets, nil)
        default:
            return (theme.title, targets, nil)
        }
    }

    /// Avoid words that contain each other (e.g. SUN / SUNNY) — one find would be ambiguous.
    private static func isCompatible(_ word: String, with others: [String]) -> Bool {
        !others.contains { $0.contains(word) || word.contains($0) }
    }
}
