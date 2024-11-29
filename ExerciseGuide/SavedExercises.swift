import SwiftUI

struct SavedExercisesView: View {
    @Binding var savedExercises: [Exercise]  // Binding to the saved exercises array
    
    // Current index of the exercise being displayed
    @State private var currentIndex = 0
    
    // Function to split the instructions into numbered lines
    func splitInstructions(instructions: String) -> [String] {
        // Split instructions by full stop (period), trimming spaces from each sentence
        let sentences = instructions.split(separator: ".").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
        
        // Return sentences with numbering
        return sentences.enumerated().map { "\($0 + 1). \($1)." }
    }
    
    var body: some View {
        VStack {
            if !savedExercises.isEmpty {
                // Display current exercise
                let currentExercise = savedExercises[currentIndex]
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        Text(currentExercise.name)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Text("Type: \(currentExercise.type.capitalized)")
                        Text("Muscle: \(currentExercise.muscle.capitalized)")
                        Text("Equipment: \(currentExercise.equipment.capitalized)")
                        Text("Difficulty: \(currentExercise.difficulty.capitalized)")
                            .padding(.bottom)
                        
                        Text("Instructions:")
                            .font(.headline)
                        
                        // Split instructions and show each sentence as a numbered line
                        ForEach(splitInstructions(instructions: currentExercise.instructions), id: \.self) { line in
                            Text(line)
                                .font(.body)
                                .foregroundColor(.black)
                                .padding(.top, 2)
                        }
                    }
                    .padding()
                }
                
                // Controls for navigation
                HStack {
                    // Go back to the previous exercise if possible
                    if currentIndex > 0 {
                        Button("Previous") {
                            currentIndex -= 1
                        }
                        .padding()
                    }
                    
                    Spacer()
                    
                    // Go to the next exercise if possible
                    if currentIndex < savedExercises.count - 1 {
                        Button("Next") {
                            currentIndex += 1
                        }
                        .padding()
                    }
                }
                .padding(.bottom)
                
                // Option to remove the current exercise from the saved list
                Button(action: {
                    let exerciseToRemove = savedExercises[currentIndex]
                    DatabaseHelper.shared.deleteExercise(name: exerciseToRemove.name)
                    savedExercises = DatabaseHelper.shared.fetchExercises()
                    
                    // Ensure the currentIndex is valid after the removal
                    if savedExercises.isEmpty {
                        currentIndex = 0 // No exercises left, reset index
                    } else if currentIndex >= savedExercises.count {
                        currentIndex = savedExercises.count - 1 // Adjust index if it's out of range
                    }
                }) {
                    Text("Remove this exercise")
                        .font(.subheadline)
                        .foregroundColor(.red)
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 5).stroke(Color.red))
                }
                .padding(.top)

            } else {
                // If no exercises are saved, show a message
                Text("No saved exercises yet.")
                    .font(.title)
                    .padding()
            }
        }
        .navigationTitle("Saved Exercises")
        .onAppear(
            perform: {
                savedExercises = DatabaseHelper.shared.fetchExercises()
            }
        )
    }
}

