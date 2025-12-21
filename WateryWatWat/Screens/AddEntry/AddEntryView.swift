import SwiftUI

struct AddEntryView: View {
    @State var viewModel: AddEntryViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 24) {
            datePicker
            volumeGrid
            customButton
            Spacer()
            if viewModel.showCustomPicker {
                customPicker
            }
            okButton
        }
        .padding()
        .navigationTitle(viewModel.isEditing ? "Edit Entry" : "Add Entry")
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
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
            ForEach(viewModel.availableVolumes, id: \.self) { volume in
                VolumeButton(
                    volume: volume,
                    isSelected: viewModel.selectedVolume == volume,
                    action: { viewModel.selectVolume(volume) }
                )
            }
        }
    }

    private var customButton: some View {
        Button {
            viewModel.selectCustom()
        } label: {
            Text("Custom")
                .frame(maxWidth: .infinity)
                .padding()
                .background(viewModel.showCustomPicker ? Color.accentColor : Color.secondary.opacity(0.2))
                .foregroundStyle(viewModel.showCustomPicker ? .white : .primary)
                .clipShape(RoundedRectangle(cornerRadius: 8))
        }
    }

    private var customPicker: some View {
        Picker("Volume", selection: $viewModel.customVolume) {
            ForEach(Array(stride(from: 100, through: 2000, by: 50)), id: \.self) { volume in
                Text("\(volume) ml").tag(Int64(volume))
            }
        }
        .pickerStyle(.wheel)
        .frame(height: 150)
    }

    private var okButton: some View {
        Button {
            Task {
                if viewModel.showCustomPicker {
                    viewModel.selectedVolume = viewModel.customVolume
                }
                await viewModel.confirm()
            }
        } label: {
            Text("OK")
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.borderedProminent)
        .disabled((viewModel.selectedVolume == nil && !viewModel.showCustomPicker) || viewModel.isLoading)
    }
}

#Preview {
    NavigationStack {
        AddEntryView(viewModel: AddEntryViewModel(service: MockHydrationService()))
    }
}
