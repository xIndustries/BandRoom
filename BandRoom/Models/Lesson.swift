import Foundation

struct LessonData: Codable {
    let id: String
    let grade: Int
    let section: Int
    let unit: Int
    let name: String
    let questions: [Question]
}
