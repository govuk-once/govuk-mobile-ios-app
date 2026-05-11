import SwiftUI
import GovKit
import GovKitUI

struct SARExplainerView: View {
    @StateObject private var viewModel: SARExplainerViewModel

    init(viewModel: SARExplainerViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        VStack {
            ScrollView {
                VStack(alignment: .leading) {
                    Text(viewModel.descriptionOne)
                        .font(.body)
                        .multilineTextAlignment(.leading)
                    BulletView(bulletText: viewModel.bullets,
                               bulletSpacing: 8.0,
                               itemSpacing: 4.0)
                    .padding(.bottom, 24)
                    Text(viewModel.descriptionTwo)
                        .font(.body)
                        .multilineTextAlignment(.leading)
                        .padding(.bottom, 24)
                }
                .padding(16)
            }
            SwiftUIButton(
                .primary,
                viewModel: viewModel.primaryButtonViewModel
            )
            .padding(16)
        }
        .background(Color(uiColor: .govUK.fills.surfaceBackground))
        .onAppear {
            viewModel.trackScreen(screen: self)
        }
    }
}

extension SARExplainerView: TrackableScreen {
    var trackingTitle: String? { "Your app data" }
    var trackingName: String { "SAR Explainer" }
}
