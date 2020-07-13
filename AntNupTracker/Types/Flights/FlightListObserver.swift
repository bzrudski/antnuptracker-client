//
// FlightListObserver.swift
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

/// Observer for the flight list. Callbacks exist for each list event, including callbacks for handling errors.
protocol FlightListObserver {
    func flightListRead()
    func flightListCleared()
    func flightListReadError(e: FlightList.ReadErrors)
    func flightListReadMore(count: Int)
    func flightListReadMoreError(e: FlightList.ReadErrors)
    func flightListGotNewFlights(n: Int)
    func flightListGotNewFlightsWithError(e: FlightList.GetNewFlightsErrors)
    func flightListChanged()
}

protocol ChangeLogObserver{
    func flightListGotChangelog(c: [Changelog])
    func flightListGotChangelogError(e: ChangelogManager.ChangelogErrors)
}

protocol WeatherObserver{
    func flightListGotWeather(w:Weather)
    func flightListGotWeatherError(e: WeatherManager.WeatherErrors)
}

protocol FlightChangeObserver{
    func flightListAdded()
    func flightListAddedError(e: FlightList.AddEditErrors)
    func flightListEdited()
    func flightListEditedError(e: FlightList.AddEditErrors)
}

protocol FlightFetchDetailObserver{
    func flightListGotFlight(f: Flight)
    func flightListGotFlightError(e: FlightList.ReadErrors)
}

protocol FlightCommentObserver{
    func flightListCreatedComment(c: Comment)
    func flightListCreatedCommentError(c: Comment, e: CommentManager.CommentErrors)
}

protocol FlightValidationObserver{
    func flightListValidatedFlight(id:Int)
    func flightListValidatedFlightError(id:Int, e:FlightValidationManager.ValidateErrors)
}

protocol FlightImageObserver{
    func flightListGotImage(_ image: EncodableImage)
    func flightListGotImageError(_ e:FlightImageManager.ImageErrors)
}

protocol FlightListFilteringObserver{
    func flightListFilteringChanged()
    func flightListFilteringCleared()
}
