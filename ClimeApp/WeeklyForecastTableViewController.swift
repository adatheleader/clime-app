//
//  WeeklyForecastTableViewController.swift
//  ClimeApp
//
//  Created by Лидия Хашина on 15.09.16.
//  Copyright © 2016 Lydia Khashina. All rights reserved.
//

import UIKit
import CoreLocation

class WeeklyForecastTableViewController: UITableViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var currentTemperatureLabel: UILabel?
    @IBOutlet weak var currentWeatherIcon: UIImageView?
    @IBOutlet weak var currentPrecipitationLabel: UILabel?
    @IBOutlet weak var currentTemperatureRangeLabel: UILabel?
    @IBOutlet weak var currentCityNameLabel: UILabel?
    
    
    var weeklyWeather: [DailyWeather] = []
    
    let locationManager = CLLocationManager()
    
    var latitude: Double = 0.0
    var longtitude: Double = 0.0
    var countryCode: String = "en"
    
    let locale = NSLocale.current
    
    let supportedLang: [String] = ["ar", "az", "be", "bs", "cs", "de", "el", "en", "es", "fr", "hr", "hu", "id", "it", "is", "kw", "nb", "nl", "pl", "pt", "ru", "sk", "sr", "sv", "tet", "tr", "uk", "x-pig-latin", "zh", "zh-tw"]
    
    private var didPerformGeocode = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Ask for Authorisation from the User.
        self.locationManager.requestAlwaysAuthorization()
        // For use in foreground
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest // GPS
        locationManager.startUpdatingLocation()
        configureView()
        //retrieveWeatherForecast()
        
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
            
            self.updateCityName(placemark: placemark!)
            //self.countryCode = (placemark?.isoCountryCode?.lowercased())!
            
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
    
    func configureView() {
        
        // Set custom height for tabel view row
        tableView.rowHeight = 64
        
        // Change color of nav bar text
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: #colorLiteral(red: 1, green: 0.6498119235, blue: 0, alpha: 1)]
    }
    
    func updateCityName(placemark: CLPlacemark) {
        //self.locationManager.stopUpdatingLocation()
        let cityname = placemark.locality! as String
        self.currentCityNameLabel!.text = cityname
    }
    
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDaily" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let dailyWeather = weeklyWeather[(indexPath as NSIndexPath).row]
                (segue.destination as! DailyViewController).dailyWeather = dailyWeather
            }
        }
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // return the number of rows
        return weeklyWeather.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "WeatherCell") as! DailyWeatherTabelViewCell
        
        let dailyWeather = weeklyWeather[(indexPath as NSIndexPath).row]
        if let maxTemp = dailyWeather.maxTemperature {
            cell.temperatureLabel.text = "\(maxTemp)º"
        }
        cell.weatherIcon.image = dailyWeather.icon
        cell.dayLabel.text = dailyWeather.day
        
        return cell
    }
    
    // MARK: - Delegate Methods
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        view.tintColor = UIColor.black
        
        if let header = view as? UITableViewHeaderFooterView {
            header.textLabel?.font = UIFont(name: "HelveticaNeue-Thin", size: 14.0)
            header.textLabel?.textColor = UIColor.white
        }
    }
    
    override func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        cell?.contentView.backgroundColor = UIColor.black
        let highlightView = UIView()
        highlightView.backgroundColor = UIColor.black
        cell?.selectedBackgroundView = highlightView
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
                        self.currentTemperatureLabel?.text = "\(temperature)º"
                    }
                    
                    if let precipitation = currentWeather.precipProbabitily {
                        self.currentPrecipitationLabel?.text = "🌧 \(precipitation)%"
                    }
                    
                    if let icon = currentWeather.icon {
                        self.currentWeatherIcon?.image = icon
                    }
                    
                    self.weeklyWeather = weatherForecast.weekly
                    
                    if let highTemp = self.weeklyWeather.first?.maxTemperature,
                        let lowTemp = self.weeklyWeather.first?.minTemperature {
                        self.currentTemperatureRangeLabel?.text = "↑\(highTemp)º ↓\(lowTemp)º"
                    }
                    self.locationManager.stopUpdatingLocation()
                    self.tableView.reloadData()
                }
            }
        }
    }
}
