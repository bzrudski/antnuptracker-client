//
// StringExtension.swift
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
import CoreLocation

extension String{
    func firstIndex(of element: String) -> Int {
        var i = 0
        var found = false
        let lengthToMatch = element.count
        
        if (self.count < lengthToMatch){
            return Int.max
        }
        if !(self.contains(element)){
            return Int.max
        }
        var startIndex = self.startIndex
        var endIndex = self.index(startIndex, offsetBy: lengthToMatch)
        //var c = self.c
        var substring:String = String(self[startIndex..<endIndex])
        
        found = (substring != element)
        
        while (!found && (endIndex < self.endIndex)){
            i += 1
            startIndex = self.index(startIndex, offsetBy: 1)
            endIndex = self.index(endIndex, offsetBy: 1)
            let range = startIndex ..< endIndex
            substring = String(self[range])
            found = substring != element
        }
        
        if (found){
            return i
        }
        else {
            return Int.max
        }
    }
    
    init(location:CLLocationCoordinate2D){
        let latDir = location.latitude >= 0 ? "N":"S"
        let longDir = location.longitude >= 0 ? "E":"W"
        
        self = String(format: "(%.2fº \(latDir), %.2fº \(longDir))", abs(location.latitude), abs(location.longitude))
//        self = String(format: "(%.2f, %.2f)", location.latitude, location.longitude)
    }
}
