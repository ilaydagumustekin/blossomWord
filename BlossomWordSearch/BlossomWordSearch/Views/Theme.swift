import SwiftUI
import UIKit

enum Theme {
    static let bgTop = Color(red: 1.0, green: 0.93, blue: 0.95)
    static let bgBottom = Color(red: 0.94, green: 0.90, blue: 1.0)
    static let pink = Color(red: 0.93, green: 0.42, blue: 0.60)
    static let deep = Color(red: 0.42, green: 0.20, blue: 0.38)
    static let leaf = Color(red: 0.45, green: 0.72, blue: 0.50)
    static let gold = Color(red: 0.98, green: 0.74, blue: 0.25)
    static let card = Color.white.opacity(0.85)

    static let wordColors: [Color] = [
        Color(red: 0.98, green: 0.60, blue: 0.72),
        Color(red: 0.70, green: 0.62, blue: 0.95),
        Color(red: 0.55, green: 0.82, blue: 0.62),
        Color(red: 0.99, green: 0.76, blue: 0.45),
        Color(red: 0.52, green: 0.78, blue: 0.95),
        Color(red: 0.95, green: 0.55, blue: 0.50),
        Color(red: 0.80, green: 0.65, blue: 0.85),
        Color(red: 0.60, green: 0.85, blue: 0.80),
    ]

    static func wordColor(_ index: Int) -> Color { wordColors[index % wordColors.count] }

    static var background: some View {
        LinearGradient(colors: [bgTop, bgBottom], startPoint: .top, endPoint: .bottom)
            .ignoresSafeArea()
    }
}

enum Haptics {
    static func light() { UIImpactFeedbackGenerator(style: .light).impactOccurred() }
    static func success() { UINotificationFeedbackGenerator().notificationOccurred(.success) }
    static func error() { UINotificationFeedbackGenerator().notificationOccurred(.error) }
}

struct CoinBadge: View {
    let coins: Int

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: "circle.fill")
                .foregroundStyle(Theme.gold)
                .overlay(Text("$").font(.caption2.bold()).foregroundStyle(.white))
            Text("\(coins)")
                .font(.headline.monospacedDigit())
                .foregroundStyle(Theme.deep)
                .contentTransition(.numericText())
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(Capsule().fill(Theme.card))
        .animation(.snappy, value: coins)
    }
}

struct BlossomButtonStyle: ButtonStyle {
    var color: Color = Theme.pink

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.title3.bold())
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(RoundedRectangle(cornerRadius: 22).fill(color.gradient))
            .shadow(color: color.opacity(0.35), radius: 8, y: 4)
            .scaleEffect(configuration.isPressed ? 0.96 : 1)
            .animation(.snappy(duration: 0.15), value: configuration.isPressed)
    }
}

/// Wraps children onto multiple centered rows.
struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    private func rows(for subviews: Subviews, maxWidth: CGFloat) -> [[(Int, CGSize)]] {
        var rows: [[(Int, CGSize)]] = [[]]
        var x: CGFloat = 0
        for (i, sub) in subviews.enumerated() {
            let size = sub.sizeThatFits(.unspecified)
            if x + size.width > maxWidth, !rows[rows.count - 1].isEmpty {
                rows.append([])
                x = 0
            }
            rows[rows.count - 1].append((i, size))
            x += size.width + spacing
        }
        return rows
    }

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let maxWidth = proposal.width ?? .infinity
        let rows = rows(for: subviews, maxWidth: maxWidth)
        var height: CGFloat = 0
        var width: CGFloat = 0
        for row in rows {
            let rowWidth = row.reduce(0) { $0 + $1.1.width } + spacing * CGFloat(max(0, row.count - 1))
            width = max(width, rowWidth)
            height += (row.map(\.1.height).max() ?? 0)
        }
        height += spacing * CGFloat(max(0, rows.count - 1))
        return CGSize(width: proposal.width ?? width, height: height)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var y = bounds.minY
        for row in rows(for: subviews, maxWidth: bounds.width) {
            let rowWidth = row.reduce(0) { $0 + $1.1.width } + spacing * CGFloat(max(0, row.count - 1))
            let rowHeight = row.map(\.1.height).max() ?? 0
            var x = bounds.minX + (bounds.width - rowWidth) / 2
            for (i, size) in row {
                subviews[i].place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize(size))
                x += size.width + spacing
            }
            y += rowHeight + spacing
        }
    }
}
