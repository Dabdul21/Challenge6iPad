//
//  Challenge6iPadApp.swift
//  Challenge6iPad
//
//  Created by Dayan Abdulla on 3/24/25.
//

import SwiftUI

@main
struct ClothingDesignLibraryApp: App {
    var body: some Scene {
        WindowGroup {
            ARScreen()
        }
    }
}

//NOTE: if u find this error method
//Upgrade's application-identifier entitlement string (B5N4Y94PAG.CoDa.Challenge6iPad) does not match installed application's application-identifier string (664LQW6MNA.CoDa.Challenge6iPad); rejecting upgrade.


// delete the app from the ipad and relunch. the identifiers dont match so it wont launch
