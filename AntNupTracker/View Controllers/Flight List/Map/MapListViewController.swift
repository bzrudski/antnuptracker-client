//
// MapListViewController.swift
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
import CoreLocation
import MapKit

class MapListViewController: UIViewController, MKMapViewDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        loadFlights()

        // Do any additional setup after loading the view.
    }
    
    // MARK: - UI Outlet
    @IBOutlet weak var mapView: MKMapView!
    
    // MARK: - Local variables
    var flightPins:[MKAnnotation] = []

    // MARK: - Methods
    func loadFlights(){
        flightPins = []
        for flight in FlightAppManager.shared.flights{
            let pin = MKPointAnnotation()
            pin.coordinate = CLLocationCoordinate2D(latitude: flight.latitude, longitude: flight.longitude)
            pin.title = String(describing: flight.taxonomy)
            pin.subtitle = FlightAppManager.shared.dateFormatter.string(from: flight.dateOfFlight)
            flightPins.append(pin)
            mapView.addAnnotation(pin)
        }
    }
    
    // MARK: - UI Actions
    @IBAction func refresh(_ sender:Any?){
        self.loadFlights()
    }
    
    // MARK: - MapView Delegate
//    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
//        guard let annotation = annotation as? FlightAnnotation else {
//            return nil
//        }
//        let identifier = "flightAnnotation"
//        var view: MKMarkerAnnotationView
//        if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView{
//            dequeuedView.annotation = annotation
//            view = dequeuedView
//        } else {
//            view = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
//            view.canShowCallout = true
//            //view.calloutOffset = CGPoint(x: -5, y: 0)
//            //view.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
//        }
//
//        return view
//    }
    
//    @objc func presentDetailView(_ sender:A){
//        let detailView = FlightDetailTableViewController()
//        detailView.flight = flight
//        self.present(detailView, animated: true, completion: nil)
//    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
