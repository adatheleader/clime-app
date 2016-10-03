//
//  InterfaceController.swift
//  ClimeAppWatch Extension
//
//  Created by Лидия Хашина on 03.10.16.
//  Copyright © 2016 Lydia Khashina. All rights reserved.
//

import WatchKit
import Foundation
import CoreLocation


class InterfaceController: WKInterfaceController, CLLocationManagerDelegate {
    
    
    @IBOutlet var cityNameLabel: WKInterfaceLabel!
    @IBOutlet var weatherImage: WKInterfaceImage!
    @IBOutlet var currentWeather: WKInterfaceLabel!
    @IBOutlet var rainLabel: WKInterfaceLabel!
    @IBOutlet var minMaxTempLabel: WKInterfaceLabel!
    
    private var didPerformGeocode = false
    let locationManager = CLLocationManager()
    
    var lat: Double = 0.0
    var long: Double = 0.0
    var countryCode: String = "en"
    
    var locationInfo: [String:AnyObject] = [:] {
        didSet {
            self.lat = locationInfo["lat"] as! Double
            self.long = locationInfo["long"] as! Double
            self.countryCode = locationInfo["countryCode"] as! String
            
            let cityname = locationInfo["city"] as! String
            self.cityNameLabel!.setText("\(cityname)")
            
            self.retrieveWeatherForecast(lat: self.lat, long: self.long)
        }
    }
    
    var weeklyWeather: [DailyWeather] = []

    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        // Configure interface objects here.
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        
        
        
        print("willActivate")
        super.willActivate()
    }
    
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    // MARK: - Weather Fetching
    func retrieveWeatherForecast(lat:Double, long:Double) {
        let forecastService = ForecastService(APIKey: forecastAPIKey)
        forecastService.getForecast(lat, long: long, APIoptions: "?units=auto&lang=\(self.countryCode)"){
            (forecast) in
            if let weatherForecast = forecast,
                let currentWeather = weatherForecast.currentWeather {
                DispatchQueue.main.async {
                    print("API request init")
                    if let temperature = currentWeather.temperature {
                        self.currentWeather?.setText("\(temperature)º")
                    }
                    
                    if let precipitation = currentWeather.precipProbabitily {
                        self.rainLabel?.setText("🌧 \(precipitation)%")
                    }
                    
                    if let icon = currentWeather.icon {
                        self.weatherImage?.setImage(icon)
                    }
                    
                    self.weeklyWeather = weatherForecast.weekly
                    
                    if let highTemp = self.weeklyWeather.first?.maxTemperature,
                        let lowTemp = self.weeklyWeather.first?.minTemperature {
                        self.minMaxTempLabel?.setText("↑\(highTemp)º ↓\(lowTemp)º")
                    }
                }
            }
        }
    }
}
