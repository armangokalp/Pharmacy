
import SwiftUI
import MapKit
import CoreLocation
import CoreLocationUI

struct SearchView: View {
    
    @State private var searchText = ""
    @StateObject var globalState = GlobalState.shared
    @EnvironmentObject var vm: locationViewModel
    
    
    var body: some View {
        VStack {
            Text("Arama")
                .multilineTextAlignment(.center)
            SearchBar(text: $searchText)
                .padding(.top, 10)
                .padding(.horizontal, 10)
            
            List {
                ForEach(vm.searchItems, id: \.self) { item in
                    search(name: item.name, address: item.address!)
                        .onTapGesture {
                            guard let coordinate = item.coordinate else { return }
                            vm.mapLocation.coordinates = coordinate
                            goToSearchResult()
                        }
                }
            }
            .listStyle(PlainListStyle())
        }
        .padding()
    }
}


extension SearchView {
    
    func search(name: String, address: String) -> some View {
        HStack {
            
            VStack (alignment: .leading) {
                Text(name)
                    .fontWeight(.bold)
                Text(address)
                    .fontWeight(.light)
            }
            Spacer()
            Image(systemName: "arrow.counterclockwise")
                .opacity(0.6)
        }
        .opacity(0.7)
    }
    
    func goToSearchResult() {
        globalState.tabViewTag = 0
        globalState.showHeader = false
        vm.selectionHeader1Active = true
        vm.isLocationCenter = false
        vm.shouldCenterOnUser = false
        vm.searchItems = []
    }
    
}


struct SearchBar: View {
    
    @Binding var text: String
    @FocusState var inFocus: Bool
    @ObservedObject var globalState = GlobalState.shared
    @EnvironmentObject var vm: locationViewModel

    
    var body: some View {
        HStack {
            TextField("Eczane veya yer ara...", text: $text)
                .submitLabel(.done)
                .onChange(of: inFocus) { newValue in
                    if !newValue && !self.text.isEmpty {
                        self.text = ""
                        inFocus = false
                        globalState.tabViewTag = 0
                    }
                }
                .onChange(of: text) { newValue in
                    if !newValue.isEmpty {
                        vm.fetchPlaces(with: text)
                    }
                }
                .onSubmit {
                    if !vm.searchItems.isEmpty {
                        guard let coordinate = vm.searchItems[0].coordinate else { return }
                        vm.mapLocation.coordinates = coordinate
                        goToSearchResult()
                    }
                }
                .padding(7)
                .padding(.horizontal, 25)
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .focused($inFocus)
                .overlay(
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                            .padding(.leading, 8)
                        
                        if inFocus {
                            Button(action: {
                                self.text = ""
                            }) {
                                Image(systemName: "multiply.circle.fill")
                                    .foregroundColor(.gray)
                                    .padding(.trailing, 8)
                            }
                        }
                        else {
                            
                        }
                    }
                )
                .onTapGesture {
                    self.inFocus = true
                }
            
            if inFocus {
                Button(action: {
                    self.inFocus = false
                    self.text = ""

                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                }) {
                    Text("İptal")
                        .foregroundColor(Color("txt1"))
                }
                .padding(.trailing, 10)
                .transition(.move(edge: .trailing))
            }
        }
        .onAppear {
            inFocus = true
        }
    }
    
    
    func goToSearchResult() {
        globalState.tabViewTag = 0
        globalState.showHeader = false
        vm.selectionHeader1Active = true
        vm.isLocationCenter = false
        vm.shouldCenterOnUser = false
        vm.searchItems = []
    }
}


extension DispatchWorkItem {
    func perform(afterDelay seconds: Double) {
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds, execute: self)
    }
}



struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        SearchView()
    }
}
