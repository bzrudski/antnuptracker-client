//
// SpeciesList.swift
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

class SpeciesList: Sequence
{
    private var speciesArray:[Species]
    private var currentFrame:Frame<Species>? = nil
    
    // MARK: - Observer
    private var observer:SpeciesListObserver? = nil
    
    func setObserver(listObserver:SpeciesListObserver){
        observer = listObserver
    }
    
    func unsetObserver(){
        observer = nil
    }
    
    subscript(i:Int)->Species
    {
        return speciesArray[i]
    }
    
    public var totalCount: Int{
        return currentFrame?.count ?? 0
    }
    
    public var count:Int {
        get {
            return speciesArray.count
        }
    }
    
    public func clear()
    {
        speciesArray.removeAll()
        observer?.speciesListCleared()
    }
    
    
    // MARK: - Initializer
    
    init(pSpecies: [Species]=[])
    {
        speciesArray = pSpecies
    }
    
    func makeIterator() -> Array<Species>.Iterator {
        return speciesArray.makeIterator()
    }
    
    // MARK: - List methods
    
    // MARK: - Reading
    enum ReadErrors:Error
    {
        case authError
        case readError(_ status:Int)
        case jsonParseError
        case noResponse
    }
    
    func read(link:URL)
    {
        
        WebInt.shared.request(.get, link: link, body: nil, authToken: FlightAppManager.shared.session?.authToken, completionHandler: {
                status, data in
            
            if (status == 401){
                self.observer?.speciesListReadWithError(e: .authError)
            }
            
                if (status != 200) {
                    self.observer?.speciesListReadWithError(e: .readError(status))
                    return
                }
                   
                if let newFrame = try? JSONDecoder.shared.decode(Frame<Species>.self, from: data) {
                    self.currentFrame = newFrame
                    self.speciesArray.append(contentsOf: newFrame.results)
                    self.observer?.speciesListRead()
                }
                else {
                    self.observer?.speciesListReadWithError(e: .jsonParseError)
                }

            }, errorHandler: {
                _ in
                self.observer?.speciesListReadWithError(e: .noResponse)
            })
    }
    
    func readNext()
    {
        guard currentFrame != nil else {
            observer?.speciesListReadNext(c: 0)
            return
        }
        guard let link:String = currentFrame?.next else
        {
            observer?.speciesListReadNext(c: 0)
            return
        }
        
        let url = URL(string: link)!
        
        WebInt.shared.request(.get, link: url, body: nil, authToken: FlightAppManager.shared.session?.authToken, completionHandler: {
            status, data in
            
            if (status == 401){
                self.observer?.speciesListReadNextWithError(e: .authError)
                return
            }
            
            if (status != 200){
                self.observer?.speciesListReadNextWithError(e: .readError(status))
                return
            }
            
                if let newFrame = try? JSONDecoder.shared.decode(Frame<Species>.self, from: data) {
                    self.currentFrame = newFrame
                self.speciesArray.append(contentsOf: newFrame.results)
                self.observer?.speciesListReadNext(c: newFrame.results.count)
                } else {
                    self.observer?.speciesListReadNextWithError(e: .jsonParseError)
            }
            
        }, errorHandler: {
            _ in
            self.observer?.speciesListReadNextWithError(e: .noResponse)
        })
    }
    
    // MARK: - Adding
    enum AddErrors {
        case authError
        case addError(_ status:Int)
        case jsonParseError
        case noResponse
    }
    
    func add(link:URL, species pSpecies: [Species])
    {
        guard let authToken = FlightAppManager.shared.session?.authToken else {
            self.observer?.speciesListSpeciesAddedWithError(s: pSpecies, e: .authError)
            return
        }
        
        let command = SpeciesUpdate(species: pSpecies)
        
        let body:Data = try! JSONEncoder.shared.encode(command)
        
        WebInt.shared.request(.post, link: link, body: body, authToken: authToken, completionHandler: {
            status, _ in
            
            if status == 401 {
                self.observer?.speciesListSpeciesAddedWithError(s: pSpecies, e: .authError)
            }
                
            else if status != 200 {
                self.observer?.speciesListSpeciesAddedWithError(s: pSpecies, e: .addError(status))
            }
            
            else {
                self.speciesArray.append(contentsOf: pSpecies)
                self.observer?.speciesListSpeciesAdded(s: pSpecies)
            }
        }, errorHandler: {
            _ in
            self.observer?.speciesListSpeciesAddedWithError(s: pSpecies, e: .noResponse)
        })
    }
    
    // MARK: - Delete
    enum RemoveErrors {
        case authError
        case removeError(_ status:Int)
        case jsonParseError
        case noResponse
    }
    
    func delete(link: URL, species pSpecies: [Species])
    {
        guard let authToken = FlightAppManager.shared.session?.authToken else {
            self.observer?.speciesListSpeciesRemovedWithError(s: pSpecies, e: .authError)
            return
        }
        
        let command = SpeciesUpdate(species: pSpecies)
        
        let body:Data = try! JSONEncoder.shared.encode(command)
        
        WebInt.shared.request(.delete, link: link, body: body, authToken: authToken, completionHandler: {
            status, _ in
            
            if status == 401 {
                self.observer?.speciesListSpeciesRemovedWithError(s: pSpecies, e: .authError)
            }
            
            else if status != 200 {
                self.observer?.speciesListSpeciesRemovedWithError(s: pSpecies, e: .removeError(status))
            }
            
            else {
                self.speciesArray.removeAll(where: pSpecies.contains)
                self.observer?.speciesListSpeciesRemoved(s: pSpecies)
            }
        }, errorHandler: {
            _ in
            self.observer?.speciesListSpeciesRemovedWithError(s: pSpecies, e: .noResponse)
        })
    }
}
