//
// MySpeciesListViewController.swift
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

class MySpeciesListViewController: UITableViewController, SpeciesListObserver {
    
    let species = FlightAppManager.shared.session!.species
    
    private var speciesToDelete: [Species] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        species.setObserver(listObserver: self)
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        //refreshList()
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(readSpecies), for: .valueChanged)
        refreshControl?.beginRefreshing()
        readSpecies()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return species.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "speciesCell", for: indexPath) as! MySpeciesTableViewCell

        cell.setSpecies(species: species[indexPath.row])
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let lastIndex = species.count - 1
        
        if (lastIndex >= species.totalCount - 1)
        {
            return
        }
        
        if (indexPath.row == lastIndex)
        {
            readNext()
        }
    }
    
    @objc private func readSpecies()
    {
        refreshControl?.beginRefreshing()
        species.clear()
        species.read(link: URLManager.current.getMySpeciesURL())
    }
    
    private func readNext()//(_ indexPath:IndexPath)
    {
        species.readNext()
//        do
//        {
//            let numberAdded = try species.readNext()
//            var offset = tableView.contentOffset
//            for i in 0 ..< numberAdded
//            {
//                let row = indexPath.row + i
//                let index = IndexPath(row: row, section: indexPath.section)
//                offset.y += tableView(tableView, heightForRowAt: index)
//            }
//            tableView.reloadData()
//            tableView.setContentOffset(offset, animated: true)
//        }
//        catch
//        {
//            print("Error: \(error)")
//        }
    }
    
//    @objc private func updateList()
//    {
//        do
//        {
//            species.clear()
//            try species.read(link: FlightAppManager.shared.urlManager.getMySpeciesURL())
//        }
//        catch
//        {
//            print(error.localizedDescription)
//            let alert = UIAlertController(title: "Network Error", message: "Unable to fetch the list from the server. Please try again.", preferredStyle: .alert)
//            let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: { action in
//                self.refreshControl!.endRefreshing()
//            })
//            let tryAgain = UIAlertAction(title: "Try again", style: .default, handler: { action in
//                    alert.dismiss(animated: true, completion: nil)
//                    self.updateList()
//                })
//
//            alert.addAction(cancel)
//            alert.addAction(tryAgain)
//
//            self.present(alert, animated: true, completion: nil)
//        }
//    }
    
//    func refreshList()
//    {
//        updateList()
//        tableView.reloadData()
//
//    }
    
//    @objc private func refresh()
//    {
//        updateList()
//        refreshControl?.endRefreshing()
//        tableView.reloadData()
//    }

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
            let toDelete = (tableView.cellForRow(at: indexPath) as! MySpeciesTableViewCell).getSpecies()!
//            speciesToDelete.append(toDelete)
//            print(species.count)
            species.delete(link: URLManager.current.getMySpeciesURL(), species: [toDelete])
