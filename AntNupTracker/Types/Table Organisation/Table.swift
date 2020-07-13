//
// Table.swift
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

class Table<M>{
    var sections = [Section<M>]()
    
    var count:Int{
        get {
            return self.sections.count
        }
    }
    
    subscript(i:Int)->Section<M>{
        get{
            return self.sections[i]
        }
        set(section){
            self.sections[i] = section
        }
    }
    
    subscript(indexPath:IndexPath)->Row<Any, M>{
        get{
            return self[indexPath.section][indexPath.row]
        }
    }
    
    subscript(header:String?)->[Section<M>]{
        get{
            var sections = [Section<M>]()
            for section in self.sections {
                if (section.header == header) {
                    sections.append(section)
                }
            }
            
            return sections
        }
    }
    
    init(sections:[Section<M>]){
        self.sections = sections
    }
    
    /// Get the index of a specific section by header
    /// - parameter header: header to search by
    /// - returns: `Int` if present, `nil` otherwise
    func getFirstIndex(by header:String?)->Int?{
        return self.sections.firstIndex(where: { section in
            section.header == header
        })
    }
}
