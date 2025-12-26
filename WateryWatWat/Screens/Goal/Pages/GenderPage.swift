import SwiftUI

struct GenderPage: View {
    @Binding var gender: Gender?

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Text("What is your gender?")
                .font(.title)

            HStack(spacing: 16) {
                ForEach([Gender.female, Gender.male], id: \.self) { value in
                    GoalChoiceSelectionButton(
                        icon: value.icon,
                        title: value.name,
                        value: value,
                        selection: $gender,
                        layout: .vertical
                    )
                }
            }

            Spacer()
        }
        .padding()
    }
}

#Preview {
    @Previewable @State var gender: Gender? = .male
    GenderPage(gender: $gender)
}
