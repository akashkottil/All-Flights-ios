// Models/FlightTrack/WeatherResponse.swift
import Foundation
import SwiftUI

struct WeatherResponse: Codable {
    let latitude: Double
    let longitude: Double
    let generationtimeMs: Double
    let utcOffsetSeconds: Int
    let timezone: String
    let timezoneAbbreviation: String
    let elevation: Double
    let currentUnits: CurrentUnits
    let current: CurrentWeather
    
    enum CodingKeys: String, CodingKey {
        case latitude, longitude
        case generationtimeMs = "generationtime_ms"
        case utcOffsetSeconds = "utc_offset_seconds"
        case timezone
        case timezoneAbbreviation = "timezone_abbreviation"
        case elevation
        case currentUnits = "current_units"
        case current
    }
}

struct CurrentUnits: Codable {
    let time: String
    let interval: String
    let temperature2m: String
    let isDay: String
    let rain: String
    let weatherCode: String
    
    enum CodingKeys: String, CodingKey {
        case time, interval
        case temperature2m = "temperature_2m"
        case isDay = "is_day"
        case rain
        case weatherCode = "weather_code"
    }
}

struct CurrentWeather: Codable {
    let time: String
    let interval: Int
    let temperature2m: Double
    let isDay: Int
    let rain: Double
    let weatherCode: Int
    
    enum CodingKeys: String, CodingKey {
        case time, interval
        case temperature2m = "temperature_2m"
        case isDay = "is_day"
        case rain
        case weatherCode = "weather_code"
    }
}

// MARK: - Enhanced Weather Extensions using WeatherConditionMapper
extension CurrentWeather {
    var temperatureDisplay: String {
        return "\(Int(temperature2m))°C"
    }
    
    // Updated to use the new WeatherConditionMapper
    var weatherCondition: String {
        return WeatherConditionMapper.getWeatherDescription(code: weatherCode)
    }
    
    // Updated to use the new WeatherConditionMapper with proper day/night logic
    var weatherIcon: String {
        return WeatherConditionMapper.getSFSymbol(code: weatherCode, isDay: isDay)
    }
    
    // New: Get custom weather icon name
    var customWeatherIcon: String {
        return WeatherConditionMapper.getWeatherIcon(code: weatherCode, isDay: isDay)
    }
    
    // New: Get complete weather condition info
    var weatherConditionInfo: WeatherConditionMapper.WeatherCondition {
        return WeatherConditionMapper.getWeatherCondition(code: weatherCode, isDay: isDay)
    }
    
    // New: Get background color for weather card
    var backgroundColor: Color {
        return WeatherConditionMapper.getBackgroundColor(code: weatherCode, isDay: isDay)
    }
    
    // Enhanced weather description with more details
    var detailedWeatherCondition: String {
        let condition = WeatherConditionMapper.getWeatherCondition(code: weatherCode, isDay: isDay)
        let timeOfDay = isDay == 1 ? "Day" : "Night"
        return "\(condition.description) (\(timeOfDay))"
    }
}

// MARK: - Error Handling (Keep existing)
enum WeatherError: LocalizedError {
    case invalidURL
    case invalidResponse
    case noData
    case decodingError(Error)
    case networkError(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid weather API URL"
        case .invalidResponse:
            return "Invalid response from weather service"
        case .noData:
            return "No weather data available"
        case .decodingError(let error):
            return "Weather data parsing error: \(error.localizedDescription)"
        case .networkError(let error):
            return "Weather network error: \(error.localizedDescription)"
        }
    }
}
