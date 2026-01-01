import SwiftUI

struct ActivityLevelPage: View {
    @Binding var activityLevel: ActivityLevel?
    @State private var maxIconWidth: CGFloat = 0

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Text("goal.activityLevel.question".localized)
                .font(.title)
                .multilineTextAlignment(.center)

            VStack(spacing: 16) {
                ForEach([ActivityLevel.low, ActivityLevel.moderate, ActivityLevel.high], id: \.self) { value in
                    GoalChoiceSelectionButton(
                        icon: value.icon,
                        title: value.name,
                        description: value.description,
                        value: value,
                        selection: $activityLevel,
                        iconWidth: maxIconWidth
                    )
                }
            }
            .animation(nil, value: maxIconWidth)
            .onPreferenceChange(IconWidthPreferenceKey.self) { width in
                maxIconWidth = width
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
