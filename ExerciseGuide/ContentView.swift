import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = ExerciseViewModel() // ViewModel for exercises
    @State private var exerciseName: String = ""
    @State private var selectedType: String? = nil
    @State private var selectedMuscle: String? = nil
    @State private var difficulty: Double = 1.0
    
    let exerciseTypes = ["", "cardio", "olympic_weightlifting", "plyometrics", "powerlifting", "strength", "stretching", "strongman"]
    let muscleGroups = ["", "abdominals", "abductors", "adductors", "biceps", "calves", "chest", "forearms", "glutes", "hamstrings", "lats", "lower_back", "middle_back", "neck", "quadriceps", "traps", "triceps"]
    let difficultyLevels = ["beginner", "intermediate", "expert"]
    
    @State private var navigateToResults = false // State to control navigation
    @State private var navigateToSavedExercises = false // State for the new saved exercises navigation
    
    
    @State var savedExercises : [Exercise] = []

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Exercise Details")) {
                    TextField("Enter exercise name", text: $exerciseName)
                    
                    Picker("Select Exercise Type", selection: Binding(get: {
                        selectedType ?? ""
                    }, set: {
                        selectedType = $0.isEmpty ? nil : $0
                    })) {
                        ForEach(exerciseTypes, id: \.self) { type in
                            Text(type.isEmpty ? "Any" : type.capitalized).tag(type)
                        }
                    }
                    
                    Picker("Select Target Muscle", selection: Binding(get: {
                        selectedMuscle ?? ""
                    }, set: {
                        selectedMuscle = $0.isEmpty ? nil : $0
                    })) {
                        ForEach(muscleGroups, id: \.self) { muscle in
                            Text(muscle.isEmpty ? "Any" : muscle.capitalized).tag(muscle)
                        }
                    }
                    
                    Text("Difficulty Level: \(difficultyLevels[Int(difficulty)])")
                    Slider(value: $difficulty, in: 0...2, step: 1)
                        .padding()
                }
                
                Section {
                    Button("Search") {
                        print("Search button pressed")
                        print("Selected Muscle: \(selectedMuscle ?? "Any"), Difficulty: \(difficultyLevels[Int(difficulty)])")

                        let difficultyLevel = difficultyLevels[Int(difficulty)]
                        //need to updaate this for all params 
                        viewModel.fetchExercises(name: exerciseName,type: selectedType ?? "" , muscle: selectedMuscle ?? "", difficulty: difficultyLevel)
                    }
                }
                
                if viewModel.isLoading {
                    Text("Loading...")
                } else if let error = viewModel.error {
                    Text("Error: \(error)").foregroundColor(.red)
                }
                
                
                // Navigate to the results view when exercises are loaded
                NavigationLink(
                    destination: ResultView(savedExercises: $savedExercises, exercises: viewModel.exercises),
                    isActive: $navigateToResults,
                    label: { EmptyView() }
                )
                .hidden() // Hide the navigation link for now

                // New NavigationLink to show saved exercises
                NavigationLink(
                    destination: SavedExercisesView(savedExercises: $savedExercises),
                    isActive: $navigateToSavedExercises,
                    label: {
                        Button("View Saved Exercises") {
                            navigateToSavedExercises = true
                        }
                    }
                )
            }
            .navigationBarTitle("Exercise Guide")
            .onChange(of: viewModel.exercises) { exercises in
                // When exercises are fetched successfully, trigger navigation
                if !exercises.isEmpty {
                    navigateToResults = true
                }
            }
            .onAppear {
                self.savedExercises = DatabaseHelper.shared.fetchExercises()
            }
        }
    }
}


#Preview {
    ContentView()
}
