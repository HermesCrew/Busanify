//
//  WeatherIcon.swift
//  Busanify
//
//  Created by 장예진 on 7/26/24.
//

import UIKit
import WeatherKit

class WeatherIcon {
    
    static func getWeatherIcon(for weather: Any) -> UIImage? {
        let symbolName: String
        
        switch weather {
        case let currentWeather as CurrentWeather:
            symbolName = getSymbolName(for: currentWeather.condition)
        case let hourWeather as HourWeather:
            symbolName = getSymbolName(for: hourWeather.condition)
        case let dayWeather as DayWeather:
            symbolName = getSymbolName(for: dayWeather.condition)
        default:
            symbolName = "questionmark.circle"
        }
        
        let config = UIImage.SymbolConfiguration(paletteColors: [.systemBlue, .systemYellow, .systemGray])
        return UIImage(systemName: symbolName)?.applyingSymbolConfiguration(config)
    }
    

    private static func getSymbolName(for condition: WeatherCondition) -> String {
        switch condition {
        case .blowingDust:
            return "smoke"
        case .clear:
            return "sun.max"
        case .cloudy, .mostlyCloudy:
            return "cloud"
        case .foggy:
            return "cloud.fog"
        case .haze:
            return "sun.haze"
        case .mostlyClear, .partlyCloudy:
            return "cloud.sun"
        case .smoky:
            return "smoke"
        case .breezy, .windy:
            return "wind"
        case .drizzle:
            return "cloud.drizzle"
        case .heavyRain, .rain:
            return "cloud.rain"
        case .isolatedThunderstorms, .scatteredThunderstorms, .strongStorms, .thunderstorms:
            return "cloud.bolt"
        case .frigid:
            return "snow"
        case .hail:
            return "cloud.hail"
        case .hot:
            return "sun.max.fill"
        case .flurries, .snow, .sunFlurries:
            return "cloud.snow"
        case .sleet, .wintryMix:
            return "cloud.sleet"
        case .blizzard, .blowingSnow, .freezingDrizzle, .freezingRain, .heavySnow:
            return "cloud.snow.fill"
        case .hurricane, .tropicalStorm:
            return "tropicalstorm"
        case .sunShowers:
            return "cloud.sun.rain"
        default:
            return "questionmark.circle"
        }
    }
}
