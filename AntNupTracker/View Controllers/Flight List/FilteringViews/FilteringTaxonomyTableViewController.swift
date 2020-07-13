//
// FilteringTaxonomyTableViewController.swift
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

class FilteringTaxonomyTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

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
            return FilteringManager.shared.filteringGenusCount
        } else if section == 1 {
            return FilteringManager.shared.filteringSpeciesCount
        }
        
        return 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "taxonCell", for: indexPath)

        if indexPath.section == 0 {
            cell.textLabel!.text = FilteringManager.shared.getFilteredGenus(at: indexPath.row).name
        } else if indexPath.section == 1 {
            cell.textLabel!.text = FilteringManager.shared.getFilteredSpecies(at: indexPath.row).description
        }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Filtering Genera"
        } else if section == 1 {
            return "Filtering Species"
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

    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            if indexPath.section == 0 {
                FilteringManager.shared.removeFilteringGenus(atIndex: indexPath.row)
            } else if indexPath.section == 1 {
                FilteringManager.shared.removeFilteringSpecies(atIndex: indexPath.row)
            } else {
                return
            }
            
            tableView.deleteRows(at: [indexPath], with: .fade)
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
    }
    
    @IBAction func done(_ sender: UIBarButtonItem){
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func unwindToFiltering(_ segue: UIStoryboardSegue) {
        guard let changesManager = segue.source as? FilteringChangeTableViewController else {
            return
        }
        
        let newGenera = changesManager.generaToAdd
        let newSpecies = changesManager.speciesToAdd
        
//        if !(newGenera.isEmpty && newSpecies.isEmpty){
//            FlightAppManager.shared.flights.refilter()
//        }
        
        FilteringManager.shared.addFiltering(genera: newGenera, species: newSpecies)
        tableView.reloadSections(.init(arrayLiteral: 0, 1), with: .automatic)
    }
    
    // MARK: - Clear Filters
    @IBAction func clearFilters(_ sender: UIBarButtonItem){
        FilteringManager.shared.clearFiltering()
        tableView.reloadSections(.init(arrayLiteral: 0, 1), with: .automatic)
    }

}
