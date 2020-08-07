//
// FlightDetailTableViewController.swift
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

class FlightDetailTableViewController: UITableViewController, FlightFetchDetailObserver, FlightImageObserver, FlightCommentObserver, FlightValidationObserver {
    
    typealias ListErrors = FlightList.ReadErrors
    typealias CommentErrors = CommentManager.CommentErrors
    typealias ImageErrors = FlightImageManager.ImageErrors
    typealias ValidationErrors = FlightValidationManager.ValidateErrors

    override func viewDidLoad() {
        //self.tableView.register(CommentTableViewCell.self, forCellReuseIdentifier: "commentCell")
        //self.tableView.register(, forCellReuseIdentifier: "commentCell")
//        self.flight = getFlightForID(self.flightID)
//        self.dataSource = .init(from: self.flight)
        super.viewDidLoad()
        
//        tableView.rowHeight = UITableView.automaticDimension
//        tableView.estimatedRowHeight = 500
        
        FlightAppManager.shared.flights.setFlightDetailObserver(observer: self)
        FlightImageManager.shared.setObserver(self)
        CommentManager.shared.setObserver(self)
        FlightValidationManager.shared.setObserver(self)
        
        self.updateCommentButtonState()
        self.updateVerifyButtonState()
        
        guard flightID != nil else {
            let alert = UIAlertController(title: "No Flight", message: "No flight selected. Please select a flight and try again.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: {self.dismiss(animated: true, completion: nil)})
            return
        }
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl?.addTarget(self, action: #selector(triggerLoadFlight), for: .valueChanged)
        self.refreshControl?.beginRefreshing()
        self.triggerLoadFlight()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    // MARK: - UI Outlets
    
    // MARK: Buttons
    @IBOutlet weak var editButton: UIBarButtonItem!
    @IBOutlet weak var commentButton: UIBarButtonItem!
    @IBOutlet weak var verifyButton: UIBarButtonItem!
    
    // MARK: - UI Actions
    @IBAction func addComment(_ sender: UIBarButtonItem) {
        createComment()
    }
    
    @IBAction func verifyFlight(_ sender: UIBarButtonItem){
        let validateAlert = UIAlertController(title: "Confirm Validation", message: "Are you sure that you want to mark this flight as validated?", preferredStyle: .alert)
        validateAlert.addAction(.init(title: "Cancel", style: .cancel, handler: nil))
        validateAlert.addAction(.init(title: "Validate", style: .destructive, handler: {
            action in
            self.triggerValidation()
        }))
        
        self.present(validateAlert, animated: true, completion: nil)
    }
    
    @IBAction func done(_ sender: UIBarButtonItem){
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Local Variables
    var flightID:Int? = nil
    private var flight:Flight? = nil
    private var dataSource:Table<RowModifier>? = nil
    private var imageCell: ImageTableViewCell? = nil
    private var image: UIImage? = nil

    // MARK: - Methods
    
    @objc private func triggerLoadFlight()
    {
//        print("Getting flight")
        FlightAppManager.shared.flights.getFlightBy(id: self.flightID!)
    }
    
    func triggerImageFetch()
    {
//        print("Triggering Image Fetch")
        FlightImageManager.shared.getImage(with: self.flight!.image!.imageURL!, for: self.flightID!)
    }
    
    func triggerImageReload()
    {
        FlightImageManager.shared.getImage(with: self.flight!.image!.imageURL!, for: self.flightID!, reload: true)
    }
    
    func triggerValidation()
    {
        FlightValidationManager.shared.validateFlightWith(id: self.flightID!)
    }
    
    func updateCommentButtonState(){
        commentButton.isEnabled = FlightAppManager.shared.loggedIn
    }
    
    func updateVerifyButtonState(){
        verifyButton.isEnabled = false
        
        guard let f = flight else {
            return
        }
        
        if let role = FlightAppManager.shared.session?.role {
            verifyButton.isEnabled = (role == .professional && !(f.validated))
        } else {
            verifyButton.isEnabled = false
        }
    }
    
    func setFlight(_ f:Flight){
        flight = f
        dataSource = .init(from: f)
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
//        if (flight?.comments.count == 0){
//            return 1
//        }
        //return 4
        return self.dataSource?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.dataSource?[section].count ?? 0
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        self.tableView.estimatedRowHeight = 400
        
        if let modifier = dataSource?[indexPath].modifier, modifier == .image {
            if let cellImage = self.image {
                return tableView.frame.width * cellImage.size.height / cellImage.size.width
            }
        }

//        if let row = tableView.cellForRow(at: indexPath){
//        if let content = self.dataSource?[indexPath].content as? CLLocationCoordinate2D{
//            if (modifier is LocationTableViewCell || row is ImageTableViewCell){
//                self.tableView.estimatedRowHeight = 300
//            }
//        }
        
//        if (self.dataSource?[indexPath].content as? UIImage != nil) {
//            self.tableView.estimatedRowHeight = 300
//        }
//        else if (self.dataSource?[indexPath].content as? CLLocationCoordinate2D != nil){
//            self.tableView.estimatedRowHeight = 325
//        }

        return UITableView.automaticDimension

    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
//    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//
//
////        let entry = self.dataSource[indexPath]
//
////        if (indexPath.section == 0){
////            if (indexPath.row == 6){
////                return 350
////            }
////            if (indexPath.row == 8){
////                return 350
////            }
////        }
//
//    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let entry = self.dataSource?[indexPath] else{
            return UITableViewCell()
        }
        
        let header = entry.header
        
        if let (coordinates, radius) = entry.content as? (CLLocationCoordinate2D, CLLocationDistance) {
                let cell = tableView.dequeueReusableCell(withIdentifier: "location", for: indexPath) as! LocationTableViewCell
//                cell.titleLabel.text = header
                cell.configure(for: coordinates, radius: radius)
//            print("Location cell")
            
                return cell
        }
        
        if let coordinates = entry.content as? CLLocationCoordinate2D {
            let cell = tableView.dequeueReusableCell(withIdentifier: "labelCell") as! DetailTableViewCell
            cell.textLabel!.text = header
            cell.detailTextLabel!.text = String(location: coordinates)
            
            return cell
        }
        
        if let radius = entry.content as? CLLocationDistance {
            let cell = tableView.dequeueReusableCell(withIdentifier: "labelCell") as! DetailTableViewCell
            cell.textLabel!.text = header
            cell.detailTextLabel!.text = "\(radius) km"
            
            return cell
        }
        
        if let date = entry.content as? Date {
            let cell = tableView.dequeueReusableCell(withIdentifier: "labelCell", for: indexPath) as! DetailTableViewCell
            let description = FlightAppManager.shared.dateFormatter.string(from: date)
            cell.textLabel!.text = header
            cell.detailTextLabel!.text = description
            return cell
        }
        
        if let comment = entry.content as? Comment {
            let cell = tableView.dequeueReusableCell(withIdentifier: "comment", for: indexPath) as! CommentTableViewCell
//            cell.textLabel!.text = comment.text
//            cell.detailTextLabel!.text = "\(comment.author), \(FlightAppManager.shared.dateFormatter.string(from: comment.time))"
            cell.configure(for: comment)
            return cell
        }
        
        if let image = entry.content as? EncodableImage {
            let cell = tableView.dequeueReusableCell(withIdentifier: "image", for: indexPath) as! ImageTableViewCell
//            cell.titleLabel.text = header
            cell.configure(for: image.image)
            imageCell = cell
            return cell
        }
        
        if (entry.modifier == .weather){
            let cell = tableView.dequeueReusableCell(withIdentifier: "weather", for: indexPath)
            return cell
        }
        
        if (entry.modifier == .changelog){
            let cell = tableView.dequeueReusableCell(withIdentifier: "history", for: indexPath)
            return cell
        }
        
        if (entry.modifier == .user)
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "userCell", for: indexPath) as! UserTableViewCell
            
            guard let userInfo = entry.content as? [Any] else {
                fatalError("Improperly formatted user content")
            }
            
            guard let username = userInfo[0] as? String, let userRole = userInfo[1] as? Role else {
                fatalError("Improperly formatted user content - 2")
            }
            
            cell.setUp(header: entry.header, username: username, role: userRole)
            
            return cell
        }
        
        if let text = entry.content as? String {
            let cell = tableView.dequeueReusableCell(withIdentifier: "labelCell", for: indexPath) as! DetailTableViewCell
            cell.textLabel!.text = header
            cell.detailTextLabel!.text = text
            
            if (entry.modifier == .taxonomy){
                cell.detailTextLabel!.font = .italicSystemFont(ofSize: cell.detailTextLabel!.font.pointSize)
            } else {
                cell.detailTextLabel!.font = .systemFont(ofSize: cell.detailTextLabel!.font.pointSize)
            }
            
            return cell
        }
        
        return UITableViewCell()
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        return self.dataSource?[section].header
    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        
        return self.dataSource?[section].footer
    }

/*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        
        if (indexPath.row != 7){
            return false
        }
        
        return true
    }


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
    
    // MARK: - Flight Detail Observer Callbacks
    private func updateEditButtonState() {
        if (self.flight!.owner == FlightAppManager.shared.session?.username){
            
            if self.flight!.hasImage && self.image == nil {
                self.editButton.isEnabled = false
            } else {
                self.editButton.isEnabled = true
            }
        } else {
            self.editButton.isEnabled = false
        }
    }
    
    func flightListGotFlight(f: Flight){
//        print("Got flight")
        DispatchQueue.main.async {
            self.setFlight(f)
            self.updateEditButtonState()
            self.updateVerifyButtonState()
            
            if f.hasImage {
                self.triggerImageFetch()
            }
            
            self.refreshControl?.endRefreshing()
            self.tableView.reloadData()
        }
    }
    func flightListGotFlightError(e: ListErrors){
//        print("Error getting flight")
        DispatchQueue.main.async {
            let title:String
            let body: String
            var actions:[UIAlertAction] = []
            let alert: UIAlertController
            let dismissClosure : (UIAlertAction) -> Void = {
                action in
                self.dismiss(animated: true, completion: nil)
            }
            
            let okAndDismiss: UIAlertAction = UIAlertAction(title: "OK", style: .cancel, handler: dismissClosure)
            
            switch e {
            case .invalidID:
                title = "Invalid Flight ID Selected"
                body = "The selected flight has an invalid id. Refresh the flight list and try again. If the problem persists, please contact us."
                actions.append(okAndDismiss)
            case .noResponse:
                title = "Network Error"
                body = "Unable to retrieve the flight information from the server. Please check your network connection and try again."
                actions.append(UIAlertAction(title: "Cancel", style: .cancel, handler: dismissClosure))
                actions.append(UIAlertAction(title: "Try Again", style: .default, handler: {
                    action in
                    self.triggerLoadFlight()
                }))
            case .noFlight:
                title = "No Flight Found"
                body = "No flight was found for the selected ID. Refresh the list and try again."
                actions.append(okAndDismiss)
            case .getError(let status):
                title = "Error Retrieving Flight"
                body = "An error occurred when trying to retrieve the flight (status=\(status)). Please try again later."
                actions.append(okAndDismiss)
            case .jsonError:
                title = "Parse Error"
                body = "Error parsing the flight information. Please try again later."
                actions.append(okAndDismiss)
            default:
                title = "Other Error"
                body = "Some other error occurred when loading the flight. Please try again later."
                actions.append(okAndDismiss)
            }
            
            alert = UIAlertController(title: title, message: body, preferredStyle: .alert)
            
            for action in actions {
                alert.addAction(action)
            }
            
            self.present(alert, animated: true, completion: self.refreshControl?.endRefreshing)
        }
    }
    
    // MARK: - Validation Callbacks
    func flightListValidatedFlight(id:Int){
        DispatchQueue.main.async {
            self.triggerLoadFlight()
//            self.flight!.validatedBy = FlightAppManager.shared.session!.username
//            self.flight!.validatedAt = Date()
//            self.dataSource = .init(from: self.flight!)
//            self.tableView.reloadData()
        }
    }
    
    func flightListValidatedFlightError(id:Int, e:FlightValidationManager.ValidateErrors){
        DispatchQueue.main.async {
        let title:String
        let body: String
        var actions:[UIAlertAction] = []
        let alert: UIAlertController
        
        let okAction: UIAlertAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        
        switch e {
        case .noResponse:
            title = "Network Error"
            body = "Error sending the request to validate the flight. Check your network connection and try again."
            actions.append(.init(title: "Cancel", style: .cancel, handler: nil))
            actions.append(.init(title: "Try Again", style: .default, handler: {action in
                self.triggerValidation()
            }))
        case .invalidID:
            title = "Invalid Flight ID Selected"
            body = "The selected flight has an invalid id. Refresh the flight list and try again. If the problem persists, please contact us."
            actions.append(okAction)
        case .notLoggedIn:
            title = "Not Logged In"
            body = "You are not logged in. This may be caused by an expired session. Log back in and try again."
            actions.append(.init(title: "OK", style: .cancel, handler: {action in
                self.updateVerifyButtonState()
            }))
        case .insufficientPrivileges:
            title = "Insufficient Privileges"
            body = "Validation can only be performed by professionals. If you are a professional, try logging back in. If the problem persists, contact us."
            actions.append(.init(title: "OK", style: .cancel, handler: {action in
                self.updateVerifyButtonState()
            }))
        case .notFound:
            title = "Not Found"
            body = "The selected flight was not found. Please try again later. If you think this is an error, please contact us."
            actions.append(okAction)
        case let .validateError(status):
            title = "Other Validate Error"
            body = "An error occurred while attempting to validate the flight (status=\(status)). Please try again later. If the problem persists, please contact us."
            actions.append(.init(title: "OK", style: .cancel, handler: nil))
        }
        alert = UIAlertController(title: title, message: body, preferredStyle: .alert)
        
        for action in actions {
            alert.addAction(action)
        }
        
        self.present(alert, animated: true, completion: nil)
        }
    }
    
    // MARK: - Image Observer
    func flightListGotImage(_ image: EncodableImage) {
        DispatchQueue.main.async {
//            print("Got image!")
            self.flight!.image = image
            self.dataSource = .init(from: self.flight!)
//            let imageSectionIndex = self.dataSource!.getFirstIndex(by: "Image")!
//
//            self.tableView.reloadSections(.init(integer: imageSectionIndex), with: .automatic)
            self.imageCell?.configure(for: image.image)
            self.image = image.image
            self.updateEditButtonState()
            
            if let imageIndex = self.dataSource?.getFirstIndex(by: "Image") {
                self.tableView.reloadSections(.init(integer: imageIndex), with: .none)
            }
        }
    }
    
    func flightListGotImageError(_ e: FlightImageManager.ImageErrors) {
        DispatchQueue.main.async {
            let title:String
            let body: String
            var actions:[UIAlertAction] = []
            let alert: UIAlertController
            
            let okAction: UIAlertAction = UIAlertAction(title: "OK", style: .cancel, handler: {
                action in
                self.flight!.image = nil
                self.dataSource = Table(from: self.flight!)
                self.tableView.reloadData()
            })
            
            switch e {
            case .noResponse:
                title = "Network Error"
                body = "Error retrieving the flight image from the server. Check your network connection and try again."
                actions.append(.init(title: "Cancel", style: .cancel, handler: {
                    action in
                    self.flight!.image = nil
                    self.dataSource = Table(from: self.flight!)
                    self.tableView.reloadData()
                }))
                actions.append(.init(title: "Try Again", style: .default, handler: {action in
                    self.triggerImageFetch()
                }))
            case .noImage:
                title = "No Image Found"
                body = "No image was found for this flight. If you think this is a mistake, try reloading."
                actions.append(okAction)
            case .dataError:
                title = "Image Decoding Error"
                body = "Error decoding the image. Please try again later."
                actions.append(okAction)
            case let .imageError(status):
                title = "Other Error"
                body = "An error occured retrieving the image (status=\(status)). Please try again later."
                actions.append(okAction)
            }
            
            alert = UIAlertController(title: title, message: body, preferredStyle: .alert)
            
            for action in actions {
                alert.addAction(action)
            }
            
            self.present(alert, animated: true, completion: self.refreshControl?.endRefreshing)
        }
    }
    
    // MARK: - Comment Observer
    func flightListCreatedComment(c: Comment){
        DispatchQueue.main.async {
            self.flight!.comments.append(c)
            self.dataSource = .init(from: self.flight!)
            
            guard let commentsSection = self.dataSource?.getFirstIndex(by: "Comments") else {
                return
            }
            self.tableView.reloadSections(.init(integer: commentsSection), with: .fade)
        }
    }
    func flightListCreatedCommentError(c: Comment, e: CommentErrors){
        DispatchQueue.main.async {
            let title:String
            let body: String
            var actions:[UIAlertAction] = []
            let alert: UIAlertController
            
            let okAction: UIAlertAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            
            switch e {
            case .noResponse:
                title = "Network Error"
                body = "Unable to retrieve the flight information from the server. Please check your network connection and try again."
                actions.append(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                actions.append(UIAlertAction(title: "Try Again", style: .default, handler: {
                    action in
                    self.triggerAddComment(c)
                }))
            case .noFlight:
                title = "No Flight Found"
                body = "No flight was found for the selected ID. Refresh the list and try again."
                actions.append(okAction)
            case .otherError(let status):
                title = "Error Sending Comment"
                body = "An error occurred when trying to send the comment (status=\(status)). Please try again later."
                actions.append(okAction)
            case .jsonError:
                title = "Encoding Error"
                body = "Error encoding the comment. Please try again later."
                actions.append(okAction)
            case .notLoggedIn:
                title = "Authentication Error"
                body = "You are not logged in. This can be caused by an expired session. Please log back in and try again."
                actions.append(okAction)
            }
            
            alert = UIAlertController(title: title, message: body, preferredStyle: .alert)
            
            for action in actions {
                alert.addAction(action)
            }
            
            self.present(alert, animated: true, completion: self.refreshControl?.endRefreshing)
        }
    }
    

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        
        if (segue.identifier == "expandImage"){
            if let imageView = segue.destination as? FullscreenImageViewController {
//                print("Image: ")
//                print(self.image ?? "No image")
                imageView.image = self.image
            }
            return
        }
        
        if (segue.identifier == "editFlight") {
            if let inputView = segue.destination as? DynamicFlightInputTableViewController {
                inputView.currentFlight = flight
            }
            return
        }
        
        if (segue.identifier == "history"){
//            print("Preparing for segue")
            if let historyView = segue.destination as? HistoryTable {
//                print("Have the right view controller")
                historyView.flightID = flightID
            }
//            print("Returning")
            return
        }
        
        if (segue.identifier == "weather"){
            if let weatherView = segue.destination as? WeatherTableViewController {
                weatherView.flightID = flightID
            }
            return
        }
        
        if (segue.identifier == "userDetail"){
            guard let userCell = sender as? UserTableViewCell else {
                return
            }
            
            if let userView = segue.destination as? UserTableViewController {
                userView.username = userCell.username!
            }
            return
        }
        
        if (segue.identifier == "commentUserDetail"){
            guard let userView = segue.destination as? UserTableViewController else {
                return
            }
            
            guard let senderButton = sender as? UIButton else {
                return
            }
            
            guard let username = senderButton.titleLabel?.text else {
                return
            }
            
            userView.username = username
            return
        }
    }
    
    // MARK: - Comments
    private func triggerAddComment(_ comment: Comment){
        CommentManager.shared.createComment(comment: comment)
    }
    
    func createComment(){
        let alert = UIAlertController(title: "New Comment", message: "Enter your comment below.", preferredStyle: .alert)
        alert.addTextField(configurationHandler: {(textField) in
            textField.placeholder = "Enter comment text"
        })
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let addCommentAction = UIAlertAction(title: "Add", style: .default, handler: {action in
            let text = alert.textFields![0].text!
            let comment = Comment(flight: self.flight!.flightID, author: FlightAppManager.shared.session!.username, text: text, time:Date(), role: FlightAppManager.shared.session!.role)
            
            alert.dismiss(animated: true, completion: nil)
            self.triggerAddComment(comment)
        })
        
        alert.addAction(cancel)
        alert.addAction(addCommentAction)
        
        self.present(alert, animated: true, completion: nil)
    }

}
