//
// FilteringManager.swift
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

class FilteringManager {
    private init() {}
    
    public static let shared = FilteringManager()
    
    private var flightList = FlightAppManager.shared.flights
    
    private var observer: FlightListFilteringObserver? = nil
    
    public func setObserver(_ o:FlightListFilteringObserver) {
        observer = o
    }
    
    public func unsetObserver(){
        observer = nil
    }
    
    private var filteringGenera: [Genus] = []
    private var filteringSpecies: [Species] = []
    
    public var filteringGenusCount: Int {
        filteringGenera.count
    }
    
    public var filteringSpeciesCount: Int {
        filteringSpecies.count
    }
    
    private var isFiltering: Bool {
        !(filteringGenera.isEmpty && filteringSpecies.isEmpty)
    }
    
    private func isIncluded(_ f:FlightBarebone) -> Bool {
        
        if isFiltering {
            return filteringGenera.contains(f.taxonomy.genus) || filteringSpecies.contains(f.taxonomy)
        }
        
        // Since there is no filtering set
        return true
    }
    
    public func addFiltering(genera: [Genus] = [], species: [Species] = []){
        filteringGenera.append(contentsOf: genera)
        filteringSpecies.append(contentsOf: species)
//        filteredFlights = flights.filter(isIncluded(_:))
//        flightListObserver?.flightListFilteringChanged()
        if !(genera.isEmpty && species.isEmpty){
            flightList.refilter()
        }
        observer?.flightListFilteringChanged()
    }
    
    public func removeFiltering(genera: [Genus]=[], species: [Species]=[]){
        filteringSpecies.removeAll(where: species.contains)
        filteringGenera.removeAll(where: genera.contains)
        
        if !(genera.isEmpty && species.isEmpty){
            flightList.refilter()
        }
        
        observer?.flightListFilteringChanged()
    }
    public func removeFilteringGenus(atIndex i:Int){
        filteringGenera.remove(at: i)
        
        flightList.refilter()
        
        observer?.flightListFilteringChanged()
        
    }

    public func removeFilteringSpecies(atIndex i:Int){
        filteringSpecies.remove(at: i)
        
        flightList.refilter()
        
        observer?.flightListFilteringChanged()
    }
    
    public func clearFiltering() {
        filteringGenera.removeAll()
        filteringSpecies.removeAll()
        
        flightList.filteringCleared()
        
        observer?.flightListFilteringCleared()
    }
    
    public func genusNameInFiltering(_ genus:String) -> Bool {
        filteringGenera.contains(where: {$0.name == genus })
    }
    
    public func speciesNameInFiltering(genus: String, species: String) -> Bool {
        filteringSpecies.contains(where: {$0.genus.name == genus && $0.name == species})
    }
    
    public func getFilteredGenus(at i:Int) -> Genus {
        filteringGenera[i]
    }
    
    public func getFilteredSpecies(at i:Int) -> Species {
        filteringSpecies[i]
    }
    
    
    // MARK: - Filtering Actions
    public func filterList(flights: [FlightBarebone]) -> [FlightBarebone] {
        
        return flights.filter(isIncluded(_:))
    }
    
    public func filterNewFlights(_ newFlights:[FlightBarebone], addToExisting flights:[FlightBarebone], atEnd end: ListEnd) -> (filtered: [FlightBarebone], numberAdded: Int){
        var i = 0
                
        let toAdd: [FlightBarebone]
        var updatedFlights: [FlightBarebone] = flights

        switch end {
        case .start:
            toAdd = newFlights.reversed()
        case .end:
            toAdd = newFlights
        }
        
        for flight in toAdd {
            let id = flight.flightID
            
            if let existingFlightIndex = updatedFlights.firstIndex(where: {$0.flightID == id}) {
                let existingFlight = updatedFlights[existingFlightIndex]
                
                if existingFlight != flight {
                    updatedFlights[existingFlightIndex] = flight
                }
                
                if !isIncluded(flight) {
                    updatedFlights.removeAll(where: {$0.flightID == id})
                }
            }
            
            else {
                let index:Int

                if !isIncluded(flight){
                    continue
                }
                
                switch end {
                case .start:
                    index = 0
                case .end:
                    index = updatedFlights.count //> 0 ? flights.count : 0
                }

                updatedFlights.insert(flight, at: index)
                i += 1
            }
        }
        
        return (updatedFlights, i)
    }
    
    // MARK: - Persistence with Filtering
    private class FilterContainer: Codable {
        let filteringGenera: [Genus]
        let filteringSpecies: [Species]
        
        init(genera: [Genus], species: [Species]) {
            self.filteringGenera = genera
            self.filteringSpecies = species
        }
    }
    
    private let storedFiltersUrl = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("filters")
    
    func saveFilters(){
        let filter = FilterContainer(genera: filteringGenera, species: filteringSpecies)
        let encodedFilters = try! JSONEncoder.shared.encode(filter)
        try? encodedFilters.write(to: storedFiltersUrl)
    }
    
    func loadStoredFilters(){
        guard let filterData = try? Data.init(contentsOf: storedFiltersUrl) else {
            return
        }
        
        guard let storedFilters = try? JSONDecoder.shared.decode(FilterContainer.self, from: filterData) else {
            return
        }
        
        self.filteringGenera = storedFilters.filteringGenera
        self.filteringSpecies = storedFilters.filteringSpecies
    }
    
    
    func clearStoredFilters(){
        do{
            try FileManager.default.removeItem(at: storedFiltersUrl)
        } catch {
//            print(error.localizedDescription)
        }
    }
}
