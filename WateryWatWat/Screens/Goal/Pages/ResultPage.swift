import SwiftUI

struct ResultPage: View {
    @Binding var goal: Int64
    let formattedGoal: String

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Text("goal.result.title".localized)
                .font(.title)

            Text(formattedGoal)
                .font(.system(size: 60, weight: .bold).monospacedDigit())
                .foregroundStyle(Color.accentColor)
                .textCase(.uppercase)

            Text("goal.result.description".localized)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)

            GoalSlider(
                goal: $goal,
                minGoal: Constants.minGoalML,
                maxGoal: Constants.maxGoalML,
                step: Constants.stepGoalML
            )
            .padding(.horizontal)

            Text("goal.result.hint".localized)
                .font(.caption)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)

            Spacer()
        }
        .padding()
    }
}

#Preview {
    @Previewable @State var goal: Int64 = 2000
    ResultPage(goal: $goal, formattedGoal: "\(Double(goal)/1000) L")
}
