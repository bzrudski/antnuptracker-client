//
// ProgressAlertViewController.swift
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

class ProgressAlertViewController: UIAlertController, UploadDelegate {
    func uploaded(_ bytes: Int64, total: Int64) {
        DispatchQueue.main.async {
            let progress = Float(bytes)/Float(total) * 100
            self.progressBar?.setProgress(progress/100, animated: true)
            self.message = String(format: "Upload progress: %.2f%%\n", progress)
        }
    }
    
    var progressBar: UIProgressView? = nil

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
    }
    
    func prepareForPresentation() {
        let margin: CGFloat = 8.0
        let rect = CGRect(x: margin, y: 72.0, width: self.view.frame.width - 2*margin, height: 2.0)
        self.progressBar = UIProgressView(frame: rect)
        
        WebDelegate.shared.setUploadDelegate(self)
        self.view.addSubview(progressBar!)
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
