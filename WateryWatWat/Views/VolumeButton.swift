import SwiftUI

struct VolumeButton: View {
    let volume: Int64
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 0) {
                Text("\(volume)")
                    .font(.title)
                Text("ml")
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
        VolumeButton(volume: 250, isSelected: false, action: {})
        VolumeButton(volume: 500, isSelected: true, action: {})
    }
    .padding()
}
