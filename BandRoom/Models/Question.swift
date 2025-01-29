import Foundation

struct Question: Codable, Identifiable {
    let id: String
    let category: String
    let questionText: String
    let questionType: QuestionType
    let options: [String]
    let correctAnswer: String
    let image: String?
    let audio: String?
    let difficulty: DifficultyLevel?
    let hint: String?
    let explanation: String?
}

// ✅ Enum for Question Types (Multiple Choice, Audio, Image-based, etc.)
enum QuestionType: String, Codable {
    case multipleChoice
    case audioQuestion
    case imageChoice
}

// ✅ Enum for Difficulty Levels (Optional, but useful for progress tracking)
enum DifficultyLevel: String, Codable {
    case easy
    case medium
    case hard
}
