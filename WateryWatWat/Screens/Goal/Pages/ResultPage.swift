import SwiftUI

struct ResultPage: View {
    @Binding var goal: Int64
    let formattedGoal: String

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Text("Your Daily Goal")
                .font(.title)

            Text(formattedGoal)
                .font(.system(size: 60, weight: .bold))
                .foregroundStyle(Color.accentColor)

            Text("Based on your profile, this is your recommended daily water intake")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)

            GoalSlider(
                goal: $goal,
                minGoal: Constants.minGoalML,
                maxGoal: Constants.maxGoalML,
                step: Constants.stepGoalML
            )
            .padding(.horizontal)

            Text("You can adjust this to fit your needs")
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
