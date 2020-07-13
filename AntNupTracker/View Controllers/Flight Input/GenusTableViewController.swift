//
// GenusTableViewController.swift
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

class GenusTableViewController: UITableViewController, UISearchResultsUpdating, UISearchControllerDelegate, UISearchBarDelegate, SingleSelectSearchObserver {
    
    // MARK: - Define outlets
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var doneButton: UIBarButtonItem!
    
    // MARK: - Details for model
    var genera:[String] = TaxonomyManager.shared.getGenera()
    var genus:String? = nil
    var searchController:UISearchController? = nil
    var generaResultsController:SingleSelectResultSearchTableViewController = SingleSelectResultSearchTableViewController()
    
    // MARK: - UI Actions
    @IBAction func cancel(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    // MARK: - Search methods
    func updateSearchResults(for searchController: UISearchController) {
        let input = searchController.searchBar.text?.lowercased().trimmingCharacters(in: .whitespaces)
        
        guard let resultController = searchController.searchResultsController as? SingleSelectResultSearchTableViewController else {
            fatalError("Wrong type of view controller")
        }
        
        resultController.updateResults(for: input)
//
//        resultController.updateGenera(genera: genera
//            .filter({
//                $0.lowercased().contains(input)
//            })
//            .sorted(by: {FlightAppManager.sortResults(string1: $0, string2: $1, input: input)})
//        )
//
//        print("Going through genera containing \(input)")
//
//        for genus in resultController.genera{
//            print(genus)
//        }
//        resultController.tableView.reloadData()
    }
    
    func resultSelected(result: String) {
        searchController?.searchBar.resignFirstResponder()

//        selectedGenus = genera[indexPath.row]
//        print("Selected genus: \(selectedGenus!)")
        guard let index = genera.firstIndex(of: result) else {
            fatalError("Invalid genus")
        }
        
//        print("Going to index: \(index)")

        self.dismiss(animated: true, completion: nil)
        self.genus = result
        tableView.selectRow(at: IndexPath(row: index, section: 0), animated: true, scrollPosition: .middle)

//        print("Selected cell")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //loadGenera()
        genera = TaxonomyManager.shared.getGenera()
        generaResultsController.setUniverse(genera)
        
        tableView.delegate = self
        //generaResultsController = GeneraResultsTableViewController()
        generaResultsController.tableView.delegate = generaResultsController
        generaResultsController.setObserver(self)
        
        //displayingGenera = FlightAppManager.genera
        searchController = UISearchController(searchResultsController: generaResultsController)
        searchController!.searchResultsUpdater = self
        searchController!.searchBar.autocapitalizationType = .none
        searchController?.searchBar.barStyle = .black
        
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        
        searchController!.delegate = self
//        searchController!.dimsBackgroundDuringPresentation = false
        searchController!.searchBar.delegate = self
        
        definesPresentationContext = true
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the numlber of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return genera.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "genusCell", for: indexPath)

        let cellGenus = genera[indexPath.row]
        
        cell.textLabel?.text = cellGenus
        
        if (cellGenus == genus)
        {
            cell.setHighlighted(true, animated: true)
            cell.accessoryType = .checkmark
        }
        else
        {
            cell.setHighlighted(false, animated: false)
            cell.accessoryType = .none
        }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) else {
            fatalError("Something wrong with index path")
        }
        
        let previous = genus
        
        genus = cell.textLabel?.text
        cell.accessoryType = .checkmark
        
        guard previous != nil else {
            return
        }
        
        if let previousCell = self.tableView.visibleCells.first(where: {genusCell in
            return genusCell.textLabel?.text == previous!
        }) {
            previousCell.accessoryType = .none
        }
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
            cell.accessoryType = .none
        }
        
    }
    
//    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
//        super.tableView(tableView, willDisplay: cell, forRowAt: indexPath)
//        guard let selectedGenus = genus else {
//            cell.setHighlighted(false, animated: false)
//            cell.accessoryType = .none
//            return
//        }
//        if (cell.textLabel?.text == selectedGenus)
//        {
//            cell.setHighlighted(true, animated: true)
//            cell.accessoryType = .checkmark
//        }
//    }

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
//
//    override func unwind(for unwindSegue: UIStoryboardSegue, towards subsequentVC: UIViewController) {
//
//    }
//

//    func loadGenera(){
//        do {
//            FlightAppManager.genera = try FlightAppManager.getGenera()
//        } catch {
//            let alert = UIAlertController(title: "Genera Error", message: "Error loading the genera from the server. Please try again.", preferredStyle: .alert)
//            let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: {action in
//                self.navigationController?.popViewController(animated: true)
//            })
//
//            let tryAgain = UIAlertAction(title: "Try again", style: .default, handler: {action in
//                alert.dismiss(animated: true, completion: self.loadGenera)
//            })
//
//            alert.addAction(cancel)
//            alert.addAction(tryAgain)
//
//            self.present(alert, animated: true, completion: nil)
//        }
//    }
    
}
