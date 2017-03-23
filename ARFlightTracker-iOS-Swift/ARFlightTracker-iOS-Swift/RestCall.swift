//
//  RestCall.swift
//  IBMFlightTracker
//
//  Created by Sanjeev Ghimire on 3/14/17.
//  Copyright © 2017 Sanjeev Ghimire. All rights reserved.
//

import Foundation
import SwiftyJSON


class RestCall {
    
    
    private static let WEATHER_API_USERNAME : String = "<username>"
    private static let WEATHER_API_PASSWORD : String = "<password>"
    
    
    func fetchWeatherBasedOnCurrentLocation(latitude: String, longitude: String, completion: @escaping (_ result: [String: Any]) -> Void){
        
        var weatherData : [String : Any] = [:]
        
        let url:String = self.getURL(latitude: latitude, longitude: longitude)
        
        guard let endpointURL = URL(string: url) else {
            print("Error: cannot create URL")
            return
        }
        
        let urlRequest = URLRequest(url: endpointURL)
        
        let session = URLSession.shared
        
        let task = session.dataTask(with: urlRequest) {
            (data, response, error) in
            // check for any errors
            guard error == nil else {
                print("error calling weather api")
                print(error!)
                return
            }
            // make sure we got data
            guard let responseData = data else {
                print("Error: did not receive data")
                return
            }
            
            
                let weatherJson = JSON(data: responseData)
                
                let observation : [String : Any] = weatherJson["observation"].dictionaryObject!
            
                weatherData["city"] = observation["obs_name"]
                weatherData["temperature"] = observation["temp"]
                weatherData["description"] = observation["wx_phrase"]
            
            let weatherIconUrl:String = "http://weather-company-data-demo.mybluemix.net/images/weathericons/icon\(observation["wx_icon"]!).png"
            
            weatherData["weatherIconUrl"] = weatherIconUrl
            
            completion(weatherData)
        }
        task.resume()
    }
    
    
    
    func getURL(latitude: String, longitude: String) -> String{
        let url: String =  "https://\(RestCall.WEATHER_API_USERNAME):\(RestCall.WEATHER_API_PASSWORD)@twcservice.mybluemix.net/api/weather/v1/geocode/\(latitude)/\(longitude)/observations.json?units=e&language=en-US"
        
        return url
    }
    

}
