//
// Comment.swift
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

/**
 Class representing a user comment.
 */
class Comment: Codable, Equatable {
    let flight:Int
    let author:String
    let time:Date
    let role: Role
    var text:String
    
    init(flight:Int, author:String, text:String, time:Date, role:Role) {
        self.flight = flight
        self.author = author
        self.text = text
        self.time = time
        self.role = role
    }
    
    static func == (l:Comment, r:Comment) -> Bool{
        if (l.flight != r.flight){ return false }
        if (l.author != r.author){ return false }
        if (l.text != r.text){ return false }
        if (l.time != r.time){ return false }
        if (l.role != r.role){ return false }
        
        return true
    }
}
