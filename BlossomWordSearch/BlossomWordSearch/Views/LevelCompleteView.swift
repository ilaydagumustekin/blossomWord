import SwiftUI

struct LevelCompleteView: View {
    let level: Level
    let coins: Int
    let flower: Flower?
    let hiddenWord: String?
    let onNext: () -> Void
    let onHome: () -> Void

    @Environment(PlayerStore.self) private var store
    @State private var bloom = false

    var body: some View {
        ZStack {
            Color.black.opacity(0.35).ignoresSafeArea()

            VStack(spacing: 18) {
                Text(flower?.emoji ?? "🌸")
                    .font(.system(size: 90))
                    .scaleEffect(bloom ? 1 : 0.2)
                    .rotationEffect(.degrees(bloom ? 0 : -90))

                Text(level.kind == .daily ? store.t("Daily Puzzle Solved!", "Günlük Bulmaca Çözüldü!") : store.t("Level Complete!", "Bölüm Tamamlandı!"))
                    .font(.title.bold())
                    .foregroundStyle(Theme.deep)

                if let flower {
                    Text(store.t("A new flower bloomed", "Yeni bir çiçek açtı") + ": \(flower.name(store.language))")
                        .font(.subheadline)
                        .foregroundStyle(Theme.deep.opacity(0.8))
                }

                if let hiddenWord {
                    Text(store.t("Hidden word", "Gizli kelime") + ": \(hiddenWord)")
                        .font(.headline)
                        .foregroundStyle(Theme.leaf)
                }

                CoinBadge(coins: coins)
                    .overlay(alignment: .leading) { Text("+").font(.headline).offset(x: -14) }

                Button(level.kind == .daily ? store.t("Done", "Tamam") : store.t("Next Level", "Sonraki Bölüm"), action: onNext)
                    .buttonStyle(BlossomButtonStyle())

                if level.kind != .daily {
                    Button(store.t("Home", "Ana Sayfa"), action: onHome)
                        .font(.headline)
                        .foregroundStyle(Theme.deep)
                }
            }
            .padding(28)
            .background(RoundedRectangle(cornerRadius: 32).fill(Theme.bgTop))
            .padding(.horizontal, 32)
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.55).delay(0.1)) { bloom = true }
        }
    }
}
