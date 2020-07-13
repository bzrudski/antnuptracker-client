//
// CommentTableViewCell.swift
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

class CommentTableViewCell: UITableViewCell {
    
    @IBOutlet weak var contentsLabel:UILabel!
    @IBOutlet weak var authorButton: UIButton!
    @IBOutlet weak var roleImageView: UIImageView!
    @IBOutlet weak var dateLabel:UILabel!
    
    var comment: Comment? = nil
    
    func configure(for c:Comment){
        contentsLabel.text = c.text
        authorButton.setTitle(c.author, for: .normal)
        
        switch c.role {
        case .citizen:
            roleImageView.image = nil
            roleImageView.isHidden = true
        case .professional:
            roleImageView.image = UIImage.init(named: "antBlueSmall", in: .main, compatibleWith: traitCollection)
            roleImageView.isHidden = false
        case .flagged:
            roleImageView.image = UIImage.init(named: "antRedVerySmall", in: .main, compatibleWith: traitCollection)
            roleImageView.isHidden = false
        }
        dateLabel.text = FlightAppManager.shared.dateFormatter.string(from: c.time)
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
