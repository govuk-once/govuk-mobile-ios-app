import SwiftUI
import GovKitUI
import GovKit

struct YourAccountsView: View {
    @StateObject private var viewModel: YourAccountsViewViewModel
    @State private var isEditMode = false
    @State private var showAlert = false

    init(viewModel: YourAccountsViewViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        VStack {
            switch viewModel.state {
            case .success:
                successView
            case .failure:
                failureView
            case .loading:
                loadingView
            case .empty:
                emptyView
            }
        }
        .background(Color(uiColor: .govUK.fills.surfaceBackground).ignoresSafeArea())
        .task {
            await viewModel.fetchLinkedAccounts()
        }
    }

    private var loadingView: some View {
        ZStack {
            Color(uiColor: .govUK.fills.surfaceBackground)
            ProgressView()
        }
    }

    private var failureView: some View {
        VStack {
            VStack(spacing: 8) {
                Image(systemName: "exclamationmark.circle")
                    .font(.title)
                    .foregroundColor(Color(uiColor: .govUK.text.iconTertiary))
                    .accessibilityHidden(true)

                VStack(spacing: 2) {
                    Text(viewModel.failureViewTitle)
                        .font(Font.govUK.bodySemibold)
                        .foregroundColor(Color(uiColor: .govUK.text.primary))
                    Text(viewModel.failureViewDescription)
                        .font(Font.govUK.body)
                        .foregroundColor(Color(uiColor: .govUK.text.primary))
                }
            }
            .padding(.vertical, 24)
            .frame(maxWidth: .infinity)
            .background(Color(uiColor: .govUK.fills.surfaceList))
            .roundedBorder(borderColor: .clear)

            Spacer()
        }
        .padding(.top, 8)
        .padding(.horizontal, 16)
    }

    private var emptyView: some View {
        VStack {
            NonTappableCardView(text: viewModel.emptyViewDescription)
                .padding(.top, 8)
            Spacer()
        }
        .background(Color(uiColor: .govUK.fills.surfaceBackground).ignoresSafeArea())
        .padding(.horizontal, 16)
    }

    private var successView: some View {
        VStack {
            HStack(spacing: 16) {
                if isEditMode {
                    Button {
                        showAlert.toggle()
                        viewModel.trackEvent(
                            "DVLA unlink",
                            type: "Button",
                            section: "false",
                            action: "Settings"
                        )
                    } label: {
                        Image(systemName: "minus.circle.fill")
                            .font(Font.govUK.body)
                            .imageScale(.large)
                            .fontWeight(.medium)
                            .symbolRenderingMode(.palette)
                            .foregroundStyle(.white, .red)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Remove \(viewModel.yourAccountsCardTitle)")
                    .accessibilityHint("Double tap to prompt account removal confirmation.")
                }
                Text(viewModel.yourAccountsCardTitle)
                    .font(Font.govUK.body)
                    .multilineTextAlignment(.leading)
                    .foregroundColor(Color(uiColor: .govUK.text.primary))

                Spacer()
            }
            .padding(16)
            .background(Color(uiColor: .govUK.fills.surfaceList))
            .roundedBorder(borderColor: .clear)

            Spacer()
        }
        .padding(.top, 8)
        .padding(.horizontal, 16)
        .background(Color(uiColor: .govUK.fills.surfaceBackground).ignoresSafeArea())
        .alert(viewModel.alertMessageTitle, isPresented: $showAlert, actions: {
            Button(viewModel.alertCancelButtonTitle, role: .cancel) {
                // wip
                viewModel.trackEvent(
                    "DVLA unlink",
                    type: "Button",
                    section: "false",
                    action: "Settings"
                )
            }
            Button(viewModel.alertRemoveButtonTitle, role: .destructive) {
                viewModel.unlinkAccount()
                // wip
                viewModel.trackEvent(
                    "DVLA unlink",
                    type: "Button",
                    section: "false",
                    action: "Settings"
                )
            }
        }, message: {
            Text(viewModel.alertMessage)
        })
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                if isEditMode {
                    Button {
                        isEditMode.toggle()
                    } label: {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.body)
                    }
                    .buttonStyle(.plain)
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(.white, .blue)
                } else {
                    Button {
                        isEditMode.toggle()
                        viewModel.trackEvent(
                            "Edit",
                            type: "Button",
                            section: "settings",
                            action: "false"
                        )
                    } label: {
                        Text(viewModel.editButtonTitle)
                    }
                }
            }
        }
    }
}
