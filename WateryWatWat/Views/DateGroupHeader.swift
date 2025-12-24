import SwiftUI

struct DateGroupHeader: View {
    let date: Date
    let formattedVolume: String

    var body: some View {
        HStack {
            dateText
            Spacer()
            volumeText
        }
    }

    private var dateText: some View {
        Text(date, format: .dateTime.month().day().weekday(.wide))
            .font(.headline)
    }

    private var volumeText: some View {
        Text(formattedVolume)
            .font(.subheadline)
            .foregroundStyle(.secondary)
            .textCase(.uppercase)
    }
}

#Preview {
    DateGroupHeader(date: Date(), formattedVolume: "2.5 L")
        .padding()
}
