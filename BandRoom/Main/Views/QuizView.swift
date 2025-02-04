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
    @State private var exitedEarly = false // ✅ Track early exits
    @State private var correctStreak: Int = 0
    @State private var showStreakPopup = false
    @State private var selectedDetent: PresentationDetent = .fraction(0.3)

    @AppStorage("xp") private var xp: Int = 0 // 🏆 XP Tracking
    @AppStorage("hearts") private var hearts: Int = 5 // ❤️ Heart system
    @AppStorage("lastHeartReset") private var lastHeartReset: TimeInterval = Date().timeIntervalSince1970

    @Environment(\.dismiss) var dismiss

    var body: some View {
        ZStack {
            VStack {
                // ❤️ Display Hearts & XP Bar
                HStack {
                    ForEach(0..<hearts, id: \.self) { _ in
                        Image(systemName: "heart.fill")
                            .foregroundColor(.red)
                    }
                    ForEach(0..<(5 - hearts), id: \.self) { _ in
                        Image(systemName: "heart")
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                    
                    // 🏆 XP Display
                    HStack {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                        Text("\(xp) XP")
                            .font(.headline)
                            .foregroundColor(.yellow)
                    }
                }
                .padding()

                if questions.isEmpty {
                    ProgressView("Loading Questions...")
                        .onAppear {
                            resetHeartsIfNeeded()
                            loadQuestions()
                        }
                } else if quizCompleted {
                    QuizCompletedView(onExit: {
                        onComplete(lessonNumber)
                        dismiss()
                    })
                } else {
                    if hearts == 0 {
                        VStack {
                            Text("Out of Hearts! ❤️")
                                .font(.title)
                                .bold()
                                .padding()
                            
                            Button("Try Again Tomorrow") {
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
            .onDisappear { handleExit() }
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
            
            // 🎉 Fixed Streak Popup Auto-Dismiss
            if showStreakPopup {
                StreakCongratsView()
                    .transition(.scale)
                    .onAppear {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            showStreakPopup = true
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                            withAnimation {
                                showStreakPopup = false
                            }
                        }
                    }
            }
        }
    }

    // ✅ Reset hearts if 24 hours have passed
    func resetHeartsIfNeeded() {
        let currentTime = Date().timeIntervalSince1970
        let timeDifference = currentTime - lastHeartReset

        if timeDifference > 86400 { // 24 hours
            hearts = 5
            lastHeartReset = currentTime
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
            xp += 10 // 🏆 Award XP for correct answers
            
            if correctStreak == 5 {
                showStreakPopup = true
                correctStreak = 0
            }
        } else {
            correctStreak = 0
            if hearts > 0 {
                hearts -= 1 // ❤️ Deduct a heart for wrong answer
            }
        }
        
        if currentQuestionIndex + 1 < questions.count {
            showResultModal = true
        } else {
            quizCompleted = true
        }
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
        }
    }

    // ✅ Change button color based on selection
    func getButtonColor(for option: String) -> Color {
        if showFeedback {
            return option == questions[currentQuestionIndex].correctAnswer ? .green : .red
        }
        return Color.blue
    }
}

// ✅ Preview
struct QuizView_Previews: PreviewProvider {
    static var previews: some View {
        QuizView(lessonNumber: 1, onComplete: { _ in })
    }
}
