import SwiftUI

struct NextReminderPanel: View {
    let nextReminderTime: Date?
    let onAddReminder: () -> Void

    var body: some View {
        if let nextTime = nextReminderTime {
            Text(timeUntilReminder(nextTime))
                .font(.largeTitle)
                .frame(maxHeight: .infinity)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        } else {
            Button("button.addReminder".localized, action: onAddReminder)
                .frame(maxHeight: .infinity)
        }
    }

    private func timeUntilReminder(_ time: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter.localizedString(for: time, relativeTo: Date())
    }
}

#Preview {
    VStack(spacing: 20) {
        NextReminderPanel(
            nextReminderTime: Calendar.current.date(byAdding: .minute, value: 45, to: Date()),
            onAddReminder: {}
        )

        NextReminderPanel(
            nextReminderTime: nil,
            onAddReminder: {}
        )
        
        Spacer()
    }
    .padding()
}
