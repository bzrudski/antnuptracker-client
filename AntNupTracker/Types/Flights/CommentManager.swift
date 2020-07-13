//
// ComentManager.swift
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

/// Singleton for posting comments on flights
class CommentManager{
    
    private init(){}
    
    /// Singleton instance
    public static let shared = CommentManager()
    
    /// Observer to notify of the creation of comments, or the
    /// failure to create them
    private var observer: FlightCommentObserver? = nil
    
    public func setObserver(_ o: FlightCommentObserver){
        observer = o
    }
    
    public func unsetObserver(){
        observer = nil
    }
    
    enum CommentErrors:Error{
        case noResponse
        case notLoggedIn
        case noFlight
        case otherError(status:Int)
        case jsonError
    }
    
    func createComment(comment:Comment) {
        let url = URLManager.current.urlForComments()
        guard let body = try? JSONEncoder.shared.encode(comment) else {
            observer?.flightListCreatedCommentError(c: comment, e: CommentErrors.jsonError)
            return
        }
        
        guard let authToken = FlightAppManager.shared.session?.authToken else {
            observer?.flightListCreatedCommentError(c: comment, e: CommentErrors.notLoggedIn)
            return
        }
        
        WebInt.shared.request(.post, link: url, body: body, authToken: authToken, completionHandler: {
            status, _ in
            
            if status == 404 {
                self.observer?.flightListCreatedCommentError(c: comment, e: CommentErrors.noFlight)
                return
            }
            
            if status == 401 {
                self.observer?.flightListCreatedCommentError(c: comment, e: CommentErrors.notLoggedIn)
                return
            }
            
            if status != 201 {
                self.observer?.flightListCreatedCommentError(c: comment, e: CommentErrors.otherError(status: status))
                return
            }
            
            self.observer?.flightListCreatedComment(c: comment)
            return
        }, errorHandler: {
            _ in
            self.observer?.flightListCreatedCommentError(c: comment, e: CommentErrors.noResponse)
        })
    }
}
