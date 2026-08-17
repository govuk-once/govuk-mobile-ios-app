import SwiftUI
import GovKitUI
import GovKit

struct TravelTopicWidgetView: View {
    @StateObject var viewModel: TravelTopicWidgetViewModel
    @State var isShowingCountryList: Bool = false

    var body: some View {
        VStack(spacing: 16) {
            switch viewModel.viewState {
            case .loading:
                loadingView
            case .loaded:
                emptyCountryListView
            case .error:
                Text("THERE IS AN ERROR")
            }
        }
        .task {
            await viewModel.viewDidAppear()
        }
        .sheet(
            isPresented: $isShowingCountryList,
            onDismiss: {
                viewModel.didDismissList()
                viewModel.isShowingList = false
            }, content: {
                NavigationView {
                    FollowCountryView(
                        viewModel: FollowCountryViewModel(
                            dismissAction: {
                                viewModel.didDismissList()
                                isShowingCountryList = false
                            }
                        )
                    )
                }
            }
        )
    }

    private var loadingView: some View {
        ZStack {
            ProgressView()
                .frame(maxWidth: .infinity)
                .padding(.vertical, 86)
        }
        .background(Color(UIColor.govUK.fills.surfaceList))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .padding(.horizontal, 16)
    }

    private var emptyCountryListView: some View {
        IconActionCardView(
            viewModel: IconActionCardViewModel(
                iconName: "plus.circle",
                title: String(localized: .Travel.followCountryWidgetTitle),
                description: String(localized: .Travel.followCountryWidgetDescription),
                action: {
                    viewModel.openCountryList()
                    isShowingCountryList.toggle()
                },
                contentPadding: 24,
                iconBottomPadding: 8
            )
        )
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
    }
}
