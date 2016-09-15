//
//  DailyViewController.swift
//  ClimeApp
//
//  Created by Лидия Хашина on 15.09.16.
//  Copyright © 2016 Lydia Khashina. All rights reserved.
//

import UIKit

class DailyViewController: UIViewController {
    
    var dailyWeather: DailyWeather? {
        didSet {
            configureView()
        }
    }
    
    @IBOutlet weak var summaryLabel: UILabel?
    @IBOutlet weak var currentWeatherIcon: UIImageView?
    @IBOutlet weak var lowTemperatureLabel: UILabel?
    @IBOutlet weak var highTemperatureLabel: UILabel?
    @IBOutlet weak var precipitationLabel: UILabel?
    @IBOutlet weak var humidityLabel: UILabel?
    @IBOutlet weak var sunriseTimeLabel: UILabel?
    @IBOutlet weak var sunsetTimeLabel: UILabel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        configureView()
    }
    
    func configureView() {
        if let weather = dailyWeather {
            self.title = weather.day
            summaryLabel?.text = weather.summary
            currentWeatherIcon?.image = weather.largeIcon
            sunriseTimeLabel?.text = weather.sunriseTime
            sunsetTimeLabel?.text = weather.sunsetTime
            if let lowTemp = weather.minTemperature,
                let highTemp = weather.maxTemperature,
                let rain = weather.precipChance,
                let humidity = weather.humidity {
                lowTemperatureLabel?.text = "\(lowTemp)º"
                highTemperatureLabel?.text = "\(highTemp)º"
                precipitationLabel?.text = "\(rain)%"
                humidityLabel?.text = "\(humidity)%"
            }
            
        }
        
        // Configure nav bar back button
        if let buttonFont = UIFont(name: "HelveticaNeue-Thin", size: 20.0) {
            let barButtonAttributesDictionary: [String: AnyObject]? = [
                NSForegroundColorAttributeName: #colorLiteral(red: 1, green: 0.6498119235, blue: 0, alpha: 1),
                NSFontAttributeName: buttonFont
            ]
            UIBarButtonItem.appearance().setTitleTextAttributes(barButtonAttributesDictionary, for: UIControlState())
        }
        
        // Update UI with information from the data model
        currentWeatherIcon?.image
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
