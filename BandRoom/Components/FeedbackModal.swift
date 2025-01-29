import SwiftUI

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
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(red: 0.1, green: 0.1, blue: 0.1))
        .cornerRadius(20, corners: [.topLeft, .topRight])
        .ignoresSafeArea()
    }
}

// ✅ Custom Rounded Corner Implementation
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

// ✅ Fixed Preview with Mock Data
#Preview {
    FeedbackModal(
        isCorrect: false, // Example: Incorrect answer
        correctAnswer: "C",
        nextAction: { print("Next question triggered") }
    )
}
