//
// FullscreenImageViewController.swift
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

// WORK IN PROGRESS

import UIKit

/// View controller for full-screen viewing of flight images.
class FullscreenImageViewController: UIViewController, UIScrollViewDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard image != nil else {
            self.navigationController?.popViewController(animated: true)
            return
        }
        
        imageView.image = image!
        x = image!.size.width
        y = image!.size.height

        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 5.0
        // Do any additional setup after loading the view.
        scrollView.delegate = self
    }
    
    var image: UIImage? = nil
    var x: CGFloat = 0.0
    var y: CGFloat = 0.0
    var scale: CGFloat = 1.0
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet var pinchRecogniser: UIPinchGestureRecognizer!
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    @IBAction func zoom(_ sender: UIPinchGestureRecognizer){
        if sender.state == .began || sender.state == .changed {
            
//            if (scale * sender.scale <= 1.0){
//                sender.view?.transform = (sender.view?.transform.scaledBy(x: 1/(sender.scale), y: 1/(sender.scale)))!
//            } else if (scale * sender.scale >= 6.0){
//                sender.view?.transform = (sender.view?.transform.scaledBy(x: T##CGFloat, y: T##CGFloat))!
//            }
            
            sender.view?.transform = (sender.view?.transform.scaledBy(x: sender.scale, y: sender.scale))!
            sender.scale = 1.0
        }
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
