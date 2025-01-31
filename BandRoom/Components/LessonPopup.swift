import SwiftUI

struct LessonPopup: View {
    let lesson: LessonUI
    let onStart: () -> Void
    let onDismiss: () -> Void // ✅ New closure to handle dismissing

    var body: some View {
        ZStack {
            // ✅ Transparent background to detect taps
            Color.black.opacity(0.5)
                .edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    onDismiss() // ✅ Dismiss the popup when tapping outside
                }

            VStack(spacing: 12) {
                Text(lesson.title2)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)

                Text("\(lesson.id) of 10")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white.opacity(0.6))

                Button(action: onStart) {
                    HStack {
                        Text("START")
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
                    .padding(.horizontal, 12)
                }
            }
            .padding()
            .frame(width: 360, height: 170)
            .background(Color.blue)
            .cornerRadius(20)
            .shadow(radius: 10)
        }
    }
}

// ✅ Preview
#Preview {
    LessonPopup(
        lesson: LessonUI(id: "Lesson 1", title: "SECTION 1, UNIT 1", title2: "Introduction to Notes", icon: "music.note", isLocked: false),
        onStart: {},
        onDismiss: {}
    )
}
