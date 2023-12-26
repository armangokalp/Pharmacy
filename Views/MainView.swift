//
//  MainView.swift
//  Pharmacy
//
//  Created by Arman on 20.09.2023.
//

import SwiftUI

struct MainView: View {
    
    @EnvironmentObject var vm: locationViewModel
    @ObservedObject var globalState = GlobalState.shared
    
    var body: some View
    {
        ZStack {
                
            TabView (selection: $globalState.tabViewTag) {
                
                
                if #available(iOS 16.0, *) {
                    locationView
                        .toolbarBackground(.visible, for: .tabBar)
                    
                    searchView
                        .toolbarBackground(.visible, for: .tabBar)
                    
                    nearestPahramicesView
                        .toolbarBackground(.visible, for: .tabBar)
                    
                    medicineTracker
                        .toolbarBackground(.visible, for: .tabBar)
                    
                    settingsView
                        .toolbarBackground(.visible, for: .tabBar)
                } else {
                    locationView
                    
                    searchView
                    
                    nearestPahramicesView
                    
                    medicineTracker
                    
                    settingsView
                }
            }
        }
    }
}

extension MainView {
    
    private var locationView: some View {
        LocationView()
            .tabItem {
                Image(systemName: "map")
                Text("Harita")
            }
            .tag(0)
    }
    
    private var searchView: some View {
        SearchView()
            .tabItem {
                Image(systemName: "magnifyingglass")
                Text("Arama")
            }
            .tag(1)
    }
    
    private var nearestPahramicesView: some View {
        NearestPharmaciesView()
            .tabItem {
                Image(systemName: "cross.fill")
                Text("Yakın Eczaneler")
            }
            .tag(2)
            .badge(!vm.selectionHeader1Active ? vm.nearestLocations.filter { $0.isNobetci }.count : vm.nearestLocations.count)
    }
    
    private var medicineTracker: some View {
        MedicineTrackerView()
            .tabItem {
                Image(systemName: "pills")
                Text("İlaç Listem")
            }
            .tag(3)
    }
    
    private var settingsView: some View {
        SettingsView()
            .tabItem {
                Image(systemName: "gear")
                Text("Ayarlar")
            }
            .tag(4)
    }
    
}


struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
            .environmentObject(locationViewModel())
    }
}
