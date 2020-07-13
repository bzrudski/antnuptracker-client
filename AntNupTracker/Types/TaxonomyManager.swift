//
//  TaxonomyManager.swift
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

class TaxonomyManager
{
    public static let shared = TaxonomyManager()
    
    private var genera: [String] = []
    private var taxonomy: [String:[String]] = [:]
    
    private init()
    {
        generateTaxonomy()
    }
    
    private func generateTaxonomy(){
        guard let fileURL = Bundle.main.url(forResource: "taxonomyRaw", withExtension: "txt") else {
            fatalError("Taxonomy file not found in bundle.")
        }
        
        guard let data = try? Data(contentsOf: fileURL) else {
            fatalError("Taxonomy file is corrupted.")
        }
        
        guard let rawString = String(data:data, encoding: .utf8) else {
            fatalError("Taxonomy file is unreadable.")
        }
        taxonomy = generateSpeciesDictionary(raw: rawString)
        
        var rawGenera = Array<String>(taxonomy.keys).sorted()
        rawGenera.remove(at: rawGenera.firstIndex(of: "Unknown")!)
        rawGenera.insert("Unknown", at: 0)
        
        genera = rawGenera
        
//        print("Found \(genera.count) genera")
        
//        var totalSpecies = 0
//        for genus in taxonomy.keys {
//            totalSpecies += taxonomy[genus]!.count
//        }
//
//        print("Found \(totalSpecies) species")

    }
    
    private func generateGenera(raw:String)->[String]{
        var genera = Array<String>()
        
        let split = raw.split(separator: "\n")
        
        for line in split {
            
            if (line.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty){
                continue
            }
            
            if (line.starts(with: "#") || line.starts(with: "//")){
                continue
            }
            
            let subsplit = line.split(separator: " ")
            let genus = String(subsplit[0])
            
            if (genera.contains(genus)){
                continue
            } else {
                genera.append(genus)
            }
        }
        
        return genera
    }
    
    private func generateSpeciesDictionary(raw: String)->[String:[String]]{
        var taxonomy = Dictionary<String, Array<String>>()
        taxonomy["Unknown"] = ["sp. (Unknown)"]
        
        let split = raw.split(separator: "\n")
        
        for line in split {
            if (line.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty){
                continue
            }
            
            if (line.starts(with: "#") || line.starts(with: "//")){
                continue
            }
            
            let subsplit = line.split(separator: " ", maxSplits: 1, omittingEmptySubsequences: true)
            let genus = String(subsplit[0])
            let species = String(subsplit[1])
            
            if !(taxonomy.keys.contains(genus)){
                taxonomy[genus] = ["sp. (Unknown)"]
            }
            taxonomy[genus]!.append(species)
        }
        
        return taxonomy
    }
    
    public func isValidGenus(pGenus:String) -> Bool
    {
        return genera.contains(pGenus)
    }
    
    public func isValidSpecies(pGenus:String, pSpecies:String) -> Bool
    {
        if (isValidGenus(pGenus: pGenus))
        {
            return taxonomy[pGenus]!.contains(pSpecies)
        }
        
        return false
    }
    
    public func getSpecies(for genus:String) throws -> [String]{
        guard let species = taxonomy[genus] else {
            throw TaxonomyErrors.invalidGenus
        }
        return species
    }
    
    public func getGenera() -> [String]
    {
        return genera
    }
}
