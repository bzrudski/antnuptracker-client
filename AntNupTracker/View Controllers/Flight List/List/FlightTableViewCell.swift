//
// FlightTableViewCell.swift
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
import CoreLocation

class FlightTableViewCell: UITableViewCell {

    // MARK: - Labels
    @IBOutlet weak var taxonLabel:UILabel!
    @IBOutlet weak var locationLabel:UILabel!
    @IBOutlet weak var dateLabel:UILabel!
    @IBOutlet weak var antImage: UIImageView!
    @IBOutlet weak var roleImageView: UIImageView!
    @IBOutlet weak var usernameButton: UIButton!
    
    // MARK: - Reference to flight
    weak var flight:FlightBarebone?
    
    // MARK: - Cell configuration
    func configure(forFlight flight: FlightBarebone){
        self.flight = flight
        self.taxonLabel.text = flight.taxonomy.description
        self.locationLabel.text = String(location: CLLocationCoordinate2D(latitude: flight.latitude, longitude: flight.longitude))
        self.dateLabel.text = FlightAppManager.shared.dateFormatter.string(from: flight.dateOfFlight)
        
        if flight.validationLevel == .citizen && !flight.validated {
            antImage.isHidden = true
        }
        else {
            if flight.validationLevel == .professional {
                antImage.image = UIImage(named: "antGreenSmall", in: .main, compatibleWith: self.traitCollection)
            } else {
                antImage.image = UIImage(named: "antRedSmall", in: .main, compatibleWith: self.traitCollection)
            }
            antImage.isHidden = false
        }
        
        usernameButton.setTitle(flight.owner, for: .normal)
        
        switch flight.ownerRole {
        case .citizen:
            roleImageView.isHidden = true
        case .professional:
            roleImageView.image = UIImage.init(named: "antBlueSmall", in: .main, compatibleWith: traitCollection)
            roleImageView.isHidden = false
        case .flagged:
            roleImageView.image = UIImage.init(named: "antRedVerySmall", in: .main, compatibleWith: traitCollection)
            roleImageView.isHidden = false
        }
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
