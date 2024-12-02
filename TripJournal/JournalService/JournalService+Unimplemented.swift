import Combine
import Foundation

/// An unimplemented version of the `JournalService`.
class UnimplementedJournalService: JournalService {
    @Published private var token: Token?
    var isAuthenticated: AnyPublisher<Bool, Never> {
        $token
            .map { $0 != nil }
            .eraseToAnyPublisher()
    }

    func register(username: String, password: String) async throws -> Token {
        guard let url = URL(string: "http://localhost:8000/register") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "accept")
        
        let credentials = Credentials(username: username, password: password)
        request.httpBody = try? JSONEncoder().encode(credentials)
        
        let responseData = try await performRequest(with: request)
        if let token = try? JSONDecoder().decode(Token.self, from: responseData) {
            self.token = token
            return token
        } else {
            throw CustomError.message(message: "Failed to decode token")
        }
    }
    
    func logOut() {
        self.token = nil
    }
    
    func logIn(username: String, password: String) async throws -> Token {
        guard let url = URL(string: "http://localhost:8000/token") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "accept")
        
        let credentials = ["username": username, "password": password]
        let formBody = credentials.map { key, value in
            "\(key)=\(value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"
        }.joined(separator: "&")
        request.httpBody = formBody.data(using: .utf8)
        
        let responseData = try await performRequest(with: request)
        if let token = try? JSONDecoder().decode(Token.self, from: responseData) {	
            self.token = token
            return token
        } else {
            throw CustomError.message(message: "Failed to decode token")
        }
    }
    
    func createTrip(with trip: TripCreate) async throws -> Trip {
        guard let url = URL(string: "http://localhost:8000/trips") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "accept")
        request.setValue("Bearer \(token?.accessToken ?? "")", forHTTPHeaderField: "Authorization")
        request.httpBody = try? JSONEncoder().encode(trip)
        
        let responseData = try await performRequest(with: request)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        if let trip = try? decoder.decode(Trip.self, from: responseData) {
            return trip
        } else {
            throw CustomError.message(message: "Failed to decode trips")
        }
    }
    
    func getTrips() async throws -> [Trip] {
        guard let url = URL(string: "http://localhost:8000/trips") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "accept")
        request.setValue("Bearer \(token?.accessToken ?? "")", forHTTPHeaderField: "Authorization")
        
        let responseData = try await performRequest(with: request)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        if let trips = try? decoder.decode([Trip].self, from: responseData) {
            return trips
        } else {
            throw CustomError.message(message: "Failed to decode trips")
        }
    }
    
    func getTrip(withId id: Trip.ID) async throws -> Trip {
        guard let url = URL(string: "http://localhost:8000/trips/\(id)") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "accept")
        request.setValue("Bearer \(token?.accessToken ?? "")", forHTTPHeaderField: "Authorization")
        
        let responseData = try await performRequest(with: request)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        if let trip = try? decoder.decode(Trip.self, from: responseData) {
            return trip
        } else {
            throw CustomError.message(message: "Failed to decode trips")
        }
    }
    
    func updateTrip(withId id: Trip.ID, and trip: TripUpdate) async throws -> Trip {
        guard let url = URL(string: "http://localhost:8000/trips/\(id)") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "accept")
        request.setValue("Bearer \(token?.accessToken ?? "")", forHTTPHeaderField: "Authorization")
        request.httpBody = try? JSONEncoder().encode(trip)
        
        let responseData = try await performRequest(with: request)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        if let trip = try? decoder.decode(Trip.self, from: responseData) {
            return trip
        } else {
            throw CustomError.message(message: "Failed to decode trips")
        }
    }
    
    func deleteTrip(withId id: Trip.ID) async throws {
        guard let url = URL(string: "http://localhost:8000/trips/\(id)") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("*/*", forHTTPHeaderField: "accept")
        request.setValue("Bearer \(token?.accessToken ?? "")", forHTTPHeaderField: "Authorization")
        
        let _ = try await performRequest(with: request)
    }
    
    func createEvent(with event: EventCreate) async throws -> Event {
        guard let url = URL(string: "http://localhost:8000/events") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "accept")
        request.setValue("Bearer \(token?.accessToken ?? "")", forHTTPHeaderField: "Authorization")
        request.httpBody = try? JSONEncoder().encode(event)
        
        let responseData = try await performRequest(with: request)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        if let event = try? decoder.decode(Event.self, from: responseData) {
            return event
        } else {
            throw CustomError.message(message: "Failed to decode trips")
        }
    }
    
    func updateEvent(withId _: Event.ID, and _: EventUpdate) async throws -> Event {
        fatalError("Unimplemented updateEvent")
    }
    
    func deleteEvent(withId id: Event.ID) async throws {
        guard let url = URL(string: "http://localhost:8000/events/\(id)") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("*/*", forHTTPHeaderField: "accept")
        request.setValue("Bearer \(token?.accessToken ?? "")", forHTTPHeaderField: "Authorization")
        
        let _ = try await performRequest(with: request)
    }
    
    func createMedia(with media: MediaCreate) async throws -> Media {
        guard let url = URL(string: "http://localhost:8000/media") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "accept")
        request.setValue("Bearer \(token?.accessToken ?? "")", forHTTPHeaderField: "Authorization")
        request.httpBody = try? JSONEncoder().encode(media)
        
        let responseData = try await performRequest(with: request)
        if let media = try? JSONDecoder().decode(Media.self, from: responseData) {
            return media
        } else {
            throw CustomError.message(message: "Failed to decode trips")
        }
    }
    
    func deleteMedia(withId id: Media.ID) async throws {
        guard let url = URL(string: "http://localhost:8000/media/\(id)") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("*/*", forHTTPHeaderField: "accept")
        request.setValue("Bearer \(token?.accessToken ?? "")", forHTTPHeaderField: "Authorization")
        
        let _ = try await performRequest(with: request)
    }
    
    private func performRequest(with request: URLRequest) async throws -> Data {
        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw CustomError.networkError
        }
        
        /* Client error */
        if ((400...499).contains(httpResponse.statusCode)) {
            print("Client error")
            let message = try? JSONDecoder().decode(ErrorResponse.self, from: data)
            throw CustomError.invalidInput(detail: message?.detail)
        }
        
        /* Internal server error */
        if ((500...599).contains(httpResponse.statusCode)) {
            print("Internal server error")
            throw CustomError.serverError(code: httpResponse.statusCode)
        }

        return data
    }
}
