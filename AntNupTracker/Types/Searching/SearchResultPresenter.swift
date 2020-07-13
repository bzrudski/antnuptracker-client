//
// SearchResultPresenter.swift
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
 This protocol should be implemented by view controllers that present a list of search results.
 */
protocol SearchResultPresenter {
    /** Sort the results for a given input query.
 - parameter string1: First `String` to compare
 - parameter string2: Second `String` to compare
 - parameter input: Input query
 - returns: - `true` if `string2` should come before `string1`
                    - `false` otherwise
     */
    func sortResults(string1:String, string2:String, input:String) -> Bool
    
    /**
     Set the universe of possible results.
    - parameter u: the list of all possible results
     */
    func setUniverse(_ u:[String])
    
    /**
     Update the results based on a search query. If `searchKey` is `nil`, the results should be reset be the universe.
     - parameter searchKey: the search query.
     */
    func updateResults(for searchKey: String?)
}

extension SearchResultPresenter{
    func sortResults(string1:String, string2:String, input:String) -> Bool {
        let index1 = string1.firstIndex(of: input)
        let index2 = string2.firstIndex(of: input)
        
        return index1 > index2
    }
}
