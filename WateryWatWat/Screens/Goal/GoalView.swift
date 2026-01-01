import SwiftUI

struct GoalView: View {
    @State var viewModel: GoalViewModel
    @Environment(\.dismiss) private var dismiss
    
    private var currentPageTransition: AnyTransition {
        viewModel.navigatingForward ? .push(from: .trailing) : .push(from: .leading)
    }

    var body: some View {
        VStack(spacing: 0) {
            currentPageView
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .transition(currentPageTransition)
            
            bottomButton
        }
        .navigationTitle("Daily Goal")
        .navigationBarTitleDisplayMode(.inline)
    }

    @ViewBuilder
    private var currentPageView: some View {
        switch viewModel.currentPage {
        case .intro:
            IntroPage()
        case .weight:
            WeightPage(weight: $viewModel.data.weight)
        case .gender:
            GenderPage(gender: $viewModel.data.gender)
        case .activity:
            ActivityLevelPage(activityLevel: $viewModel.data.activityLevel)
        case .climate:
            ClimatePage(climate: $viewModel.data.climate)
        case .factors:
            AdditionalFactorsPage(factors: $viewModel.data.additionalFactors)
        case .result:
            ResultPage(goal: $viewModel.adjustedGoal, formattedGoal: viewModel.formattedGoal)
        }
    }

    private var bottomButton: some View {
        HStack(spacing: 16) {
            if viewModel.currentPage != .intro {
                Button(action: viewModel.previousPage) {
                    Image(systemName: "chevron.left")
                        .padding(.vertical, 6)
                }
                .buttonStyle(.bordered)
                .bold()
            }

            Button(action: viewModel.nextPage) {
                Text(viewModel.currentPage == .result ? "Done" : "Next")
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 6)
            }
            .buttonStyle(.borderedProminent)
            .disabled(!viewModel.canGoNext)
            .bold()
        }
        .padding()
    }
}

#Preview {
    NavigationStack {
        GoalView(viewModel: GoalViewModel(settingsService: MockSettingsService()))
    }
}
