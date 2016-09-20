//
//  WeeklyForecastTableViewController.swift
//  ClimeApp
//
//  Created by Лидия Хашина on 15.09.16.
//  Copyright © 2016 Lydia Khashina. All rights reserved.
//

import UIKit
import CoreLocation

class WeeklyForecastTableViewControvarr: UITableViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var currentTemperatureLabel: UILabel?
    @IBOutlet weak var currentWeatherIcon: UIImageView?
    @IBOutlet weak var currentPrecipitationLabel: UILabel?
    @IBOutlet weak var currentTemperatureRangeLabel: UILabel?
    @IBOutlet weak var currentCityNameLabel: UILabel?
    
    
    var weeklyWeather: [DailyWeather] = []
    
    let locationManager = CLLocationManager()
    
    var latitude: Double = 0.0
    var longtitude: Double = 0.0
    var countryCode: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Ask for Authorisation from the User.
        self.locationManager.requestAlwaysAuthorization()
        // For use in foreground
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest // GPS
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        configureView()
        //retrieveWeatherForecast()
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation: CLLocation = locations[0]
        self.longtitude = userLocation.coordinate.longitude
        self.latitude = userLocation.coordinate.latitude
        print("\(longtitude)")
        print("\(latitude)")
        
        CLGeocoder().reverseGeocodeLocation(manager.location!, completionHandler: {(placemarks, error)-> Void in
            if (error != nil) {
                print("Reverse geocoder failed with error" + (error?.localizedDescription)!)
                return
            }
            
            if (placemarks?.count)! > 0 {
                let pm = (placemarks?[0])! as CLPlacemark
                //print(pm)
                self.updateCityName(placemark: pm)
                self.countryCode = (pm.isoCountryCode?.lowercased())!
                print(self.countryCode)
                self.retrieveWeatherForecast(lat: self.latitude, long: self.longtitude)
            } else {
                print("Problem with the data received from geocoder")
            }
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func configureView() {
        
        // Set custom height for tabel view row
        tableView.rowHeight = 64
        
        // Change the size and font of nav bar text
        if let navBarFont = UIFont(name: "HelveticaNeue-Thin", size: 20.0) {
            let navBarAttributesDictionary: [String: AnyObject]? = [
                NSForegroundColorAttributeName: #colorLiteral(red: 1, green: 0.6498119235, blue: 0, alpha: 1),
                NSFontAttributeName: navBarFont
            ]
            navigationController?.navigationBar.titleTextAttributes = navBarAttributesDictionary
        }
        
        // Position refresh control above background view
        //refreshControl?.layer.zPosition = (tableView.backgroundView?.layer.zPosition)! + 1
        
        refreshControl?.tintColor = #colorLiteral(red: 1, green: 0.6498119235, blue: 0, alpha: 1)
    }
    
    func updateCityName(placemark: CLPlacemark) {
        //self.locationManager.stopUpdatingLocation()
        let cityname = placemark.locality! as String
        print(cityname)
        self.currentCityNameLabel!.text = cityname
    }
    
    @IBAction func refreshWeather() {
        
        self.retrieveWeatherForecast(lat: latitude, long: longtitude)
        refreshControl?.endRefreshing()
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
    
    /*override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return ""
    }*/
    
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
        forecastService.getForecast(lat, long: long, APIoptions: "?units=si&lang=\(self.countryCode)"){
            (forecast) in
            if let weatherForecast = forecast,
                let currentWeather = weatherForecast.currentWeather {
                DispatchQueue.main.async {
                    print("LOLOLOLOLOL")
                    print(self.countryCode)
                    if let temperature = currentWeather.temperature {
                        self.currentTemperatureLabel?.text = "\(temperature)º"
                    }
                    
                    if let precipitation = currentWeather.precipProbabitily {
                        print(precipitation)
                        self.currentPrecipitationLabel?.text = "🌧 \(precipitation)%"
                    }
                    
                    if let icon = currentWeather.icon {
                        self.currentWeatherIcon?.image = icon
                    }
                    
                    self.weeklyWeather = weatherForecast.weekly
                    
                    if let highTemp = self.weeklyWeather.first?.maxTemperature,
                        let lowTemp = self.weeklyWeather.first?.minTemperature {
                        self.currentTemperatureRangeLabel?.text = "↑\(highTemp)º↓\(lowTemp)º"
                    }
                    self.locationManager.stopUpdatingLocation()
                    self.tableView.reloadData()
                    print("reload")
                }
            }
        }
    }
}
