import Combine
import Foundation

/// An unimplemented version of the `JournalService`.
class LiveJournalService: JournalService {
    private let baseURL = "http://localhost:8000"
    
    @Published private var token: Token?
    var isAuthenticated: AnyPublisher<Bool, Never> {
        $token
            .map { $0 != nil }
            .eraseToAnyPublisher()
    }
    
    func register(username: String, password: String) async throws -> Token {
        let headers = HTTPHeaders.defaultHeaders(token: nil)
        let credentials = Credentials(username: username, password: password)
        let body = try? JSONEncoder().encode(credentials)
        guard let request = createURLRequest(for: "\(baseURL)/register", method: HTTPMethod.post, headers: headers, body: body) else {
            throw URLError(.badURL)
        }
        
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
        var headers = HTTPHeaders.defaultHeaders(token: nil)
        headers[HTTPHeaders.contentType] = "application/x-www-form-urlencoded"
        
        let credentials = ["username": username, "password": password]
        let formBody = credentials.map { key, value in
            "\(key)=\(value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"
        }.joined(separator: "&")
        let body = formBody.data(using: .utf8)
        
        guard let request = createURLRequest(for: "\(baseURL)/token", method: HTTPMethod.post, headers: headers, body: body) else {
            throw URLError(.badURL)
        }
        
        let responseData = try await performRequest(with: request)
        if let token = try? JSONDecoder().decode(Token.self, from: responseData) {
            self.token = token
            return token
        } else {
            throw CustomError.message(message: "Failed to decode token")
        }
    }
    
    func createTrip(with trip: TripCreate) async throws -> Trip {
        let headers = HTTPHeaders.defaultHeaders(token: token?.accessToken)
        let body = try? JSONEncoder().encode(trip)
        guard let request = createURLRequest(for: "\(baseURL)/trips", method: HTTPMethod.post, headers: headers, body: body) else {
            throw URLError(.badURL)
        }
        
        let responseData = try await performRequest(with: request)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        if let trip = try? decoder.decode(Trip.self, from: responseData) {
            return trip
        } else {
            throw CustomError.message(message: "Failed to decode trip")
        }
    }
    
    func getTrips() async throws -> [Trip] {
        let headers = HTTPHeaders.defaultHeaders(token: token?.accessToken)
        guard let request = createURLRequest(for: "\(baseURL)/trips", method: HTTPMethod.get, headers: headers, body: nil) else {
            throw URLError(.badURL)
        }
        
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
        let headers = HTTPHeaders.defaultHeaders(token: token?.accessToken)
        guard let request = createURLRequest(for: "\(baseURL)/trips/\(id)", method: HTTPMethod.get, headers: headers, body: nil) else {
            throw URLError(.badURL)
        }
        
        let responseData = try await performRequest(with: request)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        if let trip = try? decoder.decode(Trip.self, from: responseData) {
            return trip
        } else {
            throw CustomError.message(message: "Failed to decode trip")
        }
    }
    
    func updateTrip(withId id: Trip.ID, and trip: TripUpdate) async throws -> Trip {
        let headers = HTTPHeaders.defaultHeaders(token: token?.accessToken)
        let body = try? JSONEncoder().encode(trip)
        guard let request = createURLRequest(for: "\(baseURL)/trips/\(id)", method: HTTPMethod.put, headers: headers, body: body) else {
            throw URLError(.badURL)
        }
        
        let responseData = try await performRequest(with: request)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        if let trip = try? decoder.decode(Trip.self, from: responseData) {
            return trip
        } else {
            throw CustomError.message(message: "Failed to decode trip")
        }
    }
    
    func deleteTrip(withId id: Trip.ID) async throws {
        var headers = HTTPHeaders.defaultHeaders(token: token?.accessToken)
        headers[HTTPHeaders.accept] = "*/*"
        guard let request = createURLRequest(for: "\(baseURL)/trips/\(id)", method: HTTPMethod.delete, headers: headers, body: nil) else {
            throw URLError(.badURL)
        }
        
        let _ = try await performRequest(with: request)
    }
    
    func createEvent(with event: EventCreate) async throws -> Event {
        let body = try? JSONEncoder().encode(event)
        var headers = HTTPHeaders.defaultHeaders(token: token?.accessToken)
        guard let request = createURLRequest(for: "\(baseURL)/events", method: HTTPMethod.post, headers: headers, body: body) else {
            throw URLError(.badURL)
        }
        
        let responseData = try await performRequest(with: request)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        if let event = try? decoder.decode(Event.self, from: responseData) {
            return event
        } else {
            throw CustomError.message(message: "Failed to decode event")
        }
    }
    
    func updateEvent(withId id: Event.ID, and event: EventUpdate) async throws -> Event {
        let body = try? JSONEncoder().encode(event)
        var headers = HTTPHeaders.defaultHeaders(token: token?.accessToken)
        guard let request = createURLRequest(for: "\(baseURL)/events/\(id)", method: HTTPMethod.put, headers: headers, body: body) else {
            throw URLError(.badURL)
        }
        
        let responseData = try await performRequest(with: request)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        if let event = try? decoder.decode(Event.self, from: responseData) {
            return event
        } else {
            throw CustomError.message(message: "Failed to decode event")
        }
    }
    
    func deleteEvent(withId id: Event.ID) async throws {
        var headers = HTTPHeaders.defaultHeaders(token: token?.accessToken)
        headers[HTTPHeaders.accept] = "*/*"
        guard let request = createURLRequest(for: "\(baseURL)/events/\(id)", method: HTTPMethod.delete, headers: headers, body: nil) else {
            throw URLError(.badURL)
        }
        
        let _ = try await performRequest(with: request)
    }
    
    func createMedia(with media: MediaCreate) async throws -> Media {
        let body = try? JSONEncoder().encode(media)
        var headers = HTTPHeaders.defaultHeaders(token: token?.accessToken)
        guard let request = createURLRequest(for: "\(baseURL)/media", method: HTTPMethod.post, headers: headers, body: body) else {
            throw URLError(.badURL)
        }
        
        let responseData = try await performRequest(with: request)
        if let media = try? JSONDecoder().decode(Media.self, from: responseData) {
            return media
        } else {
            throw CustomError.message(message: "Failed to decode media")
        }
    }
    
    func deleteMedia(withId id: Media.ID) async throws {
        var headers = HTTPHeaders.defaultHeaders(token: token?.accessToken)
        headers[HTTPHeaders.accept] = "*/*"
        guard let request = createURLRequest(for: "\(baseURL)/media/\(id)", method: HTTPMethod.delete, headers: headers, body: nil) else {
            throw URLError(.badURL)
        }
        
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
    
    func createURLRequest(for endpoint: String, method: HTTPMethod, headers: [String: String]?, body: Data?) -> URLRequest? {
        guard let url = URL(string: endpoint) else {
            print("Invalid URL: \(endpoint)")
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        
        if let headers = headers {
            for (key, value) in headers {
                request.setValue(value, forHTTPHeaderField: key)
            }
        }
        
        if let body = body {
            request.httpBody = body
        }
        
        return request
    }
}

struct HTTPHeaders {
    static let contentType = "Content-Type"
    static let authorization = "Authorization"
    static let accept = "accept"
    
    static func defaultHeaders(token: String?) -> [String: String] {
        var headers = [String: String]()
        headers[contentType] = "application/json"
        headers[accept] = "application/json"
        
        if let token = token {
            headers[authorization] = "Bearer \(token)"
        }
        
        return headers
    }
}

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
    case patch = "PATCH"
}
