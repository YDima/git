//
//  WeatherManager.swift
//  Weather App
//
//  Created by Dmytro Yurchenko on 10/10/20.
//  All rights reserved.
//

import UIKit
import CoreLocation

protocol WeatherManagerDelegate {
    func didUpdateWeather(_ weatherManager: WeatherManager, weather: WeatherModel)
    func didFailWithError(_ error: Error)
}

struct WeatherManager {
    
    let weatherUrl = "https://api.openweathermap.org/data/2.5/weather?appid=8022a936e09b18d1f6516299dcac53d8&units=metric"
    
    var delegate: WeatherManagerDelegate?
    
    func fetchWeather(cityName: String) {
        let url = "\(weatherUrl)&q=\(cityName)"
        performRequest(with: url)
    }
    
    func fetchWeather(lat: CLLocationDegrees, lon: CLLocationDegrees) {
        let url = "\(weatherUrl)&lat=\(lat)&lon=\(lon)"
        performRequest(with: url)
    }
    
    func performRequest(with urlString: String) {
        
        // 1. Create URL
        if let url = URL(string: urlString) {
            
            // 2. Create a url session
            let session = URLSession(configuration: .default)
            
            // 3. Give the session a task
            
            //OLD version   let task = session.dataTask(with: url, completionHandler: handle(data:response:error:))
            let task = session.dataTask(with: url) { (data, response, error) in
                if error != nil {
                    self.delegate?.didFailWithError(error!)
                    return
                }
                if let safeData = data {
                    /* let dataString = String(data: safeData, encoding: .utf8) */
                    if let weather = self.parseJSON(safeData) {
                        self.delegate?.didUpdateWeather(self, weather: weather)
                    }
                }
            }
            // 4. Start the task
            task.resume()
        }
        
    }
    
    /*   OLD version
     func handle(data: Data?, response: URLResponse?, error: Error?) {
     if error != nil {
     print(error!)
     return
     }
     if let safeData = data {
     let dataString = String(data: safeData, encoding: .utf8)
     }
     } */
    
    func parseJSON(_ weatherData: Data) -> WeatherModel? {
        let decoder = JSONDecoder()
        
        do {
            let decodedData = try decoder.decode(WeatherData.self, from: weatherData)
            let id = decodedData.weather[0].id
            let temperature = decodedData.main.temp
            let city = decodedData.name
            
            let weather = WeatherModel(id: id, city: city, temperature: temperature)
            
            return weather
        } catch {
            delegate?.didFailWithError(error)
            return nil
        }
        
    }
    
}

