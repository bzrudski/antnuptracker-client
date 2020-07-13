//
// UserTableViewCell.swift
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

class UserTableViewCell: UITableViewCell {

    @IBOutlet weak var mainTextLabel: UILabel!
    @IBOutlet weak var contentTextLabel: UILabel!
    @IBOutlet weak var checkmarkBox: UIImageView!
    
    public var username: String? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setUp(header: String?, username: String, role: Role)
    {
        self.username = username
        mainTextLabel.text = header
        contentTextLabel.text = username
        
        let labelToCheck = contentTextLabel.constraints.first(where: {
        constraint in
        return constraint.identifier == "labelToCheck"
            }
        )
        
        let labelToCellEnd = contentTextLabel.constraints.first(where: {
        constraint in
        return constraint.identifier == "labelToWall"
        })
        
//        let betweenLabels = contentTextLabel.constraints.first(where: {
//            constraint in
//            return constraint.identifier == "betweenLabels"
//        })
        
//        print("Should show the checkmark: \(showCheckmark)")
        
//        checkmarkBox.image = UIImage.init(named: "checkmark")
        if (role == .citizen) {
            checkmarkBox.isHidden = true
            labelToCellEnd?.isActive = true
            labelToCheck?.isActive = false
        }
        else {
            if (role == .professional){
                checkmarkBox.image = UIImage.init(named: "antBlueSmall", in: .main, compatibleWith: self.traitCollection)
            } else {
                checkmarkBox.image = UIImage.init(named: "antRedVerySmall", in: .main, compatibleWith: self.traitCollection)
            }
            
            checkmarkBox.isHidden = false
            labelToCellEnd?.isActive = false
            labelToCheck?.isActive = true
        }

        
//        print("Checkmark is visible: \(!checkmarkBox.isHidden)")
    }

}
