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
                    QuizCompletedView(onExit: { dismiss() }) // ✅ Exit to previous screen
                } else {
                    let question = questions[currentQuestionIndex]
                    
                    Text("Question \(currentQuestionIndex + 1) of \(questions.count)")
                        .font(.headline)
                        .padding(.top)
                    
                    Text(question.questionText)
                        .font(.title2.bold())
                        .multilineTextAlignment(.center)
                        .padding()
                    
                    if let image = question.image {
                        Image(image)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 200, height: 200)
                            .padding()
                    }
                    
                    VStack(spacing: 15) {
                        ForEach(question.options, id: \.self) { option in
                            Button(action: {
                                selectedAnswer = option
                                checkAnswer(option: option)
                            }) {
                                HStack {
                                    Text(option)
                                        .font(.headline)
                                        .foregroundColor(.white)
                                        .padding()
                                        .frame(maxWidth: .infinity)
                                        .background(getButtonColor(for: option))
                                        .cornerRadius(10)
                                }
                            }
                            .disabled(showFeedback)
                        }
                    }
                    .padding()
                }
            }
            .padding()
            .navigationTitle("Quiz - Lesson \(lessonNumber)") // ✅ Uses NavigationStack from MainTabBarView
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
            quizCompleted = true
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
            quizCompleted = true
        }
    }

    func getButtonColor(for option: String) -> Color {
        if showFeedback {
            return option == questions[currentQuestionIndex].correctAnswer ? .green : .red
        }
        return Color.blue
    }
}

struct QuizView_Previews: PreviewProvider {
    static var previews: some View {
        QuizView(lessonNumber: 1)
    }
}
