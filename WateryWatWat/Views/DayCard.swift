import SwiftUI

struct DayCard: View {
    let date: Date
    let formattedVolume: String

    var body: some View {
        VStack(spacing: 0) {
            monthText
            dayText
            Spacer(minLength: 8)
            volumeText
        }
        .padding(.vertical, 8)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    private var weekdayText: some View {
        Text(date, format: .dateTime.weekday(.abbreviated).locale(Locale(identifier: "en_US")))
            .font(.caption)
            .textCase(.uppercase)
            .foregroundStyle(.secondary)
    }

    private var dayText: some View {
        Text(date, format: .dateTime.day())
            .font(.title2)
            .fontWeight(.bold)
    }

    private var monthText: some View {
        Text(date, format: .dateTime.month(.abbreviated))
            .font(.caption)
            .foregroundStyle(.secondary)
    }

    private var volumeText: some View {
        Text(formattedVolume)
            .font(.caption)
            .fontWeight(.semibold)
            .textCase(.uppercase)
    }
}

#Preview {
    DayCard(date: Date(), formattedVolume: "0.9 L")
        .padding()
}
