import SwiftUI

struct ProfileView: View {
    @AppStorage("xp") private var xp: Int = 0 // ✅ Store XP persistently
    @AppStorage("streak") private var streak: Int = 0 // ✅ Store streak persistently
    @AppStorage("currentLessonIndex") private var currentLessonIndex: Int = 0 // ✅ Lesson progress
    @AppStorage("completedLessons") private var completedLessons: String = "" // ✅ Track completed lessons
    
    @State private var showResetAlert = false // ✅ Confirmation alert

    var body: some View {
        VStack(spacing: 20) {
            Text("Profile")
                .font(.largeTitle)
                .bold()

            VStack {
                Text("XP: \(xp)")
                    .font(.title2)
                    .bold()
                    .foregroundColor(.blue)
                
                Text("Streak: \(streak) Days")
                    .font(.title3)
                    .foregroundColor(.green)
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)

            // ✅ Reset Button with Confirmation Alert
            Button(action: {
                showResetAlert = true // ✅ Show alert before reset
            }) {
                Text("Reset Progress")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.red)
                    .cornerRadius(12)
                    .padding(.horizontal, 20)
            }
        }
        .padding()
        .alert(isPresented: $showResetAlert) {
            Alert(
                title: Text("Reset Progress?"),
                message: Text("This will erase all XP, streaks, and lesson progress."),
                primaryButton: .destructive(Text("Reset")) {
                    resetUserProgress()
                },
                secondaryButton: .cancel()
            )
        }
    }

    // ✅ Reset UserDefaults for XP, Streaks, and Lessons
    private func resetUserProgress() {
        UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
        UserDefaults.standard.synchronize()
        
        // ✅ Reset specific stored values
        xp = 0
        streak = 0
        currentLessonIndex = 0
        completedLessons = ""

        print("✅ User Progress Reset Successfully")
    }
}

#Preview {
    ProfileView()
}
