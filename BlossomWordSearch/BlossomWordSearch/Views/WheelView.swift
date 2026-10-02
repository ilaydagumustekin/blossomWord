import SwiftUI

/// Blossom Wheel: one free spin per day for coins.
struct WheelView: View {
    @Environment(PlayerStore.self) private var store
    @Environment(\.dismiss) private var dismiss

    private let rewards = [10, 50, 20, 100, 15, 30, 25, 200]
    @State private var rotation: Double = 0
    @State private var spinning = false
    @State private var wonReward: Int?

    var body: some View {
        ZStack {
            Theme.background
            VStack(spacing: 24) {
                Text(store.t("Blossom Wheel", "Çiçek Çarkı"))
                    .font(.largeTitle.bold())
                    .foregroundStyle(Theme.deep)

                ZStack(alignment: .top) {
                    wheel
                        .rotationEffect(.degrees(rotation))
                        .frame(width: 290, height: 290)
                    Image(systemName: "arrowtriangle.down.fill")
                        .font(.largeTitle)
                        .foregroundStyle(Theme.deep)
                        .offset(y: -18)
                }

                if let wonReward {
                    Text(store.t("You won \(wonReward) coins! 🌸", "\(wonReward) coin kazandın! 🌸"))
                        .font(.title2.bold())
                        .foregroundStyle(Theme.pink)
                } else if !store.spinAvailable {
                    Text(store.t("Come back tomorrow for another spin", "Yeni çevirme hakkı için yarın gel"))
                        .foregroundStyle(Theme.deep.opacity(0.7))
                }

                Button(store.spinAvailable ? store.t("Spin!", "Çevir!") : store.t("Close", "Kapat")) {
                    store.spinAvailable ? spin() : dismiss()
                }
                .buttonStyle(BlossomButtonStyle())
                .disabled(spinning)
                .padding(.horizontal, 40)
            }
        }
        .presentationDragIndicator(.visible)
    }

    private var wheel: some View {
        let slice = 360.0 / Double(rewards.count)
        return ZStack {
            ForEach(rewards.indices, id: \.self) { i in
                // Slice i is centered on the pointer (top) when rotation == -i * slice.
                let start = Angle.degrees(Double(i) * slice - slice / 2 - 90)
                let end = Angle.degrees(Double(i) * slice + slice / 2 - 90)
                Path { p in
                    p.move(to: CGPoint(x: 145, y: 145))
                    p.addArc(center: CGPoint(x: 145, y: 145), radius: 145, startAngle: start, endAngle: end, clockwise: false)
                }
                .fill(Theme.wordColor(i))

                Text("\(rewards[i])")
                    .font(.headline.bold())
                    .foregroundStyle(.white)
                    .offset(y: -100)
                    .rotationEffect(.degrees(Double(i) * slice))
            }
            Circle().fill(.white).frame(width: 50, height: 50)
            Text("🌸").font(.title)
        }
    }

    private func spin() {
        spinning = true
        let index = Int.random(in: 0..<rewards.count)
        let slice = 360.0 / Double(rewards.count)
        let current = rotation.truncatingRemainder(dividingBy: 360)
        let target = rotation - current + 360 * 5 + (360 - Double(index) * slice)
        withAnimation(.easeOut(duration: 3.5)) { rotation = target }
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.6) {
            store.recordSpin(reward: rewards[index])
            Haptics.success()
            withAnimation(.spring) { wonReward = rewards[index] }
            spinning = false
        }
    }
}
