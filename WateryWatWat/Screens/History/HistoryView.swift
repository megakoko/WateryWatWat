import SwiftUI

struct HistoryView: View {
    @State var viewModel: HistoryViewModel

    var body: some View {
        List {
            ForEach(viewModel.groupedEntries) { group in
                Section {
                    ForEach(group.entries, id: \.objectID) { entry in
                        Button {
                            viewModel.onDidTap(entry)
                        } label: {
                            EntryRow(entry: entry)
                        }
                        .buttonStyle(.plain)
                    }
                    .onDelete { indexSet in
                        deleteEntries(at: indexSet, in: group)
                    }
                } header: {
                    DateGroupHeader(date: group.date, formattedVolume: group.formattedTotalVolume)
                }
            }
        }
        .navigationTitle("History")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(item: $viewModel.editEntryViewModel) { editEntryViewModel in
            NavigationStack {
                AddEntryView(viewModel: editEntryViewModel)
            }
        }
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
