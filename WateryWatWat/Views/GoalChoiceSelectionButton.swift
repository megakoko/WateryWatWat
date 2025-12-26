import SwiftUI

struct IconWidthPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
}

struct GoalChoiceSelectionButton<Value: Equatable>: View {
    let icon: String
    let title: String
    let description: String?
    let value: Value
    @Binding var selection: Value?
    var layout: Layout = .horizontal
    var iconWidth: CGFloat? = nil

    var body: some View {
        Button {
            if selection == value {
                selection = nil
            } else {
                selection = value
            }
        } label: {
            content
                .frame(maxWidth: .infinity)
                .padding()
                .background {
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(selection == value ? Color.accent : .gray.opacity(0.4), lineWidth: 2)
                }
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private var content: some View {
        switch layout {
        case .horizontal:
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.title)
                    .frame(minWidth: iconWidth, alignment: .center)
                    .background(GeometryReader { geo in
                        Color.clear.preference(key: IconWidthPreferenceKey.self, value: geo.size.width)
                    })

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    if let description {
                        Text(description)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        case .vertical:
            VStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.largeTitle)
                Text(title)
            }
            .frame(height: 140)
        }
    }
}

extension GoalChoiceSelectionButton {
    enum Layout {
        case horizontal
        case vertical
    }
}

#Preview {
    @Previewable @State var selection: String? = "low"
    @Previewable @State var gender: Gender? = nil

    VStack {
        GoalChoiceSelectionButton(
            icon: "figure.walk",
            title: "Low",
            description: "Sedentary",
            value: "low",
            selection: $selection
        )

        GoalChoiceSelectionButton(
            icon: "figure.run",
            title: "High",
            description: "Intense exercise",
            value: "high",
            selection: $selection
        )

        Spacer()

        HStack(spacing: 16) {
            GoalChoiceSelectionButton(
                icon: "figure.dress.line.vertical.figure",
                title: "Female",
                description: nil,
                value: Gender.female,
                selection: $gender,
                layout: .vertical
            )

            GoalChoiceSelectionButton(
                icon: "figure.arms.open",
                title: "Male",
                description: nil,
                value: Gender.male,
                selection: $gender,
                layout: .vertical
            )
        }

        Spacer()
    }
    .padding()
}
