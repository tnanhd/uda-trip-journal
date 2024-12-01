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

    func register(username _: String, password _: String) async throws -> Token {
        fatalError("Unimplemented register")
    }
    
    func logOut() {
        fatalError("Unimplemented logOut")
    }
    
    func logIn(username: String, password: String) async throws -> Token {
        guard let url = URL(string: "http://localhost:8000/token") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        let credentials = ["username": username, "password": password]
        let formBody = credentials.map { key, value in
            "\(key)=\(value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"
        }.joined(separator: "&")
        request.httpBody = formBody.data(using: .utf8)
        
        let data = try await performRequest(with: request)
        if let token = try? JSONDecoder().decode(Token.self, from: data) {
            print("Login succesful")
            self.token = token
            return token
        } else {
            throw CustomError.message(message: "Failed to decode token")
        }
    }
    
    func createTrip(with _: TripCreate) async throws -> Trip {
        fatalError("Unimplemented createTrip")
    }
    
    func getTrips() async throws -> [Trip] {
        fatalError("Unimplemented getTrips")
    }
    
    func getTrip(withId _: Trip.ID) async throws -> Trip {
        fatalError("Unimplemented getTrip")
    }
    
    func updateTrip(withId _: Trip.ID, and _: TripUpdate) async throws -> Trip {
        fatalError("Unimplemented updateTrip")
    }
    
    func deleteTrip(withId _: Trip.ID) async throws {
        fatalError("Unimplemented deleteTrip")
    }
    
    func createEvent(with _: EventCreate) async throws -> Event {
        fatalError("Unimplemented createEvent")
    }
    
    func updateEvent(withId _: Event.ID, and _: EventUpdate) async throws -> Event {
        fatalError("Unimplemented updateEvent")
    }
    
    func deleteEvent(withId _: Event.ID) async throws {
        fatalError("Unimplemented deleteEvent")
    }
    
    func createMedia(with _: MediaCreate) async throws -> Media {
        fatalError("Unimplemented createMedia")
    }
    
    func deleteMedia(withId _: Media.ID) async throws {
        fatalError("Unimplemented deleteMedia")
    }
    
    private func performRequest(with request: URLRequest) async throws -> Data {
        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw CustomError.networkError
        }
        
        if ([401, 403].contains(httpResponse.statusCode)) {
            let message = try? JSONDecoder().decode(ErrorResponse.self, from: data)
            throw CustomError.invalidInput(detail: message?.detail)
        }
        
        if ((500...599).contains(httpResponse.statusCode)) {
            throw CustomError.serverError(code: httpResponse.statusCode)
        }

        return data
    }
}
