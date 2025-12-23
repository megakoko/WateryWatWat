import SwiftUI

struct CircularProgressView: View {
    let progress: Double
    let formattedValue: String
    let symbol: String
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
                .shadow(color: .aquaBlue.opacity(0.6), radius: lineWidth * 0.2, x: 0, y: 0)
                .shadow(color: .aquaBlue.opacity(0.3), radius: lineWidth * 0.8, x: 0, y: 0)

            HStack(alignment: .firstTextBaseline, spacing: 0) {
                Text(formattedValue)

                Text(symbol)
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
    CircularProgressView(progress: 0.65, formattedValue: "1.3", symbol: "L", font: .system(size: 60, weight: .bold), lineWidth: 25)
        .frame(height: 300)
        .padding()
}

private struct UnitWidthKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}
