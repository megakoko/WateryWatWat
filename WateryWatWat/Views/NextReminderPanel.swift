import SwiftUI

struct NextReminderPanel: View {
    let nextReminderTime: Date?
    let onAddReminder: () -> Void

    var body: some View {
        if let nextTime = nextReminderTime {
            Text(timeUntilReminder(nextTime))
                .font(.largeTitle)
                .frame(maxHeight: .infinity)
        } else {
            Button("Add Reminder", action: onAddReminder)
                .frame(maxHeight: .infinity)
        }
    }

    private func timeUntilReminder(_ time: Date) -> String {
        let interval = time.timeIntervalSince(Date())

        guard interval > 0 else {
            return "Soon"
        }

        let hours = Int(interval) / 3600
        let minutes = (Int(interval) % 3600) / 60

        if hours > 0 {
            return "in \(hours)h \(minutes)m"
        } else if minutes > 0 {
            return "in \(minutes)m"
        } else {
            return "in < 1m"
        }
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
