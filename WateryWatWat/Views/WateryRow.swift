import SwiftUI

struct WateryRow<Leading: View, Trailing: View>: View {
    @Environment(\.sizeCategory) private var sizeCategory

    let leading: Leading
    let trailing: Trailing?

    init(@ViewBuilder leading: () -> Leading, @ViewBuilder trailing: () -> Trailing) {
        self.leading = leading()
        self.trailing = trailing()
    }

    init(@ViewBuilder content: () -> Leading) where Trailing == EmptyView {
        self.leading = content()
        self.trailing = nil
    }

    var body: some View {
        if let trailing {
            if sizeCategory.isAccessibilityCategory {
                GridRow {
                    leading
                        .gridCellColumns(2)
                }
                GridRow {
                    trailing
                        .gridCellColumns(2)
                }
            } else {
                GridRow {
                    leading
                    trailing
                }
            }
        } else {
            GridRow {
                leading
                    .gridCellColumns(2)
            }
        }
    }
}
