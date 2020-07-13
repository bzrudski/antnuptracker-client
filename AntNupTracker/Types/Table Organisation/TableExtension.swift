//
// TableExtension.swift
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

extension Table where M == RowModifier{
    convenience init(from flightOp:Flight?){
        var sections:[Section<M>] = []
        
        guard let flight = flightOp else {
            self.init(sections:sections)
            return
        }
        
        let flightID:Row<Any, M> = Row(header: "Flight ID", content: String(flight.flightID))
        let genus:Row<Any, M> = Row(header: "Genus", content: flight.taxonomy.genus.name, modifier: .taxonomy)
        let species:Row<Any, M> = Row(header: "Species", content: flight.taxonomy.name, modifier: .taxonomy)
        let confidence:Row<Any, M> = Row(header: "Species Confidence", content: flight.confidence.description)
        let size:Row<Any, M> = Row(header: "Size of Flight", content: flight.size.description)
        
        let basicInfo = Section(header: "Basic Information", rows: [flightID, genus, species, confidence, size])
        
        sections.append(basicInfo)
        
        let dateOfFlight:Row<Any, M> = Row(header: "Date of Flight", content: FlightAppManager.shared.dateOnlyFormatter.string(from: flight.dateOfFlight))
        let timeOfFlight:Row<Any, M> = Row(header: "Time of Flight", content: FlightAppManager.shared.timeFormatter.string(from: flight.dateOfFlight))
        let dateAndTime = Section(header: "Date and Time of Flight", rows: [dateOfFlight, timeOfFlight])
        
        sections.append(dateAndTime)
        
        let map:Row<Any, M> = Row(header: "Map", content: (flight.location, CLLocationDistance(flight.radius)))
        let coordinates:Row<Any, M> = Row(header: "GPS Coordinates", content: String(location: flight.location))
        let radius:Row<Any, M> = Row(header: "Within (±)", content: "\(flight.radius) km")
        let location = Section(header: "Flight Location", rows: [map, coordinates, radius])
        
        sections.append(location)
        
        if flight.hasImage {
            let image: Row<Any, M>
            if flight.image!.image != nil {
                image = Row(header: "Image", content: flight.image!, modifier: .image)
            } else {
                image = Row(header: "Image", content: flight.image!, modifier: .image)
            }
            let imageSection = Section(header: "Image", rows: [image], footer: nil)
            sections.append(imageSection)
        }
        
        
//        var flightOwnerInfo:String = flight.owner
//        print(flight.ownerRole)
//        if (flight.ownerRole == .professionalMyrmecologist)
//        {
//            flightOwnerInfo = flightOwnerInfo.appending(" ✔︎")
//        }
        
//        let calendar = Calendar(identifier: .gregorian)
//        let date = calendar.dateComponents([.day, .weekOfMonth, .year], from: flight.dateRecorded)
//        let time = calendar.dateComponents([.hour, .minute], from: flight.dateRecorded)
        
        let recordingUser:Row<Any, M> = Row(header: "Recorded by", content: [flight.owner, flight.ownerRole], modifier: .user)
        let recordingDate:Row<Any, M> = Row(header: "Date Recorded", content: FlightAppManager.shared.dateOnlyFormatter.string(from: flight.dateRecorded))
        let recordingTime:Row<Any, M> = Row(header: "Time Recorded", content: FlightAppManager.shared.timeFormatter.string(from: flight.dateRecorded))
        let recordedSection = Section(header: "Recording Information", rows: [recordingUser, recordingDate, recordingTime])
        
        sections.append(recordedSection)
        
        if (flight.validated && flight.ownerRole != .professional){
            let validatedBy:Row<Any, M> = Row(header: "Validated by", content: [flight.validatedBy!, Role.professional], modifier: .user)
            let validatedAt: Row<Any, M> = Row(header: "Time of validation", content: flight.validatedAt!)
            let validationSection = Section(header: "Flight Validated", rows: [validatedBy, validatedAt])
            
            sections.append(validationSection)
        }
        
        if (flight.weather){
            let weatherRow:Row<Any, M> = Row(header: "Weather for Flight", content: "", modifier: .weather)
            let weather = Section(header: "Weather", rows: [weatherRow])
            sections.append(weather)
        }
        
        let comments = Section<M>(header: "Comments", rows: [])
        for comment in flight.comments{
            comments.rows.append(Row(header: "Comment", content: comment))
        }
        
        if (comments.count == 0){
            comments.footer = "No comments"
        }
        
        sections.append(comments)
        
        let history:Row<Any, M> = Row(header: "Record History", content: "", modifier: .changelog)
        let changelog = Section(header: "Record History", rows: [history])
        sections.append(changelog)
        
        self.init(sections: sections)
    }
}
