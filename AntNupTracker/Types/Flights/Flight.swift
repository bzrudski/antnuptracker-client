//
// Flight.swift
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
import UIKit

class Flight:Codable, Equatable{
    
    // MARK: - Fields
    let flightID:Int
    var taxonomy: Species
    var location: CLLocationCoordinate2D
    var radius:Double
    var dateOfFlight:Date
    let dateRecorded:Date
    let owner:String
    let ownerProfessional:Bool
    let ownerFlagged:Bool
    var ownerRole:Role {
        if ownerFlagged {
            return .flagged
        }
        else if ownerProfessional {
            return .professional
        } else {
            return .citizen
        }
    }
    
    var weather:Bool=false
    
    var confidence:ConfidenceLevel
    var image:EncodableImage?=nil
    var hasImage: Bool {
        return image != nil
    }
    
    var comments:[Comment]
    
    var size:FlightSize
    
    var validated: Bool = false
    var validatedBy: String? = nil
    var validatedAt: Date? = nil
    
    // MARK: - Initializers
    init(flightID: Int=0, taxonomy: Species, confidence:ConfidenceLevel, location:CLLocationCoordinate2D, radius: Double, dateOfFlight:Date, owner:String, weather: Bool = false, ownerProfessional:Bool, ownerFlagged:Bool=false, comments:[Comment]=[], dateRecorded:Date=Date(), size:FlightSize, image:EncodableImage?=nil){//, uiimage:UIImage?=nil) {
        self.flightID = flightID
//        self.genus = genus
//        self.species = species
        
        self.taxonomy = taxonomy//try! Species.get(pGenus: Genus.get(genus), pSpecies: species)
        
        self.location = location
        
//        self.latitude = location.latitude
//        self.longitude = location.longitude
        self.radius = radius
        self.dateOfFlight = dateOfFlight
        self.owner = owner
        self.ownerProfessional = ownerProfessional
        self.ownerFlagged = ownerFlagged
        self.comments = comments
        self.weather = weather
        self.dateRecorded = dateRecorded
        self.confidence = confidence
        self.size = size
        
//        if let image = encodableImage {
        self.image = image
//            self.hasImage = true
//        }
//        else if let image = uiimage {
//            self.image = EncodableImage(image: image)
//        }
//        else {
//            self.image = nil
//        }
    }
    
    // MARK: - Static Methods
    static func == (l:Flight, r:Flight)->Bool{
        if (l.flightID != r.flightID){ return false }
        if (l.taxonomy != r.taxonomy){ return false }
        if (l.confidence != r.confidence){ return false }
        if (l.location.latitude != r.location.latitude){ return false }
        if (l.location.longitude != r.location.longitude){ return false }
        if (l.radius != r.radius){ return false }
        if (l.dateOfFlight != r.dateOfFlight){ return false }
        if (l.dateRecorded != r.dateRecorded){ return false }
        if (l.owner != r.owner){ return false }
        if (l.comments != r.comments){ return false }
//        if (l.image != nil && r.image != nil){
//            if (l.image! != r.image!){
//                return false
//            }
//        }
        
        if (l.image != r.image) {return false}
        
        if (l.weather != r.weather){ return false }
        
        if (l.size != r.size){ return false}
        
        return true
    }
    
    // MARK: - Instance Methods
    func copy()->Flight{
        return Flight(flightID: self.flightID, taxonomy: self.taxonomy, confidence: self.confidence, location: self.location, radius: radius, dateOfFlight: self.dateOfFlight, owner: self.owner, weather: self.weather, ownerProfessional: self.ownerProfessional, ownerFlagged: self.ownerFlagged, comments: self.comments, dateRecorded: self.dateRecorded, size: self.size, image: self.image)
    }
    
    private enum EncodingKeys:String, CodingKey{
        case owner = "owner"
        case flightID = "flightID"
        case taxonomy = "taxonomy"
        case dateOfFlight = "dateOfFlight"
        case latitude = "latitude"
        case longitude = "longitude"
        case radius = "radius"
        case dateRecorded = "dateRecorded"
        case hasImage = "hasImage"
        case image = "image"
        case confidence = "confidence"
        case size = "size"
        case comments = "comments"
    }
        
    private enum SpeciesKeys: String, CodingKey
    {
        case name = "name"
        case genus = "genus"
    }
    
    private enum GenusKeys: String, CodingKey
    {
        case name = "name"
    }
    
