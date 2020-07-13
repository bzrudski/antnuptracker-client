//
// LocationViewController.swift
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

class LocationViewController: UIViewController, MKMapViewDelegate, UIToolbarDelegate, UITextFieldDelegate {

    private let locationManager = FlightAppManager.shared.locationManager
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.prepKeyboardNotifications()
        
        mapView.delegate = self
        latField.delegate = self
        longField.delegate = self
        radiusChanger.value = Double(radius)
        
        if (CLLocationManager.authorizationStatus() == .authorizedWhenInUse){
            currentToolbar.isHidden = false
            mapView.bounds = mapView.bounds.insetBy(dx: 0, dy: currentToolbar.bounds.height)
        }
        
        // Do any additional setup after loading the view.
        mapView.addAnnotation(pin)
        
//        if (location == nil){
//        if (CLLocationManager.authorizationStatus() == .authorizedWhenInUse){
//            // If authorised, start with the current location
//            updateLocation(newLoc: getCurrentLocation()!)
//            //mapView.centerCoordinate = location!
//        } else {
//            updateLocation(newLoc: .init(latitude: 0.0, longitude: 0.0))
//        }
//        }
//        else
//        {
        updateLocation(newLoc: location)
//        }
//        circle = MKCircle(center: location!, radius: CLLocationDistance(radius*1000))
//        mapView.addOverlay(circle)
        updateRadiusCircle()
        updateFields()
        updateRadiusLabel()
        
        let touchRecogniser = UITapGestureRecognizer(target: self, action: #selector(pickPoint(_ :)))
        mapView?.addGestureRecognizer(touchRecogniser)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        mapView.removeOverlays(mapView.overlays)
        mapView.removeAnnotations(mapView.annotations)
        mapView.delegate = nil
    }
    
    // MARK: - UI outlets
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet var tapRecogniser: UITapGestureRecognizer!
    @IBOutlet weak var currentToolbar: UIToolbar!
    @IBOutlet weak var longField: UITextField!
    @IBOutlet weak var latField: UITextField!
    @IBOutlet weak var radiusLabel: UILabel!
    @IBOutlet weak var radiusChanger: UIStepper!
    @IBOutlet weak var scrollView: UIScrollView!
    
