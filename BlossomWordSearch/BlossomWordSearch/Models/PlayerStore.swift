import Foundation
import Observation

struct Flower: Identifiable {
    let id: Int
    let emoji: String
    let nameEN: String
    let nameTR: String

    func name(_ lang: AppLanguage) -> String { lang == .tr ? nameTR : nameEN }
}

enum FlowerCatalog {
    static let all: [Flower] = [
        Flower(id: 0, emoji: "🌸", nameEN: "Cherry Blossom", nameTR: "Kiraz Çiçeği"),
        Flower(id: 1, emoji: "🌷", nameEN: "Tulip", nameTR: "Lale"),
        Flower(id: 2, emoji: "🌼", nameEN: "Daisy", nameTR: "Papatya"),
        Flower(id: 3, emoji: "🌹", nameEN: "Rose", nameTR: "Gül"),
        Flower(id: 4, emoji: "🌻", nameEN: "Sunflower", nameTR: "Ayçiçeği"),
        Flower(id: 5, emoji: "🌺", nameEN: "Hibiscus", nameTR: "Ebegümeci"),
        Flower(id: 6, emoji: "🪷", nameEN: "Lotus", nameTR: "Nilüfer"),
        Flower(id: 7, emoji: "🪻", nameEN: "Hyacinth", nameTR: "Sümbül"),
        Flower(id: 8, emoji: "🏵️", nameEN: "Rosette", nameTR: "Rozet Çiçeği"),
        Flower(id: 9, emoji: "💮", nameEN: "White Blossom", nameTR: "Beyaz Çiçek"),
        Flower(id: 10, emoji: "🥀", nameEN: "Wilted Rose", nameTR: "Solgun Gül"),
        Flower(id: 11, emoji: "💐", nameEN: "Bouquet", nameTR: "Buket"),
    ]

    /// A new flower blooms every this many completed levels.
    static let levelsPerBloom = 3
}

struct PlayerData: Codable {
    var level = 1
    var coins = 200
    var collectedFlowers: [Int] = []
    var bloomProgress = 0
    var wordsFound = 0
    var lastDailyDate: String?
    var lastSpinDate: String?
    /// nil = follow the system language.
    var language: AppLanguage?
}

@Observable
final class PlayerStore {
    private static let key = "playerData"
    private(set) var data: PlayerData

    init() {
        if let raw = UserDefaults.standard.data(forKey: Self.key),
           let decoded = try? JSONDecoder().decode(PlayerData.self, from: raw) {
            data = decoded
        } else {
            data = PlayerData()
        }
    }

    private func save() {
        if let raw = try? JSONEncoder().encode(data) {
            UserDefaults.standard.set(raw, forKey: Self.key)
        }
    }

    static func dayKey(_ date: Date = .now) -> String {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f.string(from: date)
    }

    var language: AppLanguage { data.language ?? .system }

    func setLanguage(_ lang: AppLanguage) {
        data.language = lang
        save()
    }

    func t(_ en: String, _ tr: String) -> String { language.t(en, tr) }

    var dailyAvailable: Bool { data.lastDailyDate != Self.dayKey() }
    var spinAvailable: Bool { data.lastSpinDate != Self.dayKey() }

    var nextFlower: Flower {
        FlowerCatalog.all[data.collectedFlowers.count % FlowerCatalog.all.count]
    }

    func spend(_ amount: Int) -> Bool {
        guard data.coins >= amount else { return false }
        data.coins -= amount
        save()
        return true
    }

    func addCoins(_ amount: Int) {
        data.coins += amount
        save()
    }

    func recordWordFound() {
        data.wordsFound += 1
        save()
    }

    /// Returns the flower that bloomed, if this level completed a bloom cycle.
    @discardableResult
    func completeLevel(_ level: Level, bonusCoins: Int = 0) -> Flower? {
        data.coins += level.reward + bonusCoins
        var bloomed: Flower?
        if level.kind == .daily {
            data.lastDailyDate = Self.dayKey()
        } else {
            data.level = level.number + 1
            data.bloomProgress += 1
            if data.bloomProgress >= FlowerCatalog.levelsPerBloom {
                data.bloomProgress = 0
                let flower = nextFlower
                data.collectedFlowers.append(flower.id)
                bloomed = flower
            }
        }
        save()
        return bloomed
    }

    func recordSpin(reward: Int) {
        data.lastSpinDate = Self.dayKey()
        data.coins += reward
        save()
    }
}
