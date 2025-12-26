import SwiftUI

struct IntroPage: View {
    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "drop.fill")
                .font(.system(size: 80))
                .foregroundStyle(.blue)

            Text("Set Your Daily Goal")
                .font(.title)

            Text("Answer a few questions to calculate your personalized daily water intake goal")
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
