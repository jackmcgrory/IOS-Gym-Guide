import Foundation
import Combine

class ExerciseViewModel: ObservableObject {
    @Published var exercises: [Exercise] = []  // List of exercises
    @Published var isLoading: Bool = false      // Loading state
    @Published var error: String? = nil         // Error message

    private var cancellables: Set<AnyCancellable> = []

    private let exerciseService = ExerciseService()

    // Function to fetch exercises based on muscle and difficulty level
    func fetchExercises(name: String, type: String, muscle: String, difficulty: String) {
        isLoading = true  // Start loading

        exerciseService.fetchExercises(name: name, type: type ,muscle: muscle, difficulty: difficulty) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false // Stop loading
                switch result {
                case .success(let exercises):
                    self?.exercises = exercises  // Update the exercises list
                case .failure(let error):
                    self?.error = error.localizedDescription  // Set error message
                }
            }
        }
    }
}
