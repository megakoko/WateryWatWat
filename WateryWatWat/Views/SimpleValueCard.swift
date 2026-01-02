import SwiftUI

struct SimpleValueCard: View {
    let title: String
    let value: String
    let periodDays: Int?
    let onTogglePeriod: (() -> Void)?

    init(title: String, value: String, periodDays: Int? = nil, onTogglePeriod: (() -> Void)? = nil) {
        self.title = title
        self.value = value
        self.periodDays = periodDays
        self.onTogglePeriod = onTogglePeriod
    }

    var body: some View {
        if let periodDays, let onTogglePeriod {
            CardPanel(title, content: content) {
                Button(action: onTogglePeriod) {
                    Text("period.days".localized(periodDays))
                        .animation(nil, value: periodDays)
                }
            }
        } else {
            CardPanel(title, content: content)
        }
    }
    
    private func content() -> some View {
        Text(value)
            .lineLimit(1)
            .font(.largeTitle)
    }
}

#Preview {
    SimpleValueCard(title: "Goal", value: "2.0 L")
        .padding()
}
