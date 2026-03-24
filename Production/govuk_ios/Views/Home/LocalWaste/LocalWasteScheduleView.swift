import SwiftUI
import GovKit
import GovKitUI

struct LocalWasteScheduleView: View {
    @StateObject
    private var viewModel: LocalWasteScheduleViewModel

    init(viewModel: LocalWasteScheduleViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        ZStack {
            Color(uiColor: .govUK.fills.surfaceModal)
            VStack {
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        Text(viewModel.viewTitle)
                            .title1BoldPrimary()
                            .maxWidthMultilineLeading()
                            .accessibilityAddTraits(.isHeader)

                        Spacer().frame(height: 16)

                        Text(viewModel.address)
                            .bodySecondary()
                            .maxWidthMultilineLeading()

                        Spacer().frame(height: 16)

                        ForEachWithSeparator(
                            viewModel.items,
                            id: \.id,
                            content: {
                                group($0)
                            },
                            separator: {
                                Spacer().frame(height: 16)
                            }
                        )

                        Spacer()
                    }.padding()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                cancelButton
            }
            .onAppear {
                viewModel.trackScreen(screen: self)
            }
        }
    }

    private func group(_ group: LocalWasteScheduleGroupViewModel) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(group.dateDisplay)
                .title3SemiboldPrimary()
                .maxWidthMultilineLeading()

            ForEachWithSeparator(
                group.items,
                id: \.id,
                content: {
                    LocalWasteScheduleItemView(item: $0)
                },
                separator: {
                    Divider()
                        .overlay(Color(UIColor.govUK.strokes.listDivider))
                        .padding(.leading, 56)
                }
            )
        }
    }

    private var cancelButton: some ToolbarContent {
        ToolbarItem(placement: ToolbarItemPlacement.confirmationAction) {
            Button(viewModel.cancelButton) {
                viewModel.dismissAction()
            }
            .foregroundColor(Color(UIColor.govUK.text.linkSecondary))
        }
    }
}

extension LocalWasteScheduleView: TrackableScreen {
    var trackingTitle: String? { "Bin collection schedule" }
    var trackingName: String { "Bin collection schedule" }
}
