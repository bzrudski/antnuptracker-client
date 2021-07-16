//
// FlightListTableViewController.swift
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

class FlightListTableViewController: UITableViewController, UIPopoverPresentationControllerDelegate, UIAdaptivePresentationControllerDelegate, FlightListObserver, VerifySessionObserver, LoginScreenObserver, SessionClearObserver, FlightListFilteringObserver {

    typealias ListError = FlightList.ReadErrors
    typealias VerificationErrors = SessionManager.VerificationErrors
    
    private let flights = FlightAppManager.shared.flights
    
    override func viewDidLoad() {
        
//        if (!FlightAppManager.shared.loggedIn){
//            FlightAppManager.shared.session = .initFromKeychain()
//        }
        FlightAppManager.shared.setSessionClearObserver(self)
        FlightAppManager.shared.sessionManager.setVerifySessionObserver(observer: self)
        FlightAppManager.shared.sessionManager.initiateLoadAndVerifySessionFromKeychain()
        FlightAppManager.shared.flights.setFlightListObserver(observer: self)
        
        super.viewDidLoad()
        if !(UIApplication.shared.isRegisteredForRemoteNotifications)
        {
            UIApplication.shared.registerForRemoteNotifications()
        }
    
        
//        let loginScreen = UIStoryboard(name: "LoginScreen", bundle: nil).instantiateInitialViewController() as! LoginViewController
//        self.getTopViewController().present(loginScreen, animated: true, completion: nil)
        
        //let loginScreen = LoginViewController()
        //self.getTopViewController().present(loginScreen, animated: true, completion: nil)
        
//        self.refreshList()
        self.updateButtonsState()
        self.refreshControl = UIRefreshControl()
        self.refreshControl!.addTarget(self, action: #selector(triggerFetchNew), for: .valueChanged)
        self.refreshControl!.beginRefreshing()
        FlightAppManager.shared.flights.loadStoredFlights()
        
        self.triggerReload()
        
        DispatchQueue.main.async {
            if self.shouldShowWelcomeScreen(){
                self.showWelcomeScreen()
            }
        }

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return FlightAppManager.shared.flights.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "flightCell", for: indexPath) as? FlightTableViewCell else {
            fatalError("Wrong type of cell dequeued.")
        }

        // Configure the cell...
        let flight = FlightAppManager.shared.flights[indexPath.row]
        
        cell.configure(forFlight: flight)

        return cell
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let lastIndex = FlightAppManager.shared.flights.count - 1
        
        if (lastIndex >= FlightAppManager.shared.flights.totalCount - 1){
            return
        }
        
        if (indexPath.row == lastIndex){
//            self.fetchNextFlights(indexPath)
            self.triggerLoadNext()
        }
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
    
    
    // MARK: - List Methods
    func triggerReload(){
//        print("Reloading")
        refreshControl!.beginRefreshing()
        flights.read()
    }
    
    func triggerLoadNext(){
        flights.readNext()
    }
    
    @objc func triggerFetchNew(){
        flights.getNewFlights()
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        
        if (segue.identifier == "flightDetail"){
            guard let detailView = segue.destination as? FlightDetailTableViewController else {
                fatalError("Wrong type of destination.")
            }
            guard let selectedFlightCell = sender as? FlightTableViewCell else {
                fatalError("Wrong type of sender for segue.")
            }
            guard let index = tableView.indexPath(for: selectedFlightCell) else {
                fatalError("Wrong cell selected.")
            }
            let flight = FlightAppManager.shared.flights[index.row]
            
            detailView.flightID = flight.flightID
            
            //detailView.flight = detailView.getFlightForID(detailView.flightID)
        }
        
        if (segue.identifier == "userDetailFromList"){
            let userView = segue.destination as! UserTableViewController
            
            let userButton = sender as! UIButton
            
            userView.username = userButton.currentTitle!
        }
    }
    
    @IBAction func unwindToFlightList(_ segue:UIStoryboardSegue){
//        tableView.reloadData()
        refreshControl!.beginRefreshing()
        triggerReload()
    }
    
    // MARK: - Welcome Screen
    func shouldShowWelcomeScreen() -> Bool {
        return !(UserDefaults.standard.bool(forKey: "welcomeScreenHasOpened"))
    }
    
    func showWelcomeScreen() {
        let welcomeStoryboard = UIStoryboard.init(name: "Welcome", bundle: .main)
        if let welcomeScreen = welcomeStoryboard.instantiateInitialViewController() {
            self.getTopViewController().present(welcomeScreen, animated: true, completion: nil)
        }
    }
    
    @IBAction func welcome(_ sender: UIBarButtonItem) {
        self.showWelcomeScreen()
    }
    
    // MARK: - Account Management
    @IBOutlet weak var accountButton: UIBarButtonItem!
    
    @objc func displayLogin(){
        let loginScreen = UIStoryboard(name: "LoginScreen", bundle: .main).instantiateViewController(withIdentifier: "loginScreen") as! LoginViewController
        
        loginScreen.setLoginScreenObserver(self)
        
        let loginNavigationController = UINavigationController(rootViewController: loginScreen)
        
        loginNavigationController.navigationBar.barTintColor = .init(red: 0.0, green: 0.0, blue: 65/255, alpha: 1.0)
        loginNavigationController.navigationBar.titleTextAttributes = [.foregroundColor : UIColor.white]
        
        loginNavigationController.modalPresentationStyle = .formSheet
        
        self.getTopViewController().present(loginNavigationController, animated: true, completion: nil)
        
    }
    
//    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
//        return .popover
//    }
    
    @objc func displayAccountDetail(){
        let storyboard = UIStoryboard(name: "UserProfile", bundle: nil)
        
        guard let accountProfile = storyboard.instantiateInitialViewController() as? UINavigationController else {
            fatalError("Could not load user profile.")
        }
        
        accountProfile.modalPresentationStyle = .fullScreen
        
        guard let profileController = accountProfile.children.first as? AccountDetailViewController else {
            fatalError("Loading the wrong type of view")
        }
        
        profileController.flightListView = self
        
        self.getTopViewController().present(accountProfile, animated: true, completion: nil)
    }
    
    // MARK: - Flight Addition Permissions
    @IBOutlet weak var addButton: UIBarButtonItem!
    
    func updateButtonsState(){
        addButton.isEnabled = FlightAppManager.shared.loggedIn
        
        if FlightAppManager.shared.loggedIn {
            accountButton.title = "Account"
            accountButton.target = self
            accountButton.action = #selector(displayAccountDetail)
        } else {
            accountButton.title = "Sign In"
            accountButton.target = self
            accountButton.action = #selector(displayLogin)
        }
    }
    
    // MARK: - Flight List Observer
    func flightListRead() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
            self.refreshControl!.endRefreshing()
        }
    }
    
    func flightListCleared() {
        return
    }
    
    func flightListFilteringChanged() {
        self.tableView.reloadData()
    }
    
    func flightListFilteringCleared() {
        self.tableView.reloadData()
    }
    
    func flightListReadError(e: ListError) {
        DispatchQueue.main.async {
            let title:String
            let description:String
            var actions: [UIAlertAction] = []
            let alert:UIAlertController
            
            switch e {
            case let .readError(status):
                title = "Read Error"
                description = "Error reading the flights (status=\(status)). Please try again later."
                actions.append(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            case .jsonError:
                title = "Parse Error"
                description = "Error parsing the flight information. Please try again later."
                actions.append(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            case .noResponse:
                title = "Network Error"
                description = "Unable to reach the server. Please check your network connection and try again."
                actions.append(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                actions.append(UIAlertAction(title: "Try Again", style: .default, handler: {action in
                    
                    self.refreshControl!.beginRefreshing()
                    self.triggerReload()
                }))
            case .authError:
                FlightAppManager.shared.clearSession()
                self.refreshControl!.beginRefreshing()
                self.triggerReload()
                return
            default:
                title = "Other Error"
                description = "Some other error occurred. Please try again later."
                actions.append(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            }
            
            alert = UIAlertController(title: title, message: description, preferredStyle: .alert)
            for action in actions{
                alert.addAction(action)
            }
            
//            let topViewController = (UIApplication.shared.delegate as! AppDelegate).getTopViewController()
            self.getTopViewController().present(alert, animated: true, completion: self.refreshControl!.endRefreshing)
            
        }
    }
    
    func flightListReadMore(count: Int) {
        DispatchQueue.main.async {
            var offset = self.tableView.contentOffset
            for i in 0..<count{
                let row =  self.flights.count - count + i
                let index = IndexPath(row: row, section: 0)
                offset.y += self.tableView(self.tableView, heightForRowAt: index)
            }
            self.tableView.reloadData()
            self.tableView.setContentOffset(offset, animated: true)
        }
    }
    
    func flightListReadMoreError(e: ListError) {
        DispatchQueue.main.async {
            let title:String
            let description:String
            var actions: [UIAlertAction] = []
            let alert:UIAlertController
            
            switch e {
            case let .readError(status):
                title = "Read Error"
                description = "Error reading the flights (status=\(status)). Please try again later."
                actions.append(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            case .jsonError:
                title = "Parse Error"
                description = "Error parsing the flight information. Please try again later."
                actions.append(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            case .noResponse:
                title = "Network Error"
                description = "Unable to reach the server. Please check your network connection and try again."
                actions.append(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                actions.append(UIAlertAction(title: "Try Again", style: .default, handler: {action in
                    self.refreshControl!.beginRefreshing()
                    self.triggerLoadNext()
                }))
            case .authError:
                FlightAppManager.shared.clearSession()
                self.refreshControl!.beginRefreshing()
                self.triggerLoadNext()
                return
            default:
                title = "Other Error"
                description = "Some other error occurred. Please try again later."
                actions.append(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            }
            
            alert = UIAlertController(title: title, message: description, preferredStyle: .alert)
            for action in actions{
                alert.addAction(action)
            }
            
            self.getTopViewController().present(alert, animated: true, completion: nil)
            
        }
    }
    
    func flightListChanged() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    func flightListGotNewFlights(n: Int) {
        DispatchQueue.main.async {
            self.refreshControl!.endRefreshing()
//            self.tableView.reloadSections(.init(integer: 0), with: .automatic)
            
            var indexPaths: [IndexPath] = []
            
            for i in 0 ..< n {
                indexPaths.append(IndexPath(row: i, section: 0))
            }
            
            self.tableView.insertRows(at: indexPaths, with: .automatic)
            
        }
    }
    
    func flightListGotNewFlightsWithError(e: FlightList.GetNewFlightsErrors) {
        DispatchQueue.main.async {
            let title:String
            let description:String
            var actions: [UIAlertAction] = []
            let alert:UIAlertController
            
            let okAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            
            switch e {
            case .noResponse:
                title = "Network Error"
                description = "Unable to retrieve new flights due to a network error. Please check your network connection and try again."
                actions.append(okAction)
                actions.append(.init(title: "Try Again", style: .default, handler: {action in
                    self.refreshControl!.beginRefreshing()
                    self.triggerFetchNew()
                }))
            case .jsonError:
                title = "Parse Error"
                description = "Error parsing new flight information. Please close the app and try again. If the problem persists, please contact us."
                actions.append(okAction)
            case let .getError(status):
                title = "Error Retrieving Flights"
                description = "Error retrieving new flight information (status=\(status)). Please close the app and try again. If the problem persists, please contact us."
                actions.append(okAction)
            case .authError:
                FlightAppManager.shared.clearSession()
                self.refreshControl!.beginRefreshing()
                self.triggerFetchNew()
                return
            }
            
            alert = UIAlertController(title: title, message: description, preferredStyle: .alert)
            for action in actions{
                alert.addAction(action)
            }
            
            self.refreshControl!.endRefreshing()
            self.getTopViewController().present(alert, animated: true, completion: nil)
        }
    }
    
    func sessionVerified(session: Session?, valid: Bool, response: [String : String?]?) {
        DispatchQueue.main.async {
            if valid{
                FlightAppManager.shared.session = session
//                print("Session is valid")
            }
            self.updateButtonsState()
        }
    }
    
    func sessionVerifiedWithError(e: VerificationErrors) {
        DispatchQueue.main.async {
            let title:String
            let description:String
            var actions: [UIAlertAction] = []
            let alert:UIAlertController
            
            switch e {
            
            case .noResponse:
                title = "Network Error"
                description = "No response from the server in verifying your credentials. Please check your network connection and try again, or press cancel and manually sign back in."
                actions.append(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                actions.append(UIAlertAction(title: "Try Again", style: .default, handler: {action in
                    FlightAppManager.shared.sessionManager.initiateLoadAndVerifySessionFromKeychain()
                }))
            case .invalidCreds:
                title = "Invalid Credentials"
                description = "Stored Credentials are invalid."
                actions.append(.init(title: "OK", style: .cancel, handler: nil))
            case .jsonError:
                title = "Parse Error"
                description = "Error parsing credentials."
                actions.append(.init(title: "OK", style: .cancel, handler: nil))
            case .otherError(let status):
                title = "Login Error"
                description = "Error verifying (status=\(status)). Please try again later. If the problem persists, please contact us."
                actions.append(.init(title: "OK", style: .cancel, handler: nil))
            }
            
            alert = UIAlertController(title: title, message: description, preferredStyle: .alert)
            
            for action in actions {
                alert.addAction(action)
            }
            
            self.getTopViewController().present(alert, animated: true, completion: nil)
        }
    }
    
    // MARK: - LoginScreenObserver
    func loginScreenHasLoggedIn() {
        self.updateButtonsState()
   }
    
    // MARK: - Session Clear Observer
    func sessionCleared() {
        self.updateButtonsState()
    }
    
//    func showTestNotification(){
//        let title = "Flight Created"
//        let body = "A new Pheidole Dentata flight (id 25) has been recorded by lasiusaurus."
//        let alert = UIAlertController(title: title, message: body, preferredStyle: .actionSheet)
//
//        alert.addAction(.init(title: "OK", style: .cancel, handler: nil))
//
//        alert.addAction(.init(title: "View Record", style: .default, handler: nil))
//
//        self.present(alert, animated: true, completion: nil)
//    }
}
