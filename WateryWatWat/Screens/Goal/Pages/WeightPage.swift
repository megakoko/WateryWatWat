import SwiftUI

struct WeightPage: View {
    @Binding var weight: Int?
    @FocusState private var isWeightFocused: Bool

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Text("goal.weight.question".localized)
                .font(.title)

            TextField("0", value: $weight, format: .number)
                .font(.system(size: 60))
                .textFieldStyle(.plain)
                .keyboardType(.numberPad)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
                .focused($isWeightFocused)

            Spacer()
        }
        .padding()
        .onAppear {
            isWeightFocused = true
        }
    }
}

#Preview {
    @Previewable @State var weight: Int? = nil
    WeightPage(weight: $weight)
}
