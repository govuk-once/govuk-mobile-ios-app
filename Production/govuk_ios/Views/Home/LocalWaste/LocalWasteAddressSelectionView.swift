import SwiftUI
import GovKit
import GovKitUI

struct LocalWasteAddressSelectionView: View {
    
    @StateObject
    private var viewModel: LocalWasteAddressSelectionViewModel
    
    @Environment(\.verticalSizeClass)
    var verticalSizeClass

    private var buttonViewModel: GOVUKButton.ButtonViewModel {
        .init(
            localisedTitle: viewModel.primaryButton,
            action: {
                viewModel.confirmAddress()
            }
        )
    }

    init(viewModel: LocalWasteAddressSelectionViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        ZStack {
            Color(uiColor: .govUK.fills.surfaceModal)
            VStack(spacing: 0) {
                ScrollView {
                    HeaderView(
                        title: viewModel.title,
                        subheading: viewModel.subtitle
                    )
                    .padding()
                    listView
                    Spacer()
                }
                PrimaryButtonView(viewModel: buttonViewModel)
                    .disabled(viewModel.selectedAddress == nil)
                    .padding(.bottom, 16)
            }
            .navigationBarTitleDisplayMode(.inline)
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

    private var listView: some View {
        ForEach(
            viewModel.addresses,
            id: \.uprn
        ) { address in
            RadioButtonView(
                title: address.addressFull,
                selected: isSelected(address.uprn),
                isLastRow: viewModel.addresses.last?.uprn == address.uprn
            )
            .onTapGesture {
                viewModel.selectedAddress = address
            }
        }
        .padding(.horizontal, 16)
    }

    private var cancelButton: some ToolbarContent {
        ToolbarItem(placement: ToolbarItemPlacement.confirmationAction) {
            Button(viewModel.cancelButton) {
                viewModel.dismissAction()
            }
            .foregroundColor(Color(UIColor.govUK.text.linkSecondary))
        }
    }

    private func isSelected(_ uprn: String) -> Binding<Bool> {
        return .constant(uprn == viewModel.selectedAddress?.uprn)
    }
}

extension LocalWasteAddressSelectionView: TrackableScreen {
    var trackingTitle: String? { "What is your address" }
    var trackingName: String { "What is your address" }
}
