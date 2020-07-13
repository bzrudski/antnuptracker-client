//
// FilteringSpeciesTableViewCell.swift
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

class FilteringSpeciesTableViewCell: UITableViewCell {

    private var genus: Genus = try! .get("Unknown")
    private var speciesName: String = "sp. (Unknown)"
    
    public func getGenus() -> String {
        genus.name
    }
    
    public func getSpeciesName() -> String {
        speciesName
    }
    
    public func getSpecies() -> Species {
//        let genus = try! Genus.get(genusName)
        return try! Species.get(pGenus: genus, pSpecies: speciesName)
    }
    
    public func setTaxonomy(genus: Genus, speciesName: String) {
        self.genus = genus
        self.speciesName = speciesName
        self.textLabel!.text = genus.name + " " + speciesName
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
        if selected {
            self.accessoryType = .checkmark
        }
        else {
            self.accessoryType = .none
        }
    }

}
