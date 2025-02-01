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
                    QuizCompletedView(onExit: { dismiss() })
                } else {
                    let question = questions[currentQuestionIndex]
                    
                    VStack(spacing: 10) {
                        Text("Question \(currentQuestionIndex + 1) of \(questions.count)")
                            .font(.headline)
                        //                        .padding(.top)
                        
                        Text(question.questionText)
                            .font(.title3)
                            .fontWeight(.semibold)
                            .multilineTextAlignment(.center)
                        //                        .padding()
                    }
                    
                    if let image = question.image {
                        Image(image)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 200, height: 140)
                            .padding()
                    }
                    
                    // ✅ 2x2 Grid for multiple-choice options
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
            
            // ✅ Show Streak Popup when user hits 5 correct answers in a row
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

    // ✅ Load JSON questions
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
    
    // ✅ Check if the selected answer is correct
    func checkAnswer(option: String) {
        let question = questions[currentQuestionIndex]
        isCorrect = option == question.correctAnswer
        showFeedback = true
        
        if isCorrect == true {
            correctStreak += 1
            if correctStreak == 5 {
                showStreakPopup = true
                
                // 🎉 Hide Streak Popup after 4 seconds
                DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                    showStreakPopup = false
                    correctStreak = 0 // Reset streak
                }
            }
        } else {
            correctStreak = 0 // Reset streak if incorrect
        }
        
        if currentQuestionIndex + 1 < questions.count {
            showResultModal = true
        } else {
            quizCompleted = true
            updateLessonProgress() // ✅ Update progress when lesson is finished
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
            updateLessonProgress() // ✅ Update lesson progress in UserDefaults
        }
    }

    // ✅ Save progress when a lesson is completed
    func updateLessonProgress() {
        let currentLesson = UserDefaults.standard.integer(forKey: "currentLessonIndex")
        if currentLesson == lessonNumber - 1 { // ✅ Only update if the lesson was just completed
            UserDefaults.standard.set(currentLesson + 1, forKey: "currentLessonIndex")
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

// ✅ Fixed Preview
struct QuizView_Previews: PreviewProvider {
    static var previews: some View {
        QuizView(lessonNumber: 1)
    }
}
