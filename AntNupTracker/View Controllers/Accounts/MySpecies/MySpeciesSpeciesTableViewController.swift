//
// MySpeciesSpeciesTableViewController.swift
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

class MySpeciesSpeciesTableViewController: UITableViewController, UISearchResultsUpdating, UISearchControllerDelegate, UISearchBarDelegate, SingleSelectSearchObserver {

    var genus: Genus? = nil
    var speciesList : [Species] = []
    var originalSpecies : [Species] = []
    var selectedSpecies : Set<Species> = Set()
    var unSelectedSpecies : [Species] = []
    var searchController: UISearchController? = nil
    var speciesResultsController = SingleSelectResultSearchTableViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if (genus == nil)
        {
            fatalError("Impossible! No genus selected!")
        }
        

//        print(genus!)
//        print(selectedSpecies)
        
        speciesList = {
            var speciesForGenus: [Species] = []
            for species in try! TaxonomyManager.shared.getSpecies(for: genus!.name)
            {
                let newSpecies = try! Species.get(pGenus: genus!, pSpecies: species)
                speciesForGenus.append(newSpecies)
            }
            
            return speciesForGenus
        }()
        
        speciesResultsController.setUniverse(try! TaxonomyManager.shared.getSpecies(for: genus!.name))
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
        
        tableView.reloadData()
        
//        print("**** There are \(speciesList.count) cells ****\n")
//        for i in 0..<tableView.numberOfSections
//        {
//            print("There are \(tableView.numberOfRows(inSection: i)) in section \(i).\n")
//        }
        
//        for species in originalSpecies
//        {
//            let index = speciesList.firstIndex(of: species)!
//            let indexPath = IndexPath(row: index, section: 0)
//            guard let cell = tableView.cellForRow(at: indexPath) as? MySpeciesTableViewCell
//                else {
//                    print("Cell was really of type \( String(describing: tableView.cellForRow(at: indexPath)))")
//                    return
//            }
//            cell.setSelected(true, animated: true)
//            cell.accessoryType = .checkmark
//        }
        
//        for i in 0..<speciesList.count
//        {
//            let indexPath = IndexPath(row: i, section: 0)
//            guard let cell = tableView.cellForRow(at: indexPath) as? MySpeciesTableViewCell
//                else {
//                    print("Cell was really of type \( String(describing: tableView.cellForRow(at: indexPath)))")
//                    return
//            }
//            if (originalSpecies.contains(cell.getSpecies()!))
//            {
//                cell.setSelected(true, animated: true)
//                cell.accessoryType = .checkmark
//            }
//        }
        
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
        return speciesList.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "speciesListCell", for: indexPath) as! MySpeciesTableViewCell
        
        cell.accessoryType = .none

        let cellSpecies = speciesList[indexPath.row]
        cell.setSpecies(species: cellSpecies)

        if (selectedSpecies.contains(cellSpecies) || originalSpecies.contains(cellSpecies))
        {
            cell.setSelected(true, animated: true)
            cell.accessoryType = .checkmark
            cell.setHighlighted(true, animated: true)
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! MySpeciesTableViewCell
        cell.accessoryType = .checkmark
        selectedSpecies.insert(cell.getSpecies()!)
//        append(cell.getSpecies()!)
//        print(selectedSpecies)
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! MySpeciesTableViewCell
        cell.accessoryType = .none
        selectedSpecies.remove(cell.getSpecies()!)
//        print(selectedSpecies)
    }
    
    
//    func unwindToGenusList(_ segue:UIStoryboardSegue) {
//        if let genusTable = parent as? MySpeciesGeneraTableViewController
//        {
//            genusTable.toAdd.append(contentsOf: selectedSpecies)
//            genusTable.toAdd.removeAll(where: unSelectedSpecies.contains)
//            genusTable.tableView.reloadSections(.init(integer: 0), with: .fade)
//        }
//    }
    
    @IBAction func cancel(_ sender: UIBarButtonItem)
    {
//        if let genusList = parent as? MySpeciesGeneraTableViewController
//        {
//            genusList.toAdd.append(contentsOf: originalSpecies)
//        }
        navigationController!.popViewController(animated: true)
    }
    
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
        let index = speciesList.firstIndex(where: {species in
            species.name == result
        })!
        speciesResultsController.dismiss(animated: true, completion: nil)
       
        let indexPath = IndexPath(row:index, section: 0)
        tableView.selectRow(at: indexPath, animated: true, scrollPosition: .middle)
//        let cell = tableView.cellForRow(at: indexPath)
//        cell?.setSelected(true, animated: true)
//        cell?.setHighlighted(true, animated: true)
//        cell?.accessoryType = .checkmark
//        tableView.reloadRows(at: [indexPath], with: .none)
        self.selectedSpecies.insert(speciesList[index])
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
