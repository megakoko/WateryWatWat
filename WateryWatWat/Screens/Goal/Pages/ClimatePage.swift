import SwiftUI

struct ClimatePage: View {
    @Binding var climate: Climate?

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Text("What is your typical climate?")
                .font(.title)
                .multilineTextAlignment(.center)

            VStack(spacing: 16) {
                ForEach([Climate.cold, Climate.warm, Climate.hot], id: \.self) { value in
                    GoalChoiceSelectionButton(
                        icon: value.icon,
                        title: value.name,
                        value: value,
                        selection: $climate
                    )
                }
            }

            Spacer()
        }
        .padding()
    }
}

#Preview {
    @Previewable @State var climate: Climate? = .warm
    ClimatePage(climate: $climate)
}
