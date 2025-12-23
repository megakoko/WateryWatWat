import SwiftUI

struct RemainingToGoalCard: View {
    let remaining: String

    var body: some View {
        CardPanel("Remaining") {
            Text(remaining)
                .font(.largeTitle)
        }
    }
}

#Preview {
    RemainingToGoalCard(remaining: "0,5 L")
        .padding()
}
