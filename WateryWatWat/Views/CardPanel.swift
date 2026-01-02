import SwiftUI

struct CardPanel<Content: View, TrailingButton: View>: View {
    let title: String?
    let content: Content
    let trailingButton: TrailingButton?
    let usePadding: Bool

    init(_ title: String? = nil, usePadding: Bool = true, @ViewBuilder content: () -> Content) where TrailingButton == EmptyView {
        self.title = title
        self.content = content()
        self.trailingButton = nil
        self.usePadding = usePadding
    }

    init(_ title: String? = nil, usePadding: Bool = true, @ViewBuilder content: () -> Content, @ViewBuilder trailingButton: () -> TrailingButton) {
        self.title = title
        self.content = content()
        self.trailingButton = trailingButton()
        self.usePadding = usePadding
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            if let title {
                HStack {
                    Text(title)
                        .textCase(.uppercase)
                        .lineLimit(1)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    trailingButton
                }
                .font(.caption)
                .padding(.horizontal)
            }

            if usePadding {
                content
                    .padding(.horizontal)
            } else {
                content
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, 10)
        .padding(.bottom, 8)
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    CardPanel("Title") {
        Text("Content")
            .font(.largeTitle)
    }
    .padding()
}
