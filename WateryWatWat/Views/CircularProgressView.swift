import SwiftUI

struct CircularProgressView: View {
    let progress: Double
    let current: Int64
    let goal: Int64

    private var cappedProgress: Double {
        min(progress, 1.0)
    }

    var body: some View {
        let lineWidth: CGFloat = 25

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

            VStack(spacing: 8) {
                Text(current.formattedLiters())
                    .font(.system(size: 60, weight: .bold))
                Text("L")
                    .font(.title)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

#Preview {
    CircularProgressView(progress: 0.65, current: 1300, goal: 2000)
        .frame(height: 300)
        .padding()
}
