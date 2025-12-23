import SwiftUI

struct AverageIntakeCard: View {
    let average: String
    let periodDays: Int
    let onTogglePeriod: () -> Void

    var body: some View {
        CardPanel("Average") {
            Text(average)
                .font(.largeTitle)
        } trailingButton: {
            Button("\(periodDays)d", action: onTogglePeriod)
                .font(.subheadline)
        }
    }
}

#Preview {
    AverageIntakeCard(average: "1,8 L", periodDays: 7, onTogglePeriod: {})
        .padding()
}
