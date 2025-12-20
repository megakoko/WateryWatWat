import SwiftUI

struct DateGroupHeader: View {
    let date: Date
    let totalVolume: Int64

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
        Text("\(totalVolume.formattedLiters()) L")
            .font(.subheadline)
            .foregroundStyle(.secondary)
    }
}

#Preview {
    DateGroupHeader(date: Date(), totalVolume: 2500)
        .padding()
}
