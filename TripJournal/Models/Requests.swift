import Foundation

/// An object that can be used to create a new trip.
struct TripCreate: Encodable {
    let name: String
    let startDate: Date
    let endDate: Date
    
    private enum CodingKeys: String, CodingKey {
        case name
        case startDate = "start_date"
        case endDate = "end_date"
    }
}

/// An object that can be used to update an existing trip.
struct TripUpdate: Encodable {
    let name: String
    let startDate: Date
    let endDate: Date
    
    private enum CodingKeys: String, CodingKey {
        case name
        case startDate = "start_date"
        case endDate = "end_date"
    }
}

/// An object that can be used to create a media.
struct MediaCreate: Encodable {
    let eventId: Event.ID
    let base64Data: Data
    
    private enum CodingKeys: String, CodingKey {
        case eventId = "event_id"
        case base64Data = "base64_data"
    }
}

/// An object that can be used to create a new event.
struct EventCreate: Encodable {
    let tripId: Trip.ID
    let name: String
    let note: String?
    let date: Date
    let location: Location?
    let transitionFromPrevious: String?
    
    private enum CodingKeys: String, CodingKey {
        case tripId = "trip_id"
        case name
        case note
        case date
        case location
        case transitionFromPrevious = "transition_from_previous"
    }
}

/// An object that can be used to update an existing event.
struct EventUpdate: Encodable {
    var name: String
    var note: String?
    var date: Date
    var location: Location?
    var transitionFromPrevious: String?
    
    private enum CodingKeys: String, CodingKey {
        case name
        case note
        case date
        case location
        case transitionFromPrevious = "transition_from_previous"
    }
}

struct Credentials: Encodable {
    let username: String
    let password: String
}
