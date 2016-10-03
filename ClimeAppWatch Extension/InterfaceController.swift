//
//  InterfaceController.swift
//  ClimeAppWatch Extension
//
//  Created by Лидия Хашина on 03.10.16.
//  Copyright © 2016 Lydia Khashina. All rights reserved.
//

import WatchKit
import Foundation


class InterfaceController: WKInterfaceController {
    
    
    @IBOutlet var cityNameLabel: WKInterfaceLabel!
    @IBOutlet var weatherImage: WKInterfaceImage!
    @IBOutlet var currentWeather: WKInterfaceLabel!
    @IBOutlet var rainLabel: WKInterfaceLabel!
    @IBOutlet var minMaxTempLabel: WKInterfaceLabel!
    
    

    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        // Configure interface objects here.
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

}
