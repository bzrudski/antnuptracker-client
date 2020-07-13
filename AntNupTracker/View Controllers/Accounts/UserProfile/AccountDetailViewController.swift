//
// AccountDetailViewController.swift
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

class AccountDetailViewController: UITableViewController, LogoutObserver {
    
    
    typealias LogoutErrors = SessionManager.LogoutErrors

    var dataSource:Table<SessionTableModifiers> = Table(session: FlightAppManager.shared.session!)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        FlightAppManager.shared.sessionManager.setLogoutObserver(observer: self)
//        self.loadUserInformation()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        FlightAppManager.shared.sessionManager.unsetLogoutObserver()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return dataSource.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
//        if section == 0
//        {
//                return 3
//        }
//        return 2
        return dataSource[section].count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if dataSource[indexPath.section][indexPath.row].modifier == .some(.logout){
                self.triggerLogout()
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let row = dataSource[indexPath.section][indexPath.row]
        
        let header = row.header
        let modifier = row.modifier
        let content = row.content
        
        switch modifier{
        case nil:
            let cell = tableView.dequeueReusableCell(withIdentifier: "simpleCell", for: indexPath)
            cell.textLabel?.text = header
            cell.detailTextLabel?.text = content as? String
            return cell
        case .description:
            let cell = tableView.dequeueReusableCell(withIdentifier: "detailCell", for: indexPath)
            cell.textLabel?.text = header
            cell.detailTextLabel?.text = content as? String
            return cell
        case .role:
            let cell = tableView.dequeueReusableCell(withIdentifier: "roleCell", for: indexPath) as! UserTableViewCell
            let role = content as! Role
            cell.setUp(header: header, username: role.description, role: role)
            return cell
        case .taxonomy:
            let cell = tableView.dequeueReusableCell(withIdentifier: "mySpeciesCell", for: indexPath)
            return cell
        case .logout:
            let cell = tableView.dequeueReusableCell(withIdentifier: "logoutCell", for: indexPath)
            return cell
        case .url:
            let cell = tableView.dequeueReusableCell(withIdentifier: "urlCell", for: indexPath) as! UrlTableViewCell
            cell.textLabel?.text = header
            
            if let url = content as? URL {
                cell.url = url
            }
            
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return dataSource[section].header
    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return dataSource[section].footer
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    // MARK: - UI Outlets
    @IBOutlet weak var usernameCell: UITableViewCell!
    @IBOutlet weak var roleCell: UITableViewCell!
    @IBOutlet weak var logoutCell: UITableViewCell!
    
    // MARK: - UIActions
    @IBAction func dismiss(_ sender: Any) {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Local variables
    var flightListView:FlightListTableViewController? = nil
    
    // MARK: - Methods
    func loadUserInformation(){
        self.usernameCell.detailTextLabel?.text = FlightAppManager.shared.session?.username
        self.roleCell.detailTextLabel?.text = FlightAppManager.shared.session?.role.description
    }
    
//    func logout(){
//        do{
//            try FlightAppManager.shared.logout()
//        } catch WebInt.networkError.noResponse{
//            let alert = generateAlerWithOkButton(title: "Network Error", message: "Unable to reach the server. Please try again.")
//            let tryAgain = UIAlertAction(title: "Try Again", style: .default, handler: {action  in
//                alert.dismiss(animated: true, completion: nil)
//                self.logout()
//            })
//
//            alert.addAction(tryAgain)
//
//            self.present(alert, animated: true, completion: nil)
//        } catch {
//            fatalError(error.localizedDescription)
//        }
//
//        if (flightListView != nil){
//            flightListView!.updateAddButtonState()
//        }
//
//        self.dismiss(logoutCell!)
//    }
    
    func triggerLogout() {
        FlightAppManager.shared.sessionManager.logout(s: FlightAppManager.shared.session!)
    }
    
    func loggedOut() {
        DispatchQueue.main.async {
            FlightAppManager.shared.session = nil
            FlightAppManager.shared.sessionManager.clearCredentials()
            self.navigationController?.dismiss(animated: true, completion: self.flightListView?.updateButtonsState)
        }
    }
    
    func loggedOutWithError(e: Error) {
        DispatchQueue.main.async {
            let title: String
            let body: String
            let alert: UIAlertController
            var actions: [UIAlertAction] = []
            
            let dismissAndClearClosure:(UIAlertAction) -> Void = {
                action in
                FlightAppManager.shared.session = nil
                self.navigationController?.dismiss(animated: true, completion: self.flightListView?.updateButtonsState)
            }
            
//            let dismissWithoutClearClosure:(UIAlertAction) -> Void = {
//                action in
//                self.navigationController?.dismiss(animated: true, completion: nil)
//            }
            
            switch e {
            case LogoutErrors.authError:
                title = "Authentication Error"
                body = "Error authenticating your logout request. Assuming your session is expired."
                actions.append(UIAlertAction(title: "OK", style: .default, handler: dismissAndClearClosure))
            case LogoutErrors.noResponse:
                title = "Network Error"
                body = "Error communicating with server. Please check your network connection and try again."
                actions.append(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                actions.append(UIAlertAction(title: "Try Again", style: .default, handler: {action in
                    self.triggerLogout()
                }))
            case let LogoutErrors.logoutError(status: status):
                title = "Logout Error"
                body = "Some other logout error occurred (status=\(status)). Please try again later."
                actions.append(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            default:
                title = "Other Error"
                body = "An unknown error occurred. Please try again later."
                actions.append(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            }
            
            alert = UIAlertController(title: title, message: body, preferredStyle: .alert)
            
            for action in actions {
                alert.addAction(action)
            }
            
            self.present(alert, animated: true, completion: nil)
        }
    }

}
