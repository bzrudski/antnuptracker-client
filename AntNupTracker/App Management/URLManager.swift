//
// URLManager.swift
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

/// Singleton for managing urls for the web interactions. Access the singleton through `URLManager.current`.
class URLManager
{
    // MARK: - Create singleton
    static let current = URLManager.init(base: "https://www.antnuptialflights.com/")
       
    private init(base pBaseURL:String)
    {
       baseURL = URL(string: pBaseURL)!
    }
    
    // MARK: - URL Components
    private let baseURL: URL
    
    private let loginURL = "login"
    private let verifyURL = "verify"
    private let logoutDeviceURL = "logout"
    private let flightsURL = "flights"
    private let createURL = "create"
    private let createAccountURL = "create-account"
    private let commentsURL = "comments"
    private let mySpeciesURL = "my-species"
    private let historyURL = "history"
    private let weatherURL = "weather"
    private let usersURL = "users"
    private let resetPassURL = "reset-password"
    private let validateURL = "validate"
    private let aboutURL = "about"
    private let privacyURL = "privacy-policy"
    private let termsURL = "terms-and-conditions"
    private let emailAddress = "mailto:nuptialtracker@gmail.com"
    
    public func getHomeURL() -> URL {
        return baseURL
    }
    
    public func listURL() -> URL
    {
        return baseURL.appendingPathComponent(flightsURL, isDirectory: true)
    }
    
    public func urlForFlight(id: Int) -> URL
    {
        return listURL().appendingPathComponent(String(id), isDirectory: true)
    }
    
    public func urlForWeather(id: Int) -> URL
    {
        return urlForFlight(id: id).appendingPathComponent(weatherURL, isDirectory: true)
    }
    
    public func urlForHistory(id: Int) -> URL
    {
        return urlForFlight(id: id).appendingPathComponent(historyURL, isDirectory: true)
    }
    
    public func urlForValidate(id: Int) -> URL
    {
        return urlForFlight(id: id).appendingPathComponent(validateURL, isDirectory: true)
    }
    
    public func urlForCreate() -> URL
    {
        return baseURL.appendingPathComponent(createURL, isDirectory: true)
    }
    
    public func urlForComments() -> URL
    {
        return baseURL.appendingPathComponent(commentsURL, isDirectory: true)
    }
    
    public func getLoginURL() -> URL
    {
        return baseURL.appendingPathComponent(loginURL, isDirectory: true)
    }
    
    public func getVerifyURL() -> URL
    {
        return getLoginURL().appendingPathComponent(verifyURL, isDirectory: true)
    }
    
    public func getLogoutURL() -> URL
    {
        return baseURL.appendingPathComponent(logoutDeviceURL, isDirectory: true)
    }
    
    public func getMySpeciesURL() -> URL
    {
        return baseURL.appendingPathComponent(mySpeciesURL, isDirectory: true)
    }
    
    public func getCreateAccountURL() -> URL
    {
        return baseURL.appendingPathComponent(createAccountURL, isDirectory: true)
    }
    
    public func getUserURL(for username:String) -> URL
    {
        return baseURL.appendingPathComponent(usersURL, isDirectory: true).appendingPathComponent(username, isDirectory: true)
    }
    
    public func getPasswordResetURL() -> URL
    {
        return baseURL.appendingPathComponent(resetPassURL, isDirectory: true)
    }
    
    public func getAboutURL() -> URL
    {
        return baseURL.appendingPathComponent(aboutURL, isDirectory: true)
    }
    
    public func getPrivacyURL() -> URL
    {
        return baseURL.appendingPathComponent(privacyURL, isDirectory: true)
    }
    
    public func getTermsURL() -> URL
    {
        return baseURL.appendingPathComponent(termsURL, isDirectory: true)
    }
    
    public func filteredListURL(forGenus genus: Genus) -> URL {
        return listURL().appendingPathComponent("?genus=\(genus.name)")
    }
    
    public func filteredListURL(forSpecies species: Species) -> URL {
        return listURL().appendingPathComponent("?genus=\(species.genus.name)&species=\(species.name)")
    }
    
    public func getContactURL() -> URL {
        return URL(string: emailAddress)!
    }
}
