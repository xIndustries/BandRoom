import SwiftUI

struct QuizCompletedView: View {
    var onExit: () -> Void // ✅ Callback to exit the quiz
    
    var body: some View {
        VStack(spacing: 20) {
            Text("🎉 Quiz Completed!")
                .font(.largeTitle)
                .bold()
            
            Text("Well done! You've finished this lesson.")
                .font(.headline)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button(action: {
                onExit() // ✅ Exit the quiz
            }) {
                Text("Return to Home")
                    .bold()
                    .frame(maxWidth: .infinity, minHeight: 50)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .padding(.horizontal, 16)
            }
            
            Button(action: {
                // Show quiz review logic
            }) {
                Text("Review Answers")
                    .bold()
                    .frame(maxWidth: .infinity, minHeight: 50)
                    .background(Color.gray)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .padding(.horizontal, 16)
            }
        }
        .padding()
        .navigationTitle("Quiz Completed")
    }
}

// ✅ Fixed Preview with Mock `onExit` Callback
#Preview {
    QuizCompletedView(
        onExit: { print("Exit Quiz Triggered") } // ✅ Added a mock function for preview
    )
}
