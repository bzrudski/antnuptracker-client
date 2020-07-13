//
//  AntNupTrackerTests.swift
//  AntNupTracker, the ant nuptial flight field database
//  Copyright (C) 2020  Abouheif Lab
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <https://www.gnu.org/licenses/>.

import XCTest
@testable import AntNupTracker

class AntNupTrackerTests: XCTestCase {
    
    var flight1: Flight? = nil
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        let comment1 = Comment(flight: 42, author: "username", text: "Comment Text", time: Date(), role: .citizen)
        flight1 = Flight(flightID: 42, taxonomy: try! .get(pGenus: try! .get("Pheidole"), pSpecies: "dentata"), confidence: .low, location: .init(latitude: 45.0, longitude: -73.2), radius: 4.0, dateOfFlight: Date(), owner: "dentata408", weather: true, ownerProfessional: false, ownerFlagged: false, comments: [comment1], dateRecorded: Date(), size: .manyQueens, image: nil)
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testEqualityFormFlight(){
        let device = Device(deviceID: 432)
        FlightAppManager.shared.session = Session(username: "username", professional: true, authToken: "w32432434324", device: device)
        let form = FlightForm()
        form.loadFlight(flight1!)
        let flightFromForm = form.generateFlight()!
        
        XCTAssertEqual(flight1!, flightFromForm)
    }
    
    func testEqualityFlightCopy(){
        let flight2 = flight1!.copy()
        XCTAssertEqual(flight1!, flight2)
    }
    /*
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    */

}
