//
// FilteringSpeciesSelectionTableViewController.swift
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

class FilteringSpeciesSelectionTableViewController: UITableViewController, UISearchResultsUpdating, UISearchControllerDelegate, UISearchBarDelegate, SingleSelectSearchObserver {
    
    var genus: Genus? = nil
    var allSpecies: [String] = []
    var selectedSpecies: [Species] = []
    var genusSelected = false
    
    let headers = ["Genus", "Species"]

    var searchController: UISearchController? = nil
    var speciesResultsController = SingleSelectResultSearchTableViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        guard genus != nil else {
            self.dismiss(animated: true, completion: nil)
            return
        }
        
        allSpecies = try! TaxonomyManager.shared.getSpecies(for: genus!.name)
        allSpecies.removeAll(where: {FilteringManager.shared.speciesNameInFiltering(genus: genus!.name, species: $0)})
        
        speciesResultsController.setUniverse(allSpecies)
        speciesResultsController.setObserver(self)
        searchController = UISearchController(searchResultsController: speciesResultsController)
        searchController!.searchResultsUpdater = self
        searchController!.searchBar.placeholder = "Search \(genus!.name)"
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

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if section == 0 {
            return FilteringManager.shared.genusNameInFiltering(genus!.name) ? 0 : 1
        } else if section == 1 {
            return allSpecies.count
        } else {
            return 0
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let section = indexPath.section
        let row = indexPath.row
        
        if section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "wholeGenusCell", for: indexPath) as! FilteringGenusTableViewCell

            cell.setGenus(genus: self.genus!)
            
            if genusSelected || FilteringManager.shared.genusNameInFiltering(genus!.name){
                cell.setSelected(true, animated: true)
//                cell.accessoryType = .checkmark
                cell.setHighlighted(true, animated: true)
            }

            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "speciesCell", for: indexPath) as! FilteringSpeciesTableViewCell

            let speciesName = allSpecies[row]
            
            cell.setTaxonomy(genus: self.genus!, speciesName: speciesName)
            
            if selectedSpecies.contains(where: {$0.name == speciesName && $0.genus == self.genus!}) {
                cell.setSelected(true, animated: true)
                cell.accessoryType = .checkmark
                cell.setHighlighted(true, animated: true)
//                print("Already in there")
            } else {
                cell.accessoryType = .none
            }

            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let section = indexPath.section
        let row = indexPath.row
        
        if section == 1 {
            let speciesName = allSpecies[row]
            
            guard let speciesCell = cell as? FilteringSpeciesTableViewCell  else {
                return
            }
            
            if selectedSpecies.contains(where: {$0.name == speciesName && $0.genus == self.genus!}) {
                speciesCell.setSelected(true, animated: true)
                speciesCell.accessoryType = .checkmark
                speciesCell.setHighlighted(true, animated: true)
//                print("Already in there")
            } else {
                speciesCell.accessoryType = .none
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return headers[section]
    }
    
    // MARK: - Selection
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? FilteringSpeciesTableViewCell {
            cell.accessoryType = .checkmark
            selectedSpecies.append(cell.getSpecies())
        } else if let cell = tableView.cellForRow(at: indexPath) as? FilteringGenusTableViewCell {
            cell.accessoryType = .checkmark
            genusSelected = true
        }
    }
        
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? FilteringSpeciesTableViewCell {
            cell.accessoryType = .none
            selectedSpecies.removeAll(where: {$0 == cell.getSpecies()})
        } else if let cell = tableView.cellForRow(at: indexPath) as? FilteringGenusTableViewCell {
            cell.accessoryType = .none
            genusSelected = false
        }
//        print(selectedSpecies)
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
//        resultController.tableView.reloadData()
    }
        
    func resultSelected(result: String) {
        searchController?.searchBar.resignFirstResponder()
        let index = allSpecies.firstIndex(of: result)!
        speciesResultsController.dismiss(animated: true, completion: nil)
       
        let indexPath = IndexPath(row: index, section: 1)
        tableView.selectRow(at: indexPath, animated: true, scrollPosition: .middle)
        let speciesName = allSpecies[index]
        let species = try! Species.get(pGenus: genus!, pSpecies: speciesName)
        selectedSpecies.append(species)
    }

}
