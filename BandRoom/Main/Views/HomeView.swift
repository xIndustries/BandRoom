import SwiftUI

struct HomeView: View {
    @State private var unlockedLessons = 1 // Number of unlocked lessons
    
    let lessons = [
        LessonUI(id: "Lesson1", title: "Introduction to Notes", icon: "music.note", isLocked: false),
        LessonUI(id: "Lesson2", title: "Introduction to Notes - Part 2", icon: "music.quarternote.3", isLocked: true),
        LessonUI(id: "Lesson3", title: "Introduction to Notes - Part 3", icon: "pianokeys", isLocked: true),
        LessonUI(id: "Lesson4", title: "Introduction to Notes - Part 4", icon: "guitars", isLocked: true),
        LessonUI(id: "Lesson5", title: "Introduction to Notes - Part 5", icon: "music.mic", isLocked: true)
    ]
    
    var body: some View {
        NavigationView {
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
                
                // ✅ Moved "Grade 1" INSIDE ScrollView
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        Text("Grade 1")
                            .font(.title2.bold())
                            .foregroundColor(.primary)
                            .padding(.horizontal, 20)

                        ForEach(lessons.indices, id: \.self) { index in
                            LessonButton(lesson: lessons[index], isUnlocked: index < unlockedLessons) {
                                if index == unlockedLessons {
                                    unlockedLessons += 1
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                }
                
                Spacer()
            }
            .navigationTitle("BandRoom")
        }
    }
}

// ✅ Updated UI Model for Lessons
struct LessonUI: Identifiable {
    let id: String
    let title: String
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
            HStack {
                Image(systemName: lesson.icon)
                    .resizable()
                    .frame(width: 40, height: 40)
                    .foregroundColor(isUnlocked ? .blue : .gray)
                
                Text(lesson.title)
                    .font(.headline)
                    .foregroundColor(isUnlocked ? .black : .gray)
                
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

#Preview {
    HomeView()
}
