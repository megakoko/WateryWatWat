import SwiftUI

struct HistoryView: View {
    @State var viewModel: HistoryViewModel

    var body: some View {
        List {
            ForEach(viewModel.groupedEntries) { group in
                Section {
                    ForEach(group.entries, id: \.objectID) { entry in
                        EntryRow(entry: entry)
                    }
                    .onDelete { indexSet in
                        deleteEntries(at: indexSet, in: group)
                    }
                } header: {
                    DateGroupHeader(date: group.date, totalVolume: group.totalVolume)
                }
            }
        }
        .navigationTitle("History")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await viewModel.onAppear()
        }
    }

    private func deleteEntries(at offsets: IndexSet, in group: GroupedHydrationEntries) {
        for index in offsets {
            let entry = group.entries[index]
            Task {
                await viewModel.deleteEntry(entry)
            }
        }
    }
}

#Preview {
    NavigationStack {
        HistoryView(viewModel: HistoryViewModel(service: MockHydrationService()))
    }
}
