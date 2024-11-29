import Foundation
import SQLite3

class DatabaseHelper {
    
    static let shared = DatabaseHelper() // Singleton instance
    private var db: OpaquePointer?
    
    private init() {
        openDatabase()
        createTable() // Ensure table is created when the app runs
    }
    
    // Open the SQLite database
    private func openDatabase() {
        let path = getDatabasePath()
        
        if sqlite3_open_v2(path, &db, SQLITE_OPEN_CREATE | SQLITE_OPEN_READWRITE, nil) != SQLITE_OK {
            print("Error opening database")
        } else {
            print("Successfully opened database at \(path)")
        }
    }
    
    // Get the path to the SQLite database
    private func getDatabasePath() -> String {
        let fileManager = FileManager.default
        let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let databaseURL = documentDirectory.appendingPathComponent("database.sqlite")
        return databaseURL.path
    }
    
    // Create the `SavedExercises` table if it doesn't exist
    private func createTable() {
        let createTableQuery = """
        CREATE TABLE IF NOT EXISTS SavedExercises (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            type TEXT,
            muscle TEXT,
            equipment TEXT,
            difficulty TEXT,
            instructions TEXT
        );
        """
        
        var stmt: OpaquePointer?
        
        if sqlite3_prepare_v2(db, createTableQuery, -1, &stmt, nil) == SQLITE_OK {
            if sqlite3_step(stmt) == SQLITE_DONE {
                print("SavedExercises table created successfully.")
            } else {
                print("Error creating table: \(String(cString: sqlite3_errmsg(db)))")
            }
        } else {
            print("Error preparing statement: \(String(cString: sqlite3_errmsg(db)))")
        }
        
        sqlite3_finalize(stmt)
    }
    
    // Insert an Exercise into the SavedExercises table
    func insertExercise(exerciseToSave: Exercise) {
        let insertQuery = """
        INSERT INTO SavedExercises (name, type, muscle, equipment, difficulty, instructions) 
        VALUES (?, ?, ?, ?, ?, ?);
        """
        var stmt: OpaquePointer?
        
        let nameC = exerciseToSave.name.cString(using: .utf8)
        let typeC = exerciseToSave.type.cString(using: .utf8)
        let muscleC = exerciseToSave.muscle.cString(using: .utf8)
        let equipmentC = exerciseToSave.equipment.cString(using: .utf8)
        let difficultyC = exerciseToSave.difficulty.cString(using: .utf8)
        let instructionsC = exerciseToSave.instructions.cString(using: .utf8)
        
        // Prepare the statement
        if sqlite3_prepare_v2(db, insertQuery, -1, &stmt, nil) == SQLITE_OK {
            // Bind values
            sqlite3_bind_text(stmt, 1, nameC, -1, nil)
            sqlite3_bind_text(stmt, 2, typeC, -1, nil)
            sqlite3_bind_text(stmt, 3, muscleC, -1, nil)
            sqlite3_bind_text(stmt, 4, equipmentC, -1, nil)
            sqlite3_bind_text(stmt, 5, difficultyC, -1, nil)
            sqlite3_bind_text(stmt, 6, instructionsC, -1, nil)
            
            // Debug: Print the full query with actual values
            print("""
            Executing SQL Query:
            \(insertQuery)
            Values:
            name: \(exerciseToSave.name)
            type: \(exerciseToSave.type)
            muscle: \(exerciseToSave.muscle)
            equipment: \(exerciseToSave.equipment)
            difficulty: \(exerciseToSave.difficulty)
            instructions: \(exerciseToSave.instructions)
            """)
            
            // Execute the statement
            if sqlite3_step(stmt) == SQLITE_DONE {
                print("Exercise inserted successfully.")
            } else {
                print("Error inserting exercise: \(String(cString: sqlite3_errmsg(db)))")
            }
        } else {
            print("Error preparing insert statement: \(String(cString: sqlite3_errmsg(db)))")
        }
        
        sqlite3_finalize(stmt)
    }

    
    // Update an Exercise in the SavedExercises table
    func updateExercise(exercise: Exercise, id: Int) {
        let updateQuery = """
        UPDATE SavedExercises 
        SET name = ?, type = ?, muscle = ?, equipment = ?, difficulty = ?, instructions = ? 
        WHERE id = ?;
        """
        var stmt: OpaquePointer?
        
        if sqlite3_prepare_v2(db, updateQuery, -1, &stmt, nil) == SQLITE_OK {
            sqlite3_bind_text(stmt, 1, exercise.name.cString(using: .utf8), -1, nil)
            sqlite3_bind_text(stmt, 2, exercise.type.cString(using: .utf8), -1, nil)
            sqlite3_bind_text(stmt, 3, exercise.muscle.cString(using: .utf8), -1, nil)
            sqlite3_bind_text(stmt, 4, exercise.equipment.cString(using: .utf8), -1, nil)
            sqlite3_bind_text(stmt, 5, exercise.difficulty.cString(using: .utf8), -1, nil)
            sqlite3_bind_text(stmt, 6, exercise.instructions.cString(using: .utf8), -1, nil)
            sqlite3_bind_int(stmt, 7, Int32(id))
            
            if sqlite3_step(stmt) == SQLITE_DONE {
                print("Exercise updated successfully.")
            } else {
                print("Error updating exercise: \(String(cString: sqlite3_errmsg(db)))")
            }
        } else {
            print("Error preparing update statement: \(String(cString: sqlite3_errmsg(db)))")
        }
        
        sqlite3_finalize(stmt)
    }
    
