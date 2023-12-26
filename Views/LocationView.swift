//
//  LocationView.swift
//  Pharmacy
//
//  Created by Arman on 19.09.2023.
//

import SwiftUI
import MapKit
import UIKit

struct LocationView: View {
    
    @EnvironmentObject var vm: locationViewModel
    @StateObject var globalState = GlobalState.shared
    
    @State var tapOnMarker: Bool = false
    
    var body: some View
    {
        MapView
    }
    
}

extension LocationView {
    

    private var MapView: some View {
        ZStack {
            if (!vm.isLoading) {
                let adjustedAnnotations = vm.adjustAnnotations(vm.locations)
                Map(coordinateRegion: $vm.mapRegion,
                    showsUserLocation: true,
                    userTrackingMode: .constant(.none),
                    annotationItems: adjustedAnnotations,
                    annotationContent: { location in
                    MapAnnotation(coordinate: location.coordinates) {
                        MapMarkerView()
                            .scaleEffect(vm.mapLocation == location && globalState.showHeader ? 1 : 0.7)
                            .shadow(radius: 10)
                            .onTapGesture {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                    //                                vm.city = vm.mapLocation.city
                                    vm.mapLocation = location
                                }
                                withAnimation(.easeInOut) {
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                        globalState.showHeader = true
                                    }
                                }
                            }
                            .opacity((!vm.selectionHeader1Active && !location.isNobetci) || !vm.isCoordinate(location.coordinates, inside: vm.mapRegion) ? 0 : location.isNobetci ? 10 : 0.99)
                    }
                })
                .conditionalSafeArea()
                .gesture(
                    DragGesture()
                        .onChanged { _ in
                            disableFocus()
                        }
                )
                .onTapGesture {
                    disableFocus()
                    closeHeader()
                }
            }
            else {ProgressView()}
            
            VStack {
                header
                selectionHeader
                
                Spacer()
                
                HStack {
                    Spacer()
                    centerLocationButton
                }
                .padding(.bottom, 80)
                .padding(.trailing, 30)
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    vm.mapRegion.center.latitude += 0.0001
                    print("dındındınd")
                }
            }
            
        }
        .onDisappear {
            disableFocus()
        }
        .alert(isPresented: $vm.showAlert) {
            Alert(title: Text("Konum Erişimi Gerekli"),
                  message: Text("Nöbetçi Eczane, size en yakın eczane ve nöbetçi eczaneleri gösterebilmek için Tam Konum'a ihtiyaç duyar. Uygulamanın hizmetlerinden en iyi şekilde faydalanabilmek için Ayarlar'a gidin ve Nöbetçi Eczane için Tam Konum'u açın."),
                  primaryButton: .cancel(Text("Şimdi Değil")) {
                globalState.tabViewTag = 1
            }, secondaryButton: .default(Text("Ayarlar'a Git")) {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                                  UIApplication.shared.open(url, options: [:], completionHandler: nil)
                              }
            })
        }
    }
    
    // Ana header
    private var header: some View {
        VStack {
            Button(action: vm.toggleHeader) {
                
                VStack {
                    VStack  {
                        Text(globalState.formatText(vm.mapLocation.name))
                            .font(.title2)
                            .fontWeight(.black)
                        Text(globalState.formatText(vm.mapLocation.districtName).prefix(15) + ", " + vm.mapLocation.cityName)
                            .font(.subheadline)
                    }
                    .frame(height: 55)
                    .animation(.none, value: vm.mapLocation)
                    .frame(maxWidth: .infinity)
                    if (vm.expandHeader) {
                        ExtendedHeaderView()
                            .frame(maxHeight: 300)
                            .onTapGesture {
                                
                            }
                    }
                    Image(systemName: "chevron.down")
                        .rotationEffect(Angle(degrees: vm.expandHeader ? 180 : 0))
                    Image(systemName: "")
                        .padding(.bottom)
                }
                .foregroundColor(Color("txt1"))
                
            }
            
            
        }
        .background(.regularMaterial)
        .cornerRadius(10)
        .shadow(radius: 20, x: 0, y: 15)
        .padding()
        .offset(y: !globalState.showHeader ? -400 : 20)
        .animation(.easeInOut, value: !globalState.showHeader)
    }
    
    
    // Nöbetçi ezaneleri göster / Tüm eczaneleri göster
    private var selectionHeader: some View {
        HStack {
            Spacer()
            // Tüm eczaneleri göster
            _selectionHeader(text: "Tümünü Göster", value: vm.selectionHeader1Active)
            Spacer()
            // Nöbetçi eczaneleri göster
            _selectionHeader(text: "Nöbetçiler Göster", value: !vm.selectionHeader1Active)
            Spacer()
        }
    }
    func _selectionHeader(text: String, value: Bool) -> some View {
        
        return Button(action: {
            if (!value) {vm.toggleSelectionHeader()}
        }) {
            Text(text)
                .font(.footnote)
                .padding(7)
                .frame(height: 32)
                .frame(width: 150)
        }
        .background(.regularMaterial)
        .cornerRadius(10)
        .foregroundColor(Color("txt1"))
        .shadow(radius: 10)
        .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(value ? Color.red : Color.clear, lineWidth: 2)
                )
        .offset(y: !globalState.showHeader ? -80 : -600)
        .animation(.spring(), value: !globalState.showHeader)
    }
    //____________________________________________________________
    
    
    // Konum ortalama tuşu
    private var centerLocationButton: some View {
        Button(action: {
            closeHeader()
            vm.shouldCenterOnUser = true
            if let userLocation = vm.userLocation {
                vm.updateMapRegion(location: userLocation)
            }
        }) {
            Image(systemName: "location.fill.viewfinder")
                .resizable()
                .scaledToFit()
                .frame(width: 25, height: 25)
                .padding(12)
                .background(.thickMaterial)
                .clipShape(Circle())
                .overlay(Circle().stroke(lineWidth: 2))
                .shadow(radius: 10)
                .foregroundColor(vm.isLocationCenter ? .red : .gray)
        }
    }
    
    
    func closeHeader() {
        withAnimation(.easeInOut) {
            globalState.showHeader = false
            vm.expandHeader = false
        }
    }
    
    func disableFocus() {
        vm.isLocationCenter = false
        vm.shouldCenterOnUser = false
    }
    

}



struct LocationView_Previews: PreviewProvider {
    static var previews: some View {
        LocationView()
            .environmentObject(locationViewModel())
    }
}
