import SwiftUI

struct RemainingToGoalCard: View {
    let remaining: Int64

    var body: some View {
        CardPanel("Remaining") {
            Text(remaining.formattedLiters() + " L")
                .font(.largeTitle)
        }
    }
}

#Preview {
    RemainingToGoalCard(remaining: 500)
        .padding()
}
