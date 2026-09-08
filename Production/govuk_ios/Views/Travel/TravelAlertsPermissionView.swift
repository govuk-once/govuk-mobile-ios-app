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
        .background(Color(uiColor: UIColor.govUK.fills.surfaceFullscreen))
        .accessibilityElement(children: .contain)
    }

    private var scrollView: some View {
        ScrollView {
            VStack(spacing: 0) {
                if verticalSizeClass == .regular {
                    Spacer(minLength: 32)
                }
                if viewModel.showImage && verticalSizeClass != .compact {
                    Image(decorative: "onboarding_notifications")
                }
                Text(viewModel.title)
                    .foregroundColor(Color(UIColor.govUK.text.primary))
                    .font(Font(UIFont.govUK.largeTitleBold))
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .accessibilityLabel(Text(viewModel.title))
                    .padding(.top, verticalSizeClass == .compact ? 32 : 24)
                    .padding([.trailing, .leading], 16)
                    .accessibilityAddTraits(.isHeader)
                    .accessibilitySortPriority(1)

                Text(viewModel.body)
                    .font(Font(UIFont.govUK.body))
                    .foregroundColor(Color(UIColor.govUK.text.primary))
                    .multilineTextAlignment(.center)
                    .accessibilityLabel(Text(viewModel.body))
                    .padding([.leading, .trailing], 16)
                    .padding(.top, 24)
                    .accessibilitySortPriority(0)
                Spacer()
            }
        }
        .padding(.top, verticalSizeClass == .compact ? 30 : 46)
        .padding(.horizontal, 16)
        .modifier(ScrollBounceBehaviorModifier())
    }
}

extension TravelAlertsPermissionView: TrackableScreen {
    var trackingName: String { "TravelAlertsPermissionScreen" }
    var trackingTitle: String? { "TravelAlertsPermissionScreen" }
}
