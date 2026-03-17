import SwiftUI
import GovKit
import GovKitUI

struct LocalWastePostcodeEntryView: View {
    @StateObject
    private var viewModel: LocalWastePostcodeEntryViewModel

    @Environment(\.verticalSizeClass)
    var verticalSizeClass

    @AccessibilityFocusState(for: .voiceOver)
    private var isErrorFocused: Bool

    @FocusState
    private var isTextFieldFocused: Bool

    private var buttonViewModel: GOVUKButton.ButtonViewModel {
        .init(
            localisedTitle: viewModel.primaryButton,
            action: {
                Task { @MainActor in
                    isTextFieldFocused = false
                    await viewModel.fetchAddresses()
                }
            }
        )
    }

    init(viewModel: LocalWastePostcodeEntryViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    var body: some View {
        ZStack {
            Color(uiColor: .govUK.fills.surfaceModal)
            VStack {
                HStack {
                    Spacer()
                    Button(
                        action: {
                            viewModel.dismissAction()
                        }, label: {
                            Text(viewModel.cancelButton)
                                .foregroundColor(
                                    Color(UIColor.govUK.text.linkSecondary)
                                )
                                .font(Font.govUK.subheadlineSemibold)
                        }
                    )
                }
                .padding(16)
                ScrollView {
                    VStack(alignment: .leading, spacing: 15) {
                        Text(viewModel.viewTitle)
                            .font(Font.govUK.title1Bold)
                            .foregroundColor(Color(UIColor.govUK.text.primary))
                            .accessibilityAddTraits(.isHeader)
                        Text(viewModel.exampleText)
                            .font(Font.govUK.body)
                            .foregroundColor(Color(UIColor.govUK.text.secondary))
                        if let errorCase = viewModel.error {
                            Text(errorCase.errorMessage)
                                .accessibilityFocused($isErrorFocused)
                                .foregroundColor(
                                    Color(uiColor: UIColor.govUK.text.buttonDestructive)
                                )
                                .font(Font.govUK.body)
                        }
                        TextField("", text: $viewModel.postcode)
                            .textContentType(.postalCode)
                            .focused($isTextFieldFocused)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 10)
                            .background(Color(UIColor.govUK.fills.surfaceSearch))
                            .roundedBorder(
                                cornerRadius: 4,
                                borderColor: Color(viewModel.textFieldColour))
                            .accessibilityLabel(viewModel.entryFieldAccessibilityLabel)
                            .disabled(viewModel.isLoading)

                        if viewModel.isLoading {
                            ProgressView()
                                .padding(.top, 28)
                                .frame(maxWidth: .infinity)
                                .tint(Color(uiColor: UIColor.govUK.text.iconTertiary))
                                .accessibilityLabel(viewModel.loadingAccessibilityLabel)
                        } else {
                            Text(viewModel.descriptionTitle)
                                .font(Font.govUK.bodySemibold)
                                .foregroundColor(Color(UIColor.govUK.text.primary))
                                .accessibilityAddTraits(.isHeader)
                            Text(viewModel.descriptionBody)
                                .font(Font.govUK.body)
                                .foregroundColor(Color(UIColor.govUK.text.primary))
                        }

                        Spacer()
                    }.padding()
                }.onReceive(viewModel.$error) { error in
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        if error != nil {
                            isErrorFocused = true
                        }
                    }
                }
                PrimaryButtonView(viewModel: buttonViewModel)
                    .disabled(viewModel.isLoading || viewModel.postcode.isEmpty)
                    .padding(.bottom, 16)
            }
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                viewModel.trackScreen(screen: self)
            }
            .animation(.linear, value: viewModel.error)
        }
    }
}

extension LocalWastePostcodeEntryView: TrackableScreen {
    var trackingTitle: String? { "What is your postcode" }
    var trackingName: String { "What is your postcode" }
}
