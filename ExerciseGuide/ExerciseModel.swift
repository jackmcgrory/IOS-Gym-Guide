import Foundation

// Model for each exercise
struct Exercise: Decodable, Equatable, Identifiable {
    var id: String { name }
    let name: String
    let type: String
    let muscle: String
    let equipment: String
    let difficulty: String
    let instructions: String
}

// Wrapper - this is how it is returned from API
struct ExerciseResponse: Decodable {
    let name: String
    let type: String
    let muscle: String
    let equipment: String
    let difficulty: String
    let instructions: String
}
