//
// ChangelogManager.swift
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

class ChangelogManager {
    private init(){}
    
    public static let shared = ChangelogManager()
    
    private var observer: ChangeLogObserver? = nil
    
    public func setObserver(_ o:ChangeLogObserver){
        observer = o
    }
    
    public func unsetObserver() {
        observer = nil
    }
    
    enum ChangelogErrors:Error{
        case noResponse
        case getChangelogError
        case jsonError
        case invalidID
        case notFound
        case authError
    }
    
    /// Get changelog for a flight with a given ID
    func getChangelogBy(id:Int){
        if (id < 0){
            observer?.flightListGotChangelogError(e: .invalidID)
            return
        }
        
        let url = URLManager.current.urlForHistory(id: id)
        WebInt.shared.request(.get, link: url, body: nil, authToken: FlightAppManager.shared.session?.authToken, completionHandler: {
            status, data in
            
            if status == 401 {
                self.observer?.flightListGotChangelogError(e: .authError)
            }
            
            if status == 404 {
                self.observer?.flightListGotChangelogError(e: .notFound)
                return
            }
            
            if status != 200 {
                self.observer?.flightListGotChangelogError(e: .getChangelogError)
                return
            }
            
            let changelog:[Changelog]
            
            do {
                changelog = try JSONDecoder.shared.decode([Changelog].self, from: data)
            } catch {
                self.observer?.flightListGotChangelogError(e: .jsonError)
                return
            }
            
            self.observer?.flightListGotChangelog(c: changelog)
            
        }, errorHandler: {
            _ in
            self.observer?.flightListGotChangelogError(e: .noResponse)
        })
    }
}
