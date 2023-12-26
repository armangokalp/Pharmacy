import SwiftUI
import MapKit

struct ExtendedHeaderView: View {
    
    @EnvironmentObject var vm: locationViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            
            VStack(alignment: .center, spacing: 8) {
                VStack (alignment: .leading, spacing: 10) {
                    Text("\(vm.mapLocation.address)")
                    let isOpen = vm.mapLocation.isOpen || vm.mapLocation.isNobetci
                    HStack {
                        Text("Bu Eczane Şu Anda \(isOpen ? "Açık" : "Kapalı")")
                        Spacer()
                        Image(systemName: "\(isOpen ? "checkmark.seal" : "nosign")")
                    }
                    .foregroundColor(isOpen ? .green : .red)
                    
                    Spacer()
                    
                    HStack {
                        Text("Puan: ")
                        ZStack {
                            RoundedRectangle(cornerRadius: 5)
                                .background(.thinMaterial)
                                .frame(width: 160, height: 40)
                                .opacity(0.15)
                            HStack {
                                ForEach(0..<5) { i in
                                    ZStack {
                                        Image(systemName: "star")
                                            .scaleEffect(1)
                                        if (vm.mapLocation.rating - Double(i) >= 0.2) {
                                            Image(systemName: "star.fill")
                                                .scaleEffect(0.6)
                                                .foregroundColor(.yellow)
                                                .opacity(0.6)

                                        }
                                    }
                                }
                            }
                        }
                    }
                    
                    Spacer()
                }
                
                HStack (spacing: 20) {
                    Button("Haritalarda Aç") {
                        if let encodedName = vm.mapLocation.name.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) {
                            let appleMapsURL = URL(string: "http://maps.apple.com/?ll=\(vm.mapLocation.coordinates.latitude),\(vm.mapLocation.coordinates.longitude)&q=\(encodedName)")
                            if let url = appleMapsURL {
                                UIApplication.shared.open(url)
                            } else {
                                print("Invalid URL")
                            }
                        }

                    }
                    .padding()
                    .foregroundColor(.white)
                    .background(Color.blue)
                    .cornerRadius(8)
                    
                    let phoneNumber = vm.mapLocation.phone_number.filter { "0123456789".contains($0) }
                    let buttonActive = phoneNumber.count < 5
                    Button(action: {
                        if let url = URL(string: "tel://\(phoneNumber)") {
                            if UIApplication.shared.canOpenURL(url) {
                                UIApplication.shared.open(url, options: [:], completionHandler: nil)
                            }
                        }
                    }) {
                        HStack {
                            Text("Ara")
                            Image(systemName: "teletype.circle")
                        }
                    }
                    .padding()
                    .foregroundColor(!buttonActive ? .white : .white.opacity(0.6))
                    .background(!buttonActive ? Color.green: Color.gray)
                    .cornerRadius(8)
                    .disabled(buttonActive)

                }
                
            }
            .padding()
            .background(Color("txt2"))
            .cornerRadius(8)
        }
        .background(RoundedRectangle(cornerRadius: 8).stroke(Color.gray, lineWidth: 1))
        .padding()
    }
}

