import SwiftUI

struct HomeView: View {
    @AppStorage("xp") private var xp: Int = 0 // ✅ XP Tracking
    @AppStorage("currentLessonIndex") private var currentLessonIndex: Int = 0 // ✅ Persist lesson progress
    @AppStorage("completedLessons") private var completedLessons: String = "" // ✅ Track completed lessons

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
            .onAppear {
                refreshLessonProgress() // ✅ Ensure lessons refresh when returning to HomeView
            }
            .navigationDestination(isPresented: $navigateToQuiz) {
                if let selectedLesson = selectedLesson {
                    let lessonNumber = extractLessonNumber(from: selectedLesson.id)
                    QuizView(lessonNumber: lessonNumber, onComplete: markLessonCompleted) // ✅ Pass completion callback
                }
            }

            // ✅ Show LessonPopup as an overlay (NOT a modal)
            if showLessonPopup, let lesson = selectedLesson {
                LessonPopup(
                    lesson: lesson,
                    lessonNumber: currentLessonIndex + 1,
                    onStart: {
                        showLessonPopup = false
                        navigateToQuiz = true
                    },
                    onDismiss: {
                        showLessonPopup = false
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
            
            // ✅ XP Display
            Text("XP: \(xp)")
                .font(.headline)
                .padding(10)
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
                    let isCompleted = isLessonCompleted(lessonID: lessons[index].id)
                    
                    LessonButton(
                        lesson: lessons[index],
                        isUnlocked: index <= currentLessonIndex,
                        isCompleted: isCompleted // ✅ Show checkmark if completed
                    ) {
                        if index == currentLessonIndex {
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

    // ✅ Refresh lesson progress when navigating back to HomeView
    private func refreshLessonProgress() {
        let savedLessonIndex = UserDefaults.standard.integer(forKey: "currentLessonIndex")
        currentLessonIndex = savedLessonIndex
    }

    // ✅ Extract lesson number from ID
    private func extractLessonNumber(from id: String) -> Int {
        return Int(id.split(separator: " ").last!) ?? 1
    }

    // ✅ Mark lesson as completed
    private func markLessonCompleted(lessonNumber: Int) {
        let lessonID = lessons[lessonNumber - 1].id
        var completedSet = Set(completedLessons.split(separator: ",").map(String.init))
        completedSet.insert(lessonID)

        completedLessons = completedSet.joined(separator: ",") // ✅ Save progress

        // ✅ Unlock next lesson only if the user is on the latest lesson
        if lessonNumber - 1 == currentLessonIndex {
            currentLessonIndex += 1
        }

        // ✅ Add XP for completing a lesson
        xp += 10 // 🎉 Earn 10 XP per lesson
    }

    // ✅ Check if a lesson is completed
    private func isLessonCompleted(lessonID: String) -> Bool {
        return completedLessons.split(separator: ",").map(String.init).contains(lessonID)
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
    let isCompleted: Bool // ✅ Show checkmark only if completed
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

                if isCompleted { // ✅ Show checkmark only if completed
                    Image(systemName: "checkmark.circle.fill")
                        .resizable()
                        .frame(width: 24, height: 24)
                        .foregroundColor(.green)
                } else if !isUnlocked {
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
