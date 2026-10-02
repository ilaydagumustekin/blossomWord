import SwiftUI

struct GardenView: View {
    @Environment(PlayerStore.self) private var store

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 14), count: 3)

    var body: some View {
        ZStack {
            Theme.background
            ScrollView {
                VStack(spacing: 16) {
                    Text(store.t("My Garden", "Bahçem"))
                        .font(.largeTitle.bold())
                        .foregroundStyle(Theme.deep)
                    Text(store.t("\(store.data.collectedFlowers.count) flowers bloomed · \(store.data.wordsFound) words found", "\(store.data.collectedFlowers.count) çiçek açtı · \(store.data.wordsFound) kelime bulundu"))
                        .font(.subheadline)
                        .foregroundStyle(Theme.deep.opacity(0.7))

                    LazyVGrid(columns: columns, spacing: 14) {
                        ForEach(FlowerCatalog.all) { flower in
                            let count = store.data.collectedFlowers.filter { $0 == flower.id }.count
                            VStack(spacing: 6) {
                                Text(flower.emoji)
                                    .font(.system(size: 48))
                                    .grayscale(count > 0 ? 0 : 1)
                                    .opacity(count > 0 ? 1 : 0.25)
                                Text(count > 0 ? flower.name(store.language) : "???")
                                    .font(.caption.bold())
                                    .foregroundStyle(Theme.deep)
                                if count > 1 {
                                    Text("×\(count)").font(.caption2).foregroundStyle(Theme.pink)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(RoundedRectangle(cornerRadius: 20).fill(Theme.card))
                        }
                    }
                }
                .padding(20)
            }
        }
        .presentationDragIndicator(.visible)
    }
}
