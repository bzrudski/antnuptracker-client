//
// FlightList.swift
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

class FlightList:Sequence
{
    
    // MARK: - Sequence setup
    func makeIterator() -> Array<FlightBarebone>.Iterator {
        return flights.makeIterator()
    }
    
    private var flights:[FlightBarebone]=[]
    private var currentFrame:Frame<FlightBarebone>?=nil
    
    private var encoder = JSONEncoder.shared
    private var decoder = JSONDecoder.shared
    private var urlManager = URLManager.current
    
    public var totalCount: Int {
        return currentFrame?.count ?? 0
    }

    subscript(i:Int)->FlightBarebone{
        // We only want to get the filtered flights
        filteredFlights[i]
    }

    var count: Int {
        get{
            return self.filteredFlights.count
        }
    }
    
    public func clear()
    {
            flights.removeAll()
    }
    
    // MARK: - Filtering
    private var filteredFlights: [FlightBarebone] = []
    
    func refilter(){
        self.filteredFlights = FilteringManager.shared.filterList(flights: self.flights)
        self.flightListObserver?.flightListRead()
    }
    
    func filteringCleared(){
        self.filteredFlights = self.flights
        self.flightListObserver?.flightListRead()
    }
    
    // MARK: - Observers
    private var flightListObserver: FlightListObserver? = nil
    private var flightChangeObserver: FlightChangeObserver? = nil
    private var flightDetailObserver: FlightFetchDetailObserver? = nil
    
    public func setFlightListObserver(observer: FlightListObserver) {
        flightListObserver = observer
    }
    
    public func unsetFlightListObserver() {
        flightListObserver = nil
    }
    
    public func setFlightChangeObserver(observer: FlightChangeObserver) {
        flightChangeObserver = observer
    }
    
    public func unsetFlightChangeObserver() {
        flightChangeObserver = nil
    }
    
    public func setFlightDetailObserver(observer: FlightFetchDetailObserver) {
        flightDetailObserver = observer
    }
    
    public func unsetFlightDetailObserver() {
        flightDetailObserver = nil
    }
    
    
    // MARK: - Initializer
    
    /// Initialise a flight list with `flights` as the recorded flights
    /// - parameter flights: flights to add to the list
    init(flights:[FlightBarebone]=[]){
        self.flights = flights
        self.filteredFlights = self.flights
    }
    
    // MARK: - Error Types
    enum ReadErrors:Error{
        case readError(_ status:Int)
        case jsonError
        case getError(status:Int)
        case invalidID
        case noFlight
        case noResponse
        case authError
    }
    
    // MARK: - List methods
    
    /// Read the list of flights from the server.
    func read() {
        loadStoredFlights()
        
        let url = urlManager.listURL()
        
        WebInt.shared.request(.get, link: url, body: nil, authToken: FlightAppManager.shared.session?.authToken, completionHandler: {
            status, data in
            
            if (status == 401){
                self.flightListObserver?.flightListReadError(e: .authError)
                return
            }
            
            if (status != 200){
                self.flightListObserver?.flightListReadError(e: ReadErrors.readError(status))
                return
            }
            
            do{
                self.currentFrame = try self.decoder.decode(Frame<FlightBarebone>.self, from: data)
                let _ = self.updateFlightList(newFlights: self.currentFrame!.results, end: .start)
//                let (filtered, _) = FilteringManager.shared.filterNewFlights(self.currentFrame!.results, addToExisting: self.filteredFlights, atEnd: .start)
//
//                self.filteredFlights = filtered
//                print("There are now \(self.count) flights")
                self.flightListObserver?.flightListRead()
            } catch {
                self.flightListObserver?.flightListReadError(e: ReadErrors.jsonError)
            }
            
        }, errorHandler: {
            _ in
            self.flightListObserver?.flightListReadError(e: ReadErrors.noResponse)
        })
    }
    
    func readNext(_ offsetFrame:Frame<FlightBarebone>?=nil) {
        
        let frameToRead: Frame<FlightBarebone>
        
        if let frame = offsetFrame {
            frameToRead = frame
        } else if let frame = currentFrame {
//            guard let frame = currentFrame else{
//                return
//            }
//            guard let link = frame.next else {
//                return
//            }
            frameToRead = frame
        } else {
            return
        }
        
        guard let link = frameToRead.next else {
            return
        }
        
        //var newFlights = [FlightBarebone]()
        
        let url = URL(string: link)!
        
        WebInt.shared.request(.get, link: url, body: nil, authToken: FlightAppManager.shared.session?.authToken, completionHandler: {
            status, data in
            
            if (status == 401){
                self.flightListObserver?.flightListReadMoreError(e: .authError)
                return
            }
            
            if (status != 200){
                self.flightListObserver?.flightListReadMoreError(e: ReadErrors.readError(status))
                return
            }
            
            do {
                self.currentFrame = try self.decoder.decode(Frame<FlightBarebone>.self, from: data)
//                self.flights.append(contentsOf: self.currentFrame!.results)
                let n = self.updateFlightList(newFlights: self.currentFrame!.results)
//                 let (filtered, _) = FilteringManager.shared.filterNewFlights(self.currentFrame!.results, addToExisting: self.filteredFlights, atEnd: .end)
//
//                self.filteredFlights = filtered
                
//                self.flightListObserver?.flightListReadMore(count: self.currentFrame!.results.count)
                self.flightListObserver?.flightListReadMore(count: n)
//                print("There are now \(self.count) flights")
            } catch {
                self.flightListObserver?.flightListReadMoreError(e: ReadErrors.jsonError)
            }
            
        }, errorHandler: {
            _ in
            self.flightListObserver?.flightListReadMoreError(e: ReadErrors.noResponse)
        })
    }
    
