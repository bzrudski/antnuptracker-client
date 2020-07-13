//
// UserManager.swift
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

class UserManager{
    private var userCache: [String: User] = [:]
    private var observer: UserObserver? = nil
    public static let shared = UserManager()
    
    private init(){}
    
    public func setObserver(observer o:UserObserver){
        observer = o
    }
    
    public func unsetObserver(){
        observer = nil
    }
    
    enum UserError: Error{
        case jsonError
        case noResponse
        case notFound
        case otherError(_ status:Int)
    }
    
    private func fetchUserInfo(for username:String){
        let url = URLManager.current.getUserURL(for: username)
        
        WebInt.shared.request(.get, link: url, body: nil, authToken: FlightAppManager.shared.session?.authToken, completionHandler: {
            status, data in
            
            if status == 404 {
                self.observer?.fetchedWithError(for: username, error: .notFound)
                return
            }
            
            else if status != 200 {
                self.observer?.fetchedWithError(for: username, error: .otherError(status))
                return
            }
            
            let user: User
            
            do {
                user = try JSONDecoder.shared.decode(User.self, from: data)
            } catch {
                self.observer?.fetchedWithError(for: username, error: .jsonError)
                return
            }
            
            self.userCache[username] = user
            self.observer?.fetched(user: user)
            return
        }, errorHandler: { _ in
            self.observer?.fetchedWithError(for: username, error: .noResponse)
        })
    }
    
    public func getInfoFor(username: String, useCache: Bool=true){
        if useCache && self.userCache.keys.contains(username){
            self.observer?.fetched(user: self.userCache[username]!)
        }
        else {
            self.fetchUserInfo(for: username)
        }
    }
    
}
