//
//  TodayViewController.swift
//  ClimeWidget
//
//  Created by Лидия Хашина on 07.10.16.
//  Copyright © 2016 Lydia Khashina. All rights reserved.
//

import UIKit
import NotificationCenter
import CoreLocation

class TodayViewController: UIViewController, NCWidgetProviding, CLLocationManagerDelegate {
    
    @IBOutlet weak var currentTemp: UILabel!
    @IBOutlet weak var currentRain: UILabel!
    @IBOutlet weak var tempIcon: UIImageView!
    
    
    let locationManager = CLLocationManager()
    
    var latitude: Double = 0.0
    var longtitude: Double = 0.0
    var countryCode: String = "en"
    
    let locale = NSLocale.current
    
    let supportedLang: [String] = ["ar", "az", "be", "bs", "cs", "de", "el", "en", "es", "fr", "hr", "hu", "id", "it", "is", "kw", "nb", "nl", "pl", "pt", "ru", "sk", "sr", "sv", "tet", "tr", "uk", "x-pig-latin", "zh", "zh-tw"]
    
    
    var temp: String = "--"
    var rain: String = "--"
    var icon: UIImage = #imageLiteral(resourceName: "default")
    
    private var didPerformGeocode = false
        
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view from its nib.
        
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // if we don't have a valid location, exit
        guard let location = locations.first , location.horizontalAccuracy >= 0 else { return }
        
        // or if we have already searched, return
        guard !didPerformGeocode else { return }
        
        // otherwise, update state variable, stop location services and start geocode
        didPerformGeocode = true
        locationManager.stopUpdatingLocation()
        print("stop updating location")
        
        CLGeocoder().reverseGeocodeLocation(location) { placemarks, error in
            let placemark = placemarks?.first
            
            // if there's an error or no placemark, then exit
            guard error == nil && placemark != nil else {
                print(error)
                return
            }
            
            let lang = self.locale.languageCode
            
            if self.supportedLang.contains(lang!) {
                print("Array contains \(lang!)")
                self.countryCode = lang!
            } else {
                print("Array does not contains \(lang!)")
                self.countryCode = "en"
            }
            self.longtitude = (placemark?.location?.coordinate.longitude)!
            self.latitude = (placemark?.location?.coordinate.latitude)!
            self.retrieveWeatherForecast(lat: self.latitude, long: self.longtitude)
            print("got country code and coordinates")
        }
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func widgetPerformUpdate(completionHandler: @escaping (NCUpdateResult) -> Void) {
        // Perform any setup necessary in order to update the view.
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest // GPS
        locationManager.startUpdatingLocation()
        
        self.currentTemp?.text = temp
        self.currentRain?.text = rain
        self.tempIcon.image = icon
        completionHandler(NCUpdateResult.newData)
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
                        self.temp = "\(temperature)º"
                        //print(self.temp)
                        self.currentTemp?.text = "\(temperature)º"
                    }
                    
                    if let precipitation = currentWeather.precipProbabitily {
                        self.rain = "\(precipitation)%"
                        self.currentRain?.text = "\(precipitation)%"
                    }
                    
                    if let iconTemp = currentWeather.icon {
                        self.icon = iconTemp
                        self.tempIcon?.image = iconTemp
                    }
                    
                    //self.weeklyWeather = weatherForecast.weekly
                    
                    /*if let highTemp = self.weeklyWeather.first?.maxTemperature,
                        let lowTemp = self.weeklyWeather.first?.minTemperature {
                        self.currentTemperatureRangeLabel?.text = "↑\(highTemp)º ↓\(lowTemp)º"
                    }
                    self.locationManager.stopUpdatingLocation()
                    self.tableView.reloadData()*/
                }
            }
        }
    }
    
}
