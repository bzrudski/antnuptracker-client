//
// FlightAnnotation.swift
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
import MapKit
import CoreLocation

class FlightAnnotation:NSObject, MKAnnotation{
    var coordinate: CLLocationCoordinate2D
    weak var flight:FlightBarebone?
    let title: String?
    let subtitle: String?
    
    
    init(flight:FlightBarebone){
        self.flight = flight
        self.title = String(describing: flight.taxonomy)
        self.subtitle = FlightAppManager.shared.dateFormatter.string(from: flight.dateOfFlight)
        self.coordinate = CLLocationCoordinate2D(latitude: flight.latitude, longitude: flight.longitude)
    }
    
}
