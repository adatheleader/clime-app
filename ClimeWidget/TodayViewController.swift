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
    @IBOutlet weak var currentSummary: UILabel!
    @IBOutlet weak var tempIcon: UIImageView!
    
    let locationManager = CLLocationManager()
    let locale = NSLocale.current
    let supportedLang: [String] = ["ar", "az", "be", "bs", "cs", "de", "el", "en", "es", "fr", "hr", "hu", "id", "it", "is", "kw", "nb", "nl", "pl", "pt", "ru", "sk", "sr", "sv", "tet", "tr", "uk", "x-pig-latin", "zh", "zh-tw"]
    var currentLocation: CLLocation?
    private var didPerformGeocode = false
        
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view from its nib.
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest // GPS
        locationManager.startUpdatingLocation()
        print("viewDidLoad")
        self.currentTemp?.textColor = UIColor.clear
        self.currentSummary?.textColor = UIColor.clear
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
        
        self.currentLocation = location
        print("got coordinates")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        print("viewWillAppear")
        self.retrieveWeatherForecast()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func widgetPerformUpdate(completionHandler: @escaping (NCUpdateResult) -> Void) {
        // Perform any setup necessary in order to update the view.
        print("widgetPerformUpdate")
        self.retrieveWeatherForecast()
        completionHandler(NCUpdateResult.newData)
    }
    
    // MARK: - Weather Fetching
    func retrieveWeatherForecast() {
        
        // Doing some preparations for API call
        var lang = self.locale.languageCode
        if self.supportedLang.contains(lang!) {
            print("Array contains \(lang!)")
        } else {
            print("Array does not contains \(lang!)")
            lang = "en"
        }
        
        if self.currentLocation != nil {
            let longtitude = (self.currentLocation?.coordinate.longitude)!
            let latitude = (self.currentLocation?.coordinate.latitude)!
            let forecastService = ForecastService(APIKey: forecastAPIKey)
            forecastService.getForecast(latitude, long: longtitude, APIoptions: "?units=auto&lang=\(lang!)"){
                (forecast) in
                if let weatherForecast = forecast,
                    let currentWeather = weatherForecast.currentWeather {
                    DispatchQueue.main.async {
                        print("API request init")
                        if let temperature = currentWeather.temperature {
                            self.currentTemp?.textColor = UIColor.darkText
                            self.currentTemp?.text = "\(temperature)º"
                        }
                        
                        /*if let precipitation = currentWeather.precipProbabitily {
                            self.currentRain?.textColor = UIColor.darkText
                            self.currentRain?.text = "\(precipitation)%"
                        }*/
                        
                        if let iconTemp = currentWeather.icon {
                            self.tempIcon?.image = iconTemp
                        }
                    }
                }
            }
        }
    }
    
    
    @IBAction func openApp(_ sender: UITapGestureRecognizer) {
        self.extensionContext?.open(NSURL(string: "foo://")! as URL, completionHandler: nil)
    }
    
    
}
