//
// FlightForm.swift
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

/// Structure of storing a flight form
class FlightForm: Sequence {
    private var sections: [Section]
    
//    private var geocoder = CLGeocoder()
    
    public var count: Int {
        sections.count
    }
    
    init () {
        var sections: [Section] = []
        
        let taxonomySection = Section(type: .taxonomy)
        taxonomySection.addField(.init(type: .genus))
        taxonomySection.addField(.init(type: .species))
        taxonomySection.addField(.init(type: .confidence))
        
        sections.append(taxonomySection)
        
        let flightSizeSection = Section(type: .flightSize)
        flightSizeSection.addField(.init(type: .flightSize))
        
        sections.append(flightSizeSection)
        
        let dateAndTimeSection = Section(type: .dateAndTime)
        dateAndTimeSection.addField(.init(type: .dateLabel))
        dateAndTimeSection.addField(.init(type: .timeLabel))
        dateAndTimeSection.addField(.init(type: .datePicker))
        
        sections.append(dateAndTimeSection)
        
        let locationSection = Section(type: .location)
        locationSection.addField(.init(type: .locationLabel))
        locationSection.addField(.init(type: .radiusLabel))
        locationSection.addField(.init(type: .locationPicker))
        
        sections.append(locationSection)
        
        let imageSection = Section(type: .image)
        imageSection.addField(.init(type: .hasImage))
        
        sections.append(imageSection)
        
        self.sections = sections
    }
    
    func getSectionBy(type t: Section.SectionType)->Section?{
        return sections.first(where: {$0.type == t})
    }
    
    func getIndexForSectionWith(type: Section.SectionType) -> Int?{
        return sections.firstIndex(where: {$0.type == type})
    }
    
    func addSection(_ s:Section){
        sections.append(s)
    }
    
    func removeSectionsWith(type t: Section.SectionType){
        sections.removeAll(where: {$0.type == t})
    }
    
    func getFieldWith(type t:Field.FieldType) -> Field? {
        for section in sections {
            if let field = section.getFieldWith(type: t) {
                return field
            }
        }
        
        return nil
    }
    
    func getIndexForFieldWith(type t:Field.FieldType) -> IndexPath? {
        var sectionIndex = 0
        
        for section in sections {
            if let fieldIndex = section.getFirstIndexForFieldWith(type: t) {
                return IndexPath(row: fieldIndex, section: sectionIndex)
            }
            
            sectionIndex += 1
        }
        
        return nil
    }
    
    subscript(i:Int) -> Section {
        get {
            sections[i]
        }
    }
    
    subscript(i: IndexPath) -> Field {
        get {
            sections[i.section][i.row]
        }
    }
    
    func makeIterator() -> IndexingIterator<[Section]> {
        return sections.makeIterator()
    }
    
    private var observer: FlightFormObserver? = nil
    
    func setObserver(_ o:FlightFormObserver){
        self.observer = o
    }
    
    func unsetObserver(){
        self.observer = nil
    }
    
    public func loadFlight(_ f:Flight) {
        
        updatingFlight = true
        
        flightID = f.flightID
        genus = f.taxonomy.genus
        species = f.taxonomy
        date = f.dateOfFlight
        location = f.location
        radius = f.radius
        confidence = f.confidence
        size = f.size
        hasImage = f.hasImage
        image = f.image
        
        if f.hasImage {
            sections[Section.SectionType.image.rawValue].addField(.init(type: .image))
        }
        
        owner = f.owner
        userProfessional = f.ownerProfessional
        dateRecorded = f.dateRecorded
        comments = f.comments
        weather = f.weather
    }
    
    // MARK: - Private Fields
    
    private var flightID: Int = 0
    
    private var genus: Genus? = nil
    
    private var species: Species? = nil
    
    private var date: Date = Date()
    
    private var location: CLLocationCoordinate2D = {
        if (CLLocationManager.authorizationStatus() == .authorizedWhenInUse){
                
                let locationManager = FlightAppManager.shared.locationManager
                
                locationManager.startUpdatingLocation()
                while (locationManager.location == nil){}
                locationManager.stopUpdatingLocation()
                return locationManager.location?.coordinate ?? .init(latitude: 0.0, longitude: 0.0)
                
            } else {
                return .init(latitude: 0.0, longitude: 0.0)
            }
        } ()
    
