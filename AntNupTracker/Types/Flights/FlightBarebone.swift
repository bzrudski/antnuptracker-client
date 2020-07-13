//
// FlightBarebone.swift
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

class FlightBarebone:Codable, Equatable{
    var flightID:Int
//    var genus:String
//    var species:String

    var taxonomy: Species
    
    var dateOfFlight:Date
    var latitude:Double
    var longitude:Double
    var lastUpdated: Date
//    var ownerProfessional: Bool
    var owner: String
//    var ownerFlagged: Bool
    var ownerRole: Role
    var validated: Bool = false
    
    var validationLevel: Role {
        if ownerRole == .flagged {
            return .flagged
        } else if validated {
            return .professional
        } else {
            return .citizen
        }
    }
    
    private enum FlightBarebonesCodingKeys: String, CodingKey
    {
        case flightID = "flightID"
        case owner = "owner"
        case taxonomy = "taxonomy"
        case dateOfFlight = "dateOfFlight"
        case latitude = "latitude"
        case longitude = "longitude"
        case lastUpdated = "lastUpdated"
//        case ownerProfessional = "ownerProfessional"
//        case ownerFlagged = "ownerFlagged"
        case ownerRole = "ownerRole"
        case validated = "validated"
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
    
    required init(from decoder: Decoder) throws
    {
        let container = try decoder.container(keyedBy: FlightBarebonesCodingKeys.self)
        flightID = try container.decode(Int.self, forKey: .flightID)
        owner = try container.decode(String.self, forKey: .owner)
        dateOfFlight = try container.decode(Date.self, forKey: .dateOfFlight)
        latitude = try container.decode(Double.self, forKey: .latitude)
        longitude = try container.decode(Double.self, forKey: .longitude)
        lastUpdated = try container.decode(Date.self, forKey: .lastUpdated)
//        ownerProfessional = try container.decode(Bool.self, forKey: .ownerProfessional)
//        ownerFlagged = try container.decode(Bool.self, forKey: .ownerFlagged)
        ownerRole = try container.decode(Role.self, forKey: .ownerRole)
        validated = try container.decode(Bool.self, forKey: .validated)
        
        let speciesNestContainer = try container.nestedContainer(keyedBy: SpeciesKeys.self, forKey: .taxonomy)
        let speciesName = try speciesNestContainer.decode(String.self, forKey: .name)
        let genusContainer = try speciesNestContainer.nestedContainer(keyedBy: GenusKeys.self, forKey: .genus)
        let genusName = try genusContainer.decode(String.self, forKey: .name)
        let genus = try Genus.get(genusName)
        taxonomy = try .get(pGenus: genus, pSpecies: speciesName)
    }
    
//    init(flightID:Int, taxonomy:Species, dateOfFlight:Date, longitude:Double, latitude:Double, lastUpdated: Date){
//        self.flightID = flightID
//        self.genus = genus
//        self.species = species
//        self.taxonomy = taxonomy
//        self.dateOfFlight = dateOfFlight
//        self.longitude = longitude
//        self.latitude = latitude
//        self.lastUpdated = lastUpdated
//    }
    
    init(_ flight: Flight){
        self.flightID = flight.flightID
//        self.genus = flight.genus
//        self.species = flight.species
        self.taxonomy = flight.taxonomy
        self.dateOfFlight = flight.dateOfFlight
        self.latitude = flight.location.latitude
        self.longitude = flight.location.longitude
        self.lastUpdated = Date()
        self.owner = flight.owner
//        self.ownerProfessional = flight.ownerProfessional
//        self.ownerFlagged = flight.ownerFlagged
        self.ownerRole = flight.ownerRole
        self.validated = flight.validated
    }
    
    static func == (l:FlightBarebone, r:FlightBarebone) -> Bool{
        if (l.flightID != r.flightID){ return false }
//        if (l.genus != r.genus){ return false }
//        if (l.species != r.species){ return false }
        if (l.owner != r.owner){ return false }
        if (l.taxonomy != r.taxonomy){ return false }
        if (l.dateOfFlight != r.dateOfFlight){ return false }
        if (l.latitude != r.latitude){ return false }
        if (l.longitude != r.longitude){ return false }
        if (l.lastUpdated != r.lastUpdated){ return false }
        if (l.validated != r.validated){ return false }
        
        return true
    }
}
