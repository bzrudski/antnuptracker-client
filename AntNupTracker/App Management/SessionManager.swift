//
// SessionManager.swift
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

/** Class that handles session management. The functionality provided by this class enables login, logout and verification of a session. Keychain management is also handled.
 
**/
class SessionManager {
    
    // MARK: - Token Management
    private var deviceToken: Data? = nil
    
    ///Converts data to a string representation of it.  This is necessary as "print" only gives the size of the data, without mapping it to a string.
    /// Code copied from "https://stackoverflow.com/questions/47386207/getting-remote-notification-device-token-in-swift-4",
    /// by Ahmad F.
    /// - parameter token: the device's token, which is necessary for notifications.
    private func convertTokenToString(token:Data)->String{
        let tokenString=token.map({
            String(format: "%02.2hhx", $0)
        }).joined()
        
        return tokenString
    }
    
    /** Get the string representation of the device token. Only to be used when logging in. Therefore, it is private.
    **/
    private func getDeviceTokenString()->String?{
        if let token = self.deviceToken {
            return convertTokenToString(token: token)
        } else {
            return nil
        }
    }
    
    public func setDeviceToken(_ token:Data?){
        deviceToken = token
    }
    
    // MARK: - Observer setup
    private var loginObserver: LoginObserver? = nil
    private var logoutObserver: LogoutObserver? = nil
    private var verifySessionObserver: VerifySessionObserver? = nil
    
    /// Setter for login observer
    /// - parameter observer: Observer to be set
    func setLoginObserver(observer: LoginObserver){
        self.loginObserver = observer
    }
    
    /// Unsetter for login observer
    func unsetLoginObserver(){
        self.loginObserver = nil
    }
    
    /// Setter for logout observer
    /// - parameter observer: Observer to be set
    func setLogoutObserver(observer: LogoutObserver){
        self.logoutObserver = observer
    }
    
    /// Unsetter for logout observer
    func unsetLogoutObserver(){
        self.logoutObserver = nil
    }
    
    /// Setter for session verification observer
    /// - parameter observer: Observer to be set
    func setVerifySessionObserver(observer: VerifySessionObserver){
        self.verifySessionObserver = observer
    }
    
    /// Unsetter for session verification observer
    func unsetVerifySessionObserver(){
        self.verifySessionObserver = nil
    }
    
    // MARK: - Login Management
    
    /// Errors associated with logging in.
    enum LoginErrors:Error{
        case emptyUserPass
        case incorrectCreds
        case jsonParseError
        case noResponse
        case otherError(status: Int)
    }
    
    /// Attempt to log into the web app with provided username and password.
    /// - parameter username: username to log in with
    /// - parameter password: password to log in with
    func login(username: String, password:String, deviceInfo: [String:String?]?=nil)
    {
//        let username = usernameRaw.lowercased()
        let url = URLManager.current.getLoginURL()
        
        if (username.count == 0 || password.count == 0){
            loginObserver?.loggedInWithError(e: LoginErrors.emptyUserPass)
            return
        }
        
        var deviceInfoFull: [String:String?]
        
        if let info = deviceInfo {
            deviceInfoFull = info
        } else {
            deviceInfoFull = [:]
        }
        
//        if let token = getDeviceTokenString() {
        deviceInfoFull.updateValue(getDeviceTokenString(), forKey: "deviceToken")
//        } else {
//            deviceInfoFull.updateValue(nil, forKey: "deviceToken")
//        }
//        print(getDeviceTokenString() ?? "No token")
        
        let body: Data?
        
        if !deviceInfoFull.isEmpty {
            body = try? JSONSerialization.data(withJSONObject: deviceInfoFull, options: [])
        } else {
            body = nil
        }
        
        WebInt.shared.request(.post, link: url, body: body, username: username, password: password, completionHandler: {
            status, data in
            
            if status == 401 || status == 403 {
                self.loginObserver?.loggedInWithError(e: LoginErrors.incorrectCreds)
                return
            }
            
            if status != 200 {
                self.loginObserver?.loggedInWithError(e: LoginErrors.otherError(status: status))
                return
            }
            
            guard let feedbackDictionary = try? JSONSerialization.jsonObject(with: data, options: []) as? [String:Any] else {
                self.loginObserver?.loggedInWithError(e: LoginErrors.jsonParseError)
                return
            }
            
//            print(feedbackDictionary)
            
            guard let authToken = feedbackDictionary["token"] as? String else {
                fatalError("Illegal Authentication token")
            }
            
            guard let professional = feedbackDictionary["professional"] as? Bool else {
                fatalError("Illegal user role")
            }
            
            guard let description = feedbackDictionary["description"] as? String else {
                fatalError("Illegal description")
            }
            
            guard let institution = feedbackDictionary["institution"] as? String else {
                fatalError("Illegal institution")
            }
            
            guard let deviceID = feedbackDictionary["deviceID"] as? Int else {
                fatalError("No deviceID returned")
            }
            
            let device = Device(deviceID: deviceID, deviceToken: self.getDeviceTokenString())
            
            let session = Session(username: username, professional: professional, description: description, institution: institution, authToken: authToken, device: device)
            
//            let session = Session(username: username, authToken: authToken, role: role, device: device)
            
            self.loginObserver?.loggedIn(s: session)
            
        }, errorHandler: {_ in
            self.loginObserver?.loggedInWithError(e: LoginErrors.noResponse)
        })
    }
    