//            print(species.count)
//            speciesToDelete.removeAll()
//            tableView.deleteRows(at: [indexPath], with: .fade)
//            tableView.reloadSections(.init(integer: 0), with: .fade)
//            tableView.reloadSections(.init(integer: indexPath.section), with: .automatic)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    
    private func getIndexPathForSpecies(s: Species) -> IndexPath?{
        for cell in tableView.visibleCells {
            if let speciesCell = cell as? MySpeciesTableViewCell {
                if s == speciesCell.getSpecies() {
                    return tableView.indexPath(for: cell)
                }
            }
        }
        return nil
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

    // MARK: - Callbacks
    func speciesListRead() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
            self.refreshControl?.endRefreshing()
        }
    }
    
    func speciesListReadWithError(e: SpeciesList.ReadErrors) {
        DispatchQueue.main.async {
            var title:String = ""
            var description:String = ""
            var actions:[UIAlertAction] = []
            let alert: UIAlertController
            let dismissClosure: (UIAlertAction) -> Void = { action in
                self.dismiss(animated: true, completion: nil)
            }
            
            switch e {
            case let .readError(status):
                title = "Read Error"
                description = "An error occurred while attempting to read the list (status=\(status)). Please try again later."
                actions.append(UIAlertAction(title: "OK", style: .cancel, handler: dismissClosure))
            case .jsonParseError:
                title = "Parse Error"
                description = "An error occurred in parsing your selection species. Please try again later or contact us."
                actions.append(UIAlertAction(title: "OK", style: .cancel, handler: dismissClosure))
            case .noResponse:
                title = "Network Error"
                description = "A network error has occurred. Check your network connection and try again."
                actions.append(UIAlertAction(title: "Cancel", style: .cancel, handler: dismissClosure))
                actions.append(UIAlertAction(title: "Try Again", style: .default, handler: {action in
                    self.readSpecies()
                }))
            case .authError:
               title = "Authentication Error"
               description = "Your session has expired. Please log back in and try again."
               actions.append(.init(title: "OK", style: .default, handler: {action in
                    self.navigationController?.dismiss(animated: true, completion: FlightAppManager.shared.clearSession)
                }))
            }
            
            alert = UIAlertController(title: title, message: description, preferredStyle: .alert)
            for action in actions {
                alert.addAction(action)
            }
        
            self.present(alert, animated: true, completion: self.refreshControl?.endRefreshing)
        }
    }
    
    func speciesListReadNext(c: Int) {
        DispatchQueue.main.async{
            var offset = self.tableView.contentOffset
            for i in 0 ..< c
            {
                let row = self.species.count - c + i
                let index = IndexPath(row: row, section: 0)
                offset.y += self.tableView(self.tableView, heightForRowAt: index)
            }
            self.tableView.reloadData()
            self.tableView.setContentOffset(offset, animated: true)
        }
    }
    
    func speciesListReadNextWithError(e: SpeciesList.ReadErrors) {
        DispatchQueue.main.async{
            var title:String = ""
            var description:String = ""
            var actions:[UIAlertAction] = []
            let alert: UIAlertController
            
            switch e {
            case let .readError(status):
                title = "Read Error"
                description = "An error occurred while attempting to read the continuation list (status=\(status)). Please try again later."
                actions.append(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            case .jsonParseError:
                title = "Parse Error"
                description = "An error occurred in parsing the next species. Please try again later or contact us."
                actions.append(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            case .noResponse:
                title = "Network Error"
                description = "A network error has occurred. Check your network connection and try again."
                actions.append(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                actions.append(UIAlertAction(title: "Try Again", style: .default, handler: {action in
                    self.readNext()
                }))
            case .authError:
                title = "Authentication Error"
                description = "Your session has expired. Please log back in and try again."
                actions.append(.init(title: "OK", style: .default, handler: {action in
                    self.navigationController?.dismiss(animated: true, completion: FlightAppManager.shared.clearSession)
                }))
            }
            
            alert = UIAlertController(title: title, message: description, preferredStyle: .alert)
            for action in actions {
                alert.addAction(action)
            }
            
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func speciesListSpeciesAdded(s: [Species]) {
        DispatchQueue.main.async{
            self.tableView.reloadSections(.init(integer: 0), with: .automatic)
            
        }
    }
    
    func speciesListSpeciesAddedWithError(s: [Species], e: SpeciesList.AddErrors) {
        DispatchQueue.main.async {
            var title:String = ""
            var description:String = ""
            var actions:[UIAlertAction] = []
            let alert: UIAlertController
            
            switch e {
            case let .addError(status):
                title = "Read Error"
                description = "An error occurred while attempting to update your preferences (status=\(status)). Please try again later."
                actions.append(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            case .jsonParseError:
                title = "Parse Error"
                description = "Error parsing your preferences. Please try again later. If the problem persists, please contact us."
                actions.append(UIAlertAction(title: "OK", style: .cancel, handler: {action in self.dismiss(animated: true, completion: nil)}))
            case .noResponse:
                title = "Network Error"
                description = "A network error has occurred. Check your network connection and try again."
                actions.append(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                actions.append(UIAlertAction(title: "Try Again", style: .default, handler: {action in
                    self.species.add(link: URLManager.current.getMySpeciesURL(), species: s)
                }))
            case .authError:
                title = "Authentication Error"
                description = "Your session has expired. Please log back in and try again."
                actions.append(.init(title: "OK", style: .default, handler: {action in
                    self.navigationController?.dismiss(animated: true, completion: FlightAppManager.shared.clearSession)
                }))
            }
            
            alert = UIAlertController(title: title, message: description, preferredStyle: .alert)
            for action in actions {
                alert.addAction(action)
            }
            
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func speciesListSpeciesRemoved(s: [Species]) {
//        speciesToDelete.removeAll()
        DispatchQueue.main.async {
            var indices: [IndexPath] = []
            
            for species in s {
                indices.append(self.getIndexPathForSpecies(s: species)!)
            }
            self.tableView.deleteRows(at: indices, with: .fade)
        }
        
//        tableView.reloadSections(.init(integer: 0), with: .automatic)
    }
    
    func speciesListSpeciesRemovedWithError(s:[Species], e: SpeciesList.RemoveErrors) {
        DispatchQueue.main.async{
            var title:String = ""
            var description:String = ""
            var actions:[UIAlertAction] = []
            let alert: UIAlertController

            switch e {
            case let .removeError(status):
               title = "Read Error"
               description = "An error occurred while attempting to update your preferences (status=\(status)). Please try again later."
               actions.append(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            case .jsonParseError:
               title = "Parse Error"
               description = "You are not logged in. Sign in before continuing."
               actions.append(UIAlertAction(title: "OK", style: .cancel, handler: {action in self.dismiss(animated: true, completion: nil)}))
            case .noResponse:
               title = "Network Error"
               description = "A network error has occurred. Check your network connection and try again."
               actions.append(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
               actions.append(UIAlertAction(title: "Try Again", style: .default, handler: {action in
                   self.species.delete(link: URLManager.current.getMySpeciesURL(), species: s)
               }))
            case .authError:
                title = "Authentication Error"
                description = "Your session has expired. Please log back in and try again."
                actions.append(.init(title: "OK", style: .default, handler: {action in
                    self.navigationController?.dismiss(animated: true, completion: FlightAppManager.shared.clearSession)
                }))
            }

            alert = UIAlertController(title: title, message: description, preferredStyle: .alert)
            for action in actions {
               alert.addAction(action)
            }

            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func speciesListCleared() {
        DispatchQueue.main.async{
            self.tableView.reloadData()
            
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    @IBAction func unwindToMySpeciesList(_ segue:UIStoryboardSegue)
    {
        guard let speciesModification = segue.source as? MySpeciesGeneraTableViewController else
        {
            return
        }
        
        let toAdd = Array(speciesModification.toAdd)
        
        if (toAdd.isEmpty)
        {
            return
        }
        
        species.add(link: URLManager.current.getMySpeciesURL(), species: toAdd)
//        tableView.reloadSections(.init(integer: 0), with: .fade)
        
//        do
//        {
//            let toAdd = Array(speciesModification.toAdd)
//
//            if (toAdd.isEmpty)
//            {
//                return
//            }
//
//            try FlightAppManager.shared.session!.species.add(link: FlightAppManager.shared.urlManager.getMySpeciesURL(), species: toAdd )
//            tableView.reloadSections(.init(integer: 0), with: .fade)
//        }
//        catch
//        {
//            let alert = UIAlertController(title: "Error updating species", message: "An error occurred updating the species list: \(error.localizedDescription).", preferredStyle: .alert)
//            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
//            alert.addAction(cancelAction)
//            self.present(alert, animated: true, completion: nil)
//        }
    }
}
