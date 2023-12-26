//
//  FavoritesView.swift
//  Pharmacy
//
//  Created by Arman on 20.09.2023.
//

import SwiftUI

struct NearestPharmaciesView: View {
    
    @EnvironmentObject var vm: locationViewModel
    @StateObject var globalState = GlobalState.shared
    @State var i: Int = 1
    @State var isLoading: Bool = false
    
    var body: some View {
        VStack {
            Text("Yakınımdaki Eczaneler")
            
            Picker("", selection: $vm.selectionHeader1Active) {
                Text("Tüm Eczaneler")
                    .tag(true)
                Text("Nöbetçi Eczaneler")
                    .tag(false)
            }
            .pickerStyle(SegmentedPickerStyle())
            .onChange(of: vm.selectionHeader1Active) { newValue in
                fetchData()
                globalState.showHeader = false
            }
            
            Spacer()
            
            if isLoading {
                ProgressView()
            }
            else if ((vm.nearestLocations.count > 0 && vm.selectionHeader1Active) || (vm.nearestLocations.filter { $0.isNobetci }.count != 0 && !vm.selectionHeader1Active)) {
                List {
                    ForEach(vm.nearestLocations) { location in
                        if (!vm.selectionHeader1Active) {
                            if (location.isNobetci) {
                                LocationsRowView(location: location)
                            }
                        }
                        else {
                            LocationsRowView(location: location)
                        }
                    }
                }
            }
            else if (!vm.selectionHeader1Active) {
                Text("Yakınınızda nöbetçi eczane bulunmamaktadır.")
                    .font(.callout)
            }
            else {
                Text("Yakınınızda eczane bulunmamaktadır.")
                    .font(.callout)
            }
            
            Spacer()
        }
        .onAppear {
            fetchData()
        }
        
    }
    
}


extension NearestPharmaciesView {
    
    func LocationsRowView(location: Location) -> some View {
        HStack {
            if !location.imageNames.isEmpty, let url = URL(string: location.imageNames) {
                AsyncImage(url: url, placeholder: Image(systemName: "Eczane"))
                    .frame(width: 45, height: 45)
                    .cornerRadius(10)
            }
            else {
                Image("Eczane")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 45, height: 45)
                    .cornerRadius(10)
            }

            
            VStack (alignment: .leading) {
                Text(globalState.formatText(location.name))
                    .font(.headline)
                Text(globalState.formatText(location.districtName).prefix(15) + ", " + globalState.formatText(location.cityName))
                    .font(.subheadline)
            }
            
            Spacer()
            
            Text(String(format: "%.1f km uzaklıkta", location.distance))
                .font(.caption)
                

        }
        .onTapGesture {
            guard vm.nearestLocations.count >= i else {return}
            vm.fetchPharmacies()
            globalState.tabViewTag = 0
            globalState.showHeader = true
            vm.isLocationCenter = false
            vm.shouldCenterOnUser = false
            withAnimation() {
                DispatchQueue.main.async {
                    vm.mapLocation = location
                }
            }
        }
    }
    
}




extension NearestPharmaciesView {
    
    func fetchData() {
        isLoading = true
        
        DispatchQueue.global().async {
            Thread.sleep(forTimeInterval: 0.5)
            
            DispatchQueue.main.async {
                isLoading = false
            }
        }
    }
    
}

struct NearestPharmaciesView_Previews: PreviewProvider {
    static var previews: some View {
        NearestPharmaciesView()
            .environmentObject(locationViewModel())
    }
}