    // MARK: - Logout Management
    
    /// Errors that may arise during the logout process
    enum LogoutErrors:Error{
        case authError
        case logoutError(status: Int)
        case noResponse
    }
    
    /// Send an asynchronous logout request to the server
    func logout(s:Session){
        let url = URLManager.current.getLogoutURL()
        
        WebInt.shared.request(.post, link: url, body: nil, authToken: s.authToken, completionHandler: {
            status, data in
            
            if status == 401 || status == 403 {
                self.logoutObserver?.loggedOutWithError(e: LogoutErrors.authError)
                return
            }
            
            if status != 200 && status != 204 {
                self.logoutObserver?.loggedOutWithError(e: LogoutErrors.logoutError(status: status))
                return
            }
            
            self.logoutObserver?.loggedOut()
            
        }, errorHandler: {
            _ in
            self.logoutObserver?.loggedOutWithError(e: LogoutErrors.noResponse)
        })
    }
    
    // MARK: - Session Verification
    enum VerificationErrors:Error{
        case noResponse
        case invalidCreds
        case jsonError
        case otherError(status: Int)
    }
    
    func verify(s: Session) {
        let url = URLManager.current.getVerifyURL()
        let headers: [String:String] = ["deviceID":String(s.device.deviceID)]
        
        WebInt.shared.request(.post, link: url, body: nil, authToken: s.authToken, headers: headers, completionHandler: {
            status, data in
            
            if status == 401 {
               self.clearCredentials()
                self.verifySessionObserver?.sessionVerified(session: s, valid: false, response: nil)
                return
            }
            
            if status != 200 {
                self.verifySessionObserver?.sessionVerifiedWithError(e: VerificationErrors.otherError(status: status))
                return
            }
            
            guard let responseDict = try? JSONSerialization.jsonObject(with: data, options: []) as? [String:String] else {
                self.verifySessionObserver?.sessionVerifiedWithError(e: VerificationErrors.jsonError)
                return
            }
//            print("Session verified")
            self.verifySessionObserver?.sessionVerified(session: s, valid: true, response: responseDict)
            
            
        }, errorHandler: {
            _ in
            self.verifySessionObserver?.sessionVerifiedWithError(e: VerificationErrors.noResponse)
        })
    }
    
    // MARK: - Keychain Management
    func initiateLoadAndVerifySessionFromKeychain() {
        do {
            
            let (username, contents) = try Keychain.shared.loadCredentials()
//            print(contents)
            let authToken = contents["authToken"] as! String
             let professional = contents["professional"] as! Bool
            let description = contents["description"] as! String
            let deviceID = contents["deviceID"] as! Int
            let institution = contents["institution"] as! String
            
            let device = Device(deviceID: deviceID, deviceToken: getDeviceTokenString())
            
            let session = Session(username: username, professional: professional, description: description, institution: institution, authToken: authToken, device: device)
            
            verify(s: session)
            
//            print("Session is now initialised")
        } catch VerificationErrors.invalidCreds {
//            print("Invalid credentials")
            try? Keychain.shared.clearCredentials()
            return
        } catch {
//            print("Other problem with credentials: \(error.localizedDescription)")
            return
        }
    }
    
    func saveSession(_ s: Session) {
        let contents: [String:Any] = [
            "authToken" : s.authToken,
            "professional": s.professional,
            "description": s.description ?? "",
            "institution": s.institution ?? "",
            "deviceID"  : s.device.deviceID
        ]
        
//        do {
        try? Keychain.shared.saveCredentials(username: s.username, content: contents)
//            return true
//        } catch {
//            return false
//        }
    }
    
    func clearCredentials(){
        try? Keychain.shared.clearCredentials()
    }
}
