import SwiftUI

struct NextReminderPanel: View {
    let nextReminderTime: Date?
    let onAddReminder: () -> Void

    var body: some View {
        if let nextTime = nextReminderTime {
            activeReminderView(nextTime)
        } else {
            inactiveReminderView
        }
    }
}

private extension NextReminderPanel {
    func activeReminderView(_ time: Date) -> some View {
        CardPanel("Next Reminder") {
            Text(timeUntilReminder(time))
                .font(.title)
        }
    }

    var inactiveReminderView: some View {
        CardPanel("Drink Reminders") {
            Button("Add Reminder", action: onAddReminder)
                .font(.title3)
        }
    }

    func timeUntilReminder(_ time: Date) -> String {
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
    }
    .padding()
}
