# antnuptracker-client
Client app for AntNupTracker

Copyright (C) 2020 Abouheif Lab

Welcome to the repository for the `AntNupTracker` app. A contribution guide is coming shortly.

This app is a tool for browsing records of [ant nuptial flights](https://www.antnuptialflights.com/about/) and reporting new flights from the field. Visit our website at https://www.antnuptialflights.com for more details. For the server-side application that manages the database of ant nuptial flights, please go to [this repository](https://github.com/bzrudski/antnuptracker-server/).

Our app is licensed under the GNU GPLv3 with App Store Exception (see `COPYING`). Therefore, the app is open source, but the binary can still be distributed through Apple's App Store without violating their terms. (All source files say GPL, but the App Store Exception is applied to all files in this project in order to not defeat the purpose of this project.)

In order to build, clone this repository and open the `Xcode` project. You may need to tweak a few settings. If you would like to test your modifications against a custom version of the backend, make sure that you change the `baseURL` in `URLManager.swift`.

IOS is a trademark or registered trademark of Cisco in the U.S. and other countries and is used under license.

App Store, Xcode are trademarks of Apple Inc., registered in the U.S. and other countries.