//
// WeatherManager.swift
// AntNupTracker, the ant nuptial flight field database
// Copyright (C) 2020  Abouheif Lab
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.

import Foundation

class WeatherManager {
    
    private init(){}
    
    public static let shared = WeatherManager()
    
    private var observer: WeatherObserver? = nil
    
    public func setObserver(_ o: WeatherObserver){
        observer = o
    }
    
    public func unsetObserver(){
        observer = nil
    }
    
    enum WeatherErrors:Error{
        case noResponse
        case notFound
        case authError
        case jsonError
        case invalidID
        case getWeatherError
    }
    
    func getWeatherBy(id:Int) {
        guard (id > 0) else {
            observer?.flightListGotWeatherError(e: WeatherErrors.invalidID)
            return
        }
        let url = URLManager.current.urlForWeather(id: id)
        
        WebInt.shared.request(.get, link: url, body: nil, authToken: FlightAppManager.shared.session?.authToken, completionHandler: {
            status, data in
            
            if status == 404 {
                self.observer?.flightListGotWeatherError(e: WeatherErrors.notFound)
                return
            }
            
            if status != 200 {
                self.observer?.flightListGotWeatherError(e: WeatherErrors.getWeatherError)
                return
            }
            
            let weather:Weather
            do {
                weather = try JSONDecoder.shared.decode(Weather.self, from: data)
            } catch {
                self.observer?.flightListGotWeatherError(e: WeatherErrors.jsonError)
                return
            }
            
            self.observer?.flightListGotWeather(w: weather)
            
        }, errorHandler: {
            _ in
            self.observer?.flightListGotWeatherError(e: WeatherErrors.noResponse)
        })
    }
    
}
