//
//  ExtensionDelegate.swift
//  ClimeAppWatch Extension
//
//  Created by Лидия Хашина on 03.10.16.
//  Copyright © 2016 Lydia Khashina. All rights reserved.
//

import WatchKit
import Foundation
import CoreLocation

class ExtensionDelegate: NSObject, WKExtensionDelegate, CLLocationManagerDelegate {
    
    let locationManager = CLLocationManager()
    
    private var didPerformGeocode = false
    
    func applicationDidFinishLaunching() {
        // Perform any final initialization of your application.
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest // GPS
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        print("applicationDidFinishLaunching")
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
            
            city = (placemark?.locality!)! as String
            long = (placemark?.location?.coordinate.longitude)!
            lat = (placemark?.location?.coordinate.latitude)!
            
            print("got coordinates")
            
            let view = WKExtension.shared().rootInterfaceController as! InterfaceController
            
            view.retrieveWeatherForecast(lat: long, long: lat)
        }
    }
    
    func applicationDidBecomeActive() {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        print("applicationDidBecomeActive")
    }

    func applicationWillResignActive() {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, etc.
        print("applicationWillResignActive")
    }

    func handle(_ backgroundTasks: Set<WKRefreshBackgroundTask>) {
        // Sent when the system needs to launch the application in the background to process tasks. Tasks arrive in a set, so loop through and process each one.
        for task in backgroundTasks {
            // Use a switch statement to check the task type
            switch task {
            case let backgroundTask as WKApplicationRefreshBackgroundTask:
                // Be sure to complete the background task once you’re done.
                backgroundTask.setTaskCompleted()
            case let snapshotTask as WKSnapshotRefreshBackgroundTask:
                // Snapshot tasks have a unique completion call, make sure to set your expiration date
                snapshotTask.setTaskCompleted(restoredDefaultState: true, estimatedSnapshotExpiration: Date.distantFuture, userInfo: nil)
            case let connectivityTask as WKWatchConnectivityRefreshBackgroundTask:
                // Be sure to complete the connectivity task once you’re done.
                connectivityTask.setTaskCompleted()
            case let urlSessionTask as WKURLSessionRefreshBackgroundTask:
                // Be sure to complete the URL session task once you’re done.
                urlSessionTask.setTaskCompleted()
            default:
                // make sure to complete unhandled task types
                task.setTaskCompleted()
            }
        }
    }

}
