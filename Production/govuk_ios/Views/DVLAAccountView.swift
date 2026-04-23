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
            if let errorViewModel = viewModel.errorViewModel {
                errorView(with: errorViewModel)
            } else {
                listView
            }
        }
        .frame(maxHeight: .infinity)
        .overlay(content: {
            loadingView
        })
        .task {
            await viewModel.fetchContent()
        }
    }

    private func errorView(with errorViewModel: AppErrorViewModel) -> some View {
        GeometryReader { geometry in
            ScrollView {
                VStack {
                    Spacer()
                    AppErrorView(viewModel: errorViewModel)
                    Spacer()
                }
                .frame(minHeight: geometry.size.height)
                .frame(width: geometry.size.width)
            }
        }
    }

    private var listView: some View {
        ScrollView {
            GroupedList(
                content: viewModel.sections,
                backgroundColor: UIColor.govUK.fills.surfaceBackground
            )
            .padding(.vertical, 24)
            .padding(.horizontal, 16)
        }
    }

    private var loadingView: some View {
        ZStack {
            Color(UIColor(light: .white, dark: .black))
            ProgressView()
        }
        .opacity(viewModel.isLoading ? 1 : 0)
    }
}
