import SwiftUI
import GovKitUI
import GovKit

struct TravelAlertsWidgetView: View {
    @StateObject var viewModel: TravelAlertsWidgetViewModel

    var body: some View {
        VStack(spacing: 16) {
            Group {
                switch viewModel.viewState {
                case .loading:
                    TravelAlertsLoadingView()
                case .loaded:
                    TravelAlertsLoadedView(onTapAction: {
                        viewModel.openCountryList()
                    })
                case .error:
                    TravelAlertsErrorView()
                }
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 16)
        }
        .task {
            await viewModel.viewDidAppear()
        }
        .sheet(
            isPresented: $viewModel.isShowingList,
            onDismiss: {
                viewModel.didDismissList()
            }, content: {
                NavigationView {
                    FollowCountryView(
                        viewModel: viewModel.followCountryViewModel
                    )
                }
            }
        )
    }
}

private struct TravelAlertsLoadedView: View {
    let onTapAction: () -> Void

    var body: some View {
        IconActionCardView(
            viewModel: IconActionCardViewModel(
                iconName: "plus.circle",
                title: String(localized: .Travel.followCountryWidgetTitle),
                description: String(localized: .Travel.followCountryWidgetDescription),
                action: onTapAction,
                contentPadding: 24,
                iconBottomPadding: 8
            )
        )
    }
}

private struct TravelAlertsLoadingView: View {
    var body: some View {
        ZStack {
            ProgressView()
                .frame(maxWidth: .infinity)
                .padding(.vertical, 86)
        }
        .background(Color(UIColor.govUK.fills.surfaceList))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

private struct TravelAlertsErrorView: View {
    var body: some View {
        ZStack {
            VStack(alignment: .center) {
                Image(systemName: "exclamationmark.circle")
                    .resizable()
                    .frame(width: 32, height: 32)
                    .padding(.bottom, 16)
                    .accessibilityHidden(true)
                    .foregroundStyle(Color(GOVUKColors.text.iconTertiary))
                Text("Error placeholder")
                    .padding(.bottom, 8)
                    .font(Font.govUK.bodySemibold)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(Color(GOVUKColors.text.primary))
                Text("Error message")
                    .font(Font.govUK.body)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(Color(UIColor.govUK.text.primary))
                Spacer()
            }
            .padding(.horizontal, 32)
            .padding(.top, 32)
        }
        .background(Color(UIColor.govUK.fills.surfaceList))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}
