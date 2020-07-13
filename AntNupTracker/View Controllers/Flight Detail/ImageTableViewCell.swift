//
// ImageTableViewCell.swift
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

class ImageTableViewCell: UITableViewCell {

    // MARK: - Field
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var flightImageView: UIImageView!
    @IBOutlet weak var loadIndicator: UIActivityIndicatorView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    // MARK: - Configure
    func configure(for image:UIImage?){
//        var correctedImage = image
//        if (image.imageOrientation != .up){
//            print("Image is not upright")
//        } else {
//            print("Image is upright")
//        }
        
        if image == nil {
            loadIndicator.startAnimating()
            loadIndicator.isHidden = false
//            flightImageView.backgroundColor = .lightGray
            self.flightImageView.image = image
        }
        else {
            loadIndicator.stopAnimating()
            loadIndicator.isHidden = true
         
//            let width = self.frame.width - 20
//
//            let imageWidth = image!.size.width
//            let imageHeight = image!.size.height
//
//            let newHeight = imageHeight/imageWidth * width
//
//            let currentImageFrame = flightImageView.frame
//
//            let newFrame = CGRect(x: 0, y: 0, width: width, height: newHeight)
//
//            let newSize = CGSize(width: width, height: newHeight)
//
//            UIGraphicsBeginImageContextWithOptions(newSize, true, 1.0)
//
//            image!.draw(in: newFrame)
//
//            let newImage = UIGraphicsGetImageFromCurrentImageContext()
//            UIGraphicsEndImageContext()
//
////            self.flightImageView.transform = .init(scaleX: width/imageWidth, y: width/imageWidth)
//            self.flightImageView.frame = newFrame
//
//            self.flightImageView.autoresizingMask = .flexibleHeight
//
////            flightImageView.contentMode = .scaleAspectFit
//
////            self.flightImageView.backgroundColor = .none
            self.flightImageView.image = image!
        }
        
//        self.flightImageView.image = image
        
//        self.flightImageView.frame.size
    }

}
