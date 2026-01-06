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
                        .contextMenu {
                            Button("button.duplicate".localized, systemImage: "plus.square.on.square") {
                                viewModel.duplicateEntry(entry)
                            }
                            Button("button.delete".localized, systemImage: "trash", role: .destructive) {
                                viewModel.requestDelete(entry)
                            }
                        }
                        .swipeActions(edge: .trailing) {
                            Button("button.delete".localized, systemImage: "trash") {
                                viewModel.requestDelete(entry)
                            }
                            .tint(.red)
                        }
                        .swipeActions(edge: .leading) {
                            Button("button.duplicate".localized, systemImage: "plus.square.on.square") {
                                viewModel.duplicateEntry(entry)
                            }
                            .tint(.blue)
                        }
                    }
                } header: {
                    DateGroupHeader(date: group.date, formattedVolume: group.formattedTotalVolume)
                }
            }
        }
        .navigationTitle("navigation.history".localized)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(item: $viewModel.editEntryViewModel) { editEntryViewModel in
            NavigationStack {
                EntryView(viewModel: editEntryViewModel)
            }
        }
        .confirmationDialog("confirmation.deleteEntry.title".localized, isPresented: $viewModel.showDeleteConfirmation, presenting: viewModel.entryToDelete) { entry in
            Button("button.delete".localized, role: .destructive, action: viewModel.confirmDelete)
        } message: { entry in
            Text("confirmation.deleteEntry.message".localized(viewModel.formattedVolumeToDelete))
        }
        .task {
            await viewModel.onAppear()
        }
        .errorAlert($viewModel.error)
    }
}

#Preview {
    NavigationStack {
        HistoryView(viewModel: HistoryViewModel(service: MockHydrationService()))
    }
}
