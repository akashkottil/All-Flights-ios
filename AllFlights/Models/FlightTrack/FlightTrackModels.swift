// Models/FlightTrack/FlightTrackModels.swift
import Foundation

// MARK: - Flight Track Airport Response Models
struct FlightTrackAirportResponse: Codable {
    let count: Int
    let next: String?
    let previous: String?
    let results: [FlightTrackAirport]
}

struct FlightTrackAirport: Codable, Identifiable {
    let id = UUID() // For SwiftUI List identification
    let iataCode: String
    let icaoCode: String? // Make this optional since it can be null
    let name: String
    let country: String
    let countryCode: String
    let isInternational: Bool?
    let isMajor: Bool?
    let city: String
    let location: FlightTrackLocation
    let timezone: FlightTrackTimezone
    
    enum CodingKeys: String, CodingKey {
        case iataCode = "iata_code"
        case icaoCode = "icao_code"
        case name, country
        case countryCode = "country_code"
        case isInternational = "is_international"
        case isMajor = "is_major"
        case city, location, timezone
    }
}

struct FlightTrackLocation: Codable {
    let lat: Double
    let lng: Double
}

struct FlightTrackTimezone: Codable {
    let timezone: String
    let countryCode: String
    let gmt: Double
    let dst: Double
    
    enum CodingKeys: String, CodingKey {
        case timezone
        case countryCode = "country_code"
        case gmt, dst
    }
}

// MARK: - Airline Response Models
struct AirlineResponse: Codable {
    let count: Int
    let next: String?
    let previous: String?
    let results: [FlightTrackAirline]
}

struct FlightTrackAirline: Codable, Identifiable {
    let id = UUID() // For SwiftUI List identification
    let name: String
    let iataCode: String? // Make this optional since it can be null
    let icaoCode: String?
    let isInternational: Bool?
    let website: String?
    let country: String
    let callsign: String?
    let isPassenger: Bool?
    let isCargo: Bool?
    let totalAircrafts: Int?
    let averageFleetAge: Double?
    let accidentsLast5y: Int?
    let crashesLast5y: Int?
    
    enum CodingKeys: String, CodingKey {
        case name
        case iataCode = "iata_code"
        case icaoCode = "icao_code"
        case isInternational = "is_international"
        case website, country, callsign
        case isPassenger = "is_passenger"
        case isCargo = "is_cargo"
        case totalAircrafts = "total_aircrafts"
        case averageFleetAge = "average_fleet_age"
        case accidentsLast5y = "accidents_last_5y"
        case crashesLast5y = "crashes_last_5y"
    }
}

// MARK: - Sheet Source Types
enum SheetSource {
    case trackedTab
    case scheduledDeparture
    case scheduledArrival
}

enum FlightSearchType {
    case departure
    case arrival
}

// MARK: - Tracked Tab Search Types
enum TrackedSearchType {
    case flight    // User entered airline code
    case airport   // User entered airport
}

enum SearchEntityType {
    case airport
    case airline
    case unknown
}
