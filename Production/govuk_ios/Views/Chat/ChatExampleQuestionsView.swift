import SwiftUI

struct ChatExampleQuestionsView: View {
    let viewModel: ChatExampleQuestionsViewModel
    let askQuestion: (String) -> Void

    var body: some View {
        VStack(alignment: .trailing, spacing: 12) {
            Text(.Chat.exampleQuestionsTitle)
                .font(.govUK.body)
                .foregroundStyle(Color(UIColor.govUK.text.secondary))
                .padding(.trailing, 16)
            ForEach(viewModel.exampleQuestions, id: \.id) { question in
                Button {
                    askQuestion(question.body)
                } label: {
                    Text(question.body)
                        .font(.govUK.body)
                        .foregroundStyle(Color(UIColor.govUK.text.link))
                        .multilineTextAlignment(.leading)
                        .padding(16)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(UIColor.govUK.fills.surfaceCardDefault))
                        .roundedBorder(
                            cornerRadius: 18,
                            borderColor: Color(UIColor.govUK.text.link),
                            borderWidth: 1
                        )
                }
            }
        }
        .padding(.leading, 44)
    }
}
