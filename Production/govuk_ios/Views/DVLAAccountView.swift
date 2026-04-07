import SwiftUI
import GovKitUI
import GovKit

struct DVLAAccountView: View {
    @StateObject private var viewModel: DVLAAccountViewModel

    init(viewModel: DVLAAccountViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        ZStack {
            Color(UIColor.govUK.fills.surfaceBackground)
            ScrollView {
                listView
            }
        }
        .frame(maxHeight: .infinity)
        .overlay(content: {
            ZStack {
                Color(UIColor(light: .white, dark: .black))
                ProgressView()
            }
            .opacity(viewModel.isLoading ? 1 : 0)
        })
        .task {
            await viewModel.fetchDrivingLicence()
        }
    }

    private var listView: some View {
        GroupedList(
            content: viewModel.sections,
            backgroundColor: UIColor.govUK.fills.surfaceBackground
        )
        .padding(.vertical, 24)
        .padding(.horizontal, 16)
    }
}
