import SwiftUI
import GovKitUI
import GovKit

struct YourAccountsView: View {
    @StateObject var viewModel: YourAccountsViewViewModel
    @State var isEditMode = false
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
        }.background {
            Color(UIColor.govUK.fills.surfaceBackground)
                .ignoresSafeArea()
        }
        .task {
            await viewModel.fetchLinkedAccounts()
        }
    }

    private var loadingView: some View {
        ZStack {
            Color(UIColor.govUK.fills.surfaceBackground)
            ProgressView()
        }
    }

    private var failureView: some View {
        VStack {
            VStack(spacing: 8) {
                Image(systemName: "exclamationmark.circle")
                    .font(.title)
                    .foregroundColor(Color(uiColor: UIColor.govUK.text.iconTertiary))
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
            .background(Color(uiColor: UIColor.govUK.fills.surfaceList))
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
        }.background {
            Color(UIColor.govUK.fills.surfaceBackground)
                .ignoresSafeArea()
        }
        .padding(.horizontal, 16)
    }

    private var successView: some View {
        VStack {
            VStack {
                HStack {
                    if isEditMode {
                        Text("x")
                            .onTapGesture {
                                showAlert.toggle()
                            }
                    }
                    Text(viewModel.yourAccountsCardTitle)
                        .font(Font.govUK.body)
                        .multilineTextAlignment(.leading)
                        .foregroundColor(Color(UIColor.govUK.text.primary))
                        .alert("Important!", isPresented: $showAlert) {
                                Button("Option 1", role: .cancel) { }
                                Button("Option 2", role: .destructive) {
                                    viewModel.unlinkAccount()
                                }
                        } message: {
                            Text("Do you want to proceed?")
                        }
                    Spacer()
                }
                .padding(16)
            }
            .background(Color(uiColor: UIColor.govUK.fills.surfaceList))
            .roundedBorder(borderColor: .clear)
            Spacer()
        }
        .background {
            Color(UIColor.govUK.fills.surfaceBackground)
                .ignoresSafeArea()
        }
        .padding(.top, 8)
        .padding(.horizontal, 16)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(
                    action: {
                        isEditMode.toggle()
                    },
                    label: {
                        if isEditMode {
                            Image(systemName: "check.circle")
                        } else {
                            Text(viewModel.editButtonTitle)
                        }
                    }
                )
            }
        }
    }
}
