//
// Species.swift
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

/**
    Pre-initialised flyweight to represent an ant genus. Essentially a wrapper for a String.
 */
class Genus: Hashable, Equatable, Codable, CustomStringConvertible
{

    public let name: String

    public var description: String {
        get {
        return name
        }
    }
    
    /// Private initialiser for the flyweight
    private init(_ pName:String)
    {
        name = pName
    }

    /// Store used for flyweight objects. Key is genus name.
    private static var genusStore: [String:Genus] = {
        var genera: [String:Genus] = [:]
        for genus in TaxonomyManager.shared.getGenera()
        {
            genera[genus] = Genus(genus)
        }
        return genera
    }()

    /// Retrieve a Genus object from the flyweight store.
    /// - parameter pName: name of the Genus to retrieve
    /// - returns: the genus representing the requested name
    /// - throws: `TaxonomyErrors.invalidGenus` if the requested name is not valid
    public static func get(_ pName:String) throws -> Genus
    {
        guard (genusStore.keys.contains(pName)) else
        {
            throw TaxonomyErrors.invalidGenus
        }
        return genusStore[pName]!
    }

    static func == (lhs: Genus, rhs: Genus) -> Bool {
//        return lhs === rhs
        return lhs.name == rhs.name
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(name)
    }
}


/**
    Lazy flyweight class for managing species
 */
class Species: Codable, CustomStringConvertible, Equatable, Hashable
{
    
    public let genus:Genus
    public let name:String

    public var description:String {
        get{
            return "\(genus) \(name)"
        }
    }

    private enum CodingKeys:CodingKey
    {
        case genus
        case name
    }
    
    private enum GenusCodingKeys:CodingKey
    {
        case name
    }

    private init(pGenus:Genus, pName:String)
    {
        genus = pGenus
        name = pName
    }

    private static var speciesStore: [Genus: [String: Species]] = {
        let keys = try! TaxonomyManager.shared.getGenera().map(Genus.get)
        var speciesDict = [Genus: [String:Species]]()

        for genus in keys
        {
            speciesDict[genus] = [:]
        }

        return speciesDict

    }()

    /**
                Retrieve a species object with a given `Genus` and `String` representing the species.
                - parameter pGenus: `Genus` object representing the genus
                - parameter pSpecies: `String` representing the species name
                - returns: the requested `Species` object
                - throws: `TaxonomyErros.invalidSpecies` if invalid species name requested
     */
    public static func get(pGenus:Genus, pSpecies:String) throws -> Species
    {
        guard TaxonomyManager.shared.isValidSpecies(pGenus: pGenus.name, pSpecies: pSpecies) else
        {
            throw TaxonomyErrors.invalidSpecies
        }

        guard let species = speciesStore[pGenus]![pSpecies] else
        {
            let newSpecies = Species(pGenus: pGenus, pName: pSpecies)
            speciesStore[pGenus]![pSpecies] = newSpecies
            return newSpecies
        }

        return species
    }
    
    public static func == (lhs:Species, rhs:Species) -> Bool
    {
        return lhs.genus == rhs.genus && lhs.name == rhs.name
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(genus)
        hasher.combine(name)
    }
    
//    required init(from decoder: Decoder) throws {
//        let container = try decoder.container(keyedBy: CodingKeys.self)
//        let speciesName = try container.decode(String.self, forKey: .name)
//
//        let genusContainer = try container.nestedContainer(keyedBy: GenusCodingKeys.self, forKey: .genus)
//        let genusName = try genusContainer.decode(String.self, forKey: .name)
//
//        let genus = try Genus.get(genusName)
//
//        self = try .get(pGenus: genus, pSpecies: speciesName)
//    }
    
//    public static func get(from decoder:Decoder)
//    {
//        let genusName = decoder.
//    }
}

enum TaxonomyErrors:Error
{
   case invalidGenus
   case invalidSpecies
   case jsonDecodingError
}
