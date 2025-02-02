import SwiftUI

struct LessonView: View {
    let lessonNumber: Int // ✅ Ensure lessonNumber is received
    let onComplete: (Int) -> Void // ✅ Accepts a completion callback

    var body: some View {
        VStack {
            Text("Lesson \(lessonNumber)")
                .font(.title.bold())
                .padding()
            
            Spacer()
            
            NavigationLink(destination: QuizView(lessonNumber: lessonNumber, onComplete: onComplete)) { // ✅ Pass onComplete
                Text("Start Quiz")
                    .bold()
                    .frame(maxWidth: .infinity, minHeight: 50)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .padding()
            }
        }
        .navigationTitle("Lesson \(lessonNumber)")
    }
}

// ✅ Fix the preview by passing a default lesson number and a sample completion function
#Preview {
    LessonView(lessonNumber: 1, onComplete: { _ in }) // ✅ Pass a sample lesson number & empty completion
}
