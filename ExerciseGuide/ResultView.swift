import SwiftUI

struct ResultView: View {
    @Binding var savedExercises: [Exercise] // Binding to the saved exercises array
    var exercises: [Exercise] // Original list of exercises

    @State private var exercisesToDisplay: [Exercise] = [] // Filtered exercises

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                //TODO - just need to fix this
                ForEach(exercisesToDisplay) { exercise in // Use the filtered exercises list
                    VStack(alignment: .leading, spacing: 8) {
                        Text(exercise.name)
                            .font(.headline)
                            .foregroundColor(.blue)
                        
                        HStack {
                            Text("Type: \(exercise.type.capitalized)")
                            Spacer()
                            Text("Muscle: \(exercise.muscle.capitalized)")
                        }
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        
                        HStack {
                            Text("Equipment: \(exercise.equipment.capitalized)")
                            Spacer()
                            Text("Difficulty: \(exercise.difficulty.capitalized)")
                        }
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        
                        // Add to Guide button
                        Button(action: {
                            addToGuide(exercise)
                        }) {
                            Text("Add to Guide")
                                .font(.body)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.blue)
                                .cornerRadius(8)
                        }
                        .padding(.top, 10)
                    }
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 10).fill(Color(UIColor.systemGray6)))
                    .shadow(radius: 5)
                    .padding([.leading, .trailing], 10)
                }
            }
            .padding([.top, .bottom], 20)
        }
        .navigationTitle("Exercise Results")
        .onAppear(perform: updateExercisesToDisplay) // Initialize filtered list on appear
    }

    // Function to add exercise to the saved list
    private func addToGuide(_ exercise: Exercise) {
        // Check if the exercise is already in the saved list
        if !savedExercises.contains(where: { $0.name == exercise.name }) {
            DatabaseHelper.shared.insertExercise(exerciseToSave: exercise) // save it
            updateExercisesToDisplay() // Recompute filtered list
        }
    }

    // Update the filtered list of exercises
    private func updateExercisesToDisplay() {
        savedExercises = DatabaseHelper.shared.fetchExercises() // update list
        exercisesToDisplay = exercises.filter { exercise in
            !savedExercises.contains(where: { $0.name == exercise.name }) // Exclude saved exercises
        }
    }
}
