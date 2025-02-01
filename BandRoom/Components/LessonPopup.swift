import SwiftUI

struct LessonPopup: View {
    let lesson: LessonUI
    let lessonNumber: Int
    let onStart: () -> Void
    let onDismiss: () -> Void

    var body: some View {
        ZStack {
            // ✅ Background to dismiss on tap
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    onDismiss() // ✅ Hide popup when tapping outside
                }

            VStack(spacing: 12) {
                Text(lesson.title2)
                    .font(.title3)
                    .bold()
                    .foregroundColor(.white)

                Text("Lesson \(lessonNumber) of 5")
                    .font(.headline)
                    .foregroundColor(.white.opacity(0.6))

                Button(action: onStart) {
                    HStack(spacing: 8) {
                        Text("Start")
                            .font(.headline)
                            .bold()
                        
                        Text("+20 XP")
                            .font(.headline)
                            .bold()
                    }
                    .frame(maxWidth: .infinity, minHeight: 50)
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .padding(.horizontal, 16)
                }
            }
            .padding()
            .frame(width: 380, height: 180)
            .background(Color.blue)
            .cornerRadius(20)
            .shadow(radius: 10)
        }
    }
}

// ✅ Preview
#Preview {
    LessonPopup(
        lesson: LessonUI(id: "Lesson 1", title: "SECTION 1, UNIT 1", title2: "Introduction to Notes", icon: "music.note"),
        lessonNumber: 1,
        onStart: {},
        onDismiss: {}
    )
}
