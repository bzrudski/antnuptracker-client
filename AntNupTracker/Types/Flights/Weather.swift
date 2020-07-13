//
// Weather.swift
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

class Weather:Codable {
    let flightID:Int
    
    let description:WeatherDescription
    let weather:WeatherBasic
    let day:WeatherDay
    let rain:WeatherRain?
    let wind:WeatherWind?
    
    let timeFetched:Date
    
    func toArray()->[(String, [(String, String)])]{
        var weatherInfo:[(String, [(String, String)])]=[]
        
        weatherInfo.append(("Flight Information", [("Flight ID", String(self.flightID))]))
        weatherInfo.append(("Weather Description", self.description.toArray()))
        weatherInfo.append(("Weather Details", self.weather.toArray()))
        
        if (rain != nil){
            weatherInfo.append(("Rain Information", self.rain!.toArray()))
        }
        
        if (wind != nil){
            weatherInfo.append(("Wind Information", self.wind!.toArray()))
        }
        
        var fetchedInfo = self.day.toArray()
        fetchedInfo.append(("Time Retrieved", FlightAppManager.shared.dateFormatter.string(from: timeFetched)))
        weatherInfo.append(("Day Information", fetchedInfo))
        
        return weatherInfo
    }
}

class WeatherDescription:Codable{
    let desc:String
    let longDesc:String
    
    func toArray()->[(String, String)]{
        var description:[(String, String)] = []
        
        description.append(("Description", self.desc))
        description.append(("Full description", self.longDesc))
        
        return description
    }
}

class WeatherBasic:Codable{
    let temperature:Double
    let pressure:Double
    let pressureSea:Double?
    let pressureGround:Double?
    let humidity:Int
    let tempMin:Double?
    let tempMax:Double?
    let clouds:Int
    
    func toArray()->[(String, String)]{
        var weather:[(String, String)] = []
        
        weather.append(("Temperature (\u{00b0}C)", String(self.temperature)))
        weather.append(("Pressure (hPa)", String(self.pressure)))
        if (pressureSea != nil){
            weather.append(("Sea-level pressure (hPa)", String(self.pressureSea!)))
        }
        if (pressureGround != nil){
            weather.append(("Ground-level pressure (hPa)", String(self.pressureGround!)))
        }
        
        weather.append(("Humidity (%)", String(self.humidity)))
        if let tempMin = tempMin {
            weather.append(("Minimum Temperature (\u{00b0}C)", String(tempMin)))
        }
        if let tempMax = tempMax{
            weather.append(("Maximum Temperature (\u{00b0}C)", String(tempMax)))
        }
        weather.append(("Clouds (%)", String(self.clouds)))
        
        return weather
    }
}

class WeatherDay:Codable{
    let sunrise:Date
    let sunset:Date
    
    func toArray()->[(String, String)]{
        var day:[(String, String)]=[]
        
        day.append(("Sunrise", FlightAppManager.shared.dateFormatter.string(from: self.sunrise)))
        day.append(("Sunset", FlightAppManager.shared.dateFormatter.string(from: self.sunset)))
        
        return day
    }
}

class WeatherWind:Codable{
    let windSpeed:Double?
    let windDegree:Int?
    
    func toArray()->[(String, String)]{
        var wind:[(String, String)]=[]
        
        if let speed = windSpeed{
            wind.append(("Speed (m/s)", String(speed)))
        }
        
        if let degree = windDegree{
            wind.append(("Direction (\u{00b0})", String(degree)))
        }
        
        return wind
    }
}

class WeatherRain:Codable{
    let rain1:Double?
    let rain3:Double?
    
    func toArray()->[(String, String)]{
        var rain:[(String, String)]=[]
        
        if let rainOne = rain1{
            rain.append(("1 hour (mm)", String(rainOne)))
        }
        
        if let rainThree = rain3{
            rain.append(("3 hour (mm)", String(rainThree)))
        }
        
        return rain
    }
}
