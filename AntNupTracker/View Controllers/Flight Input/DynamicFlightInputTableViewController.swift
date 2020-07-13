//
// FlightInputTableViewController.swift
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
import Photos

class DynamicFlightInputTableViewController: UITableViewController, MKMapViewDelegate,UINavigationControllerDelegate,  UIImagePickerControllerDelegate, FlightChangeObserver, FlightFormObserver, SegmentedCellObserver, SwitchCellObserver, ImageSelectionCellObserver {

    typealias ListErrors = FlightList.ReadErrors
    typealias AddEditErrors = FlightList.AddEditErrors
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        FlightAppManager.shared.flights.setFlightChangeObserver(observer: self)
        
//        self.updating = !(self.currentFlight == nil)
        self.form.setObserver(self)
        
        if (self.updating){
            loadFlight(self.currentFlight!)
        }
        
        self.updateSaveButton()
        self.tableView.reloadData()
        
        self.updateSaveButtonState()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Cells and buttons
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    @IBAction func save(_ sender: UIBarButtonItem) {
        addUpdateFlight()
    }
    
    // MARK: - Image picker delegate
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
//        print("Cancelled")
        picker.dismiss(animated: true, completion: nil)
    }
    
    @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
//        print("Selected Image")
        picker.dismiss(animated: true, completion: {
            guard let selectedImage = info[.originalImage] as? UIImage else {
                fatalError("Image cannot be selected due to dictionary error.")
            }
//            print("Image has now been decoded")
    //        print(selectedImage.pngData()?.base64EncodedString() ?? "No Image")
            self.form.setImage(EncodableImage(image: selectedImage))
//            print("Image has now been encoded")
            if (self.imageFromCamera){
                self.saveImage(selectedImage)
            }
//            print("Preparing to dismiss")
            self.updateSaveButtonState()
//            print("Updated Save Button State")
//            print(form.getImage()?.image?.pngData()?.base64EncodedString() ?? "No Image")
        })
    }
    
    // MARK: - Image saving
    func saveImage(_ image:UIImage){
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(_:didFinishSavingWith:contextInfo:)), nil)
    }
    
    @objc func image(_ image:UIImage, didFinishSavingWith error:Error?, contextInfo:UnsafeRawPointer){
        guard let saveError = error else {
            return
        }
        let alert = UIAlertController(title: "Error Saving Image", message: "An error occurred while trying to save the image to your library: \n \(saveError.localizedDescription)", preferredStyle: .alert)
        let tryAgain = UIAlertAction(title: "Try Again", style: .default, handler: {
            action in
            self.saveImage(image)
        })
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addAction(cancel)
        alert.addAction(tryAgain)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Cell Labelling
//    func updateGenusLabel()
//    {
//        genusCell.detailTextLabel!.text = genus
//    }
//
//    func updateSpeciesLabel()
//    {
//        speciesCell.detailTextLabel!.text = species
//    }
//
//    func updateDateAndTimeLabels()
//    {
//        dateCell.detailTextLabel?.text = FlightAppManager.shared.dateOnlyFormatter.string(from: date)
//        timeCell.detailTextLabel?.text = FlightAppManager.shared.timeFormatter.string(from: date)
//    }
//
//    func updateLocationLabel()
//    {
////        if (location != nil){
////            let label = String(format: "(%.2f, %.2f)", location!.latitude, location!.longitude)
//            let label = String(location: location)
//            locationCell.detailTextLabel?.text = label
////        }
//    }
//
//    func updateRadiusLabel()
//    {
//        radiusCell.detailTextLabel?.text = "\(radius) km"
//    }
    
    // MARK: - Layout
//    private var sizes = [3,1,3,3,2]
    var form = FlightForm()
    
    // MARK: - New or Editing
    var updating:Bool {
        currentFlight != nil
    }
    
    // MARK: - Local variables
    private let bundle = Bundle.main
    var currentFlight:Flight? = nil
    
    var operationInProgress:Bool = false
    
    var operationAlert:ProgressAlertViewController? = nil
    
    // MARK: - Save button label
    ///Update save button depending on the context
    func updateSaveButton(){
        if updating {
            saveButton.title = "Save"
            saveButton.target = self
        } else {
            saveButton.title = "Update"
            saveButton.target = self
        }
    }
    
    func updateSaveButtonState(){
        saveButton.isEnabled = form.canGenerateFlight && !operationInProgress
    }
    
    // MARK: - Editing functionality
    /// Fill fields with existing Flight information
    func loadFlight(_ flight:Flight){
        // Update variables
        form.loadFlight(flight)
        self.updateSaveButton()
//        flightID = flight.flightID
//        taxonomy = flight.taxonomy
//        genus = flight.taxonomy.genus.name
//        species = flight.taxonomy.name
//        date = flight.dateOfFlight
//        location = flight.location
//        radius = flight.radius
//        comments = flight.comments
//
//        dateRecorded = flight.dateRecorded
//        confidence = flight.confidence
//        confidenceSelector.selectedSegmentIndex = confidence
//        size = flight.size
//        sizeSelector.selectedSegmentIndex = size
//        // Update form fields
//        updateGenusLabel()
//        updateSpeciesLabel()
//        updateDateAndTimeLabels()
//        updateLocationLabel()
//        updateRadiusLabel()
//
//        if let image = flight.image {
//            self.image = image
//            imageToggle.setOn(true, animated: true)
//            flightImageView.image = image.image
//            hasImage = true
//        } else {
//            imageToggle.setOn(false, animated: true)
//            hasImage = false
//        }
//
//        updateImageCell(toggleState: hasImage)
        
    }
    
    // MARK: - Data preparation
//    enum FieldErrors:Error{
//        case noGenus
//        case noSpecies
//        case noLocation
//        case notLoggedIn
//    }
//
//    func generateFlightFromFields() throws ->Flight{
//        guard (form.getGenus() != nil) else {
//            throw FieldErrors.noGenus
//        }
//        guard (form.getSpecies() != nil) else {
//            throw FieldErrors.noSpecies
//        }
////        guard (location != nil) else {
////            throw FieldErrors.noLocation
////        }
//        guard (FlightAppManager.shared.session != nil) else {
//            throw FieldErrors.notLoggedIn
//        }
//
//        var cleanedImage:EncodableImage? = form.getImage()
//        if (self.currentFlight != nil){
//            if self.currentFlight!.hasImage && form.getImage() === currentFlight!.image! {
////                print("Using empty image")
//                cleanedImage = .EMPTY_IMAGE
//            }
//        }
//
//        // flight
//        let f = Flight(flightID: form.getFlightID(), genus: form.getGenus()!.name, species: form.getSpecies()!.name, confidence: form.getConfidence(), location: form.getLocation(), radius: form.getRadius(), dateOfFlight: form.getDate(), owner: form.getOwner(), ownerProfessional: form.getUserProfessional(), comments: form.getComments(), dateRecorded: form.getDateRecorded(), size: form.getSize(), encodableImage: cleanedImage)
//
//        f.weather = form.getHasWeather()
//
//        return f
//    }
    
    func triggerAdd(){
        guard let flight = form.generateFlight() else {//try? generateFlightFromFields() else {
            showEmptyFieldsAlert()
            return
        }
        
        self.operationAlert = .init(title: "Addition in Progress", message: "Upload progress: 0%\n", preferredStyle: .alert)
        
        // let width:CGFloat = 0.0
        // let height = width
        // let y: CGFloat = self.operationAlert!.view!.frame.minY + 60.0
        // let x: CGFloat = (self.operationAlert!.view!.frame.width) / 2.0 - 20.0
        
        // self.operationProgressWheel = .init(frame: .init(x: x, y: y, width: width, height: height))
        // self.operationProgressWheel!.style = .gray
        // self.operationAlert!.view!.addSubview(self.operationProgressWheel!)
        
        // self.operationProgressWheel!.startAnimating()
        self.present(operationAlert!, animated: true, completion: operationAlert!.prepareForPresentation)
        
        FlightAppManager.shared.flights.add(new: flight)
    }
    
    func triggerEdit(){
        guard let flight = form.generateFlight() else {//try? generateFlightFromFields() else {
            self.showEmptyFieldsAlert()
            return
        }
        
        self.operationAlert = .init(title: "Edit in Progress", message: "Upload progress: 0%\n", preferredStyle: .alert)
        /*
        let width:CGFloat = 0.0
        let height = width
        let y: CGFloat = self.operationAlert!.view!.frame.minY + 60.0
        let x: CGFloat = (self.operationAlert!.view!.frame.width) / 2.0 - 20.0
//
        self.operationProgressWheel = .init(frame: .init(x: x, y: y, width: width, height: height)) */
//        self.operationProgressWheel = .init(style: .gray)
//        self.operationProgressWheel?.center = self.operationAlert!.view!.convert(self.operationAlert!.view!.center, from: operationProgressWheel!)
        //CGPoint(x: (self.operationAlert!.view!.bounds.minX + self.operationAlert!.view!.bounds.maxX)/2.0,
                                              //        y: (self.operationAlert!.view!.bounds.minY + self.operationAlert!.view!.bounds.maxY)/2.0)
        /* self.operationProgressWheel!.style = .gray
        self.operationAlert!.view!.addSubview(self.operationProgressWheel!)
        
        self.operationProgressWheel!.startAnimating()*/
        self.present(operationAlert!, animated: true, completion: operationAlert!.prepareForPresentation)
        
        FlightAppManager.shared.flights.edit(old: self.currentFlight!, new: flight)
    }
    
    func showEmptyFieldsAlert(){
        let alert = UIAlertController(title: "Empty Fields", message: "Please fill in empty fields before continuing.", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
    
    func addUpdateFlight(){
        
        operationInProgress = true
        updateSaveButtonState()
        
        if (updating){
            triggerEdit()
        }
        else {
            triggerAdd()
        }
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return form.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return form[section].count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let field = self.form[indexPath]
        let type = field.type
        
        switch type {
        case .genus:
            let cell = tableView.dequeueReusableCell(withIdentifier: "genusCell", for: indexPath)
            cell.detailTextLabel!.text = form.getGenus()?.name
            return cell
        case .species:
            let cell = tableView.dequeueReusableCell(withIdentifier: "speciesCell", for: indexPath)
            cell.detailTextLabel!.text = form.getSpecies()?.name
            return cell
        case .confidence:
            let cell = tableView.dequeueReusableCell(withIdentifier: "confidenceCell", for: indexPath) as! SegmentedInputTableViewCell
            cell.field = .confidence
            cell.selectedIndex = form.getConfidence()
            cell.setObserver(self)
            return cell
        case .flightSize:
            let cell = tableView.dequeueReusableCell(withIdentifier: "flightSizeCell", for: indexPath) as! SegmentedInputTableViewCell
            cell.field = .flightSize
            cell.selectedIndex = form.getSize()
            cell.setObserver(self)
            return cell
        case .dateLabel:
            let cell = tableView.dequeueReusableCell(withIdentifier: "dateLabelCell", for: indexPath)
            cell.detailTextLabel!.text = FlightAppManager.shared.dateOnlyFormatter.string(from: form.getDate())
            return cell
        case .timeLabel:
            let cell = tableView.dequeueReusableCell(withIdentifier: "timeLabelCell", for: indexPath)
            cell.detailTextLabel!.text = FlightAppManager.shared.timeFormatter.string(from: form.getDate())
            return cell
        case .datePicker:
            let cell = tableView.dequeueReusableCell(withIdentifier: "datePickerCell", for: indexPath)
            return cell
        case .locationLabel:
            let cell = tableView.dequeueReusableCell(withIdentifier: "locationLabelCell", for: indexPath)
            cell.detailTextLabel!.text = String(location: form.getLocation())
            return cell
        case .radiusLabel:
            let cell = tableView.dequeueReusableCell(withIdentifier: "radiusLabelCell", for: indexPath)
            cell.detailTextLabel!.text = "\(form.getRadius()) km"
            return cell
        case .locationPicker:
            let cell = tableView.dequeueReusableCell(withIdentifier: "locationPickerCell", for: indexPath)
            return cell
        case .hasImage:
            let cell = tableView.dequeueReusableCell(withIdentifier: "hasImageCell", for: indexPath) as! SwitchInputTableViewCell
            cell.field = .hasImage
            cell.switchState = form.getHasImage()
            cell.setObserver(self)
            return cell
        case .image:
            let cell = tableView.dequeueReusableCell(withIdentifier: "imageSelectionCell", for: indexPath) as! ImageSelectionTableViewCell
            cell.selectedImageForCell = form.getImage()?.image
            cell.setObserver(self)
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return form[section].type.description
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        
        if let generaView = segue.destination as? GenusTableViewController {
            generaView.genus = form.getGenus()?.name
        } else if let speciesView = segue.destination as? SpeciesTableViewController{
            speciesView.genus = form.getGenus()?.name
            speciesView.selectedSpecies = form.getSpecies()?.name
        } else if let dateView = segue.destination as? DateViewController {
            dateView.date = form.getDate()
        } else if let locationView = segue.destination as? LocationViewController {
            locationView.location = form.getLocation()
            locationView.radius = form.getRadius()
//            print("Loading Location")
        }
        //else {
//            print("No match")
        // }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        guard (identifier == "unwindToFlightList") else {
            return true
        }
        return true
//        return addUpdateFlight()
    }
    
    @IBAction func unwindToInputView(_ segue:UIStoryboardSegue){
        if let generaView = segue.source as? GenusTableViewController {
            let newGenus = generaView.genus
            if (form.getGenus()?.name != newGenus) {
                form.setSpecies(nil)
//                updateSpeciesLabel()
            }
            
            var genus: Genus? = nil
            if let genusName = newGenus {
                genus = try! Genus.get(genusName)
            }
            form.setGenus(genus)
        } else if let speciesView = segue.source as? SpeciesTableViewController{
            var species: Species? = nil
            
            if let genus = form.getGenus(), let speciesName = speciesView.selectedSpecies {
                species = try! Species.get(pGenus: genus, pSpecies: speciesName)
            }
            
            form.setSpecies(species)
        } else if let dateView = segue.source as? DateViewController {
            form.setDate(dateView.getDate())
        } else if let locationView = segue.source as? LocationViewController {
            let (location, radius) = locationView.getData()
            form.setLocation(location)
            form.setRadius(radius)
        } else {
            fatalError("Not valid viewcontroller in unwind")
        }
        updateSaveButtonState()
    }
    
    // MARK: - Table Cell Height
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if form[indexPath].type == .image {
            if let image = form.getImage()?.image ?? UIImage.init(named: "placeholder", in: .main, compatibleWith: self.traitCollection){
                return tableView.frame.width * image.size.height / image.size.width
            }
        }
        
        return UITableView.automaticDimension
    }
    
    func flightListAdded(){
        DispatchQueue.main.async {
            self.operationAlert!.dismiss(animated: true, completion: {
                self.navigationController!.popToRootViewController(animated: true)
            })
        }
    }
    func flightListAddedError(e: AddEditErrors){
        DispatchQueue.main.async {
            let title: String
            let body: String
            let alert: UIAlertController
            var actions: [UIAlertAction] = []
            let okAndDismiss = UIAlertAction(title: "OK", style: .cancel, handler: {action in
                self.navigationController?.dismiss(animated: true, completion: nil)
            })
            
            let okAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            
            switch e {
            case .insufficientCredentials:
                title = "Session Error"
                body = "You are not logged in. Please sign in before continuing."
                actions.append(okAndDismiss)
            case .noResponse:
                title = "Network Error"
                body = "Unable to communicate with the server. Please check your network connection and try again."
                actions.append(.init(title: "Cancel", style: .cancel, handler: nil))
                actions.append(.init(title: "Try Again", style: .default, handler: {action in
                    self.triggerAdd()
                }))
            case .jsonError:
                title = "Encoding Error"
                body = "Error encoding your flight. Please try again later."
                actions.append(okAction)
            case .authenticationError:
                title = "Authentication Error"
                body = "The server was unable to authenticate your request. Please try signing out and trying again."
                actions.append(okAction)
            case let .addError(status):
                title = "Add Error"
                body = "Some other error occurred when adding the flight (status=\(status)). Please try again later."
                actions.append(okAction)
            case .updateError(_):
                // This case will not happen.
                return
            }
            
            alert = UIAlertController(title: title, message: body, preferredStyle: .alert)
            for action in actions {
                alert.addAction(action)
            }
            
            self.operationAlert?.dismiss(animated: true, completion: {
                self.present(alert, animated: true, completion: nil)
            })
            self.operationInProgress = false
            self.updateSaveButtonState()
        }
    }
    func flightListEdited(){
        DispatchQueue.main.async {
//            self.performSegue(withIdentifier: "unwindToFlightList", sender: self.saveButton)
//            self.dismiss(animated: true, completion: {
//                self.parent?.dismiss(animated: true, completion: nil)
//
//            })
            self.operationAlert!.dismiss(animated: true, completion: {
                self.navigationController!.popToRootViewController(animated: true)
            })
//            self.dismiss(animated: true, completion: nil)
//            self.navigationController!.popViewController(animated: true)
            
//            self.navigationController?.dismiss(animated: true, completion: nil)
//            self.navigationController!.popViewController(animated: true)
        }
    }
    func flightListEditedError(e: AddEditErrors){
        DispatchQueue.main.async {
                let title: String
                let body: String
                let alert: UIAlertController
                var actions: [UIAlertAction] = []
                let okAndDismiss = UIAlertAction(title: "OK", style: .cancel, handler: {action in
                    self.navigationController?.dismiss(animated: true, completion: nil)
                })
                
                let okAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                
                switch e {
                case .insufficientCredentials:
                    title = "Session Error"
                    body = "You are not logged in. Please sign in before continuing."
                    actions.append(okAndDismiss)
                case .noResponse:
                    title = "Network Error"
                    body = "Unable to communicate with the server. Please check your network connection and try again."
                    actions.append(.init(title: "Cancel", style: .cancel, handler: nil))
                    actions.append(.init(title: "Try Again", style: .default, handler: {action in
                        self.triggerEdit()
                    }))
                case .jsonError:
                    title = "Encoding Error"
                    body = "Error encoding your flight. Please try again later."
                    actions.append(okAction)
                case .authenticationError:
                    title = "Authentication Error"
                    body = "The server was unable to authenticate your request. Please try signing out and trying again."
                    actions.append(okAction)
                case .addError(_):
                    return
                case let .updateError(status):
                    title = "Update Error"
                    body = "Some other error occurred when updating the flight (status=\(status)). Please try again later."
                    actions.append(okAction)
                }
            
//                self.operationAlert?.dismiss(animated: true, completion: self.operationProgressWheel?.stopAnimating)
                
                alert = UIAlertController(title: title, message: body, preferredStyle: .alert)
                for action in actions {
                    alert.addAction(action)
                }
                
//                self.present(alert, animated: true, completion: nil)
                self.operationAlert?.dismiss(animated: true, completion: {
                    self.present(alert, animated: true, completion: nil)
                })
                self.operationInProgress = false
                self.updateSaveButtonState()
            }
        }
    
    // MARK: - Flight Form Observer
    func formFieldChanged(atIndexPaths i: [IndexPath]) {
        self.tableView.reloadRows(at: i, with: .none)
//        for index in i {
//            print("Reloading at (\(index.section), \(index.row))")
//        }
        updateSaveButtonState()
    }
    
    func formAddedField(atIndexPaths i: [IndexPath]) {
        
        self.tableView.insertRows(at: i, with: .automatic)
        self.tableView.scrollToRow(at: i.first!, at: .bottom, animated: true)
        updateSaveButtonState()
    }
    
    func formRemovedField(fromIndexPaths i: [IndexPath]) {
        self.tableView.deleteRows(at: i, with: .automatic)
        updateSaveButtonState()
    }
    
    // MARK: - Switch Cell Observer
    func switchCell(valueChangedFor s: UISwitch, toValue v: Bool, forField field: FlightForm.Field.FieldType) {
        if field == .hasImage {
            form.setHasImage(v)
        }
    }
    
    // MARK: - Segmented Cell Observer
    func segmentedCell(valueChangedFor s: UISegmentedControl, toValue v: Int, forField field: FlightForm.Field.FieldType) {
        if field == .confidence {
            form.setConfidence(v)
        } else if field == .flightSize {
            form.setSize(v)
        }
    }
    
    // MARK: - Image Selection Observer
    private var imageFromCamera: Bool = false
        
    func imageCellSelected(_ i:ImageSelectionTableViewCell) {
//        print("tapping")
        //var imageSource:UIImagePickerController.SourceType? = nil
        
        PHPhotoLibrary.requestAuthorization({
            _ in
//            switch status{
//            case .notDetermined:
//                print("Not determined")
//            case .restricted:
//                print("restricted")
//            case .denied:
//                print("denied")
//            case .authorized:
//                print("Authorized")
//            @unknown default:
//                print("Some other auth status")
//            }
        })
        
        
        let alert = UIAlertController(title: "Choose Source", message: nil, preferredStyle: .alert)
        let camera = UIAlertAction(title: "Camera", style: .default, handler: {
            action in
            let pickerView = UIImagePickerController()
            pickerView.sourceType = .camera
            pickerView.delegate = self
            alert.dismiss(animated: true, completion: nil)
            self.present(pickerView, animated: true, completion: nil)
            self.imageFromCamera = true
        })
        
        let library = UIAlertAction(title: "Library", style: .default, handler: { (action) in
            let pickerView = UIImagePickerController()
            pickerView.sourceType = .photoLibrary
            pickerView.delegate = self
            alert.dismiss(animated: true, completion: nil)
            self.present(pickerView, animated: true, completion: nil)
            self.imageFromCamera = false
        })
        
        let none = UIAlertAction(title: "No Image", style: .destructive, handler: {action in
            
            self.form.setImage(nil)
        })
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: {action in
            return
        })
        
        if (UIImagePickerController.isSourceTypeAvailable(.camera)){
            alert.addAction(camera)
        }
        if (UIImagePickerController.isSourceTypeAvailable(.photoLibrary)){
            alert.addAction(library)
        }
        alert.addAction(none)
        alert.addAction(cancel)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func imageCell(_ i:ImageSelectionTableViewCell, selectedImage image: UIImage?) {
        if let selectedImage = image {
            self.form.setImage(EncodableImage(image: selectedImage))
        } else {
            self.form.setImage(nil)
        }
   }
    
    
}
