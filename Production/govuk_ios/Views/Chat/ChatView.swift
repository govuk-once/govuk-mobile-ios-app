import SwiftUI
import GovKit

struct ChatView: View {
    @Environment(\.verticalSizeClass) var verticalSizeClass
    @StateObject private var viewModel: ChatViewModel
    @Namespace var bottomID
    @FocusState private var textAreaFocused: Bool
    @State var showClearChatAlert: Bool = false
    @State private var backgroundOpacity = 0.25
    private let introDuration = 0.5
    private let transitionDuration = 0.3

    init(viewModel: ChatViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color(UIColor.govUK.fills.surfaceChatBackground)
                    .edgesIgnoringSafeArea(.all)
                .opacity(backgroundOpacity)
                .ignoresSafeArea(edges: [.top, .leading, .trailing])

                chatContainerView(geometry.size.height - 32)
                    .conditionalAnimation(.easeInOut(duration: transitionDuration),
                                          value: viewModel.textViewHeight)
            }
        }
        .onAppear {
            viewModel.loadHistory()
            viewModel.trackScreen(screen: self)
            withAnimation(
                .easeIn(
                    duration: viewModel.currentConversationExists ? 0.0 : introDuration * 4
                )
            ) {
                backgroundOpacity = 1.0
            }
        }
        .onDisappear {
            backgroundOpacity = 0.25
        }
        .onTapGesture {
            textAreaFocused = false
        }
    }

    private func chatContainerView(_ frameHeight: CGFloat) -> some View {
        let chatActionView = ChatActionView(
            viewModel: viewModel,
            textAreaFocused: $textAreaFocused,
            showClearChatAlert: $showClearChatAlert,
            maxTextEditorFrameHeight: frameHeight
        )

        return VStack(spacing: 0) {
            chatCellsScrollViewReaderView
                .frame(maxHeight: .infinity)
                .layoutPriority(1)
                .padding(.vertical, 8)
            chatActionView
        }
    }

    private var chatCellsView: some View {
        ForEach(viewModel.cellModels, id: \.id) { cellModel in
            HStack {
                if !cellModel.isAnswer {
                    Spacer(minLength: cellModel.questionWidth)
                }
                ChatCellView(viewModel: cellModel)
            }
        }
    }

    private var chatCellsScrollViewReaderView: some View {
        ScrollViewReader { proxy in
            chatCellsScrollView(proxy: proxy)
        }
        .padding(.horizontal)
    }

    private func chatCellsScrollView(proxy: ScrollViewProxy) -> some View {
        ScrollView {
            Rectangle()
                .fill(Color.clear)
                .frame(height: 16)
            Text(.Chat.chatHeader)
                .font(.govUK.title2Bold)
                .foregroundStyle(Color(UIColor.govUK.text.primary))
                .multilineTextAlignment(.center)
                .accessibilityAddTraits(.isHeader)
                .padding(.bottom, 4.0)
            chatCellsView
            Text("")
                .id(bottomID)
        }
        .scrollIndicators(.hidden)
        .onChange(of: viewModel.scrollToBottom) { shouldScroll in
            if shouldScroll {
                withAnimation {
                    proxy.scrollTo(bottomID, anchor: .bottom)
                }
                viewModel.scrollToBottom = false
            }
        }
        .onChange(of: viewModel.scrollToTop) { shouldScroll in
            if shouldScroll {
                withAnimation {
                    proxy.scrollTo(viewModel.latestQuestionID, anchor: .top)
                }
            }
            viewModel.scrollToTop = false
        }
    }
}

extension ChatView: TrackableScreen {
    var trackingName: String {
        "Chat Screen"
    }

    var trackingTitle: String? {
        "Chat Screen"
    }
}
