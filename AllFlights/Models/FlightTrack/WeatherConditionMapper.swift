// Models/Weather/WeatherConditionMapper.swift
import Foundation
import SwiftUI

struct WeatherConditionMapper {
    
    // MARK: - Weather Condition Data Structure
    struct WeatherCondition {
        let description: String
        let iconName: String
        let sfSymbolName: String // Fallback SF Symbol
    }
    
    // MARK: - Main Weather Mapping Function
    static func getWeatherCondition(code: Int, isDay: Int) -> WeatherCondition {
        switch code {
        case 0:
            return WeatherCondition(
                description: "Clear Sky",
                iconName: isDay == 0 ? "ClearMoon" : "ClearSun",
                sfSymbolName: isDay == 0 ? "moon.stars" : "sun.max"
            )
            
        case 1:
            return WeatherCondition(
                description: "Mainly Clear",
                iconName: isDay == 0 ? "ClearMoon" : "ClearSun",
                sfSymbolName: isDay == 0 ? "moon.stars" : "sun.max"
            )
            
        case 2:
            return WeatherCondition(
                description: "Partly Cloudy",
                iconName: isDay == 0 ? "FewCloudMoon" : "Few clouds Sun",
                sfSymbolName: isDay == 0 ? "cloud.moon" : "cloud.sun"
            )
            
        case 3:
            return WeatherCondition(
                description: "Overcast",
                iconName: "BrokenClouds",
                sfSymbolName: "cloud"
            )
            
        case 45:
            return WeatherCondition(
                description: "Fog",
                iconName: "Mist",
                sfSymbolName: "cloud.fog"
            )
            
        case 48:
            return WeatherCondition(
                description: "Depositing Rime Fog",
                iconName: "Mist",
                sfSymbolName: "cloud.fog"
            )
            
        case 51:
            return WeatherCondition(
                description: "Light Drizzle",
                iconName: "ShowerRain",
                sfSymbolName: "cloud.drizzle"
            )
            
        case 53:
            return WeatherCondition(
                description: "Moderate Drizzle",
                iconName: "ShowerRain",
                sfSymbolName: "cloud.drizzle"
            )
            
        case 55:
            return WeatherCondition(
                description: "Dense Drizzle",
                iconName: "ShowerRain",
                sfSymbolName: "cloud.drizzle"
            )
            
        case 56:
            return WeatherCondition(
                description: "Light Freezing Drizzle",
                iconName: "ShowerRain",
                sfSymbolName: "cloud.drizzle"
            )
            
        case 57:
            return WeatherCondition(
                description: "Dense Freezing Drizzle",
                iconName: "ShowerRain",
                sfSymbolName: "cloud.drizzle"
            )
            
        case 61:
            return WeatherCondition(
                description: "Slight Rain",
                iconName: isDay == 0 ? "RainMoon" : "RainSun",
                sfSymbolName: isDay == 0 ? "cloud.moon.rain" : "cloud.sun.rain"
            )
            
        case 63:
            return WeatherCondition(
                description: "Moderate Rain",
                iconName: isDay == 0 ? "RainMoon" : "RainSun",
                sfSymbolName: isDay == 0 ? "cloud.moon.rain" : "cloud.sun.rain"
            )
            
        case 65:
            return WeatherCondition(
                description: "Heavy Rain",
                iconName: isDay == 0 ? "RainMoon" : "RainSun",
                sfSymbolName: "cloud.heavyrain"
            )
            
        case 66:
            return WeatherCondition(
                description: "Light Freezing Rain",
                iconName: isDay == 0 ? "RainMoon" : "RainSun",
                sfSymbolName: "cloud.rain"
            )
            
        case 67:
            return WeatherCondition(
                description: "Heavy Freezing Rain",
                iconName: isDay == 0 ? "RainMoon" : "RainSun",
                sfSymbolName: "cloud.heavyrain"
            )
            
        case 71:
            return WeatherCondition(
                description: "Slight Snow Fall",
                iconName: "Snow",
                sfSymbolName: "cloud.snow"
            )
            
        case 73:
            return WeatherCondition(
                description: "Moderate Snow Fall",
                iconName: "Snow",
                sfSymbolName: "cloud.snow"
            )
            
        case 75:
            return WeatherCondition(
                description: "Heavy Snow Fall",
                iconName: "Snow",
                sfSymbolName: "cloud.snow"
            )
            
        case 77:
            return WeatherCondition(
                description: "Snow Grains",
                iconName: "Snow",
                sfSymbolName: "cloud.snow"
            )
            
        case 80:
            return WeatherCondition(
                description: "Slight Rain Showers",
                iconName: "ShowerRain",
                sfSymbolName: "cloud.rain"
            )
            
        case 81:
            return WeatherCondition(
                description: "Moderate Rain Showers",
                iconName: "ShowerRain",
                sfSymbolName: "cloud.rain"
            )
            
        case 82:
            return WeatherCondition(
                description: "Violent Rain Showers",
                iconName: "ShowerRain",
                sfSymbolName: "cloud.heavyrain"
            )
            
        case 85:
            return WeatherCondition(
                description: "Slight Snow Showers",
                iconName: "Snow",
                sfSymbolName: "cloud.snow"
            )
            
        case 86:
            return WeatherCondition(
                description: "Heavy Snow Showers",
                iconName: "Snow",
                sfSymbolName: "cloud.snow"
            )
            
        case 95:
            return WeatherCondition(
                description: "Slight Thunderstorm",
                iconName: "Thunderstorm",
                sfSymbolName: "cloud.bolt"
            )
            
        case 96:
            return WeatherCondition(
                description: "Thunderstorm with Slight Hail",
                iconName: "Thunderstorm",
                sfSymbolName: "cloud.bolt.rain"
            )
            
        case 99:
            return WeatherCondition(
                description: "Thunderstorm with Heavy Hail",
                iconName: "Thunderstorm",
                sfSymbolName: "cloud.bolt.rain"
            )
            
        default:
            return WeatherCondition(
                description: "Clear Sky",
                iconName: isDay == 0 ? "ClearMoon" : "ClearSun",
                sfSymbolName: isDay == 0 ? "moon.stars" : "sun.max"
            )
        }
    }
    
