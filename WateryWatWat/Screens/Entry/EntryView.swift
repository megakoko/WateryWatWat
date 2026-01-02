import SwiftUI

struct EntryView: View {
    @State var viewModel: EntryViewModel
    @Environment(\.dismiss) private var dismiss
    
    private let gridSpacing: Double = 8

    var body: some View {
        VStack(spacing: 24) {
            datePicker
            volumeGrid
            customButton
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
        LazyVGrid(columns: [GridItem(.flexible(), spacing: gridSpacing), GridItem(.flexible(), spacing: gridSpacing), GridItem(.flexible(), spacing: gridSpacing)], spacing: gridSpacing) {
            ForEach(viewModel.availableVolumes, id: \.self) { volume in
                VolumeButton(
                    formattedValue: viewModel.formattedVolumeValue(for: volume),
                    unit: viewModel.volumeUnit,
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
            Text("form.custom".localized)
                .frame(maxWidth: .infinity)
                .padding()
                .background(viewModel.showCustomPicker ? Color.accentColor : Color.secondary.opacity(0.2))
                .foregroundStyle(viewModel.showCustomPicker ? .white : .primary)
                .clipShape(RoundedRectangle(cornerRadius: 8))
        }
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
