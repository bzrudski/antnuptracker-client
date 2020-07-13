//
// EncodableImage.swift
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

class EncodableImage:Codable, Equatable{
    let image:UIImage?
    var imageURL:URL? = nil
    
    public init(image: UIImage, imageURL:URL?=nil){
        self.image = image
        self.imageURL = imageURL
    }
    
    public static let EMPTY_IMAGE = EncodableImage(image: nil)
    
    private init(image: UIImage?, imageURL:URL?=nil){
        self.image = image
        self.imageURL = imageURL
    }
    
    public static func generateHolderForUrl(_ url:URL) -> EncodableImage{
        return EncodableImage(image: nil, imageURL: url)
    }
    
    enum CodingKeys: String, CodingKey{
        case image = "image"
    }
    
    class ImageEncodeError: Error {
        var localizedDescription: String
        {
            get {
                return "Error encoding image"
            }
        }
    }
    
    class ImageDecodeError: Error {
        var localizedDescription: String
        {
            get {
                return "Error decoding image"
            }
        }
    }
    
    func encode(to encoder: Encoder) throws {
        //var container = encoder.container(keyedBy: CodingKeys.self)
        var container = encoder.singleValueContainer()
//        guard let data = image.pngData() else {
//            throw ImageEncodeError()
//        }
        
//        if let data = image?.pngData() {
        if let data = image?.jpegData(compressionQuality: 0.7) {
//            throw ImageEncodeError()
            let base64String = data.base64EncodedString()
            try container.encode(base64String)
        }
        else {
            try container.encode(String?(nil))
        }
        //try container.encode(base64String, forKey: .image)
    }
    
    required init(from decoder: Decoder) throws {
        //let values = try decoder.container(keyedBy: CodingKeys.self)
        let values = try decoder.singleValueContainer()
        let rawImageData = try values.decode(String.self)
        //let rawImageData = try values.decode(String.self, forKey: .image)
        if let data = Data(base64Encoded: rawImageData) {
            if let image = UIImage(data: data, scale: 1.0){
                self.image = image
            } else {
                throw ImageDecodeError()
            }
        }
        else if let url = URL(string: rawImageData) {
            self.imageURL = url
            guard let rawData = try? Data(contentsOf: url) else {
                throw ImageDecodeError()
            }
            guard let rawImage = UIImage(data: rawData) else {
                throw ImageDecodeError()
            }
            
            self.image = rawImage
        } else {
            throw ImageDecodeError()
        }
        
    }
    static func == (l:EncodableImage, r:EncodableImage)->Bool{
        
        if l === EMPTY_IMAGE || r === EMPTY_IMAGE {
            return true
        }
        
        return l.image?.isEqual(r.image) ?? (l.imageURL != r.imageURL)
    }
}
