import SwiftUI

struct AdditionalFactorsPage: View {
    @Binding var factors: AdditionalFactors

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Text("Any additional factors?")
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
                    )
                )

                GoalChoiceSelectionButton(
                    icon: AdditionalFactor.exercise.icon,
                    title: AdditionalFactor.exercise.name,
                    description: AdditionalFactor.exercise.description,
                    value: true,
                    selection: Binding(
                        get: { factors.exercise ? true : nil },
                        set: { factors.exercise = $0 ?? false }
                    )
                )
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
