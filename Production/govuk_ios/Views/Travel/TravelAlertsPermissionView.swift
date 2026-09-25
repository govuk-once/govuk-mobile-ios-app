import Foundation
import SwiftUI
import GovKitUI
import GovKit

struct TravelAlertsPermissionView: View {
    @StateObject private var viewModel: TravelAlertsPermissionViewModel
    @Environment(\.verticalSizeClass) var verticalSizeClass

    init(viewModel: TravelAlertsPermissionViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        VStack(spacing: 0) {
            scrollView
            ButtonStackView(
                primaryButtonViewModel: viewModel.primaryButtonViewModel,
                secondaryButtonViewModel: viewModel.secondaryButtonViewModel
            )
        }
        .navigationTitle("")
        .toolbar {
            backButton
        }
        .toolbarBackground(Color(.govUK.fills.surfaceModal), for: .navigationBar)
        .background(Color(uiColor: UIColor.govUK.fills.surfaceFullscreen))
        .accessibilityElement(children: .contain)
    }

    private var scrollView: some View {
        ScrollView {
            VStack(alignment: .center, spacing: 16) {
                Spacer()
                if viewModel.showImage && verticalSizeClass != .compact {
                    Image(decorative: "onboarding_notifications")
                }
                Text(viewModel.title)
                    .foregroundColor(Color(UIColor.govUK.text.primary))
                    .font(Font(UIFont.govUK.largeTitleBold))
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .accessibilityLabel(Text(viewModel.title))
                    .padding([.trailing, .leading], 16)
                    .accessibilityAddTraits(.isHeader)
                    .accessibilitySortPriority(1)

                Text(viewModel.body)
                    .font(Font(UIFont.govUK.body))
                    .foregroundColor(Color(UIColor.govUK.text.primary))
                    .multilineTextAlignment(.center)
                    .accessibilityLabel(Text(viewModel.body))
                    .padding([.leading, .trailing], 16)
                    .accessibilitySortPriority(0)

                HStack(alignment: .center) {
                    Button(action: viewModel.openPrivacyPolicy,
                           label: {
                        Text(viewModel.privacyPolicyLinkTitle)
                            .frame(alignment: .center)
                            .foregroundColor(Color(UIColor.govUK.text.linkSecondary))
                            .font(Font.govUK.body)
                            .multilineTextAlignment(.center)
                            .accessibilityHint(Text(String.common.localized("openWebLinkHint")))
                            .accessibilityAddTraits(.isLink)
                            .padding(.vertical, 11)

                        Image(systemName: "arrow.up.right")
                            .foregroundColor(Color(UIColor.govUK.text.linkSecondary))
                    })
                }
                .accessibilityElement(children: .combine)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.top, 24)
                Spacer()
            }
        }
        .padding(.top, verticalSizeClass == .compact ? 30 : 46)
        .padding(.horizontal, 16)
        .modifier(ScrollBounceBehaviorModifier())
    }

    private var backButton: some ToolbarContent {
        ToolbarItem(placement: ToolbarItemPlacement.cancellationAction) {
            Button {
                viewModel.dismissSheetAction()
            } label: {
                Image(systemName: "chevron.left")
                    .foregroundStyle(Color(uiColor: .govUK.text.primary))
            }
        }
    }
}

extension TravelAlertsPermissionView: TrackableScreen {
    var trackingName: String { "TravelAlertsPermissionScreen" }
    var trackingTitle: String? { "TravelAlertsPermissionScreen" }
}
