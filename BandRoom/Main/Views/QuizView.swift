import SwiftUI

struct QuizView: View {
    let lessonNumber: Int
    @State private var questions: [Question] = []
    @State private var currentQuestionIndex = 0
    @State private var selectedAnswer: String?
    @State private var showFeedback = false
    @State private var isCorrect: Bool?
    @State private var showResultModal = false
    @State private var quizCompleted = false // ✅ Show completion screen after last question
    @State private var selectedDetent: PresentationDetent = .fraction(0.3) // ✅ Prevents dragging up

    var body: some View {
        NavigationStack {
            VStack {
                if questions.isEmpty {
                    ProgressView("Loading Questions...")
                        .onAppear { loadQuestions() }
                } else if quizCompleted {
                    // ✅ Show Completion Screen instead of the Quiz
                    QuizCompletedView()
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
            .navigationTitle("Quiz - Lesson \(lessonNumber)")
            .sheet(isPresented: $showResultModal) {
                FeedbackModal(isCorrect: isCorrect ?? false, correctAnswer: questions[currentQuestionIndex].correctAnswer) {
                    nextQuestion()
                }
                .interactiveDismissDisabled() // ✅ Prevent swipe-to-dismiss
                .presentationDetents([.fraction(0.3)], selection: $selectedDetent) // ✅ Prevents dragging up
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
        guard let question = questions[safe: currentQuestionIndex] else { return }
        isCorrect = option == question.correctAnswer
        showFeedback = true
        
        // ✅ Only show modal if NOT last question
        if currentQuestionIndex + 1 < questions.count {
            showResultModal = true
        } else {
            quizCompleted = true // ✅ Show completion screen instead of modal
        }
    }
    
    // ✅ Move to the next question
    func nextQuestion() {
        if currentQuestionIndex + 1 < questions.count {
            currentQuestionIndex += 1
            selectedAnswer = nil
            showFeedback = false
            isCorrect = nil
            showResultModal = false // ✅ Close modal only when Next is pressed
        } else {
            quizCompleted = true // ✅ Set to true when the last question is answered
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

// ✅ Helper to prevent out-of-range errors
extension Array {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

// ✅ "Quiz Completed" Screen
struct QuizCompletedView: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("🎉 Quiz Completed!")
                .font(.largeTitle)
                .bold()
            
            Text("Well done! You've finished this lesson.")
                .font(.headline)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button(action: {
                // Navigate back or restart logic
            }) {
                Text("Return to Home")
                    .bold()
                    .frame(maxWidth: .infinity, minHeight: 50)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .padding(.horizontal, 16)
            }
            
            Button(action: {
                // Show quiz review logic
            }) {
                Text("Review Answers")
                    .bold()
                    .frame(maxWidth: .infinity, minHeight: 50)
                    .background(Color.gray)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .padding(.horizontal, 16)
            }
        }
        .padding()
        .navigationTitle("Quiz Completed")
    }
}

// ✅ Modal View for Feedback with Custom Background & Rounded Corners
struct FeedbackModal: View {
    let isCorrect: Bool
    let correctAnswer: String
    let nextAction: () -> Void
    
    var body: some View {
        VStack(spacing: 12) {
            Text(isCorrect ? "✅ Correct!" : "❌ Incorrect")
                .font(.title)
                .bold()
                .foregroundColor(isCorrect ? .green : .red)
            
            if !isCorrect {
                Text("Correct Answer: \(correctAnswer)")
                    .font(.headline)
                    .foregroundColor(.white.opacity(0.9))
            }
            
            Button(action: nextAction) {
                Text("Next Question")
                    .bold()
                    .frame(maxWidth: .infinity, minHeight: 50)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .padding(.horizontal, 16)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity) // ✅ Expand background
        .background(Color(red: 0.1, green: 0.1, blue: 0.1)) // ✅ Custom Background
        .cornerRadius(20, corners: [.topLeft, .topRight]) // ✅ Rounded Top Corners
        .ignoresSafeArea() // ✅ Cover entire modal background
    }
}

// ✅ Extension for Custom Rounded Corners
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat
    var corners: UIRectCorner

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

// ✅ Fixed Preview
struct QuizView_Previews: PreviewProvider {
    static var previews: some View {
        QuizView(lessonNumber: 1)
    }
}
