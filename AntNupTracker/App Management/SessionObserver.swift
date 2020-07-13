//
// SessionObserver.swift
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

protocol LoginObserver
{
    func loggedIn(s: Session)
    func loggedInWithError(e: Error)
}

protocol LogoutObserver {
    func loggedOut()
    func loggedOutWithError(e: Error)
}

protocol VerifySessionObserver {
    func sessionVerified(session: Session?, valid: Bool, response: [String: String?]?)
    func sessionVerifiedWithError(e: SessionManager.VerificationErrors)
}

protocol SessionClearObserver{
    func sessionCleared()
}
