//
//  WeatherIcon.swift
//  Busanify
//
//  Created by 장예진 on 7/17/24.
//

// SF심볼 참조함.
import UIKit
import WeatherKit

class WeatherIcon {
    static func getWeatherIcon(for currentWeather: CurrentWeather) -> UIImage? {
        let symbolName: String
        
        switch currentWeather.condition {
        case .blowingDust:
            symbolName = "smoke"
        case .clear:
            symbolName = "sun.max"
        case .cloudy, .mostlyCloudy:
            symbolName = "cloud"
        case .foggy:
            symbolName = "cloud.fog"
        case .haze:
            symbolName = "sun.haze"
        case .mostlyClear, .partlyCloudy:
            symbolName = "cloud.sun"
        case .smoky:
            symbolName = "smoke"
        case .breezy, .windy:
            symbolName = "wind"
        case .drizzle:
            symbolName = "cloud.drizzle"
        case .heavyRain, .rain:
            symbolName = "cloud.rain"
        case .isolatedThunderstorms, .scatteredThunderstorms, .strongStorms, .thunderstorms:
            symbolName = "cloud.bolt"
        case .frigid:
            symbolName = "snow"
        case .hail:
            symbolName = "cloud.hail"
        case .hot:
            symbolName = "sun.max.fill"
        case .flurries, .snow, .sunFlurries:
            symbolName = "cloud.snow"
        case .sleet, .wintryMix:
            symbolName = "cloud.sleet"
        case .blizzard, .blowingSnow, .freezingDrizzle, .freezingRain, .heavySnow:
            symbolName = "cloud.snow.fill"
        case .hurricane, .tropicalStorm:
            symbolName = "tropicalstorm"
        case .sunShowers:
            symbolName = "cloud.sun.rain"
        default:
            symbolName = "questionmark.circle"
        }
        
        let config = UIImage.SymbolConfiguration(paletteColors: [.systemBlue, .systemYellow, .systemGray])
        return UIImage(systemName: symbolName)?.applyingSymbolConfiguration(config)
    }
}
