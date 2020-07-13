//
// MySpeciesGeneraTableViewController.swift
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

class MySpeciesGeneraTableViewController: UITableViewController, UISearchResultsUpdating, UISearchControllerDelegate, UISearchBarDelegate, SingleSelectSearchObserver {
    
    var toAdd : Set<Species> = Set()
    var listToAdd : [Species] {
        get{
            return Array(toAdd).sorted(by: {
                s1, s2 in
                if (s1.genus != s2.genus)
                {
                    return s1.genus.name < s2.genus.name
                }
                return s1.name < s2.name
            })
        }
    }
    let allGenera : [Genus] = {
        var genera: [Genus] = []
        
        for genus in TaxonomyManager.shared.getGenera()
        {
            try! genera.append(Genus.get(genus))
        }
        
        return genera
    }()
    
    let headers:[String] = ["Species to add","All genera"]
    
    var searchController: UISearchController? = nil
    var generaResultsController = SingleSelectResultSearchTableViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        generaResultsController.setUniverse(TaxonomyManager.shared.getGenera())
        generaResultsController.setObserver(self)
        searchController = UISearchController(searchResultsController: generaResultsController)
        searchController!.searchResultsUpdater = self
        searchController!.searchBar.placeholder = "Search genera"
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
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (section == 0)
        {
            return toAdd.count
        }
        return allGenera.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell: UITableViewCell
        
        if (indexPath.section == 0)
        {
            cell = tableView.dequeueReusableCell(withIdentifier: "speciesCell", for: indexPath) as! MySpeciesTableViewCell
            (cell as! MySpeciesTableViewCell).setSpecies(species: listToAdd[indexPath.row])
        }
        else
        {
            cell = tableView.dequeueReusableCell(withIdentifier: "genusCell", for: indexPath) as! MySpeciesGenusTableViewCell
            (cell as! MySpeciesGenusTableViewCell).setGenus(genus: allGenera[indexPath.row])
        }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return headers[section]
    }

    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return indexPath.section == 0
    }
    

    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            let toRemove = (tableView.cellForRow(at: indexPath) as! MySpeciesTableViewCell).getSpecies()!
            toAdd.remove(toRemove)
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
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
        if let speciesList = segue.destination as? MySpeciesSpeciesTableViewController
        {
            let selectedGenus: Genus
            
            if let sendingCell = sender as? MySpeciesGenusTableViewCell {
            
                selectedGenus = sendingCell.getGenus()!
            } else {
                return
            }
            
            speciesList.genus = selectedGenus
            let matching = toAdd.filter({
                species in
                return species.genus == selectedGenus
            })
            speciesList.selectedSpecies = Set(matching)
            speciesList.originalSpecies = Array(matching)
//            toAdd.removeAll(where: matching.contains)
        }
    }
    
    @IBAction func unwindToGenusList(_ segue:UIStoryboardSegue) {
        if let speciesTable = segue.source as? MySpeciesSpeciesTableViewController
        {
//            toAdd.append(contentsOf: speciesTable.selectedSpecies)
            toAdd.formUnion(speciesTable.selectedSpecies)
//            toAdd.removeAll(where: speciesTable.unSelectedSpecies.contains)
            tableView.reloadSections(.init(integer: 0), with: .fade)
        }
    }
    
    @IBAction func cancel(_ sender: UIBarButtonItem)
    {
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
        let index = allGenera.firstIndex(where: {genus in
            genus.name == result
        })!
//
//        let genusCell = self.tableView.cellForRow(at: T##IndexPath)
        generaResultsController.dismiss(animated: true, completion: nil)
        let indexPath = IndexPath(row:index, section: 1)
        tableView.selectRow(at: indexPath, animated: true, scrollPosition: .middle)
//        tableView.scrollToRow(at: indexPath, at: .middle, animated: true)
//        let cell = tableView.cellForRow(at: indexPath)
//        cell?.setSelected(true, animated: true)
//        cell?.setHighlighted(true, animated: true)
//        tableView.reloadRows(at: [indexPath], with: .none)
//        let segue = UIStoryboardSegue(identifier: "loadSpecies", source: self, destination: MySpeciesSpeciesTableViewController())
//        self.prepare(for: segue, sender: cell)
//        self.performSegue(withIdentifier: "loadSpecies", sender: cell)
//                self.performSegue(withIdentifier: "loadSpecies", sender: cell)
//        let genus = try! Genus.get(result)
    }

}
