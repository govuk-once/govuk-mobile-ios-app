import SwiftUI

struct LocalWasteScheduleItemView: View {
    let item: LocalWasteScheduleItemViewModel

    var body: some View {
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
    }
}
