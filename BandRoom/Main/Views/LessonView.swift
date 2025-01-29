import SwiftUI

struct LessonView: View {
    let lessonNumber: Int // ✅ Ensure lessonNumber is received

    var body: some View {
        VStack {
            Text("Lesson \(lessonNumber)")
                .font(.title.bold())
                .padding()
            
            Spacer()
            
            NavigationLink(destination: QuizView(lessonNumber: lessonNumber)) { // ✅ Pass lessonNumber
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

// ✅ Fix the preview by passing a default lesson number
#Preview {
    LessonView(lessonNumber: 1) // ✅ Pass a sample lesson number
}
