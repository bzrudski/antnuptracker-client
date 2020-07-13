//
// ImageDelegate.swift
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

import Foundation
/*import UIKit

@objc protocol ImageDelegate {
    func saveImage(_ image:UIImage)
    @objc func image(_ image:UIImage, didFinishSavingWith error:Error?, contextInfo:UnsafeRawPointer)
}

extension ImageDelegate where Self:UIViewController{
    func saveImage(_ image:UIImage){
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(_:didFinishSavingWith:contextInfo:)), nil)
    }
    
    func image(_ image:UIImage, didFinishSavingWith error:Error?, contextInfo:UnsafeRawPointer){
        guard let saveError = error else {
            return
        }
        let alert = UIAlertController(title: "Error Saving Image", message: "An error occurred while trying to save the image to your library: \n \(saveError.localizedDescription)", preferredStyle: .alert)
        let tryAgain = UIAlertAction(title: "Try Again", style: .default, handler: {
            action in
            self.saveImage(image)
        })
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addAction(cancel)
        alert.addAction(tryAgain)
        
        self.present(alert, animated: true, completion: nil)
    }
}
*/
