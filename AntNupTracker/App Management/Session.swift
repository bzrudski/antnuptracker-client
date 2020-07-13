//
// Session.swift
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
import os

class Session{
//    let username:String
//    let role:Role
    private let user:User
    let authToken:String
    let device:Device
    let species: SpeciesList = SpeciesList()
    
    var username:String {
        return user.username
    }
    
    var professional:Bool {
        return user.professional
    }
    
    var role:Role {
        return user.role
    }
    
    var description:String? {
        return user.description
    }
    
    var institution:String? {
        return user.institution
    }
//    var sessionExpiry:Date
    
    init(username:String, professional:Bool, description:String?=nil, institution:String?=nil, authToken:String, device:Device){
        self.user = User(username: username, professional: professional, description: description, institution: institution)
        self.authToken = authToken
//        self.role = Role(rawValue: role)!
        self.device = device
    }
}

enum SessionTableModifiers{
    case role
    case description
    case taxonomy
    case logout
    case url
}

extension Table where M==SessionTableModifiers{
    convenience init(session s:Session){
        var sections: [Section<M>] = []
        
        var userInfoRows: [Row<Any, M>] = []
        let username: Row<Any, M>
        let role: Row<Any, M>
        let institution: Row<Any, M>?
        let description: Row<Any, M>?
        
        username = Row(header: "Username", content: s.username)
        userInfoRows.append(username)
        role = Row(header: "Role", content: s.role, modifier: .role)
        userInfoRows.append(role)
        if let institutionText = s.institution {
            institution = Row(header: "Institution/Affiliation", content: institutionText, modifier: .description)
            userInfoRows.append(institution!)
        }
        if let descriptionText = s.description {
            description = Row(header: "Description", content: descriptionText, modifier: .description)
            userInfoRows.append(description!)
        }
        
        let userInfoSection: Section<M> = Section(header: "User Information", rows: userInfoRows, footer: "If you want to change this information, email us at nuptialtracker@gmail.com from the email address you provided.")
        
        sections.append(userInfoSection)
        
        let mySpecies:Row<Any, M> = Row(header: "My Species", content: "my species", modifier: .taxonomy)
        let speciesSection = Section(header: "Notification Settings", rows: [mySpecies], footer: nil)
        
        sections.append(speciesSection)
        
        let logout:Row<Any, M> = Row(header: "Logout", content: "logout", modifier: .logout)
        let sessionManagement = Section(header: "Session Management", rows: [logout], footer: nil)
        
        sections.append(sessionManagement)
        
        let home:Row<Any, M> = Row(header: "AntNupTracker Homepage", content: URLManager.current.getHomeURL(), modifier: .url)
        let privacy:Row<Any, M> = Row(header: "Privacy Policy", content: URLManager.current.getPrivacyURL(), modifier: .url)
         let terms: Row<Any, M> = Row(header: "Terms of Use", content: URLManager.current.getTermsURL(), modifier: .url)
        let contactUs: Row<Any, M> = Row(header: "Contact us", content: URLManager.current.getContactURL(), modifier: .url)
        
        let moreInfo = Section(header: "More information", rows: [home, privacy, terms, contactUs], footer: "For more, visit us at \(URLManager.current.getHomeURL()).")
        
        sections.append(moreInfo)
        
        self.init(sections: sections)
    }
}
