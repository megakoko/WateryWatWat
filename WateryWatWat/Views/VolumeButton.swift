import SwiftUI

struct VolumeButton: View {
    let formattedValue: String
    let unit: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 0) {
                Text(formattedValue)
                    .font(.title)
                Text(unit)
                    .font(.caption)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 100)
            .background(isSelected ? Color.accentColor : Color.secondary.opacity(0.2))
            .foregroundStyle(isSelected ? .white : .primary)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    VStack {
        VolumeButton(formattedValue: "250", unit: "ml", isSelected: false, action: {})
        VolumeButton(formattedValue: "500", unit: "ml", isSelected: true, action: {})
    }
    .padding()
}
