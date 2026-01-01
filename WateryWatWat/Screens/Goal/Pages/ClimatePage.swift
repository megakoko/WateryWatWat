import SwiftUI

struct ClimatePage: View {
    @Binding var climate: Climate?
    @State private var maxIconWidth: CGFloat = 0

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Text("goal.climate.question".localized)
                .font(.title)
                .multilineTextAlignment(.center)

            VStack(spacing: 16) {
                ForEach([Climate.cold, Climate.warm, Climate.hot], id: \.self) { value in
                    GoalChoiceSelectionButton(
                        icon: value.icon,
                        title: value.name,
                        description: value.description,
                        value: value,
                        selection: $climate,
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
    @Previewable @State var climate: Climate? = .warm
    ClimatePage(climate: $climate)
}
