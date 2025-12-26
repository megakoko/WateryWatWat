import SwiftUI

struct ResultPage: View {
    @Binding var goal: Int64
    let formattedGoal: String

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 80))
                .foregroundStyle(.green)

            Text("Your Daily Goal")
                .font(.title)

            Text(formattedGoal)
                .font(.system(size: 60, weight: .bold))
                .foregroundStyle(Color.accentColor)

            GoalSlider(
                goal: $goal,
                minGoal: Constants.minGoalML,
                maxGoal: Constants.maxGoalML,
                step: Constants.stepGoalML
            )
            .padding(.horizontal)

            Text("Based on your profile, this is your recommended daily water intake")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)

            Spacer()
        }
        .padding()
    }
}

#Preview {
    @Previewable @State var goal: Int64 = 2000
    ResultPage(goal: $goal, formattedGoal: "2.0 L")
}
