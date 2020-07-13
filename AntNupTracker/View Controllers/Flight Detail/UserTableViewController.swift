//
// UserTableViewController.swift
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

/// User profile screen.
class UserTableViewController: UITableViewController, UserObserver {

    // MARK: - Variables
    var username:String? = nil
    var user: User? = nil
    var dataSource:Table<UserTableModifiers>? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard username != nil else {
            let alert = UIAlertController(title: "No Username", message: "No username selected. Please select a user and try again.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: {self.dismiss(animated: true, completion: nil)})
            return
        }
        
        navigationItem.title = username!
        
        UserManager.shared.setObserver(observer: self)
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(triggerReload), for: .valueChanged)
        refreshControl?.beginRefreshing()
        self.triggerFetch()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return dataSource?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return dataSource?[section].count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let data = dataSource else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
            return cell
        }
        let row = data[indexPath.section][indexPath.row]
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
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if let source = dataSource{
            return source[section].header
        } else {
            return nil
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    // MARK: - Methods
    @objc func triggerFetch(){
        UserManager.shared.getInfoFor(username: username!)
    }
    
    @objc func triggerReload(){
        UserManager.shared.getInfoFor(username: username!, useCache: false)
    }
    
    func updateFor(user: User){
        self.user = user
        self.dataSource = .init(user: user)
    }
    
    func fetched(user: User) {
        DispatchQueue.main.async {
            self.updateFor(user: user)
            self.refreshControl?.endRefreshing()
            self.tableView.reloadData()
        }
    }
    
    func fetchedWithError(for username: String, error: UserManager.UserError) {
        DispatchQueue.main.async {
            var title = ""
            var body = ""
            var actions: [UIAlertAction] = []
            let alert: UIAlertController
            
            let dismissClosure: (UIAlertAction)->Void = {
                action in
                self.dismiss(animated: true, completion: nil)
            }
            
            let okAndDismiss = UIAlertAction(title: "OK", style: .cancel, handler: dismissClosure)
            
            switch error {
            case .jsonError:
                title = "Parse Error"
                body = "Error parsing the user information. Please try again later."
                actions.append(okAndDismiss)
            case .noResponse:
                title = "Network Error"
                body = "No response was received from the server. Please check your network connection and try again."
                actions.append(.init(title: "Cancel", style: .cancel, handler: dismissClosure))
                actions.append(.init(title: "Try Again", style: .default, handler: {_ in
                    self.refreshControl?.beginRefreshing()
                    self.triggerReload()
                }))
            case .notFound:
                title = "User Not Found"
                body = "A user with name \(username) was not found. Please try again later."
                actions.append(okAndDismiss)
            case let .otherError(status):
                title = "Other Error"
                body = "An error occurred when retrieving the user information (status=\(status)). Please try again later."
                actions.append(okAndDismiss)
            }
            
            alert = UIAlertController(title: title, message: body, preferredStyle: .alert)
            
            for action in actions{
                alert.addAction(action)
            }
            
            self.present(alert, animated: true, completion: nil)
        }
    }
}
