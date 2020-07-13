//
// Role.swift
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

/// Represents user roles
enum Role:Int, Codable, CustomStringConvertible
{
    case citizen = 0
    case professional = 1
    case flagged = -1
    
    var description: String {
        switch self{
        case .citizen:
            return "Citizen Scientist"
        case .professional:
            return "Myrmecologist"
        case .flagged:
            return "Flagged"
        }
    }
}