    func fetchExercises() -> [Exercise] {
        var exercises : [Exercise] = []
        let fetchQuery = "SELECT * FROM SavedExercises;"
        var stmt: OpaquePointer?
        
        // Prepare the query
        if sqlite3_prepare_v2(db, fetchQuery, -1, &stmt, nil) == SQLITE_OK {
            while sqlite3_step(stmt) == SQLITE_ROW {
                // Fetching each column based on their index in the table
                let id = sqlite3_column_int(stmt, 0) // Assuming `id` is the first column (auto-increment)
                let name = String(cString: sqlite3_column_text(stmt, 1)) // Second column
                let type = String(cString: sqlite3_column_text(stmt, 2)) // Third column
                let muscle = String(cString: sqlite3_column_text(stmt, 3)) // Fourth column
                let equipment = String(cString: sqlite3_column_text(stmt, 4)) // Fifth column
                let difficulty = String(cString: sqlite3_column_text(stmt, 5)) // Sixth column
                let instructions = String(cString: sqlite3_column_text(stmt, 6)) // Seventh column

                // Debugging: Printing column values fetched from the query
                print("Results for fetching exercises:")
                print("id: \(id), name: \(name), type: \(type), muscle: \(muscle), equipment: \(equipment), difficulty: \(difficulty), instructions: \(instructions)")
                
                // Create Exercise object with the fetched data
                let exercise = Exercise(
                    name: name,
                    type: type,
                    muscle: muscle,
                    equipment: equipment,
                    difficulty: difficulty,
                    instructions: instructions
                )
                
                // Append the exercise to the array
                exercises.append(exercise)
            }
        } else {
            print("Error preparing statement: \(String(cString: sqlite3_errmsg(db)))")
        }
        
        // Finalize the statement to release resources
        sqlite3_finalize(stmt)
        return exercises
    }

    
    // Delete an Exercise from the SavedExercises table
    func deleteExercise(name: String) {
        let deleteQuery = "DELETE FROM SavedExercises WHERE name = ?;"
        var stmt: OpaquePointer?
        
        if sqlite3_prepare_v2(db, deleteQuery, -1, &stmt, nil) == SQLITE_OK {
            let nameCString = name.cString(using: .utf8)
            sqlite3_bind_text(stmt, 1, nameCString, -1, nil)
            
            if sqlite3_step(stmt) == SQLITE_DONE {
                print("Exercise deleted successfully.")
            } else {
                print("Error deleting exercise: \(String(cString: sqlite3_errmsg(db)))")
            }
        } else {
            print("Error preparing delete statement: \(String(cString: sqlite3_errmsg(db)))")
        }
        
        sqlite3_finalize(stmt)
    }
    
    // Close the database connection
    deinit {
        sqlite3_close(db)
    }
}
