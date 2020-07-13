//
// WeatherTableViewController.swift
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

class WeatherTableViewController: UITableViewController, WeatherObserver {
    
    typealias WeatherErrors = WeatherManager.WeatherErrors
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard flightID != nil else {
            let alert = UIAlertController(title: "No Flight", message: "No flight selected. Please select a flight and try again.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: {self.dismiss(animated: true, completion: nil)})
            return
        }
        
        WeatherManager.shared.setObserver(self)

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(triggerFetch), for: .valueChanged)
        refreshControl?.beginRefreshing()
        self.triggerFetch()
    }
    
    // MARK: - Local Variables
    var flightID:Int? = nil
    private var weather:Weather? = nil
    private var weatherArray:[(String, [(String, String)])] = []

    private func setWeather(_ w: Weather){
        weather = w
        weatherArray = w.toArray()
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        if (weather == nil){
            return 1
        }
        return weatherArray.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (weather != nil){
            return weatherArray[section].1.count
        }
        return 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "weatherCell", for: indexPath) as! WeatherTableViewCell
        guard (!weatherArray.isEmpty) else {
            return cell
        }
        
        let detailsForCell = weatherArray[indexPath.section].1[indexPath.row]

        let cellLabel:String = detailsForCell.0
        let detailLabel:String = detailsForCell.1
        
        cell.fieldLabel.text = cellLabel
        cell.detailLabel.text = detailLabel

        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if (!self.weatherArray.isEmpty){
            return self.weatherArray[section].0
        }
        else{
            return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if (weather == nil){
            return "No weather information to display"
        } else if section == weatherArray.count - 1 {
            return "Weather information from OpenWeatherMap (https://openweathermap.org/), which is made available here under the Open Database License (ODbL) (https://opendatacommons.org/licenses/odbl/1-0/)."
        }
        return nil
    }
    
//    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        //if (indexPath.section == 1){
//            //tableView.estimatedRowHeight = 350
//            return UITableView.automaticDimension
////        }
////        else{
////            tableView.estimatedRowHeight = 80
////            return UITableView.automaticDimension
////        }
//    }

    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        if (indexPath.section == 1){
            tableView.estimatedRowHeight = 200
            return UITableView.automaticDimension
        }
        else{
            tableView.estimatedRowHeight = 75
            return UITableView.automaticDimension
        }
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
    
    // MARK: - Load Weather
    @objc func triggerFetch(){
        WeatherManager.shared.getWeatherBy(id: flightID!)
    }
    
    func flightListGotWeather(w: Weather) {
        DispatchQueue.main.async {
            self.setWeather(w)
            self.refreshControl?.endRefreshing()
            self.tableView.reloadData()
        }
        
    }
    
    func flightListGotWeatherError(e: WeatherErrors) {
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
                body = "No weather was found for this flight."
                actions.append(UIAlertAction(title: "OK", style: .default, handler: dismissClosure))
            case .invalidID:
                title = "Invalid Flight ID"
                body = "Invalid flight ID provided. Please try again later."
                actions.append(UIAlertAction(title: "OK", style: .default, handler: dismissClosure))
            case .jsonError:
                title = "Parse Error"
                body = "Error parsing the flight weather. Please try again later."
                actions.append(UIAlertAction(title: "OK", style: .default, handler: dismissClosure))
            case .getWeatherError:
                title = "Server Error"
                body = "Error retrieving the flight weather. Please try again later."
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
