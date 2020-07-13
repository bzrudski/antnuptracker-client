//
// HistoryTable.swift
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

class HistoryTable: UITableViewController, ChangeLogObserver {
    
    // MARK: - Local Variables
    var changelog:[Changelog]?
    var flightID:Int?
    
    // MARK: - Typealias
    typealias ChangelogErrors = ChangelogManager.ChangelogErrors
    
    // MARK: - View Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard flightID != nil else {
            let alert = UIAlertController(title: "No Flight", message: "No flight selected. Please select a flight and try again.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: {self.dismiss(animated: true, completion: nil)})
            return
        }
        
        ChangelogManager.shared.setObserver(self)
        
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(triggerFetch), for: .valueChanged)
        refreshControl?.beginRefreshing()
        triggerFetch()
        
//        self.changelog = getChangelog(for: id)
//        self.tableView.reloadSections(.init(integer: 0), with: .bottom)

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
        return self.changelog?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "historyCell", for: indexPath) as? HistoryTableViewCell else {
            fatalError("Wrong type of cell dequeued.")
        }

        // Configure the cell...
        if let changelogEntry = self.changelog?[indexPath.row]{
            cell.configure(for: changelogEntry)
        }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        tableView.estimatedRowHeight = 200
        
        return UITableView.automaticDimension
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
    
    // MARK: - Get Changelog
//    func getChangelog(for flightID:Int)->[Changelog]?{
//        var changelog:[Changelog]? = nil
//
//        do {
//            changelog = try FlightAppManager.shared.flights.getChangelogBy(id: flightID)
//        } catch {
//            let alert = generateAlerWithOkButton(title: "Error Loading Changelog", message: "Unable to load changelog because of an error:\n\(error.localizedDescription)")
//            self.present(alert, animated: true, completion: nil)
//        }
//
//        return changelog
//    }
    
    @objc func triggerFetch(){
        ChangelogManager.shared.getChangelogBy(id: flightID!)
    }
    
    func flightListGotChangelog(c: [Changelog]) {
        DispatchQueue.main.async {
            self.changelog = c
            self.refreshControl?.endRefreshing()
            self.tableView.reloadData()
        }
        
    }
    
    func flightListGotChangelogError(e: ChangelogErrors) {
        DispatchQueue.main.async {
            var title = ""
            var body = ""
            var actions: [UIAlertAction] = []
            let alert: UIAlertController
            
            let dismissClosure: (UIAlertAction)->Void = {
                action in
                self.dismiss(animated: true, completion: nil)
            }
            
            switch e {
            case .noResponse:
                title = "Network Error"
                body = "No reply from server. Please try again."
                actions.append(UIAlertAction(title: "Cancel", style: .cancel, handler: dismissClosure))
                actions.append(UIAlertAction(title: "Try Again", style: .default, handler: {action in
                    self.triggerFetch()
                }))
            case .notFound:
                title = "Not Found"
                body = "No history was found for this flight."
                actions.append(UIAlertAction(title: "OK", style: .default, handler: dismissClosure))
            case .invalidID:
                title = "Invalid Flight ID"
                body = "Invalid flight ID provided. Please try again later."
                actions.append(UIAlertAction(title: "OK", style: .default, handler: dismissClosure))
            case .jsonError:
                title = "Parse Error"
                body = "Error parsing the flight history. Please try again later."
                actions.append(UIAlertAction(title: "OK", style: .default, handler: dismissClosure))
            case .getChangelogError:
                title = "Server Error"
                body = "Error retrieving the flight history. Please try again later."
                actions.append(UIAlertAction(title: "OK", style: .default, handler: dismissClosure))
            case .authError:
                // IMPLEMENT
                break
            }
            
            alert = UIAlertController(title: title, message: body, preferredStyle: .alert)
            
            for action in actions{
                alert.addAction(action)
            }
            
            self.present(alert, animated: true, completion: nil)
        }
    }

}
