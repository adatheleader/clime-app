//
//  DailyWeather.swift
//  ClimeApp
//
//  Created by Лидия Хашина on 15.09.16.
//  Copyright © 2016 Lydia Khashina. All rights reserved.
//

import Foundation
import UIKit

struct DailyWeather {
    
    let maxTemperature: Int?
    let minTemperature: Int?
    let humidity: Int?
    let precipChance: Int?
    let summary: String?
    var icon: UIImage? = UIImage(named: "default.png")
    var largeIcon: UIImage? = UIImage(named: "default_large.png")
    var sunriseTime: String?
    var sunsetTime: String?
    var day: String?
    let dateFormatter = DateFormatter()
    
    init(dailyWeatherDictionary: [String: AnyObject]) {
        
        maxTemperature = dailyWeatherDictionary["temperatureMax"] as? Int
        minTemperature = dailyWeatherDictionary["temperatureMin"] as? Int
        if let humidityFloat = dailyWeatherDictionary["humidity"] as? Double {
            humidity = Int(humidityFloat * 100)
        } else {
            humidity = nil
        }
        if let precipChanceFloat = dailyWeatherDictionary["precipProbability"] as? Double {
            precipChance = Int(precipChanceFloat * 100)
        } else {
            precipChance = nil
        }
        summary = dailyWeatherDictionary["summary"] as? String
        if let iconString = dailyWeatherDictionary["icon"] as? String,
            let iconEnum = Icon(rawValue: iconString) {
            (icon, largeIcon) = iconEnum.toImage()
        }
        if let sunriseDate = dailyWeatherDictionary["sunriseTime"] as? Double {
            sunriseTime = timeStringFromUnixTime(sunriseDate)
        } else {
            sunriseTime = nil
        }
        if let sunsetDate = dailyWeatherDictionary["sunsetTime"] as? Double {
            sunsetTime = timeStringFromUnixTime(sunsetDate)
        } else {
            sunsetTime = nil
        }
        if let time = dailyWeatherDictionary["time"] as? Double {
            day = dayStringFromTime(time)
        } else {
            day = nil
        }
    }
    
    
    func timeStringFromUnixTime(_ unixTime: Double) -> String {
        let date = Date(timeIntervalSince1970: unixTime)
        
        // Return date formatted as 12 hour time.
        dateFormatter.dateFormat = "hh:mm a"
        return dateFormatter.string(from: date)
    }
    
    func dayStringFromTime(_ time: Double) -> String {
        let date = Date(timeIntervalSince1970: time)
        dateFormatter.locale = Locale(identifier: Locale.current.identifier)
        dateFormatter.dateFormat = "EEEE"
        return dateFormatter.string(from: date)
    }
}