    // MARK: - UI actions
    @IBAction func cancel(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func useCurrentLocation(_ sender: Any) {
        let loc = getCurrentLocation() ?? location
        updateLocation(newLoc: loc)
//        pin.coordinate = location!
//        mapView.setRegion(MKCoordinateRegion(center: location!, latitudinalMeters: 90000, longitudinalMeters: 90000), animated: true)
        
        updateFields()
//        updateRadiusCircle()
    }
    
    // MARK: - Local variables
    var pin:MKPointAnnotation = MKPointAnnotation()
    var location:CLLocationCoordinate2D = .init(latitude: 0.0, longitude: 0.0)
    
    var circle:MKCircle = MKCircle()
    var radius:Double = 0

    // MARK: - Map methods
    @objc func pickPoint(_ sender: UITapGestureRecognizer){
        //        if (sender.state != UITapGestureRecognizer.State.began){
        //            print("Not recognising tap")
        //            return
        //        }
//        print("Start recognising tap")
        guard (mapView != nil) else {
            return
        }
        
//        print("Recognising tap")
        
        let touchedLocation = sender.location(in: mapView!)
        location = mapView!.convert(touchedLocation, toCoordinateFrom: mapView!)
        pin.coordinate = location
        updateFields()
        updateRadiusCircle()
        //mapView!.addAnnotation(pin)
    }
    
    // MARK: - Toolbar
    func position(for bar: UIBarPositioning) -> UIBarPosition {
        return UIBarPosition.bottom
    }
    
    func getCurrentLocation()->CLLocationCoordinate2D? {
        locationManager.startUpdatingLocation()
        while (locationManager.location == nil){}
        locationManager.stopUpdatingLocation()
        return locationManager.location?.coordinate
    }
    
    func updateRadiusLabel(){
        radiusLabel.text = "\(radius) km"
    }
    
    func updateRadiusCircle(){
        mapView!.removeOverlay(circle)

        if radius > 0 {
            circle = MKCircle(center: location, radius: CLLocationDistance(radius * 1000))
            mapView!.addOverlay(circle)
        }
    }
    
    func updateFields(){
        longField.text = String(location.longitude)
        latField.text = String(location.latitude)
    }
    
    func updateLocation(newLoc:CLLocationCoordinate2D) {
        location = newLoc
        pin.coordinate = location
//        mapView.centerCoordinate = location!
        mapView.setRegion(MKCoordinateRegion(center: location, latitudinalMeters: 90000, longitudinalMeters: 90000), animated: true)
        updateRadiusCircle()
    }
    
    @IBAction func radiusChanged(_ sender: UIStepper) {
        guard sender === radiusChanger else {
            return
        }
        
        radius = sender.value
        updateRadiusLabel()
        updateRadiusCircle()
    }
    
    private func validateInput(for textField: UITextField) -> Bool {
        guard let text = textField.text,
        let _ = Double(text) else {
            return false
        }
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.text == nil || textField.text!.count == 0 {
            return false
        }
        
//        guard let text = textField.text,
//            let _ = Double(text) else {
//                let alert = UIAlertController(title: "Illegal Value Entered", message: "The latitude and longitude must be decimal numbers. Please remove any letters and other characters and try again.", preferredStyle: .alert)
//                let okAction = UIAlertAction(title: "OK", style: .default, handler: {action in
//                    textField.becomeFirstResponder()
//                })
//
//                alert.addAction(okAction)
//                self.present(alert, animated: true, completion: nil)
//
//                return false
//        }
        
        if !self.validateInput(for: textField) {
            let alert = UIAlertController(title: "Illegal Value Entered", message: "The latitude and longitude must be decimal numbers. Please remove any letters and other characters and try again.", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: {action in
                textField.becomeFirstResponder()
            })

            alert.addAction(okAction)
            self.present(alert, animated: true, completion: nil)

            return false
        }
        
        if textField === longField {
            textField.resignFirstResponder()
            latField.becomeFirstResponder()
        }
        else {
            textField.resignFirstResponder()
        }
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if !validateInput(for: textField) {
            let alert = UIAlertController(title: "Illegal Value Entered", message: "The latitude and longitude must be decimal numbers. Please remove any letters and other characters and try again.", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: {action in
                textField.becomeFirstResponder()
            })
            
            alert.addAction(okAction)
            self.present(alert, animated: true, completion: nil)
            return false
        }
        
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        if !validateInput(for: textField) {
            let alert = UIAlertController(title: "Illegal Value Entered", message: "The latitude and longitude must be decimal numbers. Please remove any letters and other characters and try again.", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: {action in
                textField.becomeFirstResponder()
            })
            
            alert.addAction(okAction)
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        if textField === latField {
            let lat = Double(latField.text!)!
            
            let lon = Double(longField.text!)!
            
            updateLocation(newLoc: CLLocationCoordinate2D(latitude: lat, longitude: lon))
        }

    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let circleOverlay = overlay as? MKCircle {
            let renderer = MKCircleRenderer(circle: circleOverlay)
            renderer.fillColor = .none
            renderer.strokeColor = .red
            return renderer
        }
        else {
            return MKOverlayRenderer()
        }
    }
    
    func getData() -> (CLLocationCoordinate2D, Double)
    {
        mapView.removeOverlay(circle)
        return (location, radius)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    // MARK: - Keyboard Management
    func prepKeyboardNotifications(){
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(notification:NSNotification){
        let userInfo = notification.userInfo!
        var keyboardFrame = (userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        keyboardFrame = self.view.convert(keyboardFrame, from: nil)
        
        var contentInset = self.scrollView.contentInset
        contentInset.bottom = keyboardFrame.size.height
        scrollView.contentInset = contentInset

        let desiredSpace:CGFloat = 10.0
        let keyboardTop = keyboardFrame.maxY
        let currentFieldBottom = latField.bounds.minY
        
        let distanceBetween = currentFieldBottom - keyboardTop
        let offsetY = distanceBetween - desiredSpace

        let newRectToScrollTo = self.view.bounds.offsetBy(dx: 0, dy: offsetY)

        scrollView.scrollRectToVisible(newRectToScrollTo, animated: true)
    }
    
    @objc func keyboardWillHide(notification:NSNotification){
        scrollView.contentInset.bottom = 0
    }
}
