//
// SpeciesTableViewController.swift
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

class SpeciesTableViewController: UITableViewController, UISearchResultsUpdating, UISearchControllerDelegate, UISearchBarDelegate, SingleSelectSearchObserver {
    
    // MARK: - UI Outlets
    @IBOutlet weak var doneButton: UIBarButtonItem!
    
    // MARK: - UI Functions
    @IBAction func cancel(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Local variables
    var genus:String? = nil
    var selectedSpecies: String? = nil
    var species:[String] = []
    var searchController:UISearchController? = nil
    var speciesResultsController = SingleSelectResultSearchTableViewController()
     

    override func viewDidLoad() {
        super.viewDidLoad()

        loadSpecies()
        
        speciesResultsController.setUniverse(species)
        speciesResultsController.tableView.delegate = speciesResultsController
        speciesResultsController.setObserver(self)
        
        searchController = UISearchController(searchResultsController: speciesResultsController)
        searchController!.searchResultsUpdater = self
        searchController!.searchBar.autocapitalizationType = .none
        searchController?.searchBar.barStyle = .black
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        
        searchController!.delegate = self
        searchController!.searchBar.delegate = self
        
        definesPresentationContext = true
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    // MARK: - Species Loading
    
/** Load the species for the genus specified in the `genus` field.
    If the `genus` field is `nil`, an alert appears prompting the user to
    select a genus before continuing. If for some reason the specified genus
    does not exist, a different alert appears.
    
    - This method **does not** return anything. Instead, it populates the `species` list field
    with the appropriate species names.
    - Perhaps in future, the list will be changed to actually consist of `Species` objects.
    */
    func loadSpecies(){
        if (genus == nil) {
            let alert = UIAlertController(title: "No Genus Selected", message: "Please select a genus before continuing.", preferredStyle: .alert)
            let cancel = UIAlertAction(title: "OK", style: .cancel, handler: {action in
                self.navigationController?.popViewController(animated: true)
            })
            alert.addAction(cancel)
            self.present(alert, animated: true, completion: nil)
        }
        else{
            do {
                self.species = try TaxonomyManager.shared.getSpecies(for: genus!)
            } catch {
                let alert = UIAlertController(title: "Invalid Genus", message: "Invalid genus selected. Go back and select a correct genus.", preferredStyle: .alert)
                let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: {action in
                    self.navigationController?.popViewController(animated: true)
                })
                
                alert.addAction(cancel)
                
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.species.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "speciesCell", for: indexPath)

        cell.textLabel?.text = species[indexPath.row]
        
        if (selectedSpecies != nil) && (selectedSpecies == cell.textLabel?.text)
        {
            cell.setHighlighted(true, animated: true)
            cell.accessoryType = .checkmark
//            return cell
        }
//        if (cell.textLabel?.text == species)
//        {
//            cell.setHighlighted(true, animated: true)
//            cell.accessoryType = .checkmark
//        }
        else {
            cell.setHighlighted(false, animated: false)
            cell.accessoryType = .none
        }

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) else {
            fatalError("Error with cell index path")
        }
        
        let previous = selectedSpecies
        
        selectedSpecies = cell.textLabel?.text
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
    
    // MARK: - Search Methods
    
    func updateSearchResults(for searchController: UISearchController) {
        let input = searchController.searchBar.text?.lowercased().trimmingCharacters(in: .whitespaces)
        
        guard let resultController = searchController.searchResultsController as? SingleSelectResultSearchTableViewController else {
            fatalError("Wrong type of view controller")
        }
        
        resultController.updateResults(for: input)
//        resultController.tableView.reloadData()
    }
    
    func resultSelected(result: String) {
        searchController?.searchBar.resignFirstResponder()

        //        selectedGenus = genera[indexPath.row]
        //        print("Selected genus: \(selectedGenus!)")
        guard let index = species.firstIndex(of: result) else {
            fatalError("Invalid genus")
        }
        
//        print("Going to index: \(index)")

        self.dismiss(animated: true, completion: nil)
        self.selectedSpecies = result
        tableView.selectRow(at: IndexPath(row: index, section: 0), animated: true, scrollPosition: .middle)

//        print("Selected cell")
    }
    
//    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
//        super.tableView(tableView, willDisplay: cell, forRowAt: indexPath)
//        guard let species = selectedSpecies else {
//            return
//        }
//        if (cell.textLabel?.text == species)
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

}
