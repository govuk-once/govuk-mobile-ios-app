import SwiftUI
import GovKit
import GovKitUI

struct SARResultView: View {
    @StateObject private var viewModel: SARResultViewModel

    init(viewModel: SARResultViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        VStack(alignment: .leading) {
            Text("PushID: \(viewModel.userState?.notifications.pushId ?? "")")
            Text("NotificationConsent: \(viewModel.userState?.notifications.consentStatus.rawValue ?? "")")
            Spacer()
            SwiftUIButton(
                .primary,
                viewModel: viewModel.primaryButtonViewModel
            )
        }
        .padding(16)
        .background(Color(uiColor: .govUK.fills.surfaceBackground))
        .overlay(content: {
            ZStack {
                Color(uiColor: .govUK.fills.surfaceBackground)
                ProgressView()
            }
            .opacity(viewModel.progressOpacity)
            .animation(.easeOut,
                       value: viewModel.progressOpacity)
            .ignoresSafeArea()
        })
        .onAppear {
            viewModel.trackScreen(screen: self)
        }
    }
}

extension SARResultView: TrackableScreen {
    var trackingTitle: String? { "Your app data" }
    var trackingName: String { "SAR Result" }
}
