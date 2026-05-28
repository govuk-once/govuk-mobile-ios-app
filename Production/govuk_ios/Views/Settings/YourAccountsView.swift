import SwiftUI
import GovKitUI

struct YourAccountsView: View {
    @StateObject var viewModel: YourAccountsViewViewModel

    init(viewModel: YourAccountsViewViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    var body: some View {
        VStack {
            switch viewModel.state {
            case .success:
                successView
            case .failure:
                errorView
            case .loading:
                loadingView
            }
        }.background {
            Color(UIColor.govUK.fills.surfaceBackground)
                .ignoresSafeArea()
        }
        .onAppear {
            Task {
                await viewModel.fetchLinkStatus()
            }
        }
    }

    @ViewBuilder
    private var loadingView: some View {
        ZStack {
            Color(UIColor.govUK.fills.surfaceBackground)
            ProgressView()
        }
    }

    @ViewBuilder
    private var errorView: some View {
        VStack {
            HStack {
                ToolbarGlassButton(
                    action: {
                        viewModel.dismissAction()
                    },
                    label: {
                        Image(systemName: "chevron.left")
                            .font(Font.govUK.body)
                            .foregroundColor(
                                Color(
                                    UIColor.govUK.text.primary
                                )
                            )
                    }
                )
                Spacer()
            }
            HStack {
                Text(viewModel.title)
                    .font(Font.govUK.largeTitleBold)
                    .foregroundColor(
                        Color(
                            UIColor.govUK.text.primary
                        )
                    )
                Spacer()
            }
            NonTappableCardView(text: viewModel.errorViewDescription)
            Spacer()
        }.background {
            Color(UIColor.govUK.fills.surfaceBackground)
                .ignoresSafeArea()
        }
        .padding([.horizontal], 16)
    }

    @ViewBuilder
    private var successView: some View {
        VStack {
            HStack {
                ToolbarGlassButton(
                    action: {
                        viewModel.dismissAction()
                    },
                    label: {
                        Image(systemName: "chevron.left")
                            .frame(minHeight: 24)
                            .font(Font.govUK.body)
                            .foregroundColor(Color(UIColor.govUK.text.primary))
                    }
                )
                Spacer()
                ToolbarGlassButton(
                    action: { },
                    label: {
                        Text(viewModel.editButtonTitle)
                            .frame(minHeight: 24)
                            .font(Font.govUK.body)
                            .foregroundColor(
                                Color(
                                    UIColor.govUK.text.primary
                                )
                            )
                    }
                )
            }
            HStack {
                Text(viewModel.title)
                    .font(Font.govUK.largeTitleBold)
                    .foregroundColor(
                        Color(
                            UIColor.govUK.text.primary
                        )
                    )
                Spacer()
            }
                VStack {
                    HStack {
                        Text(viewModel.yourAccountsCardTitle)
                            .font(Font.govUK.body)
                            .multilineTextAlignment(.leading)
                            .foregroundColor(
                                Color(UIColor.govUK.text.primary)
                            )

                        Spacer()
                    }
                    .padding(16)
                }
                .background(
                    Color(uiColor: UIColor.govUK.fills.surfaceList)
                )
                .roundedBorder(borderColor: .clear)
                Spacer()
        }.background {
            Color(UIColor.govUK.fills.surfaceBackground)
                .ignoresSafeArea()
        }
        .padding([.horizontal], 16)
    }
}
