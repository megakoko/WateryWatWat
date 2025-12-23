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
            Button(action: onTogglePeriod) {
                Text("\(periodDays)d")
                    .animation(nil, value: periodDays)
            }
        }
    }
}

#Preview {
    AverageIntakeCard(average: "1,8 L", periodDays: 7, onTogglePeriod: {})
        .padding()
}
