//
// User.swift
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

class User:Decodable{
    let username:String
    let professional: Bool
    let flagged: Bool
    let description: String?
    let institution: String?
    
    var role: Role {
        if flagged {
            return .flagged
        }
        else if professional {
            return .professional
        } else {
            return .citizen
        }
    }
    
    enum CodingKeys:String, CodingKey{
        case username, professional, description, institution, flagged
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        username = try container.decode(String.self, forKey: .username)
        professional = try container.decode(Bool.self, forKey: .professional)
        flagged = try container.decode(Bool.self, forKey: .flagged)
        let descriptionRaw = try container.decode(String.self, forKey: .description)
        if descriptionRaw != "" {
            description = descriptionRaw
        } else {
            description = nil
        }
        let institutionRaw = try container.decode(String.self, forKey: .institution)
        if institutionRaw != "" {
            institution = institutionRaw
        } else {
            institution = nil
        }
    }
    
    init(username:String, professional:Bool, description:String?=nil, institution:String?=nil, flagged:Bool=false){
        
//        assert((professional && institution != nil) || (!professional && institution == nil), "Only professionals have institutions and professionals must have institutions.")
        
        self.username = username
        self.professional = professional
        self.flagged = flagged
        
        self.description = {
            if description != "" {
                return description
            } else {
                return nil
            }
        }()
        
        self.institution = {
            if institution != "" {
                return institution
            } else {
                return nil
            }
        }()
    }
}

enum UserTableModifiers{
    case role
    case description
}

extension Table where M==UserTableModifiers{
    convenience init(user u:User){
        var sections: [Section<M>] = []
        
        var userInfoRows: [Row<Any, M>] = []
        let username: Row<Any, M>
        let role: Row<Any, M>
        let institution: Row<Any, M>?
        let description: Row<Any, M>?
        
        username = Row(header: "Username", content: u.username)
        userInfoRows.append(username)
        role = Row(header: "Role", content: u.role, modifier: .role)
        userInfoRows.append(role)
        if let institutionText = u.institution {
            institution = Row(header: "Institution/Affiliation", content: institutionText, modifier: .description)
            userInfoRows.append(institution!)
        }
        if let descriptionText = u.description {
            description = Row(header: "Description", content: descriptionText, modifier: .description)
            userInfoRows.append(description!)
        }
        
        let userInfoSection: Section<M> = Section(header: "User Information", rows: userInfoRows, footer: nil)
        
        sections.append(userInfoSection)
        
        self.init(sections: sections)
    }
}
