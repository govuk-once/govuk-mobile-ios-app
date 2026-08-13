import SwiftUI
import Foundation
import GovKitUI

struct IconActionCardView: View {
    @StateObject private var viewModel: IconActionCardViewModel

    init(viewModel: IconActionCardViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        Button(action: viewModel.action) {
            HStack(alignment: .center) {
                Spacer()
                VStack(alignment: .center) {
                    Spacer()

                    Image(systemName: viewModel.iconName)
                        .font(.title)
                        .foregroundColor(Color(UIColor.govUK.text.iconTertiary))
                        .padding(.bottom, 6)
                    VStack(spacing: 8) {
                        if let title = viewModel.title {
                            Text(title)
                                .multilineTextAlignment(.center)
                                .font(Font.govUK.bodySemibold)
                                .foregroundColor(Color(UIColor.govUK.text.primary))
                        }
                        if let description = viewModel.description {
                            Text(description)
                                .multilineTextAlignment(.center)
                                .font(Font.govUK.body)
                                .foregroundColor(
                                    viewModel.title != nil
                                    ? Color(UIColor.govUK.text.secondary)
                                    : Color(UIColor.govUK.text.primary)
                                )
                        }
                    }
                    .padding(.horizontal)

                    Spacer()
                }
                .padding()
                Spacer()
            }
            .background {
                Color(uiColor: UIColor.govUK.fills.surfaceList)
            }
            .roundedBorder(borderColor: .clear)
            .shadow(
                color: Color(uiColor: UIColor.govUK.strokes.cardDefault),
                radius: 0,
                x: 0,
                y: 3
            )
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(viewModel.accessibilityLabel))
    }
}
