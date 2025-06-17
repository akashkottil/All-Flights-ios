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
    let icaoCode: String
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
