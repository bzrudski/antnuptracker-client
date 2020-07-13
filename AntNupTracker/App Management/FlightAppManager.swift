//
// FlightAppManager.swift
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
import CoreLocation

/// Singleton for managing the state of the app.
class FlightAppManager: NSObject, CLLocationManagerDelegate, URLSessionDelegate{
    // MARK: - Singleton
    static let shared = FlightAppManager()
    
    override private init(){
        super.init()
    }
    
    // MARK: - Store flight data
    var flights:FlightList=FlightList()
    
    // MARK: - Create encoder and decoder
    let encoder = JSONEncoder()
    let decoder = JSONDecoder()
    
    let jsonDateFormatter = DateFormatter()
    
    // MARK: - Session Management
    var session:Session?
    var sessionManager = SessionManager()
    private var sessionClearObserver: SessionClearObserver? = nil
//    var deviceToken:Data?
    
    var loggedIn:Bool{
        get{
            return session != nil
        }
    }
    
    public func setSessionClearObserver(_ o: SessionClearObserver){
        self.sessionClearObserver = o
    }
    
    public func unsetSessionClearObserver(){
        self.sessionClearObserver = nil
    }
    
    public func clearSession(){
        self.session = nil
        self.sessionClearObserver?.sessionCleared()
    }
    
    // MARK: - Location, Location, Location
    let locationManager = CLLocationManager()
    var location:CLLocation?
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
//        print(error.localizedDescription)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.location = locations.last//[locations.count - 1]
    }
    
    // MARK: - Date formatting
    let dateFormatter = DateFormatter()
    let dateOnlyFormatter = DateFormatter()
    let timeFormatter = DateFormatter()
}
