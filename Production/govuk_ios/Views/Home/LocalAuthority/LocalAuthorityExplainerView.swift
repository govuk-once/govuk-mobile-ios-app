import SwiftUI
import GovKit
import GovKitUI

struct LocalAuthorityExplainerView: View {
    private var viewModel: LocalAuthorityExplainerViewModel
    @Environment(\.verticalSizeClass) var verticalSizeClass

    init(viewModel: LocalAuthorityExplainerViewModel) {
        self.viewModel = viewModel
    }
    var body: some View {
        ZStack {
            Color(uiColor: .govUK.fills.surfaceModal)
            VStack {
                GeometryReader { geometry in
                    ScrollView {
                        VStack {
                            if verticalSizeClass != .compact {
                                Image(decorative: "your_local_services")
                                    .padding(.bottom, 26)
                            }
                            Text(viewModel.explainerViewTitle)
                                .foregroundColor(Color(UIColor.govUK.text.primary))
                                .font(Font.govUK.largeTitleBold)
                                .multilineTextAlignment(.center)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding([.horizontal], 16)
                                .padding(.bottom, 4)
                                .accessibilityAddTraits(.isHeader)
                            Text(viewModel.explainerViewDescription)
                                .font(Font.govUK.body)
                                .foregroundColor(Color(UIColor.govUK.text.primary))
                                .padding([.horizontal], 16)
                                .multilineTextAlignment(.center)
                        }
                        .frame(width: geometry.size.width,
                               height: geometry.size.height)
                        .accessibilityElement(children: .contain)
                    }
                }
                PrimaryButtonView(
                    viewModel: viewModel.primaryButtonViewModel
                )
                .padding(.bottom, 16)
            }
            .toolbar {
                cancelButton
            }
            .toolbarBackground(
                Color(uiColor: .govUK.fills.surfaceModal),
            )
            .toolbarBackground(.visible)
            .onAppear {
                viewModel.trackScreen(screen: self)
            }
        }
    }

    private var cancelButton: some ToolbarContent {
        ToolbarItem(placement: .confirmationAction) {
            Button(viewModel.cancelButtonTitle) {
                viewModel.dismissAction()
            }
            .foregroundColor(Color(UIColor.govUK.text.linkSecondary))
        }
    }
}

extension LocalAuthorityExplainerView: TrackableScreen {
    var trackingTitle: String? { "Your local services" }
    var trackingName: String { "Your local services" }
}
