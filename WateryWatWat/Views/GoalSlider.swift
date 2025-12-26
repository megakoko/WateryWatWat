import SwiftUI

struct GoalSlider: View {
    @Binding var goal: Int64
    let minGoal: Int64
    let maxGoal: Int64
    let step: Int64

    let volumeFormatter = VolumeFormatter(unit: .liters)

    var body: some View {
        Slider(
            value: Binding(
                get: { Double(goal) },
                set: { goal = Int64($0) }
            ),
            in: Double(minGoal)...Double(maxGoal),
            step: Double(step)
        ) {
            Text("Daily Goal")
        } minimumValueLabel: {
            Text(volumeFormatter.string(from: minGoal))
                .font(.caption)
                .monospacedDigit()
                .textCase(.uppercase)
        } maximumValueLabel: {
            Text(volumeFormatter.string(from: maxGoal))
                .font(.caption)
                .monospacedDigit()
                .textCase(.uppercase)
        }
    }
}

#Preview {
    @Previewable @State var goal: Int64 = 2000
    GoalSlider(goal: $goal, minGoal: 500, maxGoal: 5000, step: 100)
        .padding()
}
