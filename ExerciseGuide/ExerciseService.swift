import Foundation

class ExerciseService {
    private let baseURL = "https://api.api-ninjas.com/v1/exercises"
    
    // The function to fetch exercises from the API
    func fetchExercises(name: String, type: String?, muscle: String?, difficulty: String, completion: @escaping (Result<[Exercise], Error>) -> Void) {
        // Construct the API URL with optional parameters
        var queryItems: [URLQueryItem] = []
        
        if let muscle = muscle, !muscle.isEmpty {
            queryItems.append(URLQueryItem(name: "muscle", value: muscle))
        }
        if let type = type, !type.isEmpty {
            queryItems.append(URLQueryItem(name: "type", value: type))
        }
        if !name.isEmpty {
            queryItems.append(URLQueryItem(name: "name", value: name))
        }
        
        queryItems.append(URLQueryItem(name: "difficulty", value: difficulty))
        
        var urlComponents = URLComponents(string: baseURL)!
        urlComponents.queryItems = queryItems
        
        guard let url = urlComponents.url else {
            completion(.failure(NSError(domain: "Invalid URL", code: 0, userInfo: nil)))
            return
        }
        
        var request = URLRequest(url: url)
        request.addValue("ENTERAPIKEYHERE", forHTTPHeaderField: "X-Api-Key")
        
        print("URL Request: \(request)") // Debug the request details
        
        // Perform the network request
        URLSession.shared.dataTask(with: request) { data, response, error in
            // Output error if any
            if let error = error {
                print("Error: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            
            // Output full response details
            if let httpResponse = response as? HTTPURLResponse {
                print("HTTP Status Code: \(httpResponse.statusCode)")
                print("HTTP Headers: \(httpResponse.allHeaderFields)")
            }
            
            // Print raw response body
            if let data = data {
                if let rawResponse = String(data: data, encoding: .utf8) {
                    print("Raw Response Body: \(rawResponse)")
                } else {
                    print("Unable to decode response body to string.")
                }
            } else {
                print("No response data.")
            }
            
            // Ensure data exists
            guard let data = data else {
                completion(.failure(NSError(domain: "No Data", code: 0, userInfo: nil)))
                return
            }
            
            // Decode the response into an array of Exercise objects
            do {
                let exercises = try JSONDecoder().decode([Exercise].self, from: data)
                completion(.success(exercises))
            } catch {
                print("Decoding Error: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }.resume()
    }
}