    func getFlightBy(id: Int){
        if (id < 0){
            flightDetailObserver?.flightListGotFlightError(e: ReadErrors.invalidID)
            return
        }
        
        let url = urlManager.urlForFlight(id: id)
        WebInt.shared.request(.get, link: url, body: nil, authToken: FlightAppManager.shared.session?.authToken, completionHandler: {
            status, data in
            
            if (status == 404) {
                self.flightDetailObserver?.flightListGotFlightError(e: .noFlight)
                return
            }
            
            if (status == 401) {
                self.flightDetailObserver?.flightListGotFlightError(e: .authError)
                return
            }
            
            if (status != 200){
                self.flightDetailObserver?.flightListGotFlightError(e: ReadErrors.getError(status: status))
                return
            }
            
            let flight:Flight
            
            do {
                flight = try self.decoder.decode(Flight.self, from: data)
            } catch {
//                print(error.localizedDescription)
//                print(error)
                self.flightDetailObserver?.flightListGotFlightError(e: ReadErrors.jsonError)
                return
            }
            
            self.flightDetailObserver?.flightListGotFlight(f: flight)
//            print("Successfully got flight info.")
        }, errorHandler: {
            _ in
            self.flightDetailObserver?.flightListGotFlightError(e: ReadErrors.noResponse)
        })
    }
    
    enum AddEditErrors: Error {
        case noResponse
        case jsonError
        case insufficientCredentials
        case authenticationError
        case addError(_ status: Int)
        case updateError(_ status: Int)
    }
    
    func add(new flight:Flight) {
        // Can ONLY add if logged in
        guard let authToken = FlightAppManager.shared.session?.authToken else {
            flightChangeObserver?.flightListAddedError(e: .insufficientCredentials)
            return
        }
        
        let url = urlManager.listURL()
        let body: Data
        
        do {
            body = try encoder.encode(flight)
        } catch {
            self.flightChangeObserver?.flightListAddedError(e: .jsonError)
            return
        }
        
//        print(String(data: body, encoding: .utf8)!)
        
        WebInt.shared.request(.post, link: url, body: body, authToken: authToken, completionHandler: {
            status, data in
            
            if (status == 401 || status == 403) {
                self.flightChangeObserver?.flightListAddedError(e: .authenticationError)
                return
            }
            else if (status != 201) {
                self.flightChangeObserver?.flightListAddedError(e: .addError(status))
                return
            }
            
//            self.flights.append(FlightBarebone(flight))
            self.getNewFlights()
            self.flightChangeObserver?.flightListAdded()
            
        }, errorHandler: {
            _ in
            self.flightChangeObserver?.flightListAddedError(e: .noResponse)
        }, delegate: WebDelegate.shared)
    }
    

    func edit(old:Flight, new:Flight) {
        
        if (FlightAppManager.shared.session == nil){
            flightChangeObserver?.flightListEditedError(e: .insufficientCredentials)
        }
        
        if (old == new){
            // No need to update
            flightChangeObserver?.flightListEdited()
            return
        }
        
        if (old.owner != new.owner || old.owner != FlightAppManager.shared.session?.username){
            flightChangeObserver?.flightListEditedError(e: .insufficientCredentials)
        }
        
//        let url = FlightAppManager.baseURL + FlightAppManager.flightsURL + String(old.flightID) + "/"
        let url = urlManager.urlForFlight(id: old.flightID)
//        let status:Int
//        let feedback:Data?
        let body:Data
        
        do{
            body = try encoder.encode(new)
        } catch {
            flightChangeObserver?.flightListEditedError(e: .jsonError)
            return
        }
        
        WebInt.shared.request(.put, link: url, body: body, authToken: FlightAppManager.shared.session!.authToken, completionHandler: {
            status, data in
            
            if status == 401 || status == 403 {
                self.flightChangeObserver?.flightListEditedError(e: .authenticationError)
                return
            }
            
            if status < 200 || status >= 300 {
//                print(String(data: data, encoding: .utf8)!)
                self.flightChangeObserver?.flightListEditedError(e: .updateError(status))
                return
            }
            
            let updatedFlight:Flight
            
            do {
                updatedFlight = try self.decoder.decode(Flight.self, from: data)
            } catch {
                updatedFlight = new
            }
            
            if let index = self.flights.firstIndex(where: {$0 == FlightBarebone(old)}) {
                self.flights[index] = FlightBarebone(updatedFlight)
            }
            
            self.flightChangeObserver?.flightListEdited()
            self.flightListObserver?.flightListChanged()
            
        }, errorHandler: {
            _ in
            self.flightChangeObserver?.flightListEditedError(e: .noResponse)
        }, delegate: WebDelegate.shared)
    }
    
