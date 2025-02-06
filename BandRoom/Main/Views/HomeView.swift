import SwiftUI

struct HomeView: View {
    @AppStorage("xp") private var xp: Int = 0
    @AppStorage("currentLessonIndex") private var currentLessonIndex: Int = 0
    @AppStorage("completedLessons") private var completedLessons: String = ""

    @State private var selectedLesson: LessonUI?
    @State private var showLessonPopup = false
    @State private var navigateToQuiz = false

    let lessons = [
        LessonUI(id: "Lesson 1", title: "SECTION 1, UNIT 1", title2: "Introduction to Notes", icon: "music.note.list"),
        LessonUI(id: "Lesson 2", title: "SECTION 1, UNIT 2", title2: "Introduction to Notes", icon: "music.note.list"),
        LessonUI(id: "Lesson 3", title: "SECTION 1, UNIT 3", title2: "Introduction to Notes", icon: "music.note.list"),
        LessonUI(id: "Lesson 4", title: "SECTION 1, UNIT 4", title2: "Introduction to Notes", icon: "music.note.list"),
        LessonUI(id: "Lesson 5", title: "SECTION 1, UNIT 5", title2: "Introduction to Notes", icon: "music.note.list")
    ]

    var body: some View {
        ZStack {
            VStack {
                // 👤 Profile & XP Progress
                userProfileSection()
                
                // 📚 Lessons List
                lessonScrollView()
            }
            .onAppear {
                refreshLessonProgress()
            }
            .navigationDestination(isPresented: $navigateToQuiz) {
                if let selectedLesson = selectedLesson {
                    let lessonNumber = extractLessonNumber(from: selectedLesson.id)
                    QuizView(lessonNumber: lessonNumber, onComplete: markLessonCompleted)
                }
            }

            // ✨ Floating Lesson Popup
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
            }
        }
        .background(Color(.systemGray6).edgesIgnoringSafeArea(.all))
    }

    // 🏆 Profile & XP Progress Bar
    private func userProfileSection() -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "person.crop.circle.fill")
                    .resizable()
                    .frame(width: 50, height: 50)
                    .foregroundColor(.blue)

                VStack(alignment: .leading) {
                    Text("Welcome Back!")
                        .font(.headline)

                    Text("XP: \(xp)")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                Spacer()
            }

            // 🎯 XP Progress Bar
            ProgressView(value: Double(xp) / 100.0)
                .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                .frame(height: 8)
                .clipShape(Capsule())
                .background(Color.white.opacity(0.2))
                .padding(.top)
            
            Text("LEVEL UP at 100 XP!")
                .font(.subheadline)
                .foregroundColor(.gray)
                .padding(.top, 2)
        }
        .padding(.horizontal)
        .padding(.top, 20)
    }

    // 📖 Lesson Scroll View
    private func lessonScrollView() -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                Text("Grade 1")
                    .font(.title2.bold())
                    .padding(.horizontal)
                    .padding(.top, 10)

                ForEach(lessons.indices, id: \.self) { index in
                    let isCompleted = isLessonCompleted(lessonID: lessons[index].id)
                    let isUnlocked = index <= currentLessonIndex

                    LessonButton(
                        lesson: lessons[index],
                        isUnlocked: isUnlocked,
                        isCompleted: isCompleted
                    ) {
                        if isUnlocked {
                            selectedLesson = lessons[index]
                            showLessonPopup = true
                        }
                    }
                }
            }
            .padding(.horizontal)
        }
    }

    // 🔄 Refresh Lesson Progress
    private func refreshLessonProgress() {
        let savedLessonIndex = UserDefaults.standard.integer(forKey: "currentLessonIndex")
        currentLessonIndex = savedLessonIndex
    }

    // 🔢 Extract Lesson Number
    private func extractLessonNumber(from id: String) -> Int {
        return Int(id.split(separator: " ").last!) ?? 1
    }

    // ✅ Mark Lesson as Completed
    private func markLessonCompleted(lessonNumber: Int) {
        let lessonID = lessons[lessonNumber - 1].id
        var completedSet = Set(completedLessons.split(separator: ",").map(String.init))
        completedSet.insert(lessonID)

        completedLessons = completedSet.joined(separator: ",")

        if lessonNumber - 1 == currentLessonIndex {
            currentLessonIndex += 1
        }

        xp += 10 // 🎉 Earn 10 XP per lesson
    }

    // ✅ Check if Lesson is Completed
    private func isLessonCompleted(lessonID: String) -> Bool {
        return completedLessons.split(separator: ",").map(String.init).contains(lessonID)
    }
}

// 🎵 Updated UI Model
struct LessonUI: Identifiable {
    let id: String
    let title: String
    let title2: String
    let icon: String
}

// 📖 Clean Lesson Button (with `title2` added back)
struct LessonButton: View {
    let lesson: LessonUI
    let isUnlocked: Bool
    let isCompleted: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: {
            if isUnlocked {
                onTap()
            }
        }) {
            HStack {
                Image(systemName: lesson.icon)
                    .resizable()
                    .frame(width: 30, height: 30)
                    .foregroundColor(isUnlocked ? .blue : .gray)

                VStack(alignment: .leading, spacing: 4) {
                    Text(lesson.title)
                        .font(.subheadline)
                        .foregroundColor(isUnlocked ? .primary : .gray)

                    Text(lesson.title2) // 🔥 `title2` ADDED BACK HERE
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(isUnlocked ? .primary : .gray)
                }

                Spacer()

                if isCompleted {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                } else if !isUnlocked {
                    Image(systemName: "lock.fill")
                        .foregroundColor(.gray)
                }
            }
            .padding()
            .background(isUnlocked ? Color.white : Color.gray.opacity(0.3))
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .shadow(radius: isUnlocked ? 5 : 2)
        }
        .disabled(!isUnlocked)
    }
}

// ✅ Preview
#Preview {
    HomeView()
}
