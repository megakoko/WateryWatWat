import SwiftUI

struct WeightPage: View {
    @Binding var weight: Int?
    @FocusState private var isWeightFocused: Bool

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Text("What is your weight?")
                .font(.title)

            TextField("Weight (kg)", value: $weight, format: .number)
                .textFieldStyle(.roundedBorder)
                .keyboardType(.numberPad)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 200)
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
    @Previewable @State var weight: Int? = 70
    WeightPage(weight: $weight)
}
