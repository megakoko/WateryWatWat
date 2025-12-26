import SwiftUI

struct ActivityLevelPage: View {
    @Binding var activityLevel: ActivityLevel?

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Text("What is your daily activity level?")
                .font(.title)
                .multilineTextAlignment(.center)

            VStack(spacing: 16) {
                ForEach([ActivityLevel.low, ActivityLevel.moderate, ActivityLevel.high], id: \.self) { value in
                    GoalChoiceSelectionButton(
                        icon: value.icon,
                        title: value.name,
                        value: value,
                        selection: $activityLevel
                    )
                }
            }

            Spacer()
        }
        .padding()
    }
}

#Preview {
    @Previewable @State var activityLevel: ActivityLevel? = .moderate
    ActivityLevelPage(activityLevel: $activityLevel)
}
