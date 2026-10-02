import SwiftUI

struct GameSession: Identifiable {
    let id = UUID()
    let level: Level
}

struct HomeView: View {
    @Environment(PlayerStore.self) private var store
    @State private var session: GameSession?
    @State private var showGarden = false
    @State private var showWheel = false

    var body: some View {
        ZStack {
            Theme.background

            VStack(spacing: 20) {
                HStack {
                    languageButton
                    Spacer()
                    CoinBadge(coins: store.data.coins)
                }

                VStack(spacing: 4) {
                    Text("Blossom")
                        .font(.system(size: 44, weight: .heavy, design: .rounded))
                        .foregroundStyle(Theme.pink.gradient)
                    Text(store.t("Word Search", "Kelime Avı"))
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(Theme.deep)
                }

                Spacer()

                bloomCard

                Spacer()

                Button {
                    session = GameSession(level: LevelFactory.make(level: store.data.level, language: store.language))
                } label: {
                    Label(store.t("Level", "Bölüm") + " \(store.data.level)", systemImage: "play.fill")
                }
                .buttonStyle(BlossomButtonStyle())

                HStack(spacing: 12) {
                    tile(icon: "calendar", title: store.t("Daily", "Günlük"), badge: store.dailyAvailable) {
                        session = GameSession(level: LevelFactory.makeDaily(language: store.language))
                    }
                    tile(icon: "camera.macro", title: store.t("Garden", "Bahçe"), badge: false) { showGarden = true }
                    tile(icon: "circle.dashed", title: store.t("Wheel", "Çark"), badge: store.spinAvailable) { showWheel = true }
                }
            }
            .padding(20)
        }
        .fullScreenCover(item: $session) { session in
            GameView(level: session.level)
        }
        .sheet(isPresented: $showGarden) { GardenView() }
        .sheet(isPresented: $showWheel) { WheelView() }
    }

    private var languageButton: some View {
        Menu {
            ForEach(AppLanguage.allCases, id: \.self) { lang in
                Button {
                    store.setLanguage(lang)
                } label: {
                    if lang == store.language {
                        Label(lang == .tr ? "Türkçe" : "English", systemImage: "checkmark")
                    } else {
                        Text(lang == .tr ? "Türkçe" : "English")
                    }
                }
            }
        } label: {
            HStack(spacing: 6) {
                Text(store.language.flag)
                Text(store.language.code).font(.headline)
            }
            .foregroundStyle(Theme.deep)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Capsule().fill(Theme.card))
        }
    }

    private var bloomCard: some View {
        let progress = Double(store.data.bloomProgress) / Double(FlowerCatalog.levelsPerBloom)
        return VStack(spacing: 12) {
            ZStack {
                Circle().stroke(Theme.pink.opacity(0.15), lineWidth: 12)
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(Theme.pink, style: StrokeStyle(lineWidth: 12, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .animation(.spring, value: progress)
                Text(store.nextFlower.emoji)
                    .font(.system(size: 70))
                    .opacity(0.35 + 0.65 * progress)
                    .scaleEffect(0.6 + 0.4 * progress)
            }
            .frame(width: 170, height: 170)

            Text(store.t("Next bloom", "Sıradaki çiçek") + ": \(store.nextFlower.name(store.language))")
                .font(.headline)
                .foregroundStyle(Theme.deep)
            Text(store.t("\(FlowerCatalog.levelsPerBloom - store.data.bloomProgress) level(s) to go", "\(FlowerCatalog.levelsPerBloom - store.data.bloomProgress) bölüm kaldı"))
                .font(.subheadline)
                .foregroundStyle(Theme.deep.opacity(0.7))
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .background(RoundedRectangle(cornerRadius: 28).fill(Theme.card))
    }

    private func tile(icon: String, title: String, badge: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: icon).font(.title2)
                Text(title).font(.subheadline.bold())
            }
            .foregroundStyle(Theme.deep)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(RoundedRectangle(cornerRadius: 20).fill(Theme.card))
            .overlay(alignment: .topTrailing) {
                if badge {
                    Circle().fill(Theme.pink).frame(width: 12, height: 12).padding(8)
                }
            }
        }
    }
}
