import SwiftUI

struct QuizView: View {
    let lessonNumber: Int
    let onComplete: (Int) -> Void // ✅ Callback for lesson completion

    @State private var questions: [Question] = []
    @State private var currentQuestionIndex = 0
    @State private var selectedAnswer: String?
    @State private var showFeedback = false
    @State private var isCorrect: Bool?
    @State private var showResultModal = false
    @State private var quizCompleted = false
    @State private var exitedEarly = false
    @State private var correctStreak: Int = 0
    @State private var showStreakPopup = false
    @State private var selectedDetent: PresentationDetent = .fraction(0.3)
    @State private var showExitAlert = false // ✅ Exit confirmation alert

    @AppStorage("xp") private var xp: Int = 0
    @AppStorage("hearts") private var hearts: Int = 5
    @AppStorage("lastHeartUpdate") private var lastHeartUpdate: TimeInterval = Date().timeIntervalSince1970

    // ✅ Daily Streak System
    @AppStorage("streak") private var streak: Int = 0
    @AppStorage("lastSessionDate") private var lastSessionDate: String = ""

    @Environment(\.dismiss) var dismiss

    var body: some View {
        ZStack {
            VStack {
                // ❤️ Display Hearts
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
                .padding()

                if questions.isEmpty {
                    ProgressView("Loading Questions...")
                        .onAppear {
                            restoreHeartsIfNeeded()
                            loadQuestions()
                        }
                } else if quizCompleted {
                    QuizCompletedView(onExit: {
                        updateDailyStreak() // ✅ Update streak
                        awardXP() // ✅ XP after lesson completion
                        onComplete(lessonNumber)
                        dismiss()
                    })
                } else {
                    if hearts == 0 {
                        VStack {
                            Text("Out of Hearts! ❤️\nA heart regenerates every hour.")
                                .font(.title)
                                .bold()
                                .multilineTextAlignment(.center)
                                .padding()
                            
                            Button("Try Again Later") {
                                dismiss()
                            }
                            .padding()
                            .background(Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                        }
                    } else {
                        let question = questions[currentQuestionIndex]
                        
                        VStack(spacing: 10) {
                            Text("Question \(currentQuestionIndex + 1) of \(questions.count)")
                                .font(.headline)
                            
                            Text(question.questionText)
                                .font(.title3)
                                .fontWeight(.semibold)
                                .multilineTextAlignment(.center)
                        }
                        
                        if let image = question.image {
                            Image(image)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 200, height: 140)
                                .padding()
                        }
                        
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                            ForEach(question.options, id: \.self) { option in
                                Button(action: {
                                    selectedAnswer = option
                                    checkAnswer(option: option)
                                }) {
                                    Text(option)
                                        .font(.headline)
                                        .foregroundColor(.white)
                                        .frame(width: 160, height: 190)
                                        .background(getButtonColor(for: option))
                                        .cornerRadius(15)
                                        .shadow(radius: 4)
                                }
                                .disabled(showFeedback)
                            }
                        }
                        .padding()
                    }
                }
            }
            .padding()
            .navigationBarBackButtonHidden(true) // ✅ Hide default back button
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        showExitAlert = true // ✅ Trigger exit confirmation
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.title)
                    }
                }
            }
            .onDisappear { handleExit() } // ✅ Keep original functionality
            .sheet(isPresented: $showResultModal) {
                FeedbackModal(
                    isCorrect: isCorrect ?? false,
                    correctAnswer: questions[currentQuestionIndex].correctAnswer
                ) {
                    nextQuestion()
                }
                .interactiveDismissDisabled()
                .presentationDetents([.fraction(0.3)], selection: $selectedDetent)
            }
            
            if showStreakPopup {
                StreakCongratsView()
                    .transition(.scale)
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                            withAnimation { showStreakPopup = false }
                        }
                    }
            }
        }
        .alert(isPresented: $showExitAlert) {
            Alert(
                title: Text("Exit Quiz?"),
                message: Text("Any lost hearts will NOT be restored. Are you sure?"),
                primaryButton: .destructive(Text("Exit")) {
                    handleExit()
                    dismiss()
                },
                secondaryButton: .cancel()
            )
        }
    }

    // ✅ Restore 1 heart per hour (Max: 5)
    func restoreHeartsIfNeeded() {
        let currentTime = Date().timeIntervalSince1970
        let elapsedTime = currentTime - lastHeartUpdate

        let hoursPassed = Int(elapsedTime) / 3600

        if hoursPassed >= 1 && hearts < 5 {
            let heartsToRestore = min(hoursPassed, 5 - hearts)
            hearts += heartsToRestore
            lastHeartUpdate = currentTime
            print("❤️ Restored \(heartsToRestore) hearts! Current: \(hearts)")
        }
    }

    // ✅ Load questions from JSON
    func loadQuestions() {
        let fileName = "Lesson_\(lessonNumber)"
        
        guard let url = Bundle.main.url(forResource: fileName, withExtension: "json") else {
            print("❌ Lesson JSON file not found: \(fileName).json")
            return
        }
        
        do {
            let data = try Data(contentsOf: url)
            let lesson = try JSONDecoder().decode(LessonData.self, from: data)
            questions = lesson.questions
            print("✅ Successfully loaded \(fileName).json")
        } catch {
            print("❌ Error loading questions: \(error)")
        }
    }

    // ✅ Check if the answer is correct and deduct hearts if wrong
    func checkAnswer(option: String) {
        let question = questions[currentQuestionIndex]
        isCorrect = option == question.correctAnswer
        showFeedback = true
        
        if isCorrect == true {
            correctStreak += 1
            
            if correctStreak == 5 {
                showStreakPopup = true
                correctStreak = 0
            }
        } else {
            correctStreak = 0
            if hearts > 0 {
                hearts -= 1
                lastHeartUpdate = Date().timeIntervalSince1970
            }
        }
        
        if currentQuestionIndex + 1 < questions.count {
            showResultModal = true
        } else {
            quizCompleted = true
        }
    }

    // ✅ Award XP when lesson is completed
    func awardXP() {
        xp += 20
    }

    // ✅ Move to the next question
    func nextQuestion() {
        if currentQuestionIndex + 1 < questions.count {
            currentQuestionIndex += 1
            selectedAnswer = nil
            showFeedback = false
            isCorrect = nil
            showResultModal = false
        } else {
            quizCompleted = true
        }
    }
    
    // ✅ Handle user leaving the quiz
    func handleExit() {
        if !quizCompleted {
            exitedEarly = true
            print("❌ User exited early! Hearts will NOT be restored.")
        }
    }

    // ✅ Update daily streak
    func updateDailyStreak() {
        let today = DateFormatter.localizedString(from: Date(), dateStyle: .short, timeStyle: .none)
        if lastSessionDate != today {
            streak += 1
        }
        lastSessionDate = today
    }

    // ✅ Change button color based on selection
    func getButtonColor(for option: String) -> Color {
        if showFeedback {
            return option == questions[currentQuestionIndex].correctAnswer ? .green : .red
        }
        return Color.blue
    }
}

#Preview {
    QuizView(lessonNumber: 1, onComplete: { _ in })
}
