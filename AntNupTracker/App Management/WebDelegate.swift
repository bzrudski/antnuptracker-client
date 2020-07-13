//
// WebDelegate.swift
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

protocol UploadDelegate {
    func uploaded(_ bytes: Int64, total: Int64)
}

/// Singleton for handling web request delegates
class WebDelegate: NSObject, URLSessionTaskDelegate {
    
    // MARK: - Singleton
    private override init() {}
    public static let shared = WebDelegate()
    
    // MARK: - Observers
    private var uploadDelegate: UploadDelegate? = nil
    
    public func setUploadDelegate(_ d: UploadDelegate){
        self.uploadDelegate = d
    }
    
    public func unsetUploadDelegate(){
        self.uploadDelegate = nil
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
        self.uploadDelegate?.uploaded(totalBytesSent, total: totalBytesExpectedToSend)
    }
}
