//
//  MapMarkerView.swift
//  Pharmacy
//
//  Created by Arman on 21.09.2023.
//

import SwiftUI

struct MapMarkerView: View {
    
    
    var body: some View {
        
        VStack (spacing: 0) {
            Image(systemName: "pills.circle.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 30, height: 30)
                .font(.headline)
                .foregroundColor(.white)
                .padding(6)
                .background(Color.accentColor)
                .cornerRadius(36)
            
            Image(systemName: "triangle.fill")
                .resizable()
                .scaledToFit()
                .foregroundColor(.accentColor)
                .frame(width:10 , height: 10)
                .rotationEffect(Angle(degrees: 180))
                .offset(y:-3)
//                .padding(.bottom, 40)
        }

                  
    }
}

struct MapMarkerView_Previews: PreviewProvider {
    static var previews: some View {
        MapMarkerView()
    }
}
