//
// SingleSelectResultSearchTableViewController.swift
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

class SingleSelectResultSearchTableViewController: UITableViewController, SearchResultPresenter {

    var universe: [String] = []
    var results:[String] = []
    var selectedResult:String? = nil
    private var observer: SingleSelectSearchObserver? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.results = self.universe
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "resultCell")
//        self.tableView.delegate = self
//        self.tableView.dataSource = self
//        self.tableView.reloadData()
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
        return results.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "resultCell", for: indexPath)
//        print("Preparing cell")
        cell.textLabel?.text = results[indexPath.row]

        return cell
    }

    //override func tabl
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        print("Selected")
        selectedResult = results[indexPath.row]
        self.observer?.resultSelected(result: selectedResult!)
        
        //var segue = UIStoryboardSegue(identifier: "dismiss", source: self, destination: parent)
        //performSegue(withIdentifier: "dismiss", sender: nil)
        //parent.searchController?.isActive = false
        
    }
    
    /**
     Set the `SingleSelectSearchObserver`.
    - parameter o: the observer
     */
    func setObserver(_ o: SingleSelectSearchObserver){
        self.observer = o
    }
    
    /**
     Unset the observer.
     */
    func unsetObserver(){
        self.observer = nil
    }
    
    func setUniverse(_ u:[String])
    {
        self.universe = u
        self.results = self.universe
//        self.tableView.reloadData()
    }
    
    func updateResults(for searchKey: String?){
        guard let input = searchKey?.lowercased().trimmingCharacters(in: .whitespaces) else {
            self.results = self.universe
            return
        }
        
        self.results = self.universe
            .filter({
                $0.lowercased().contains(input)
            })
            .sorted(by: {self.sortResults(string1: $0, string2: $1, input: input)})
        
//        print("There are now \(results.count) cells.")
        
        self.tableView.reloadSections(.init(integer: 0), with: .automatic)
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

}