    func encode(to e: Encoder) throws{
        var outermost = e.container(keyedBy: EncodingKeys.self)
        var species = outermost.nestedContainer(keyedBy: SpeciesKeys.self, forKey: .taxonomy)
        var genus = species.nestedContainer(keyedBy: GenusKeys.self, forKey: .genus)
        
        try genus.encode(self.taxonomy.genus.name, forKey: .name)
        try species.encode(self.taxonomy.name, forKey: .name)
        
        try outermost.encode(self.radius, forKey: .radius)
        try outermost.encode(self.location.longitude, forKey: .longitude)
        try outermost.encode(self.location.latitude, forKey: .latitude)
        try outermost.encode(self.dateOfFlight, forKey: .dateOfFlight)
        try outermost.encode(self.dateRecorded, forKey: .dateRecorded)
        try outermost.encode(self.confidence, forKey: .confidence)
        try outermost.encode(self.size, forKey: .size)
        try outermost.encode(self.flightID, forKey: .flightID)
        if let imageToEncode = image {
            if !(imageToEncode === EncodableImage.EMPTY_IMAGE) {
                try outermost.encode(imageToEncode, forKey: .image)
            }
        }
        try outermost.encode(self.hasImage, forKey: .hasImage)
        try outermost.encode(self.comments, forKey: .comments)
        try outermost.encode(self.owner, forKey: .owner)
    }
    
    private enum DecodingKeys: String, CodingKey{
        case flightID = "flightID"
        case taxonomy = "taxonomy"
        case owner = "owner"
        case ownerProfessional = "ownerProfessional"
        case ownerFlagged = "ownerFlagged"
        case dateOfFlight = "dateOfFlight"
        case latitude = "latitude"
        case longitude = "longitude"
        case radius = "radius"
        case dateRecorded = "dateRecorded"
        case image = "image"
        case weather = "weather"
        case confidence = "confidence"
        case size = "size"
        case comments = "comments"
        case validated = "validated"
        case validatedBy = "validatedBy"
        case validatedAt = "validatedAt"
    }
    
    required init(from d: Decoder) throws {
        let outer = try d.container(keyedBy: DecodingKeys.self)
        let taxonomyContainer = try outer.nestedContainer(keyedBy: SpeciesKeys.self, forKey: .taxonomy)
        let genusContainer = try taxonomyContainer.nestedContainer(keyedBy: GenusKeys.self, forKey: .genus)
        
        let genusName = try genusContainer.decode(String.self, forKey: .name)
        let speciesName = try taxonomyContainer.decode(String.self, forKey: .name)
        
        let genus = try Genus.get(genusName)
        let species = try Species.get(pGenus: genus, pSpecies: speciesName)
        self.taxonomy = species
        
        flightID = try outer.decode(Int.self, forKey: .flightID)
        let latitude = try outer.decode(Double.self, forKey: .latitude)
        let longitude = try outer.decode(Double.self, forKey: .longitude)
        location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        radius = try outer.decode(Double.self, forKey: .radius)
        size = try outer.decode(FlightSize.self, forKey: .size)
        confidence = try outer.decode(ConfidenceLevel.self, forKey: .confidence)
        
        dateOfFlight = try outer.decode(Date.self, forKey: .dateOfFlight)
        dateRecorded = try outer.decode(Date.self, forKey: .dateRecorded)
        
        owner = try outer.decode(String.self, forKey: .owner)
        ownerProfessional = try outer.decode(Bool.self, forKey: .ownerProfessional)
        ownerFlagged = try outer.decode(Bool.self, forKey: .ownerFlagged)
        
        weather = try outer.decode(Bool.self, forKey: .weather)
        
        comments = try outer.decode([Comment].self, forKey: .comments)
        
        if let imageURL = try outer.decode(URL?.self, forKey: .image) {
            image = .generateHolderForUrl(imageURL)
        }
        
        validated = try outer.decode(Bool.self, forKey: .validated)
        validatedBy = try outer.decode(String?.self, forKey: .validatedBy)
        validatedAt = try outer.decode(Date?.self, forKey: .validatedAt)
    }
    
    // MARK: - Internal Types
    enum ConfidenceLevel: Int, CustomStringConvertible, Codable {
        case low = 0
        case high = 1
        
        var description: String {
            switch self{
            case .low:
                return "Low"
            case .high:
                return "High"
            }
        }
    }
    
    enum FlightSize: Int, CustomStringConvertible, Codable {
        case manyQueens = 0
        case singleQueen = 1
        
        var description: String {
            switch self{
            case .manyQueens:
                return "Many queens"
            case .singleQueen:
                return "Single queen"
            }
        }
    }
}
