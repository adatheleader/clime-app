//
//  ForecastService.swift
//  ClimeApp
//
//  Created by Лидия Хашина on 15.09.16.
//  Copyright © 2016 Lydia Khashina. All rights reserved.
//

import Foundation

struct ForecastService {
    let forecastAPIKey: String
    let forecastBaseURL: URL?
    
    init(APIKey: String) {
        forecastAPIKey = APIKey
        forecastBaseURL = URL(string: "https://api.darksky.net/forecast/\(forecastAPIKey)/")
    }
    
    func getForecast (_ lat: Double, long: Double, APIoptions: String, completion: @escaping ((Forecast?) -> Void)) {
        if let forecastURL = URL(string: "\(lat),\(long)\(APIoptions)", relativeTo: forecastBaseURL){
            
            let networkOperation = NetworkOperation(url: forecastURL)
            
            networkOperation.downloadJSONFromURL{
                (JSONDictionary) in
                let forecast = Forecast(weatherDictionary: JSONDictionary!)
                completion(forecast)
            }
            
        } else {
            print("Could not construct a valid URL")
        }
    }
    
}
