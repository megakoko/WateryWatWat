import SwiftUI

struct AdditionalFactorsPage: View {
    @Binding var factors: AdditionalFactors
    @State private var maxIconWidth: CGFloat = 0

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Text("goal.additionalFactors.question".localized)
                .font(.title)
                .multilineTextAlignment(.center)

            VStack(spacing: 16) {
                GoalChoiceSelectionButton(
                    icon: AdditionalFactor.coffee.icon,
                    title: AdditionalFactor.coffee.name,
                    description: AdditionalFactor.coffee.description,
                    value: true,
                    selection: Binding(
                        get: { factors.coffee ? true : nil },
                        set: { factors.coffee = $0 ?? false }
                    ),
                    iconWidth: maxIconWidth
                )

                GoalChoiceSelectionButton(
                    icon: AdditionalFactor.exercise.icon,
                    title: AdditionalFactor.exercise.name,
                    description: AdditionalFactor.exercise.description,
                    value: true,
                    selection: Binding(
                        get: { factors.exercise ? true : nil },
                        set: { factors.exercise = $0 ?? false }
                    ),
                    iconWidth: maxIconWidth
                )
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
    @Previewable @State var factors = AdditionalFactors(coffee: true, exercise: false)
    AdditionalFactorsPage(factors: $factors)
}
