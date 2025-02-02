import SwiftUI

struct QuizView: View {
    let lessonNumber: Int
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

    @Environment(\.dismiss) var dismiss

    var body: some View {
        ZStack {
            VStack {
                if questions.isEmpty {
                    ProgressView("Loading Questions...")
                        .onAppear { loadQuestions() }
                } else if quizCompleted {
                    QuizCompletedView(onExit: { dismiss() })
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
            .padding()
            .onDisappear {
                print("⏳ onDisappear triggered") // Debug print
                handleExit()
            }
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
                        withAnimation(.easeInOut(duration: 0.3)) {
                            showStreakPopup = true
                        }
                    }
            }
        }
    }

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
    
    func checkAnswer(option: String) {
        let question = questions[currentQuestionIndex]
        isCorrect = option == question.correctAnswer
        showFeedback = true
        
        if isCorrect == true {
            correctStreak += 1
            if correctStreak == 5 {
                showStreakPopup = true
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                    showStreakPopup = false
                    correctStreak = 0
                }
            }
        } else {
            correctStreak = 0
        }
        
        if currentQuestionIndex + 1 < questions.count {
            showResultModal = true
        } else {
            print("✅ Quiz completed!") // Debug print
            quizCompleted = true // ✅ Quiz is complete
        }
    }
    
    func nextQuestion() {
        if currentQuestionIndex + 1 < questions.count {
            currentQuestionIndex += 1
            selectedAnswer = nil
            showFeedback = false
            isCorrect = nil
            showResultModal = false
        } else {
            print("✅ All questions answered! Marking quiz as complete.") // Debug print
            quizCompleted = true
        }
    }

    func handleExit() {
        if !quizCompleted {
            print("❌ User exited early! Progress will NOT be updated.") // Debug print
            exitedEarly = true
        }
        updateLessonProgress()
    }

    func updateLessonProgress() {
        if !quizCompleted || exitedEarly {
            print("🚫 Progress NOT updated. Reason: \(exitedEarly ? "Exited early" : "Quiz not complete")") // Debug print
            return
        }

        let currentLesson = UserDefaults.standard.integer(forKey: "currentLessonIndex")
        if currentLesson == lessonNumber - 1 {
            print("✅ Lesson \(lessonNumber) completed! Unlocking next lesson.") // Debug print
            UserDefaults.standard.set(currentLesson + 1, forKey: "currentLessonIndex")
        }
    }
    
    func getButtonColor(for option: String) -> Color {
        if showFeedback {
            return option == questions[currentQuestionIndex].correctAnswer ? .green : .red
        }
        return Color.blue
    }
}

// ✅ Fixed Preview
struct QuizView_Previews: PreviewProvider {
    static var previews: some View {
        QuizView(lessonNumber: 1)
    }
}
