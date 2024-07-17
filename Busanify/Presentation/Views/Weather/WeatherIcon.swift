//
//  WeatherIcon.swift
//  Busanify
//
//  Created by 장예진 on 7/17/24.
//

import UIKit
import WeatherKit

class WeatherIcon {
    static func getWeatherIcon(for currentWeather: CurrentWeather) -> UIImage? {
        switch currentWeather.condition {
        case .blowingDust:
            return UIImage(systemName: "smoke")
        case .clear:
            return UIImage(systemName: "sun.max")
        case .cloudy, .mostlyCloudy:
            return UIImage(systemName: "cloud")
        case .foggy:
            return UIImage(systemName: "cloud.fog")
        case .haze:
            return UIImage(systemName: "sun.haze")
        case .mostlyClear, .partlyCloudy:
            return UIImage(systemName: "cloud.sun")
        case .smoky:
            return UIImage(systemName: "smoke")
        case .breezy, .windy:
            return UIImage(systemName: "wind")
        case .drizzle:
            return UIImage(systemName: "cloud.drizzle")
        case .heavyRain, .rain:
            return UIImage(systemName: "cloud.rain")
        case .isolatedThunderstorms, .scatteredThunderstorms, .strongStorms, .thunderstorms:
            return UIImage(systemName: "cloud.bolt")
        case .frigid:
            return UIImage(systemName: "snow")
        case .hail:
            return UIImage(systemName: "cloud.hail")
        case .hot:
            return UIImage(systemName: "sun.max.fill")
        case .flurries, .snow, .sunFlurries:
            return UIImage(systemName: "cloud.snow")
        case .sleet, .wintryMix:
            return UIImage(systemName: "cloud.sleet")
        case .blizzard, .blowingSnow, .freezingDrizzle, .freezingRain, .heavySnow:
            return UIImage(systemName: "cloud.snow.fill")
        case .hurricane, .tropicalStorm:
            return UIImage(systemName: "tropicalstorm")
        case .sunShowers:
            return UIImage(systemName: "cloud.sun.rain")
        default:
            return UIImage(systemName: "questionmark.circle")
        }
    }
}
