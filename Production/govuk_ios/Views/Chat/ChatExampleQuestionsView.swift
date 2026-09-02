import SwiftUI

struct ChatExampleQuestionsView: View {
    let viewModel: ChatExampleQuestionsViewModel
    let askQuestion: (String) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Try asking:")
            ForEach(viewModel.exampleQuestions ?? [], id: \.id) { question in
                Button {
                    askQuestion(question.body)
                } label: {
                    Text(question.body)
                }
            }
        }
    }
}
