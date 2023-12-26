//
//  PharmacyApp.swift
//  Pharmacy
//
//  Created by Arman on 18.09.2023.
//

import SwiftUI
import GoogleMaps

@main
struct PharmacyApp: App {
    
    @StateObject var vm = locationViewModel()
    
    var body: some Scene {
        WindowGroup {
            MainView()
                .environmentObject(vm)
        }
    }
}
