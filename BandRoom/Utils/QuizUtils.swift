import SwiftUI

/// ✅ Determines the button color based on answer feedback.
func getButtonColor(for option: String, correctAnswer: String, showFeedback: Bool) -> Color {
    if showFeedback {
        return option == correctAnswer ? .green : .red
    }
    return Color.blue
}
