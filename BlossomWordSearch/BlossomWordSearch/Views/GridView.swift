import SwiftUI

struct GridView: View {
    @Bindable var vm: GameViewModel
    var onWordFound: () -> Void
    var onWrong: () -> Void

    @State private var dragStart: GridPos?
    @State private var hintPulse = false

    var body: some View {
        GeometryReader { geo in
            let side = min(geo.size.width, geo.size.height)
            let cell = side / CGFloat(max(vm.level.rows, vm.level.cols))

            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: 20)
                    .fill(Theme.card)
                    .shadow(color: Theme.deep.opacity(0.08), radius: 10, y: 4)

                // Highlights for found words
                ForEach(Array(vm.found.values), id: \.answer) { word in
                    highlight(word.cells, cell: cell)
                        .stroke(Theme.wordColor(word.colorIndex).opacity(0.75),
                                style: StrokeStyle(lineWidth: cell * 0.78, lineCap: .round))
                        .transition(.opacity)
                }

                // Current drag
                if !vm.selection.isEmpty {
                    highlight(vm.selection, cell: cell)
                        .stroke(Theme.wordColor(vm.found.count).opacity(0.55),
                                style: StrokeStyle(lineWidth: cell * 0.78, lineCap: .round))
                }

                // Hinted first letters
                ForEach(Array(vm.hintedCells), id: \.self) { pos in
                    Circle()
                        .stroke(Theme.gold, lineWidth: 3)
                        .frame(width: cell * 0.8, height: cell * 0.8)
                        .scaleEffect(hintPulse ? 1.08 : 0.92)
                        .position(center(of: pos, cell: cell))
                }

                // Letters
                ForEach(0..<vm.level.rows, id: \.self) { r in
                    ForEach(0..<vm.level.cols, id: \.self) { c in
                        Text(String(vm.level.grid[r][c]))
                            .font(.system(size: cell * 0.5, weight: .semibold, design: .rounded))
                            .foregroundStyle(Theme.deep)
                            .frame(width: cell, height: cell)
                            .position(center(of: GridPos(r: r, c: c), cell: cell))
                    }
                }
            }
            .frame(width: side, height: side)
            .contentShape(Rectangle())
            .gesture(dragGesture(cell: cell))
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .aspectRatio(CGFloat(vm.level.cols) / CGFloat(vm.level.rows), contentMode: .fit)
        .onAppear {
            withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) { hintPulse = true }
        }
    }

    private func center(of pos: GridPos, cell: CGFloat) -> CGPoint {
        CGPoint(x: (CGFloat(pos.c) + 0.5) * cell, y: (CGFloat(pos.r) + 0.5) * cell)
    }

    private func highlight(_ cells: [GridPos], cell: CGFloat) -> Path {
        Path { p in
            guard let first = cells.first, let last = cells.last else { return }
            p.move(to: center(of: first, cell: cell))
            p.addLine(to: center(of: last, cell: cell))
        }
    }

    private func cellAt(_ point: CGPoint, cell: CGFloat) -> GridPos? {
        let r = Int(point.y / cell), c = Int(point.x / cell)
        guard r >= 0, r < vm.level.rows, c >= 0, c < vm.level.cols, point.x >= 0, point.y >= 0 else { return nil }
        return GridPos(r: r, c: c)
    }

    /// Snaps the finger position to the nearest of the 8 directions from the start cell.
    private func snappedEnd(from start: GridPos, to point: CGPoint, cell: CGFloat) -> GridPos {
        let origin = center(of: start, cell: cell)
        let dx = point.x - origin.x, dy = point.y - origin.y
        let distance = hypot(dx, dy)
        guard distance > cell * 0.4 else { return start }

        let octant = (atan2(dy, dx) / (.pi / 4)).rounded()
        let angle = octant * .pi / 4
        let dc = Int(cos(angle).rounded()), dr = Int(sin(angle).rounded())
        let step = (dr != 0 && dc != 0) ? cell * sqrt(2) : cell
        var length = Int((distance / step).rounded())

        func inBounds(_ n: Int) -> Bool {
            let r = start.r + dr * n, c = start.c + dc * n
            return r >= 0 && r < vm.level.rows && c >= 0 && c < vm.level.cols
        }
        while length > 0 && !inBounds(length) { length -= 1 }
        return GridPos(r: start.r + dr * length, c: start.c + dc * length)
    }

    private func dragGesture(cell: CGFloat) -> some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { value in
                if dragStart == nil {
                    dragStart = cellAt(value.startLocation, cell: cell)
                }
                guard let start = dragStart else { return }
                let end = snappedEnd(from: start, to: value.location, cell: cell)
                let newSelection = vm.line(from: start, to: end) ?? [start]
                if newSelection != vm.selection {
                    vm.selection = newSelection
                    Haptics.light()
                }
            }
            .onEnded { _ in
                dragStart = nil
                let hadSelection = vm.selection.count >= 2
                let success = withAnimation(.easeOut(duration: 0.25)) { vm.submitSelection() }
                if success { onWordFound() } else if hadSelection { onWrong() }
            }
    }
}
