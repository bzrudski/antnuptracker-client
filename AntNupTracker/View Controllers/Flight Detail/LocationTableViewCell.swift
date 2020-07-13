//
// LocationTableViewCell.swift
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

import UIKit
import MapKit
import CoreLocation

class LocationTableViewCell: UITableViewCell, MKMapViewDelegate {

    // MARK: - UI Outlets
//    @IBOutlet weak var titleLabel:UILabel!
//    @IBOutlet weak var coordinatesLabel:UILabel!
    @IBOutlet weak var mapView:MKMapView!
    
    // MARK: - Setup
    var pin:MKPointAnnotation = MKPointAnnotation()
    var circle: MKCircle = MKCircle()
    
    func configure(for location:CLLocationCoordinate2D, radius: CLLocationDistance){
        pin.coordinate = location
        mapView.addAnnotation(pin)
        mapView.setCenter(location, animated: true)
        
        let visibleRegion:MKCoordinateRegion = MKCoordinateRegion(center: location, latitudinalMeters: 50000, longitudinalMeters: 50000)
        mapView.setRegion(visibleRegion, animated: false)
        circle = MKCircle(center: location, radius: 1000 * radius)
        mapView.addOverlay(circle)
        
//        coordinatesLabel.text = String(location: location)
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let circleOverlay = overlay as? MKCircle {
            let renderer = MKCircleRenderer(circle: circleOverlay)
            renderer.fillColor = .none //.init(red: 1.0, green: 0.0, blue: 0.0, alpha: 0.4)
            renderer.strokeColor = .red
//            print("adding circle")
            return renderer
        }
        else {
            return MKOverlayRenderer()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        mapView.delegate = self
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.mapView.removeOverlays(self.mapView.overlays)
//        self.mapView.overlays.removeAll()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
