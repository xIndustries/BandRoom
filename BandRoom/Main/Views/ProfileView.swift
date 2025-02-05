import SwiftUI

struct ProfileView: View {
    @AppStorage("xp") private var xp: Int = 0
    @AppStorage("streak") private var streak: Int = 0
    @AppStorage("currentLessonIndex") private var currentLessonIndex: Int = 0
    @AppStorage("completedLessons") private var completedLessons: String = ""
    
    // ❤️ Heart System
    @AppStorage("hearts") private var hearts: Int = 5
    @AppStorage("lastHeartUpdate") private var lastHeartUpdate: TimeInterval = Date().timeIntervalSince1970

    @State private var showResetAlert = false
    @State private var countdownText: String = "All hearts full!" // ✅ Real-time countdown

    var body: some View {
        VStack(spacing: 20) {
            Text("Profile")
                .font(.largeTitle)
                .bold()

            // 🏆 XP & Streak Section
            VStack {
                HStack {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("XP: \(xp)")
                            .font(.title2)
                            .bold()
                            .foregroundColor(.blue)

                        Text("Streak: \(streak) Days")
                            .font(.title3)
                            .foregroundColor(.green)
                    }
                    
                    Spacer()
                    
                    // ❤️ Heart Display
                    HStack {
                        ForEach(0..<hearts, id: \.self) { _ in
                            Image(systemName: "heart.fill")
                                .foregroundColor(.red)
                        }
                        ForEach(0..<(5 - hearts), id: \.self) { _ in
                            Image(systemName: "heart")
                                .foregroundColor(.gray)
                        }
                    }
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)

            // ❤️ Next Heart Regeneration Timer (Real-Time)
            if hearts < 5 {
                Text(countdownText)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .onAppear {
                        startCountdownTimer() // ✅ Start real-time updates
                    }
            }

            // 🔄 Reset Button with Confirmation Alert
            Button(action: {
                showResetAlert = true
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
                message: Text("This will erase all XP, hearts, streaks, and lesson progress."),
                primaryButton: .destructive(Text("Reset")) {
                    resetUserProgress()
                },
                secondaryButton: .cancel()
            )
        }
    }

    // ✅ Start the real-time countdown timer
    private func startCountdownTimer() {
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            countdownText = nextHeartRegenerationTime()
            restoreHeartsIfNeeded() // ✅ Automatically restores hearts in real-time
        }
    }

    // ✅ Restore 1 heart every 10 seconds (Max: 5)
    private func restoreHeartsIfNeeded() {
        let currentTime = Date().timeIntervalSince1970
        let elapsedTime = currentTime - lastHeartUpdate

        let secondsPassed = Int(elapsedTime) // Convert to seconds
        let heartRestoreTime = 10 // ✅ Change from 3600s (1 hour) to 10s

        if secondsPassed >= heartRestoreTime && hearts < 5 {
            let heartsToRestore = min(secondsPassed / heartRestoreTime, 5 - hearts) // Prevent exceeding max
            hearts += heartsToRestore
            lastHeartUpdate = currentTime
            print("❤️ Restored \(heartsToRestore) hearts! Current: \(hearts)")
        }
    }

    // ✅ Reset UserDefaults for XP, Streaks, Hearts, and Lessons
    private func resetUserProgress() {
        UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
        UserDefaults.standard.synchronize()
        
        xp = 0
        streak = 0
        currentLessonIndex = 0
        completedLessons = ""
        hearts = 5
        lastHeartUpdate = Date().timeIntervalSince1970

        print("✅ User Progress Reset Successfully")
    }

    // ✅ Calculate next heart regeneration time (Real-Time)
    private func nextHeartRegenerationTime() -> String {
        let currentTime = Date().timeIntervalSince1970
        let elapsedTime = currentTime - lastHeartUpdate
        let timeRemaining = max(10 - elapsedTime, 0) // ✅ Change from 3600s to 10s

        let secondsRemaining = Int(timeRemaining) % 60
        
        if hearts == 5 {
            return "All hearts full!"
        } else {
            return "Next heart in \(secondsRemaining)s"
        }
    }
}

#Preview {
    ProfileView()
}
