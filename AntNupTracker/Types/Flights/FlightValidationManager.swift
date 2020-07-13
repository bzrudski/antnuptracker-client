//
// FlightValidationManager.swift
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

class FlightValidationManager {
    private init(){}
    
    public static let shared = FlightValidationManager()
    
    private var observer: FlightValidationObserver? = nil
    public func setObserver(_ o:FlightValidationObserver){
        observer = o
    }
    
    public func unsetObserver(){
        observer = nil
    }
    
    enum ValidateErrors: Error{
        case noResponse
        case invalidID
        case notLoggedIn
        case insufficientPrivileges
        case notFound
        case validateError(Int)
    }
    
    func validateFlightWith(id: Int){
        if (id < 0){
            observer?.flightListValidatedFlightError(id: id, e: .invalidID)
            return
        }
        
        if (FlightAppManager.shared.session == nil){
            observer?.flightListValidatedFlightError(id: id, e: .notLoggedIn)
            return
        }
        
        if (FlightAppManager.shared.session!.role != .professional){
            observer?.flightListValidatedFlightError(id: id, e: .insufficientPrivileges)
            return
        }
        
        let url = URLManager.current.urlForValidate(id: id)
        WebInt.shared.request(.post, link: url, body: nil, authToken: FlightAppManager.shared.session?.authToken, completionHandler: {
            status, data in
            
            if status == 404 {
                self.observer?.flightListValidatedFlightError(id: id, e: .notFound)
                return
            }
            
            if status != 200 {
                self.observer?.flightListValidatedFlightError(id: id, e: .validateError(status))
                return
            }
            
            FlightAppManager.shared.flights.validatedFlightWith(id: id)
            
            self.observer?.flightListValidatedFlight(id: id)
        }, errorHandler: {
            _ in
            self.observer?.flightListValidatedFlightError(id: id, e: .noResponse)
        })
    }
}
