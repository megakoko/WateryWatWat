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
            Button("\(periodDays)d", action: onTogglePeriod)
                .font(.subheadline)
        }
    }
}

#Preview {
    GoalHitRateCard(hitRate: 85, periodDays: 7, onTogglePeriod: {})
        .padding()
}
