import SwiftUI
import GovKit

struct DrivingRecordView: View {
    let viewModel: DrivingRecordViewModel
    var body: some View {
        VStack(spacing: 8) {
            SubsectionHeaderText(.DVLA.drivingRecordTitle)
                .foregroundColor(Color(UIColor.govUK.text.primary))
                .frame(maxWidth: .infinity, alignment: .leading)
            GroupedList(content: viewModel.listContent)
                .padding(.top, 8)
        }
    }
}

#Preview("DrivingRecordView") {
    DrivingRecordView(viewModel:
                        DrivingRecordViewModel(
                            dvlaURLs: DvlaURLs.arrange(),
                            openURLAction: { url, buttonTitle in
                                print("openURLAction(\(url), \(buttonTitle))")
                            }
    ))
}
