//
//  ImageDelegate.swift
//  NuptialLog
//
//  Created by Benjamin on 2019-07-16.
//  Copyright © 2019 Benjamin. Some rights reserved.
//

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
