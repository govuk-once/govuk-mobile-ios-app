import SwiftUI
import GovKit

struct DrivingRecordView: View {
    let viewModel: DrivingRecordViewModel
    var body: some View {
        VStack(spacing: 8) {
            Text(.DVLA.drivingRecordTitle)
                .font(.govUK.title2.bold())
                .foregroundColor(Color(UIColor.govUK.text.primary))
                .accessibilityAddTraits(.isHeader)
                .frame(maxWidth: .infinity, alignment: .leading)
            Text(.DVLA.drivingRecordSubtitle)
                .font(.govUK.subheadline)
                .foregroundColor(Color(UIColor.govUK.text.primary))
                .frame(maxWidth: .infinity, alignment: .leading)
            GroupedList(content: viewModel.listContent)
                .padding(.top, 8)
        }
    }
}
