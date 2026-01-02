import SwiftUI

struct CircularProgressView: View {
    let progress: Double
    let formattedValue: String
    let symbol: String
    let unitPosition: UnitPosition
    let font: Font
    let lineWidth: CGFloat
    let color: Color

    @State private var unitWidth: CGFloat = 0
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(.gray.opacity(0.2), lineWidth: lineWidth)

            Circle()
                .trim(from: 0, to: cappedProgress)
                .stroke(color, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .shadow(color: color.opacity(0.6), radius: lineWidth * 0.2, x: 0, y: 0)
                .shadow(color: color.opacity(0.3), radius: lineWidth * 0.8, x: 0, y: 0)

            labelView
        }
    }
    
    private var cappedProgress: Double {
        min(progress, 1.0)
    }

    private var valueView: some View {
        Text(formattedValue)
    }

    private var unitView: some View {
        Text(symbol)
            .foregroundStyle(.secondary)
            .textCase(.uppercase)
            .background(
                GeometryReader { geo in
                    Color.clear.preference(key: UnitWidthKey.self, value: geo.size.width)
                }
            )
    }

    private var labelView: some View {
        HStack(alignment: .firstTextBaseline, spacing: 0) {
            if unitPosition == .beforeValue {
                unitView
                valueView
            } else {
                valueView
                unitView
            }
        }
        .font(font)
        .onPreferenceChange(UnitWidthKey.self) { width in
            unitWidth = width
        }
        .offset(x: unitPosition == .beforeValue ? -unitWidth / 2 : unitWidth / 2)
    }
}

#Preview {
    CircularProgressView(progress: 0.65, formattedValue: "1.3", symbol: "L", unitPosition: .afterValue, font: .system(size: 60, weight: .bold), lineWidth: 25, color: .accentColor)
        .frame(height: 300)
        .padding()
}

private struct UnitWidthKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}
