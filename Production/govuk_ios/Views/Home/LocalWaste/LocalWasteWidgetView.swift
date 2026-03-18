import SwiftUI
import Foundation
import GovKitUI

struct LocalWasteWidgetView: View {
    @StateObject
    private var viewModel: LocalWasteWidgetViewModel

    init(viewModel: LocalWasteWidgetViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeaderLabelView(
                model: SectionHeaderLabelViewModel(
                    title: viewModel.title,
                    button: .init(
                        localisedTitle: viewModel.editButton,
                        localisedAccessibilityLabel: viewModel.editButtonAccessibilityLabel,
                        action: { viewModel.openEditViewAction() }
                    )
                )
            )
            VStack(alignment: .leading, spacing: 0) {
                switch viewModel.viewState {
                case .initial, .loading:
                    loading()
                case .error:
                    error()
                case .ready:
                    ready()
                }
            }
            .padding(16)
            .background {
                Color(uiColor: UIColor.govUK.fills.surfaceList)
            }
            .roundedBorder(borderColor: .clear)
            .shadow(
                color: Color(
                    uiColor: UIColor.govUK.strokes.cardDefault
                ), radius: 0, x: 0, y: 3
            )
        }
        .onAppear {
            viewModel.startLoadingIfViewStateInitial()
        }
    }

    private var errorButtonViewModel: GOVUKButton.ButtonViewModel {
        .init(
            localisedTitle: viewModel.tryAgainButton,
            action: {
                Task { @MainActor in
                    await viewModel.load()
                }
            }
        )
    }

    private func loading() -> some View {
        ProgressView()
            .padding(.vertical, 28)
            .frame(maxWidth: .infinity)
            .tint(Color(uiColor: UIColor.govUK.text.iconTertiary))
            .accessibilityLabel(viewModel.loadingAccessibilityLabel)
    }

    private func error() -> some View {
        VStack(alignment: .center, spacing: 0) {
            Spacer().frame(height: 24)

            Image(.localAttentionIcon)
                .accessibilityHidden(true)

            Spacer().frame(height: 16)

            Text(viewModel.errorLabel)
                .bodyPrimary()
                .maxWidthMultilineCenter()

            Spacer().frame(height: 2)

            SwiftUIButton(
                .text,
                viewModel: errorButtonViewModel
            )
            Spacer().frame(height: 14)
        }
    }

    private func ready() -> some View {
        VStack(alignment: .leading, spacing: 0) {
            address()

            Spacer().frame(height: 16)

            if viewModel.items.isEmpty {
                itemsEmpty()
            } else {
                items()
            }
        }
    }

    private func address() -> some View {
        HStack(alignment: .center, spacing: 0) {
            Image(.localLocationIcon)
                .padding(8)
            Text(viewModel.address)
                .padding(.vertical, 8)
                .padding(.trailing, 8)
                .font(Font.govUK.footnote)
                .foregroundColor(Color(UIColor.govUK.text.header))
                .fixedSize(horizontal: false, vertical: true)
                .multilineTextAlignment(.leading)
        }
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(UIColor.govUK.fills.textIconSurroundPrimary)))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(viewModel.addressAccessibilityLabel)
    }

    private func itemsEmpty() -> some View {
        VStack(alignment: .center, spacing: 0) {
            Spacer().frame(height: 24)

            Image(.localAttentionIcon)
                .accessibilityHidden(true)

            Spacer().frame(height: 16)

            Text(viewModel.emptyLabel)
                .bodyPrimary()
                .maxWidthMultilineCenter()

            Spacer().frame(height: 24)
        }
    }

    private func items() -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(viewModel.dueDate)
                .title3SemiboldPrimary()
                .maxWidthMultilineLeading()

            Spacer().frame(height: 8)

            Text(viewModel.dueTimeLabel)
                .bodySecondary()
                .maxWidthMultilineLeading()

            ForEachWithSeparator(
                viewModel.items,
                id: \.id,
                content: { item in
                    HStack(alignment: .center, spacing: 0) {
                        if let color = item.color {
                            color.toColor()
                                .frame(width: 40, height: 40)
                                .clipShape(Circle())
                                .padding(.vertical, 16)
                        } else {
                            Image(.localUnknownIcon)
                                .padding(.vertical, 16)
                        }

                        Spacer().frame(width: 16)

                        VStack(alignment: .leading, spacing: 0) {
                            Text(item.title)
                                .headlineSemiboldPrimary()
                                .maxWidthMultilineLeading()
                            if let description = item.description {
                                Text(description)
                                    .subheadlineSecondary()
                                    .maxWidthMultilineLeading()
                            }
                        }
                        .padding(.vertical, 16)
                    }
                    .contentShape(Rectangle())
                    .accessibilityElement(children: .ignore)
                    .accessibilityLabel(item.accessibilityLabel)
                },
                separator: {
                    Divider()
                        .overlay(Color(UIColor.govUK.strokes.listDivider))
                        .padding(.leading, 56)
                }
            )
        }
    }
}

extension LocalWasteBinColor {
    func toColor() -> Color {
        switch self {
        case .black:
            return .black
        case .green:
            return Color(UIColor.primaryGreen)
        case .red:
            return Color(UIColor.primaryRed)
        case .blue:
            return Color(UIColor.primaryBlue)
        case .brown:
            return Color(UIColor.orangeShade50)
        case .yellow:
            return Color(UIColor.primaryYellow)
        case .silver:
            return Color(UIColor.grey100)
        case .purple:
            return Color(UIColor.primaryPurple)
        }
    }
}

private typealias ItemViewModel = LocalWasteWidgetViewModel.ItemViewModel