    // MARK: - Convenience Methods
    static func getWeatherDescription(code: Int) -> String {
        return getWeatherCondition(code: code, isDay: 1).description
    }
    
    static func getWeatherIcon(code: Int, isDay: Int) -> String {
        return getWeatherCondition(code: code, isDay: isDay).iconName
    }
    
    static func getSFSymbol(code: Int, isDay: Int) -> String {
        return getWeatherCondition(code: code, isDay: isDay).sfSymbolName
    }
}

// MARK: - SwiftUI Weather Icon View
struct WeatherIconView: View {
    let weatherCode: Int
    let isDay: Int
    let size: CGFloat
    let useCustomIcons: Bool
    
    init(weatherCode: Int, isDay: Int, size: CGFloat = 40, useCustomIcons: Bool = true) {
        self.weatherCode = weatherCode
        self.isDay = isDay
        self.size = size
        self.useCustomIcons = useCustomIcons
    }
    
    var body: some View {
        let condition = WeatherConditionMapper.getWeatherCondition(code: weatherCode, isDay: isDay)
        
        if useCustomIcons {
            // Try to load custom weather icon first
            if let _ = UIImage(named: condition.iconName) {
                Image(condition.iconName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: size, height: size)
            } else {
                // Fallback to SF Symbol
                Image(systemName: condition.sfSymbolName)
                    .font(.system(size: size * 0.8))
                    .foregroundColor(.primary)
            }
        } else {
            // Use SF Symbol directly
            Image(systemName: condition.sfSymbolName)
                .font(.system(size: size * 0.8))
                .foregroundColor(.primary)
        }
    }
}

// MARK: - Background Color Helper
extension WeatherConditionMapper {
    static func getBackgroundColor(code: Int, isDay: Int) -> Color {
        switch code {
        case 0, 1: // Clear
            return isDay == 1 ? .orange : .indigo
        case 2, 3: // Cloudy
            return .blue
        case 45, 48: // Fog
            return .gray
        case 51...67: // Rain/Drizzle
            return .blue.opacity(0.8)
        case 71...77: // Snow
            return .cyan
        case 80...86: // Showers
            return .blue
        case 95...99: // Thunderstorm
            return .purple
        default:
            return .blue
        }
    }
}
