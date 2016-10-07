//
//  InterfaceController.swift
//  ClimeAppWatch Extension
//
//  Created by Лидия Хашина on 03.10.16.
//  Copyright © 2016 Lydia Khashina. All rights reserved.
//

import WatchKit
import Foundation
import WatchConnectivity

//public var lat: Double = 0.0
//public var long: Double = 0.0
//public var city: String = ""

class InterfaceController: WKInterfaceController, WCSessionDelegate {
    
    @IBOutlet var cityNameLabel: WKInterfaceLabel!
    @IBOutlet var weatherImage: WKInterfaceImage!
    @IBOutlet var currentWeather: WKInterfaceLabel!
    @IBOutlet var rainLabel: WKInterfaceLabel!
    @IBOutlet var minMaxTempLabel: WKInterfaceLabel!
    
    private var didPerformGeocode = false
    //let locationManager = CLLocationManager()
    var weeklyWeather: [DailyWeather] = []
    
    var long: Double = 0.0
    var lat: Double = 0.0
    var city: String = ""
    
    var session: WCSession?
    
    let messageToSend = ["Temp":"0"]

    override func awake(withContext context: Any?) {
        print("awake")
        super.awake(withContext: context)
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        
        if WCSession.isSupported() {
            session = WCSession.default()
            session?.delegate = self
            session?.activate()
        }
        print("willActivate")
        super.willActivate()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    @IBAction func refreshWeather() {
        
        session?.sendMessage(self.messageToSend, replyHandler: { replyMessage in
            let temp = replyMessage["Temp"] as? String
            self.currentWeather?.setText(temp)
            let pic = replyMessage["Pic"] as? UIImage
            self.weatherImage?.setImage(pic)
            let range = replyMessage["Range"] as? String
            self.minMaxTempLabel?.setText(range)
            let rain = replyMessage["Rain"] as? String
            self.rainLabel?.setText(rain)
            let city = replyMessage["City"] as? String
            self.cityNameLabel!.setText(city)
            }
            , errorHandler: {error in
                // catch any errors here
                print(error)
        })
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        
    }
}
