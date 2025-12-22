import SwiftUI

struct CircularProgressView: View {
    let progress: Double
    let current: Int64
    let goal: Int64
    let font: Font
    let lineWidth: CGFloat

    @State private var unitWidth: CGFloat = 0

    private var cappedProgress: Double {
        min(progress, 1.0)
    }

    var body: some View {

        ZStack {
            Circle()
                .stroke(.gray.opacity(0.2), lineWidth: lineWidth)

            Circle()
                .trim(from: 0, to: cappedProgress)
                .stroke(Color.aquaBlue, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut, value: cappedProgress)
                .shadow(color: .aquaBlue.opacity(0.6), radius: 10, x: 0, y: 0)
                .shadow(color: .aquaBlue.opacity(0.3), radius: 20, x: 0, y: 0)

            HStack(alignment: .firstTextBaseline, spacing: 0) {
                Text(current.formattedLiters())

                Text(" L")
                    .foregroundStyle(.secondary)
                    .background(
                        GeometryReader { geo in
                            Color.clear.preference(key: UnitWidthKey.self, value: geo.size.width)
                        }
                    )
            }
            .font(font)
            .onPreferenceChange(UnitWidthKey.self) { width in
                unitWidth = width
            }
            .offset(x: unitWidth / 2)
        }
    }
}

#Preview {
    CircularProgressView(progress: 0.65, current: 1300, goal: 2000, font: .system(size: 60, weight: .bold), lineWidth: 25)
        .frame(height: 300)
        .padding()
}

private struct UnitWidthKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}
