import SwiftUI

struct GoalChoiceSelectionButton<Value: Equatable>: View {
    let icon: String?
    let title: String
    let value: Value
    @Binding var selection: Value?
    var layout: Layout = .horizontal

    var body: some View {
        Button {
            selection = value
        } label: {
            content
                .frame(maxWidth: .infinity)
                .padding()
                .background {
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(selection == value ? Color.accent : .gray.opacity(0.4), lineWidth: 2)
                }
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private var content: some View {
        switch layout {
        case .horizontal:
            HStack(spacing: 12) {
                if let icon {
                    Image(systemName: icon)
                        .font(.title)
                }
                Text(title)
                    .frame(maxWidth: .infinity, alignment: icon == nil ? .center : .leading)
            }
        case .vertical:
            VStack(spacing: 12) {
                if let icon {
                    Image(systemName: icon)
                        .font(.largeTitle)
                }
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
            value: "low",
            selection: $selection
        )
        
        GoalChoiceSelectionButton(
            icon: "figure.run",
            title: "High",
            value: "high",
            selection: $selection
        )
        
        Spacer()

        HStack(spacing: 16) {
            GoalChoiceSelectionButton(
                icon: "figure.dress.line.vertical.figure",
                title: "Female",
                value: Gender.female,
                selection: $gender,
                layout: .vertical
            )

            GoalChoiceSelectionButton(
                icon: "figure.arms.open",
                title: "Male",
                value: Gender.male,
                selection: $gender,
                layout: .vertical
            )
        }
        
        Spacer()
    }
    .padding()
}
