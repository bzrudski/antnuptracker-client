//
// FilteringChangeTableViewController.swift
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

class FilteringChangeTableViewController: UITableViewController, UISearchResultsUpdating, UISearchControllerDelegate, UISearchBarDelegate, SingleSelectSearchObserver {

    let headers:[String] = ["Genera to add", "Species to add", "All genera"]
    
    var searchController: UISearchController? = nil
    var generaResultsController = SingleSelectResultSearchTableViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        generaResultsController.setUniverse(allGenera)
        generaResultsController.setObserver(self)
        searchController = UISearchController(searchResultsController: generaResultsController)
        searchController!.searchResultsUpdater = self
        searchController!.searchBar.placeholder = "Search genera"
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

    // MARK: - Table view data source
//    var dataSource: [[String]] = []
//    var selectedGenera = Set<Genus>()
    var generaToAdd = [Genus] ()
//    var selectedSpecies = Set<Species>()
    var speciesToAdd = [Species]()
    var allGenera = TaxonomyManager.shared.getGenera()
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 3
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        switch section{
        case 0:
            return generaToAdd.count
        case 1:
            return speciesToAdd.count
        case 2:
            return allGenera.count
        default:
            return 0
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        

        // Configure the cell...
        
        if indexPath.section == 0{
            let cell =  tableView.dequeueReusableCell(withIdentifier: "selectedGenusCell", for: indexPath)
            cell.textLabel!.text = generaToAdd[indexPath.row].description + " (genus)"
            return cell
        } else if indexPath.section == 1 {
            let cell =  tableView.dequeueReusableCell(withIdentifier: "selectedSpeciesCell", for: indexPath)
            cell.textLabel!.text = speciesToAdd[indexPath.row].description
            return cell
        } else {
            let cell  = tableView.dequeueReusableCell(withIdentifier: "genusCell", for: indexPath)
            cell.textLabel!.text = allGenera[indexPath.row]
            return cell
        }
    }

    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return indexPath.section < 2
    }

    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            let section = indexPath.section
            let row = indexPath.row
            
            if section == 0 {
                generaToAdd.remove(at: row)
            } else if section == 1 {
                speciesToAdd.remove(at: row)
            } else {
                return
            }
            
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
//        else if editingStyle == .insert {
//            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
//        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return headers[section]
    }

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
        if segue.identifier == "speciesSelection"{
            guard let selectedCell = sender as? UITableViewCell else {
                return
            }
            guard let speciesSelection = segue.destination as? FilteringSpeciesSelectionTableViewController else {
                return
            }
            
            let selectedGenus = try! Genus.get(selectedCell.textLabel!.text!)
            
            speciesSelection.genus = selectedGenus
            
            speciesSelection.selectedSpecies.append(contentsOf: speciesToAdd.filter({$0.genus == selectedGenus}))
            
            speciesSelection.genusSelected = generaToAdd.contains(where: {$0 == selectedGenus})
        }
    }
    
    @IBAction func unwindToFilteringAddPane(_ segue: UIStoryboardSegue){
        guard let speciesSelectionView = segue.source as? FilteringSpeciesSelectionTableViewController else {
            return
        }
        
        let genus = speciesSelectionView.genus!
        
        let genusPreviouslySelected = generaToAdd.contains(genus)
        
        let genusCurrentlySelected = speciesSelectionView.genusSelected
        
        switch (genusPreviouslySelected, genusCurrentlySelected){
        case (false, true):
            generaToAdd.append(genus)
        case (false, false), (true, true):
            break
        case (true, false):
            generaToAdd.removeAll(where: {$0 == genus})
        }
        
        let speciesAdded = speciesSelectionView.selectedSpecies
        
        speciesToAdd.removeAll(where: {$0.genus == genus})
        speciesToAdd.append(contentsOf: speciesAdded)
        
        tableView.reloadSections(.init(arrayLiteral: 0, 1), with: .automatic)
    }
    
//    @IBAction func save(_ sender: UIBarButtonItem){
//        FlightAppManager.shared.flights.addFilteringGenera(generaToAdd)
//        FlightAppManager.shared.flights.addFilteringSpecies(speciesToAdd)
//    }
    
    @IBAction func cancel(_ sender: UIBarButtonItem){
        self.navigationController!.popViewController(animated: true)
    }
    
    // MARK: - Searching
        func updateSearchResults(for searchController: UISearchController) {
            let input = searchController.searchBar.text?.lowercased().trimmingCharacters(in: .whitespaces)
            
            guard let resultController = searchController.searchResultsController as? SingleSelectResultSearchTableViewController else {
                fatalError("Wrong type of view controller")
            }
            resultController.updateResults(for: input)
//            resultController.tableView.reloadData()
        }
        
        func resultSelected(result: String) {
            searchController?.searchBar.resignFirstResponder()
            let index = allGenera.firstIndex(of: result)!
            generaResultsController.dismiss(animated: true, completion: nil)
            let indexPath = IndexPath(row: index, section: 2)
            tableView.selectRow(at: indexPath, animated: true, scrollPosition: .middle)
        }


}
