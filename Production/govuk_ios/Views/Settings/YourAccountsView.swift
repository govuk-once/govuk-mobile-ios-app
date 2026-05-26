import SwiftUI
import GovKitUI

struct YourAccountsView: View {
    @StateObject var viewModel: YourAccountsSettingsViewModel

    init(viewModel: YourAccountsSettingsViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    var body: some View {
        VStack {
            switch viewModel.state {
            case .loading:
                ProgressView()
            case .success:
                successView
            case .failure:
                errorView
            }
        }
        .background {
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
    private var errorView: some View {
        VStack {
            HStack {
                Button(
                    action: {
                        viewModel.dismissAction()
                    }, label: {
                        Image(systemName: "chevron.left")
                            .font(Font.govUK.title2)
                    }
                ).applyStyle {
                    if #available(iOS 26.0, *) {
                        $0.buttonStyle(.glass)
                    } else {
                        $0
                    }
                }
                Spacer()
            }
            HStack {
                Text(viewModel.title)
                    .font(Font.govUK.largeTitleBold)
                Spacer()
            }
            NonTappableCardView(text: viewModel.errorViewDescription)
            Spacer()
        }
        .padding([.horizontal])
    }

    @ViewBuilder
    private var successView: some View {
        VStack {
            HStack {
                Button(
                    action: {
                        viewModel.dismissAction()
                    }, label: {
                        Image(systemName: "chevron.left")
                            .font(Font.govUK.title2)
                    }
                ).applyStyle {
                    if #available(iOS 26.0, *) {
                        $0.buttonStyle(.glass)
                    } else {
                        $0
                    }
                }
                Spacer()
                Button(
                    action: {
                        viewModel.dismissAction()
                    }, label: {
                        Text(viewModel.editButtonTitle)
                    }
                ).applyStyle {
                    if #available(iOS 26.0, *) {
                        $0.buttonStyle(.glass)
                    } else {
                        $0
                    }
                }
            }
            HStack {
                Text(viewModel.title)
                    .font(Font.govUK.largeTitleBold)
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
        }
        .padding([.horizontal])
    }
}
