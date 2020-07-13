//
// ImageSelectionTableViewCell.swift
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

class ImageSelectionTableViewCell: UITableViewCell, UIImagePickerControllerDelegate {
    
    // MARK: - UI Outlets
    @IBOutlet weak var antImageView: UIImageView!
    
    public var selectedImageForCell: UIImage? {
        get {
            if antImageView.image!.isEqual(UIImage.init(named: "placeholder", in: .main, compatibleWith: self.traitCollection)){
                return nil
            } else {
                return antImageView.image!
            }
        } set(i) {
            if let image = i {
                antImageView.image = image
            } else {
                antImageView.image = UIImage.init(named: "placeholder", in: .main, compatibleWith: self.traitCollection)
            }
            observer?.imageCell(self, selectedImage: i)
        }
    }
    
    // MARK: - UI Actions
    @IBAction func selectImage(_ sender:UITapGestureRecognizer){
        observer?.imageCellSelected(self)
    }
    
    private var observer:ImageSelectionCellObserver? = nil
    
    public func setObserver(_ o:ImageSelectionCellObserver){
        observer = o
    }
    
    public func unsetObserver(){
        observer = nil
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        antImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(selectImage(_:))))
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
