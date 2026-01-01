import SwiftUI

struct IntroPage: View {
    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "drop.fill")
                .font(.system(size: 80))
                .foregroundStyle(Color.accent)

            Text("goal.intro.title".localized)
                .font(.title)

            Text("goal.intro.description".localized)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)

            Spacer()
        }
        .padding()
    }
}

#Preview {
    IntroPage()
}
