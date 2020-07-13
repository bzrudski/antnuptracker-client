//
// DateViewController.swift
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

class DateViewController: UIViewController, UIPickerViewDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.datePicker.maximumDate = Date()
        self.updateConstraintsOnTimePicker(datePicker!)
        
        if (date != nil){
            self.datePicker.setDate(date!, animated: true)
            self.timePicker.setDate(date!, animated: true)
        }
    }
    
    // MARK: - UI outlets
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var timePicker: UIDatePicker!
    @IBOutlet weak var doneButton: UIBarButtonItem!

    // MARK: - UI actions
    @IBAction func cancel(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func setToday(_ sender: Any) {
        datePicker.setDate(Date(), animated: true)
        timePicker.setDate(Date(), animated: true)
    }
    
    @IBAction func updateConstraintsOnTimePicker(_ sender: Any){
        let datePickerDate = datePicker.date
        let currentDate = Date()
        let calendar = Calendar(identifier: .gregorian)
        
        let componentsPicker = calendar.dateComponents([.day, .month, .year], from: datePickerDate)
        let componentsCurrent = calendar.dateComponents([.day, .month, .year], from: currentDate)
        
        let daysEqual = (componentsPicker.day == componentsCurrent.day)
        let monthsEqual = (componentsPicker.month == componentsCurrent.month)
        let yearsEqual = (componentsPicker.year == componentsCurrent.year)
        
        if (daysEqual && monthsEqual && yearsEqual){
            timePicker.maximumDate = Date()
        } else {
            timePicker.maximumDate = nil
        }
    }
    
//    @IBAction func printDate(_ sender:Any){
//        print(datePicker.date.timeIntervalSince1970)
//    }
    
    // MARK: - Local variables
    var date:Date? = nil
    
    class InvalidDate:Error{}
    
    func getDate() -> Date {
        let time = timePicker.date
        let date = datePicker.date
        let calendar = Calendar(identifier: .gregorian)
        
        let componentsFromTime = calendar.dateComponents([.hour, .minute, .second, .timeZone, .nanosecond], from: time)
        let componentsFromDate = calendar.dateComponents([.day, .month, .year, .era, .quarter, .weekdayOrdinal, .weekOfYear, .weekday, .yearForWeekOfYear, .weekOfMonth], from: date)
        
        let hour = componentsFromTime.hour
        let minute = componentsFromTime.minute
        let second = componentsFromTime.second
        let nanosecond = componentsFromTime.nanosecond
        let timeZone = componentsFromTime.timeZone
        
        let day = componentsFromDate.day
        let month = componentsFromDate.month
        let year = componentsFromDate.year
        let era = componentsFromDate.era
        let quarter = componentsFromDate.quarter
        let weekdayOrdinal = componentsFromDate.weekdayOrdinal
        let weekOfYear = componentsFromDate.weekOfYear
        let weekday = componentsFromDate.weekday
        let yearForWeekOfYear = componentsFromDate.yearForWeekOfYear
        let weekOfMonth = componentsFromDate.weekOfMonth
        
        let jointComponents = DateComponents(calendar: calendar, timeZone: timeZone, era: era, year: year, month: month, day: day, hour: hour, minute: minute, second: second, nanosecond: nanosecond, weekday: weekday, weekdayOrdinal: weekdayOrdinal, quarter: quarter, weekOfMonth: weekOfMonth, weekOfYear: weekOfYear, yearForWeekOfYear: yearForWeekOfYear)
        
        //if (jointComponents.isValidDate(in: calendar)){
        return jointComponents.date!
        //}
//        else {
//            throw InvalidDate
//        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
