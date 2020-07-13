//
// SegmentedInputTableViewCell.swift
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

class SegmentedInputTableViewCell: UITableViewCell {

    @IBOutlet weak var segmentedController: UISegmentedControl!
    
    @IBAction func valueChanged(_ sender: UISegmentedControl) {
        self.observer?.segmentedCell(valueChangedFor: segmentedController, toValue: segmentedController.selectedSegmentIndex, forField: field!)
    }
    
    public var selectedIndex: Int {
        get {
            segmentedController.selectedSegmentIndex
        }
        
        set(n){
            segmentedController.selectedSegmentIndex = n
        }
    }
    
    
    private var observer: SegmentedCellObserver? = nil
    
    public var field: FlightForm.Field.FieldType? = nil
    
    public func setObserver(_ o:SegmentedCellObserver){
        observer = o
    }
    
    public func unsetObserver(){
        observer = nil
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
