//
// FlightImageManager.swift
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

class FlightImageManager {
    private init(){}
    
    public static let shared = FlightImageManager()
    
    private var observer: FlightImageObserver? = nil
    
    public func setObserver(_ o: FlightImageObserver){
        observer = o
    }
    
    public func unsetObserver(){
        observer = nil
    }
    
    private var imageCache: [Int:EncodableImage] = [:]
    
    enum ImageErrors:Error{
        case noResponse
        case noImage
        case dataError
        case imageError(_ status:Int)
    }
    
    public func getImage(with url:URL, for id:Int, reload:Bool=false){
        if let encodableImage = imageCache[id], !reload{
            if encodableImage.imageURL! == url {
                self.observer?.flightListGotImage(encodableImage)
                return
            }
        }
        
        fetchImageFor(with: url, for: id)
    }
    
    private func fetchImageFor(with url:URL, for id: Int){
        let contentType:String
        
        if url.pathExtension == "png" {
            contentType = "image/png"
        } else {
            contentType = "image/jpeg"
        }
        
        WebInt.shared.request(.get, link: url, body: nil, authToken: FlightAppManager.shared.session?.authToken, headers: ["content-type":contentType], json: false, completionHandler: {
            status, data in
            
            if status == 404 {
                self.observer?.flightListGotImageError(.noImage)
                return
            }
            
            if status != 200 {
                self.observer?.flightListGotImageError(.imageError(status))
                return
            }
            
            guard let image = UIImage(data: data) else {
                self.observer?.flightListGotImageError(.dataError)
                return
            }
            
            let newImage = EncodableImage(image: image, imageURL: url)
            
            self.imageCache[id] = newImage
            self.observer?.flightListGotImage(newImage)
            
        }, errorHandler: {
            _ in
            self.observer?.flightListGotImageError(.noResponse)
        })
    }
}
