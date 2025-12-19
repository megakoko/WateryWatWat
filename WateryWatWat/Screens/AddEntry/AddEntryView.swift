import SwiftUI

struct AddEntryView: View {
    @State var viewModel: AddEntryViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 24) {
            datePicker
            volumeGrid
            okButton
        }
        .padding()
        .navigationTitle("Add Entry")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            viewModel.onEntryAdded = {
                dismiss()
            }
        }
    }

    private var datePicker: some View {
        DatePicker("Date", selection: $viewModel.selectedDate, displayedComponents: [.date, .hourAndMinute])
            .datePickerStyle(.compact)
    }

    private var volumeGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
            ForEach(viewModel.availableVolumes, id: \.self) { volume in
                VolumeButton(
                    volume: volume,
                    isSelected: viewModel.selectedVolume == volume,
                    action: { viewModel.selectVolume(volume) }
                )
            }
        }
    }

    private var okButton: some View {
        Button {
            Task {
                await viewModel.confirm()
            }
        } label: {
            Text("OK")
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.borderedProminent)
        .disabled(viewModel.selectedVolume == nil || viewModel.isLoading)
    }
}

#Preview {
    NavigationStack {
        AddEntryView(viewModel: AddEntryViewModel(service: MockHydrationService()))
    }
}
