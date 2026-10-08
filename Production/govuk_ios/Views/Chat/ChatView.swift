import SwiftUI
import GovKit
import GovKitUI


struct ChatView: View {
    @Environment(\.verticalSizeClass) var verticalSizeClass
    @Environment(\.accessibilityVoiceOverEnabled) private var voiceOverEnabled
    @StateObject private var viewModel: ChatViewModel
    private let voiceOverFocusService: VoiceOverFocusServiceInterface
    @AccessibilityFocusState private(set) var textAreaAccessibilityFocused: Bool
    @Namespace var bottomID
    @FocusState private var textAreaFocused: Bool
    @State private var textAreaFocusedAnimationTrigger = true
    @State var showClearChatAlert: Bool = false
    @State private var backgroundOpacity = 0.25
    private let introDuration = 0.5
    private let transitionDuration = 0.3

    init(viewModel: ChatViewModel,
         voiceOverFocusService: VoiceOverFocusServiceInterface = VoiceOverFocusService()) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.voiceOverFocusService = voiceOverFocusService
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
        .overlay(content: {
            VStack {
                ProgressView()
                    .accessibilityLabel(.Chat.historyLoadingAccessibilityLabel)
            }
            .opacity(progressOpacity)
            .animation(.easeOut,
                       value: progressOpacity)
            .ignoresSafeArea()
        })
        .onAppear {
            viewModel.loadHistory()
            viewModel.trackScreen(screen: self)
            withAnimation(
                .easeIn(
                    duration: skipIntroFade ? 0.0 : introDuration * 4
                )
            ) {
                backgroundOpacity = 1.0
            }
        }
        .task {
            guard voiceOverEnabled else { return }
            await voiceOverFocusService.focusHeader(labelled: String(localized: .Chat.chatHeader))
        }
        .onDisappear {
            backgroundOpacity = 0.25
        }
        .onTapGesture {
            textAreaFocused = false
        }
        .onChange(of: viewModel.requestInFlight) { requestInFlight in
            if requestInFlight && !viewModel.showProgressView {
                textAreaAccessibilityFocused = true
            }
        }
        .alert(
            viewModel.validationAlertDetails.title,
            isPresented: $viewModel.showValidationAlert,
            presenting: viewModel.validationAlertDetails
        ) { details in
            Button(role: .cancel) {
                textAreaFocused = true
                viewModel.showValidationAlert = false
            } label: {
                Text(details.primaryButtonTitle)
            }
        } message: { details in
            Text(details.message)
        }
    }

    private var skipIntroFade: Bool {
        viewModel.currentConversationExists || voiceOverEnabled
    }

    private var progressOpacity: CGFloat {
        viewModel.showProgressView ? 1.0 : 0.0
    }

    private func chatContainerView(_ frameHeight: CGFloat) -> some View {
        let chatActionView = ChatActionView(
            viewModel: viewModel,
            askQuestion: askQuestion,
            textAreaFocused: $textAreaFocused,
            showClearChatAlert: $showClearChatAlert,
            textAreaFocusedAnimationTrigger: $textAreaFocusedAnimationTrigger,
            maxTextEditorFrameHeight: frameHeight
        )

        return VStack(spacing: 0) {
            chatCellsScrollViewReaderView
                .frame(maxHeight: .infinity)
                .layoutPriority(1)
                .padding(.vertical, 8)
            chatActionView
                .accessibilityFocused($textAreaAccessibilityFocused)
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
            chatExampleQuestionsView
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
        .onChange(of: verticalSizeClass) { _ in
            if viewModel.requestInFlight {
                withAnimation {
                    proxy.scrollTo(viewModel.latestQuestionID, anchor: .top)
                }
            }
        }
    }

    @ViewBuilder
    private var chatExampleQuestionsView: some View {
        let showExampleQuestions = viewModel.showExampleQuestions &&
        textAreaFocusedAnimationTrigger
        if showExampleQuestions {
            ChatExampleQuestionsView(
                viewModel: viewModel.chatExampleQuestionsViewModel,
                askQuestion: askQuestion
            )
            .transition(.opacity)
            .padding(.top, 4)
            .animation(.easeInOut(duration: 0.2), value: viewModel.showExampleQuestions)
        }
    }

    private func askQuestion(_ questionRequest: AskQuestionRequest) {
        viewModel.askQuestion(questionRequest) { success in
            textAreaFocused = !success
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
