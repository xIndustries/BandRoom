import SwiftUI

struct HomeView: View {
    @State private var unlockedLessons = 1 // Number of unlocked lessons
    @State private var selectedLesson: LessonUI? // ✅ Store selected lesson for the popup
    @State private var showLessonPopup = false // ✅ Controls pop-up visibility
    @State private var navigateToQuiz = false // ✅ Trigger navigation to QuizView

    let lessons = [
        LessonUI(id: "Lesson1", title: "SECTION 1, UNIT 1", title2: "Introduction to notes", icon: "music.note", isLocked: false),
        LessonUI(id: "Lesson2", title: "SECTION 1, UNIT 2", title2: "Introduction to notes", icon: "music.note", isLocked: true),
        LessonUI(id: "Lesson3", title: "SECTION 1, UNIT 3", title2: "Introduction to notes", icon: "music.note", isLocked: true),
        LessonUI(id: "Lesson4", title: "SECTION 1, UNIT 4", title2: "Introduction to notes", icon: "music.note", isLocked: true),
        LessonUI(id: "Lesson5", title: "SECTION 1, UNIT 5", title2: "Introduction to notes", icon: "music.note", isLocked: true)
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                VStack {
                    // Profile & XP Progress
                    HStack {
                        Image(systemName: "person.crop.circle.fill")
                            .resizable()
                            .frame(width: 50, height: 50)
                            .padding(.leading)

                        VStack(alignment: .leading) {
                            Text("Welcome Back!")
                                .font(.headline)
                            Text("Streak: 🔥 7 days")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        Spacer()
                        Text("XP: 250")
                            .font(.headline)
                            .padding()
                            .background(Color.yellow.opacity(0.2))
                            .clipShape(Capsule())
                    }
                    .padding(.top, 20)

                    // Lesson Grid
                    ScrollView {
                        VStack(alignment: .leading, spacing: 20) {
                            Text("Grade 1")
                                .font(.title2.bold())
                                .foregroundColor(.primary)

                            ForEach(lessons.indices, id: \.self) { index in
                                LessonButton(
                                    lesson: lessons[index],
                                    isUnlocked: index < unlockedLessons
                                ) {
                                    if index < unlockedLessons {
                                        selectedLesson = lessons[index] // ✅ Store selected lesson
                                        showLessonPopup = true // ✅ Show popup
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 10)
                    }

                    Spacer()
                }
                .navigationDestination(isPresented: $navigateToQuiz) { // ✅ Navigate to QuizView
                    if selectedLesson != nil {
                        QuizView(lessonNumber: 1) // ✅ Pass lesson number
                    }
                }

                // ✅ Show the LessonPopup as an overlay (NOT a modal)
                // Inside the ZStack where LessonPopup is shown
                if showLessonPopup {
                    LessonPopup(
                        lesson: selectedLesson!,
                        onStart: {
                            showLessonPopup = false // ✅ Hide popup when "Start" is tapped
                            navigateToQuiz = true // ✅ Trigger navigation to QuizView
                        },
                        onDismiss: {
                            showLessonPopup = false // ✅ Hide popup when tapping outside
                        }
                    )
                    .transition(.scale) // ✅ Smooth appearance
                    .onAppear {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            showLessonPopup = true
                        }
                    }
                }
            }
        }
    }
}

// ✅ Updated UI Model for Lessons
struct LessonUI: Identifiable {
    let id: String
    let title: String
    let title2: String
    let icon: String
    let isLocked: Bool
}

// ✅ Lesson Button UI
struct LessonButton: View {
    let lesson: LessonUI
    let isUnlocked: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: {
            if isUnlocked {
                onTap()
            }
        }) {
            HStack(alignment: .center) {
                Image(systemName: lesson.icon)
                    .resizable()
                    .frame(width: 40, height: 40)
                    .foregroundColor(isUnlocked ? .blue : .gray)

                VStack(alignment: .leading, spacing: 6) {
                    Text(lesson.title)
                        .font(.subheadline)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .foregroundColor(isUnlocked ? .black : .gray)
                    
                    Text(lesson.title2)
                        .font(.headline)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .foregroundColor(isUnlocked ? .black : .gray)
                }

                Spacer()

                if isUnlocked {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                } else {
                    Image(systemName: "lock.fill")
                        .foregroundColor(.gray)
                }
            }
            .padding()
            .background(isUnlocked ? Color.white : Color.gray.opacity(0.3))
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .shadow(radius: 2)
        }
        .disabled(!isUnlocked)
    }
}

// ✅ Preview
#Preview {
    HomeView()
}
