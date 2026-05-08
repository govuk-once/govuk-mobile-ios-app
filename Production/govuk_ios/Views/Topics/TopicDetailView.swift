import SwiftUI
import GovKitUI
import GovKit

struct TopicDetailView<T: TopicDetailViewModelInterface>: View {
    @StateObject var viewModel: T
    let widgetView: AnyView?

    init(viewModel: T, widgetView: AnyView?) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.widgetView = widgetView
    }

    var body: some View {
        ScrollView {
            VStack {
                titleView
                widgetView
                if let errorViewModel = viewModel.errorViewModel {
                    showErrorView(with: errorViewModel)
                } else if viewModel.isLoaded {
                    showLoadedContent()
                } else {
                    showLoadingView()
                }
            }
        }
        .background(Color(UIColor.govUK.fills.surfaceBackground))
        .task {
            viewModel.trackScreen(screen: self)
            await viewModel.viewDidAppear()
        }
        .onChange(of: viewModel.isLoaded) { isLoaded in
            if isLoaded {
                viewModel.trackEcommerce()
            }
        }
    }

    private func showErrorView(with errorViewModel: AppErrorViewModel) -> some View {
        ZStack {
            AppErrorView(viewModel: errorViewModel)
                .padding(.vertical, 20)
        }
        .frame(maxWidth: .infinity)
        .background(Color(UIColor.govUK.fills.surfaceList))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .padding(16)
    }

    private func showLoadedContent() -> some View {
        VStack(spacing: 0) {
            topicDetails
            subtopics
        }
    }

    private func showLoadingView() -> some View {
        ZStack {
            Color(UIColor.govUK.fills.surfaceList)
                .clipShape(RoundedRectangle(cornerRadius: 10))
            ProgressView()
                .accessibilityLabel(viewModel.loadingAccessibilityLabel)
        }
        .frame(height: 200)
        .padding(16)
    }

    private var titleView: some View {
        VStack(spacing: 0) {
            HStack {
                Text(viewModel.title)
                    .font(.govUK.largeTitleBold)
                    .multilineTextAlignment(.leading)
                    .accessibility(addTraits: .isHeader)
                    .foregroundColor(Color(UIColor.govUK.text.primary))
                Spacer()
            }
            .padding(.leading, 16)
            .padding(.bottom, viewModel.description == nil ? 8 : 0)
            .background(Color(.clear))
            if let description = viewModel.description {
                descriptionView(description: description)
            }
        }
    }

    private var topicDetails: some View {
        GroupedList(
            content: viewModel.sections,
            backgroundColor: UIColor.govUK.fills.surfaceBackground
        )
        .padding([.top, .horizontal], 16)
        .background(Color(UIColor.govUK.fills.surfaceBackground))
    }

    private var subtopics: some View {
        VStack(spacing: 8) {
            HStack {
                Text(LocalizedStringResource("topicDetailSubtopicsHeader", table: "Topics"))
                    .font(.govUK.title3Semibold)
                    .foregroundStyle(Color(UIColor.govUK.text.primary))
                    .accessibilityAddTraits(.isHeader)
                Spacer()
            }
            .padding(.vertical, 8)
            ForEach(viewModel.subtopicCards) { cardModel in
                ListCardView(viewModel: cardModel)
            }
        }
        .padding()
        .background(Color(UIColor.govUK.fills.surfaceBackground))
        .opacity(viewModel.subtopicCards.isEmpty ? 0 : 1)
    }

    private func descriptionView(description: String) -> some View {
        HStack {
            Text(description)
                .font(.govUK.title3)
                .foregroundColor(Color(UIColor.govUK.text.secondary))
                .multilineTextAlignment(.leading)
            Spacer()
        }
        .padding(.horizontal, 18)
        .padding(.top, 8)
        .padding(.bottom, 8)
        .background(Color(.clear))
    }

    private var gradient: Gradient {
        Gradient(stops: [
            .init(
                color: Color(.clear),
                location: 0),
            .init(
                color: Color(.clear),
                location: 0.33),
            .init(
                color: .clear,
                location: 0.33),
            .init(
                color: .clear,
                location: 1)
        ])
    }
}

extension TopicDetailView: TrackableScreen {
    var trackingTitle: String? { viewModel.title }
    var trackingName: String { viewModel.title }
}
