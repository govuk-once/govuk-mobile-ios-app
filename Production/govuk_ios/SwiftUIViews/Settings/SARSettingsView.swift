import SwiftUI
import GovKit
import GovKitUI

struct SARSettingsView: View {
    @StateObject private var viewModel: SARSettingsViewModel

    init(viewModel: SARSettingsViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
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
                SwiftUIButton(
                    .primary,
                    viewModel: viewModel.primaryButtonViewModel
                )
            }
            .padding(16)
        }
        .background(Color(uiColor: .govUK.fills.surfaceBackground))
        .onAppear {
            viewModel.trackScreen(screen: self)
        }
    }
}

extension SARSettingsView: TrackableScreen {
    var trackingTitle: String? { "Your app data" }
    var trackingName: String { "Your app data" }
}