    // MARK: - Update Flight List
    private func updateFlightList(newFlights toAdd: [FlightBarebone], end: ListEnd = .end)-> Int {
//        var i = 0
        
        let newFlights: [FlightBarebone]

        switch end {
        case .start:
//            if flights.count > 0{
                newFlights = toAdd.reversed()
//            } else {
//                fallthrough
//            }
        case .end:
            newFlights = toAdd
        }
        
        for flight in newFlights {
            let id = flight.flightID
            
            if let existingFlightIndex = flights.firstIndex(where: {$0.flightID == id}) {
                let existingFlight = flights[existingFlightIndex]
                
                if existingFlight != flight {
                    flights[existingFlightIndex] = flight
                }
            }
            
            else {
                let index:Int

                switch end {
                case .start:
                    index = 0
                case .end:
                    index = flights.count //> 0 ? flights.count : 0
                }

                flights.insert(flight, at: index)
//                flights.insert(flight, at: 0)
//                i += 1
            }

//            flights.sort(by: {
//                $0.flightID > $1.flightID
//            })
        }
        
        let (filtered, m) = FilteringManager.shared.filterNewFlights(toAdd, addToExisting: self.filteredFlights, atEnd: end)
        
        self.filteredFlights = filtered
        
        return m
    }
   
    // MARK: - Fetch new flights
    enum GetNewFlightsErrors:Error {
        case noResponse
        case jsonError
        case authError
        case getError(Int)
    }
    
    func getNewFlights(){
        
        if currentFrame == nil {
            self.read()
            return
        }
        
        getNewFlightsFrom(startingFrame: currentFrame!, startingUrl: urlManager.listURL())
    }
    
    private func getNewFlightsFrom(startingFrame frame: Frame<FlightBarebone>, startingUrl url: URL){
//        let url = urlManager.listURL()
        
        let oldCount = frame.count
        
        WebInt.shared.request(.get, link: url, body: nil, authToken: FlightAppManager.shared.session?.authToken, completionHandler: {
            status, data in
            
            if status == 401 {
                self.flightListObserver?.flightListGotNewFlightsWithError(e: .authError)
                return
            }
            
            if status != 200 {
                self.flightListObserver?.flightListGotNewFlightsWithError(e: .getError(status))
                return
            }
            
            guard let newFrame = try? JSONDecoder.shared.decode(Frame<FlightBarebone>.self, from: data) else {
                self.flightListObserver?.flightListGotNewFlightsWithError(e: .jsonError)
                return
            }
            
            let newFlights = newFrame.results
            let newCount = newFrame.count
            
            if (newCount - oldCount > 15){
                self.getNewFlightsFrom(startingFrame: newFrame, startingUrl: URL(string: newFrame.next!)!)
            }
            
            let m = self.updateFlightList(newFlights: newFlights, end: .start)
//            let (filtered, m) = FilteringManager.shared.filterNewFlights(newFlights, addToExisting: self.filteredFlights, atEnd: .start)
//
//            self.filteredFlights = filtered
            
            self.flightListObserver?.flightListGotNewFlights(n: m)
            
        }, errorHandler: {
            _ in
            self.flightListObserver?.flightListGotNewFlightsWithError(e: .noResponse)
        })
    }
    
    
    
    // MARK: - Validation
    func validatedFlightWith(id: Int){
        self.flights.first(where: {flight in
            flight.flightID == id
        })!.validated = true
        self.flightListObserver?.flightListChanged()
    }
    
    // MARK: - Saving the list
    let storedFlightsUrl = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("flights")
    
    func saveFlights(){
        let encodedFlights = try! JSONEncoder.shared.encode(flights)
        try? encodedFlights.write(to: storedFlightsUrl)
    }
    
    func loadStoredFlights(){
        guard let flightData = try? Data.init(contentsOf: storedFlightsUrl) else {
            return
        }
        
        guard let storedFlights = try? JSONDecoder.shared.decode([FlightBarebone].self, from: flightData) else {
            return
        }
        
        self.flights = storedFlights.sorted(by: {
            $0.flightID > $1.flightID
        })
        
        self.filteredFlights = FilteringManager.shared.filterList(flights: self.flights)
    }
    
    
    func clearStoredFlight(){
        do {
            try FileManager.default.removeItem(at: storedFlightsUrl)
        } catch {
//            print(error.localizedDescription)
        }
    }
}

public enum ListEnd{
    case start
    case end
}