    private var radius: Double = 0.0
    
    private var confidence: Flight.ConfidenceLevel = .low
    
    private var size: Flight.FlightSize = .manyQueens
    
    private var hasImage: Bool = false
    
    private var image: EncodableImage? = nil
    
    private var comments: [Comment] = []
    
    private var owner: String = FlightAppManager.shared.session!.username
    
    private var userProfessional = FlightAppManager.shared.session!.professional
    
    private var dateRecorded = Date()
    
    private var weather = false
    
    private var updatingFlight = false
    private var hasChangedImage = false
    
    // MARK: - Getters and Setters
    public func getFlightID() -> Int {
        return flightID
    }
    
    public func setGenus(_ g: Genus?){
        self.genus = g
        let genusIndexPath = self.getIndexForFieldWith(type: .genus)!
        self.observer?.formFieldChanged(atIndexPaths: [genusIndexPath])
    }
    
    public func getGenus() -> Genus? {
        return genus
    }
    
    public func setSpecies(_ s: Species?){
        self.species = s
        let speciesIndexPath = self.getIndexForFieldWith(type: .species)!
        self.observer?.formFieldChanged(atIndexPaths: [speciesIndexPath])
    }
    
    public func getSpecies() -> Species? {
        return species
    }
    
    public func setDate(_ d:Date) {
        self.date = d
        let dateIndexPath = self.getIndexForFieldWith(type: .dateLabel)!
        let timeIndexPath = self.getIndexForFieldWith(type: .timeLabel)!
        
        self.observer?.formFieldChanged(atIndexPaths: [dateIndexPath, timeIndexPath])
    }
    
    public func getDate() -> Date {
        return date
    }
    
    public func setLocation(_ l:CLLocationCoordinate2D) {
        self.location = l
        let locationIndexPath = self.getIndexForFieldWith(type: .locationLabel)!
        
//        let locationToCode = CLLocation.init(latitude: l.latitude, longitude: l.longitude)
//
//        geocoder.reverseGeocodeLocation(locationToCode){
//            placemarks, error in
//            guard let loc = placemarks?.last else {
//                return
//            }
//            guard let newTimeZone = loc.timeZone else {
//                return
//            }
//
//            let calendar = Calendar(identifier: .gregorian)
//            self.date = calendar.date(byAdding: .timeZone, value: newTimeZone.secondsFromGMT(), to: self.date) ?? self.date
//        }
//
        self.observer?.formFieldChanged(atIndexPaths: [locationIndexPath])
    }
    
    public func getLocation() -> CLLocationCoordinate2D {
        return location
    }
    
    public func setRadius(_ r:Double){
        self.radius = r
        let radiusIndexPath = self.getIndexForFieldWith(type: .radiusLabel)!
        self.observer?.formFieldChanged(atIndexPaths: [radiusIndexPath])
    }
    
    public func getRadius() -> Double {
        return radius
    }
    
    public func setConfidence(_ c: Int){
        self.confidence = Flight.ConfidenceLevel(rawValue: c)!
        // let confidenceIndexPath = self.getIndexForFieldWith(type: .confidence)!
        // self.observer?.formFieldChanged(atIndexPaths: [confidenceIndexPath])
    }
    
    public func getConfidence() -> Int {
        return confidence.rawValue
    }
    
    public func setSize(_ s:Int){
        self.size = Flight.FlightSize(rawValue: s)!
        // let sizeIndexPath = self.getIndexForFieldWith(type: .flightSize)!
        // self.observer?.formFieldChanged(atIndexPaths: [sizeIndexPath])
    }
    
    public func getSize() -> Int {
        return size.rawValue
    }
    
    public func setHasImage(_ b: Bool){
        self.hasImage = b
        self.hasChangedImage = true
        
        if hasImage {
            sections[Section.SectionType.image.rawValue].addField(.init(type: .image))
            
            let newIndex = IndexPath(row: 1, section: Section.SectionType.image.rawValue)
            
            self.observer?.formAddedField(atIndexPaths: [newIndex])
        } else {
            image = nil
            sections[Section.SectionType.image.rawValue].removeLastFieldWith(type: .image)
            let index = IndexPath(row: 1, section: Section.SectionType.image.rawValue)
            
            self.observer?.formRemovedField(fromIndexPaths: [index])
        }
    }
    
