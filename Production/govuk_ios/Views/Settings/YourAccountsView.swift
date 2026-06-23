import SwiftUI
import GovKitUI
import GovKit

struct YourAccountsView: View {
    @StateObject private var viewModel: YourAccountsViewViewModel
    @State private var isEditMode: Bool
    @State private var showAlert = false

    init(viewModel: YourAccountsViewViewModel,
         isEditMode: Bool = false) {
        _viewModel = StateObject(wrappedValue: viewModel)
        _isEditMode = State(wrappedValue: isEditMode)
    }

    var body: some View {
        ZStack {
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
            .background(Color(uiColor: .govUK.fills.surfaceBackground)
                .ignoresSafeArea()
            )
            .task {
                await viewModel.fetchLinkedAccounts()
            }
        }
        .fullScreenCover(
            isPresented: $viewModel.showingUnlinkError,
            onDismiss: { viewModel.state = .success },
            content: {
                UnlinkAccountsErrorView(
                    viewModel: viewModel.unlinkErrorViewModel
                )
            }
        )
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
            HStack(spacing: 10) {
                if isEditMode {
                    Button {
                        showAlert.toggle()
                        viewModel.trackEvent(text: "DVLA unlink")
                    } label: {
                        Image(systemName: "minus.circle.fill")
                            .font(Font.govUK.body)
                            .imageScale(.large)
                            .fontWeight(.medium)
                            .symbolRenderingMode(.palette)
                            .foregroundStyle(Color(uiColor: .greyWhite),
                                             Color(uiColor: .systemRed))
                    }
                    .buttonStyle(.plain)
                }
                Text(viewModel.yourAccountsCardTitle)
                    .font(Font.govUK.body)
                    .multilineTextAlignment(.leading)
                    .foregroundColor(Color(uiColor: .govUK.text.primary))
                Spacer()
            }.accessibilityHint(isEditMode ? viewModel.editModeAccessibilityText: "")
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
                viewModel.trackEvent(text: "DVLA Cancel")
            }
            Button(viewModel.alertRemoveButtonTitle, role: .destructive) {
                viewModel.unlinkAccount()
                viewModel.trackNavigationEvent(text: "DVLA Remove account")
            }
        }, message: {
            Text(viewModel.alertMessage)
        })
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                if isEditMode {
                    if #available(iOS 26.0, *) {
                        Button(role: .confirm, action: {
                            withAnimation(.easeInOut) {
                                isEditMode.toggle()
                            }
                        })
                    } else {
                        Button {
                            withAnimation(.easeInOut) {
                                isEditMode.toggle()
                            }
                        } label: {
                            Text(viewModel.editModeDoneButton)
                                .font(Font.govUK.body)
                                .foregroundColor(Color(uiColor: .govUK.text.linkHeader))
                        }
                    }
                } else {
                    Button {
                        withAnimation(.easeInOut) {
                            isEditMode.toggle()
                        }
                        viewModel.trackEvent(text: viewModel.editButtonTitle)
                    } label: {
                        Text(viewModel.editButtonTitle)
                    }
                }
            }
        }
    }
}
