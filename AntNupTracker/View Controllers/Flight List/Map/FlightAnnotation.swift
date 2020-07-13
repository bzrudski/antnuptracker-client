//
//  FlightAnnotation.swift
//  NuptialLog
//
//  Created by Benjamin on 2019-07-05.
//  Copyright © 2019 Benjamin. Some rights reserved.
//

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
