import SwiftUI

struct HomeView: View {
    @State private var currentLessonIndex: Int = UserDefaults.standard.integer(forKey: "currentLessonIndex") // ✅ Load lesson progress
    @State private var selectedLesson: LessonUI?
    @State private var showLessonPopup = false
    @State private var navigateToQuiz = false

    let lessons = [
        LessonUI(id: "Lesson 1", title: "SECTION 1, UNIT 1", title2: "Introduction to notes", icon: "music.note"),
        LessonUI(id: "Lesson 2", title: "SECTION 1, UNIT 2", title2: "Introduction to notes", icon: "music.note"),
        LessonUI(id: "Lesson 3", title: "SECTION 1, UNIT 3", title2: "Introduction to notes", icon: "music.note"),
        LessonUI(id: "Lesson 4", title: "SECTION 1, UNIT 4", title2: "Introduction to notes", icon: "music.note"),
        LessonUI(id: "Lesson 5", title: "SECTION 1, UNIT 5", title2: "Introduction to notes", icon: "music.note")
    ]

    var body: some View {
        ZStack {
            VStack {
                // Profile & XP Progress
                userProfileSection()

                // Lesson Grid
                lessonScrollView()
            }
            .navigationDestination(isPresented: $navigateToQuiz) {
                if let selectedLesson = selectedLesson {
                    let lessonNumber = Int(selectedLesson.id.split(separator: " ").last!) ?? 1 // ✅ Extract lesson number from ID
                    QuizView(lessonNumber: lessonNumber) // ✅ Pass the correct lesson number
                }
            }

            // ✅ Show LessonPopup as an overlay (NOT a modal)
            if showLessonPopup, let lesson = selectedLesson {
                LessonPopup(
                    lesson: lesson,
                    lessonNumber: currentLessonIndex + 1, // ✅ Display correct lesson number
                    onStart: {
                        showLessonPopup = false
                        navigateToQuiz = true
                    },
                    onDismiss: {
                        showLessonPopup = false // ✅ Close when tapping outside
                    }
                )
                .transition(.scale)
                .onAppear {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        showLessonPopup = true
                    }
                }
            }
        }
        .onAppear {
            validateProgress()
        }
    }

    // ✅ Profile & XP Section
    private func userProfileSection() -> some View {
        HStack {
            Image(systemName: "person.crop.circle.fill")
                .resizable()
                .frame(width: 50, height: 50)

            VStack(alignment: .leading) {
                Text("Welcome Back!")
                    .font(.headline)
                Text("Streak: 0 days")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            Spacer()
            Text("XP: 0")
                .font(.headline)
                .padding()
                .background(Color.yellow.opacity(0.2))
                .clipShape(Capsule())
        }
        .padding(.horizontal)
        .padding(.top, 20)
    }

    // ✅ Lesson List ScrollView
    private func lessonScrollView() -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Grade 1")
                    .font(.title2.bold())
                    .foregroundColor(.primary)

                ForEach(lessons.indices, id: \.self) { index in
                    LessonButton(
                        lesson: lessons[index],
                        isUnlocked: index == currentLessonIndex // ✅ Unlock ONLY the current lesson
                    ) {
                        if index == currentLessonIndex { // ✅ Open only if it's the correct lesson
                            selectedLesson = lessons[index]
                            showLessonPopup = true
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
        }
    }

    // ✅ Validate progress & prevent early unlocks
    private func validateProgress() {
        let savedLessonIndex = UserDefaults.standard.integer(forKey: "currentLessonIndex")

        print("🔎 Validating progress... Current lesson index: \(savedLessonIndex)")

        // ❌ If progress is ahead of expected, reset it
        if savedLessonIndex > lessons.count - 1 {
            print("🚨 Invalid lesson progress detected! Resetting to last valid lesson.")
            UserDefaults.standard.set(lessons.count - 1, forKey: "currentLessonIndex")
            currentLessonIndex = lessons.count - 1
        }
    }
}

// ✅ Updated UI Model for Lessons
struct LessonUI: Identifiable {
    let id: String
    let title: String
    let title2: String
    let icon: String
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