    public func getHasImage() -> Bool {
        return hasImage
    }
    
    public func setImage(_ i: EncodableImage?){
        if hasImage {
            self.hasChangedImage = true
            self.image = i
            let imageIndex = sections[Section.SectionType.image.rawValue].getFirstIndexForFieldWith(type: .image)!
            
            let indexPath = IndexPath(row: imageIndex, section: Section.SectionType.image.rawValue)
            self.observer?.formFieldChanged(atIndexPaths: [indexPath])
        }
    }
    
    // CAREFUL!!! LEAK OF CLASS... MAYBE SWITCH TO A STRUCT
    public func getImage() -> EncodableImage? {
        return image
    }
    
    // No setter since the form doesn't deal with comments
    public func getComments() -> [Comment] {
        return comments
    }
    
    public func getOwner() -> String {
        return owner
    }
    
    public func getUserProfessional() -> Bool {
        return userProfessional
    }
    
    public func getDateRecorded() -> Date {
        return dateRecorded
    }
    
    public func getWeather() -> Bool {
        return weather
    }
    
    // MARK: - Flight Generation
    public var canGenerateFlight: Bool {
        !(genus == nil || species == nil || (hasImage && image == nil))
    }
    
    public func generateFlight() -> Flight? {
        if !canGenerateFlight {
            return nil
        }
        
        let flightImage: EncodableImage?
        
        if hasChangedImage || !hasImage {
            flightImage = image
        } else {
            flightImage = .EMPTY_IMAGE
        }
        
        return Flight(flightID: flightID, taxonomy: species!, confidence: confidence, location: location, radius: radius, dateOfFlight: date, owner: owner, weather: weather, ownerProfessional: userProfessional, comments: comments, dateRecorded: dateRecorded, size: size, image: flightImage)
    }
    
    // MARK: - Nested Data Structures
    class Section: Sequence {
        var fields: [Field]
        var type: SectionType
        
        public var count:Int {
            fields.count
        }
        
        init(fields: [Field] = [], type: SectionType){
            self.fields = fields
            self.type = type
        }
        
        func addField(_ f:Field){
            self.fields.append(f)
        }
        
        func removeFieldsWith(type t:Field.FieldType){
            self.fields.removeAll(where: {$0.type == t})
        }
        
        func removeFirstFieldWith(type t:Field.FieldType){
            if let fieldIndex = fields.firstIndex(where: {$0.type == t}){
                fields.remove(at: fieldIndex)
            }
        }
        
        func removeLastFieldWith(type t:Field.FieldType){
            if let fieldIndex = fields.lastIndex(where: {$0.type == t}) {
                fields.remove(at: fieldIndex)
            }
        }
        
        func getFieldWith(type t:Field.FieldType)->Field?{
            return fields.first(where: {$0.type == t})
        }
        
        func getFirstIndexForFieldWith(type t: Field.FieldType) -> Int? {
            return fields.firstIndex(where: {$0.type == t})
        }
        
        func makeIterator() -> IndexingIterator<[Field]> {
            return fields.makeIterator()
        }
        
        subscript(i:Int) -> Field {
            get {
                fields[i]
            }
        }
        
        enum SectionType: Int, CustomStringConvertible {
            case taxonomy
            case flightSize
            case dateAndTime
            case location
            case image
            
            var description: String {
                switch self {
                case .taxonomy:
                    return "Taxonomy"
                case .flightSize:
                    return "Flight Size"
                case .dateAndTime:
                    return "Date and Time"
                case .location:
                    return "Location"
                case .image:
                    return "Image"
                }
            }
        }
    }
    
    class Field {
        var type: FieldType
        
        init(type: FieldType) {
            self.type = type
        }
        
        enum FieldType {
            case genus
            case species
            case confidence
            case flightSize
            case dateLabel
            case timeLabel
            case datePicker
            case locationLabel
            case radiusLabel
            case locationPicker
            case hasImage
            case image
        }
    }
}
