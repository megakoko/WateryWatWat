import SwiftUI

struct AverageIntakeCard: View {
    let average: Int64
    let periodDays: Int
    let onTogglePeriod: () -> Void

    var body: some View {
        CardPanel("Average") {
            Text(average.formattedLiters() + " L")
                .font(.largeTitle)
        } trailingButton: {
            Button("\(periodDays)d", action: onTogglePeriod)
                .font(.subheadline)
        }
    }
}

#Preview {
    AverageIntakeCard(average: 1800, periodDays: 7, onTogglePeriod: {})
        .padding()
}
