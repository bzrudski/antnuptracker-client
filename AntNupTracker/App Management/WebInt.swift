//
// WebInt.swift
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
import UIKit

/// Singleton for performing web requests. Access the singleton instance via `WebInt.shared`.
public class WebInt{
    /// Default timeout value
    public static let TIMEOUT = 20.0
    
    /// Private initialiser
    private init(){}
    
    /// Shared instance
    public static let shared = WebInt()
    
    /// Network errors for network interactions
    public enum networkError:Error{
        case illegalURL
        case noResponse
        case illegalMethod
        case insufficientAuthentication
    }
    
    /// HTTP methods available for network requests.
    public enum HttpMethod:String {
        case get = "GET"
        case put = "PUT"
        case delete = "DELETE"
        case post = "POST"
        case patch = "PATCH"
    }
    
    /// Create and send HTTP request.
    /// - parameter method: HTTP method to use for the request
    /// - parameter link: the URL of the request
    /// - parameter body: the contents of the HTTP request body
    /// - parameter timeout: timeout for the connection attempt in seconds (default `20.0`)
    /// - parameter username: username for authentication if destination uses `Basic` authentication (optional, default `nil`)
    /// - parameter password: password for authentication if destination uses `Basic` authentication (optional, default `nil`)
    /// - parameter authToken: authentication token if destination uses `Token` authentication (optional, default `nil`)
    /// - parameter headers: additional header elements aside from `Authorization` and `Content-Type` (default `[:]` empty)
    /// - parameter json: boolean to determine if request being sent is in the form of `json` (`true` if JSON)
    /// - parameter completionHandler: operation to perform with the status and response data once they are received
    /// - parameter errorHandler: operation to perform if an error occurs during the request
    /// - parameter delegate: optional delegate for the request
    /** - throws: - member of `networkError`
     + `illegalMethod` if method is not in `[PUT, POST, GET, DELETE, PATCH]`
     + `noResponse` if there is no reply from the server
     */
    /// - returns: `(Int,Data?)` tuple with the status code of the response and the response data
    public func request(_ method:HttpMethod, link:URL, body:Data?, timeout:Double=TIMEOUT, username:String?=nil, password:String?=nil, authToken:String?=nil, headers: [String:String]=[:], json:Bool=true,  completionHandler: @escaping ((Int, Data)->Void) = {status, data in }, errorHandler: @escaping ((Error?) -> Void) = {error in }, delegate: URLSessionTaskDelegate? = nil) {
        
        var credential:URLCredential? = nil
        
//        print("Performing request of type \(method) with URL \(url.absoluteString)")
        
        //let request=NSMutableURLRequest(url: url)
        var request = URLRequest(url:link)
        
        let protectionSpaceProtocol:String = {
            if (link.absoluteString.contains("https")){
                 return "https"
            }
            return "http"
        }()
        
        //let existingHeaders = request.allHTTPHeaderFields?.keys
        //URLSession.shared.delegate=self
        let protectionSpace = URLProtectionSpace(host: link.host ?? link.absoluteString, port: link.port ?? 80, protocol: protectionSpaceProtocol, realm: nil, authenticationMethod: NSURLAuthenticationMethodHTTPBasic)
        
        var authString:String? = nil
        
        // If there is no token, then assume Basic authentication
        if (authToken == nil && username != nil && password != nil){
            let credentialString = String(format: "%@:%@", username!,password!)
            let credentialData = credentialString.data(using: String.Encoding.utf8)!
            let credentialBase64 = credentialData.base64EncodedString()
            authString = "Basic \(credentialBase64)"
            
            credential = .init(user: username!, password: password!, persistence: .forSession)
            URLCredentialStorage.shared.set(credential!, for: protectionSpace)
        }
        else if (authToken != nil){
            authString = "Token \(authToken!)"
        }
        
        // If no authString, then no authentication
        if (authString != nil){
            request.setValue(authString, forHTTPHeaderField: "Authorization")
        }
        
        if (json){
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        
        for header in headers.keys {
            let value = headers[header]
            request.setValue(value, forHTTPHeaderField: header)
        }
        
        request.httpMethod = method.rawValue
        request.httpBody = body
        request.timeoutInterval = timeout
        
        let session: URLSession
        
        if delegate != nil {
            session = .init(configuration: .default, delegate: delegate, delegateQueue: .main)
        } else {
            session = .shared
        }
        
        let task = session.dataTask(with: request as URLRequest){ data, response, error in
            guard let data=data, error==nil else{
                return errorHandler(error)
            }
            if let httpResponse = response as? HTTPURLResponse {
                let status = httpResponse.statusCode
                
                completionHandler(status, data)
            }
            
        }
        
        task.resume()
    }
}
