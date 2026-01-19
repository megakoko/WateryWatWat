import SwiftUI

struct EntryView: View {
    @State var viewModel: EntryViewModel
    @Environment(\.dismiss) private var dismiss
    
    private let gridSpacing: Double = 8

    var body: some View {
        VStack(spacing: 24) {
            datePicker
            volumeGrid
            if viewModel.showCustomPicker {
                customPicker
            }
            Spacer()
        }
        .padding()
        .navigationTitle(viewModel.isEditing ? "navigation.editEntry".localized : "navigation.addEntry".localized)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("button.cancel".localized, systemImage: "xmark", role: .cancel, action: viewModel.cancel)
            }
            
            ToolbarItem(placement: .confirmationAction) {
                Button("button.done".localized, systemImage: "checkmark", role: .confirm, action: viewModel.confirmWithCustom)
                    .disabled(!viewModel.canConfirm)
            }
        }
        .onAppear {
            viewModel.onEntryAdded = {
                dismiss()
            }
        }
        .errorAlert($viewModel.error)
    }

    private var datePicker: some View {
        DatePicker("form.date".localized, selection: $viewModel.selectedDate, displayedComponents: [.date, .hourAndMinute])
            .datePickerStyle(.compact)
    }

    private var volumeGrid: some View {
        Grid(horizontalSpacing: gridSpacing, verticalSpacing: gridSpacing) {
            ForEach(viewModel.volumeRows, id: \.self) { row in
                GridRow {
                    ForEach(row, id: \.self) { volume in
                        VolumeButton(
                            formattedValue: viewModel.formattedVolumeValue(for: volume),
                            unit: viewModel.volumeUnit,
                            isSelected: viewModel.selectedVolume == volume,
                            action: { viewModel.selectVolume(volume) }
                        )
                    }
                }
            }
            GridRow {
                customButton.gridCellColumns(3)
            }
        }
    }

    private var customButton: some View {
        Button(action: viewModel.selectCustom) {
            Text("form.custom".localized)
                .font(.title)
                .frame(maxWidth: .infinity)
                .padding(.vertical)
                .background(viewModel.showCustomPicker ? Color.accentColor : Color.secondary.opacity(0.2))
                .foregroundStyle(viewModel.showCustomPicker ? .white : .primary)
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
    }

    private var customPicker: some View {
        Picker("form.volume".localized, selection: $viewModel.customVolume) {
            ForEach(Array(stride(from: 100, through: 2000, by: 50)), id: \.self) { volume in
                Text(viewModel.formattedVolume(for: volume)).tag(Int64(volume))
            }
        }
        .pickerStyle(.wheel)
        .frame(height: 200)
    }
}

#Preview {
    NavigationStack {
        EntryView(viewModel: EntryViewModel(service: MockHydrationService()))
    }
}
