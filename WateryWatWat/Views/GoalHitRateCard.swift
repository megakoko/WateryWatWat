import SwiftUI

struct GoalHitRateCard: View {
    let hitRate: Int
    let periodDays: Int
    let onTogglePeriod: () -> Void

    var body: some View {
        CardPanel("Goal Hit") {
            Text("\(hitRate)%")
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
    GoalHitRateCard(hitRate: 85, periodDays: 7, onTogglePeriod: {})
        .padding()
}
