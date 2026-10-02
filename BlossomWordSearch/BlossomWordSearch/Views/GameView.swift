import SwiftUI

struct GameView: View {
    @Environment(PlayerStore.self) private var store
    @Environment(\.dismiss) private var dismiss

    @State private var vm: GameViewModel
    @State private var shake: CGFloat = 0
    @State private var bloomedFlower: Flower?
    @State private var showComplete = false
    @State private var earnedCoins = 0
    @State private var message: String?

    init(level: Level) {
        _vm = State(initialValue: GameViewModel(level: level))
    }

    var body: some View {
        ZStack {
            Theme.background

            VStack(spacing: 14) {
                topBar
                header
                if let hidden = vm.level.hiddenWord { hiddenWordRow(hidden) }
                wordList
                Spacer(minLength: 0)
                GridView(vm: vm, onWordFound: wordFound, onWrong: wrongSwipe)
                    .modifier(ShakeEffect(amount: shake))
                    .padding(.horizontal, 4)
                Spacer(minLength: 0)
                boosters
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 8)

            if let message {
                Text(message)
                    .font(.subheadline.bold())
                    .foregroundStyle(.white)
                    .padding(.horizontal, 16).padding(.vertical, 10)
                    .background(Capsule().fill(Theme.deep.opacity(0.85)))
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .frame(maxHeight: .infinity, alignment: .top)
                    .padding(.top, 60)
            }

            if showComplete {
                LevelCompleteView(level: vm.level, coins: earnedCoins, flower: bloomedFlower,
                                  hiddenWord: vm.level.hiddenWord, onNext: nextLevel, onHome: { dismiss() })
                    .transition(.opacity.combined(with: .scale(scale: 0.9)))
            }
        }
        .onChange(of: vm.isComplete) { _, done in
            if done { finishLevel() }
        }
    }

    // MARK: Sections

    private var topBar: some View {
        HStack {
            Button { dismiss() } label: {
                Image(systemName: "chevron.left")
                    .font(.headline)
                    .foregroundStyle(Theme.deep)
                    .frame(width: 40, height: 40)
                    .background(Circle().fill(Theme.card))
            }
            Spacer()
            Text(vm.level.kind == .daily ? store.t("Daily Puzzle", "Günlük Bulmaca") : store.t("Level", "Bölüm") + " \(vm.level.number)")
                .font(.headline)
                .foregroundStyle(Theme.deep)
            Spacer()
            CoinBadge(coins: store.data.coins)
        }
    }

    private var header: some View {
        VStack(spacing: 6) {
            if vm.level.kind == .twister {
                Label(store.t("Find the opposites!", "Zıt anlamlıları bul!"), systemImage: "arrow.left.arrow.right")
                    .font(.caption.bold())
                    .foregroundStyle(.white)
                    .padding(.horizontal, 10).padding(.vertical, 4)
                    .background(Capsule().fill(Color.purple.opacity(0.7)))
            }
            Text(vm.level.title)
                .font(.title2.bold())
                .foregroundStyle(Theme.deep)
            ProgressView(value: Double(vm.foundCount), total: Double(vm.totalCount))
                .tint(Theme.pink)
                .frame(maxWidth: 220)
                .animation(.snappy, value: vm.foundCount)
        }
    }

    private func hiddenWordRow(_ hidden: String) -> some View {
        HStack(spacing: 6) {
            ForEach(Array(hidden.enumerated()), id: \.offset) { i, ch in
                let shown = i < vm.revealedHiddenLetters
                Text(shown ? String(ch) : "")
                    .font(.headline.bold())
                    .foregroundStyle(.white)
                    .frame(width: 30, height: 34)
                    .background(RoundedRectangle(cornerRadius: 8).fill(shown ? Theme.leaf : Theme.deep.opacity(0.15)))
                    .animation(.spring, value: shown)
            }
        }
    }

    private var wordList: some View {
        FlowLayout(spacing: 8) {
            ForEach(vm.level.targets) { target in
                let found = vm.found[target.answer]
                Text(label(for: target, found: found != nil))
                    .font(.subheadline.weight(.semibold))
                    .strikethrough(found != nil && target.clue == nil)
                    .foregroundStyle(found != nil ? .white : Theme.deep)
                    .padding(.horizontal, 12).padding(.vertical, 6)
                    .background(Capsule().fill(found.map { Theme.wordColor($0.colorIndex) } ?? Theme.card))
                    .animation(.snappy, value: found != nil)
            }
        }
    }

    private func label(for target: TargetWord, found: Bool) -> String {
        guard let clue = target.clue else { return target.answer }
        return found ? "\(clue) ↔ \(target.answer)" : "\(clue) ↔ ?"
    }

    private var boosters: some View {
        HStack(spacing: 14) {
            boosterButton(icon: "lightbulb.fill", title: store.t("Hint", "İpucu"), cost: GameViewModel.hintCost) {
                guard store.spend(GameViewModel.hintCost) else { return show(store.t("Not enough coins", "Yeterli coin yok")) }
                if !vm.applyHint() {
                    store.addCoins(GameViewModel.hintCost)
                    show(store.t("All first letters already shown", "Tüm ilk harfler zaten gösterildi"))
                }
            }
            boosterButton(icon: "wand.and.stars", title: store.t("Reveal", "Kelime Aç"), cost: GameViewModel.revealCost) {
                guard store.spend(GameViewModel.revealCost) else { return show(store.t("Not enough coins", "Yeterli coin yok")) }
                let ok = withAnimation(.easeOut) { vm.applyReveal() }
                if ok { wordFound() } else { store.addCoins(GameViewModel.revealCost) }
            }
        }
    }

    private func boosterButton(icon: String, title: String, cost: Int, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                VStack(alignment: .leading, spacing: 0) {
                    Text(title).font(.subheadline.bold())
                    Text("\(cost) coin").font(.caption2)
                }
            }
            .foregroundStyle(Theme.deep)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background(RoundedRectangle(cornerRadius: 16).fill(Theme.card))
        }
        .disabled(vm.isComplete)
    }

    // MARK: Actions

    private func wordFound() {
        Haptics.success()
        store.recordWordFound()
    }

    private func wrongSwipe() {
        Haptics.error()
        withAnimation(.linear(duration: 0.35)) { shake += 1 }
    }

    private func show(_ text: String) {
        withAnimation { message = text }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.6) {
            withAnimation { message = nil }
        }
    }

    private func finishLevel() {
        let bonus = vm.level.kind == .bonus ? 30 : 0
        earnedCoins = vm.level.reward + bonus
        bloomedFlower = store.completeLevel(vm.level, bonusCoins: bonus)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            withAnimation(.spring) { showComplete = true }
        }
    }

    private func nextLevel() {
        guard vm.level.kind != .daily else { return dismiss() }
        withAnimation {
            showComplete = false
            bloomedFlower = nil
            vm = GameViewModel(level: LevelFactory.make(level: store.data.level, language: vm.level.language))
        }
    }
}

struct ShakeEffect: GeometryEffect {
    var amount: CGFloat
    var animatableData: CGFloat {
        get { amount }
        set { amount = newValue }
    }

    func effectValue(size: CGSize) -> ProjectionTransform {
        ProjectionTransform(CGAffineTransform(translationX: 8 * sin(amount * .pi * 4), y: 0))
    }
}
