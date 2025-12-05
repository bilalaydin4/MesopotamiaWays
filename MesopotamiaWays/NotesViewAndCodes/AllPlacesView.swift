//
//  AllViews.swift
//  MesopotamiaWays
//
//  Created by Bilal AYDIN on 4.12.2025.
//

import SwiftUI

// Tüm Yerler View
struct AllPlacesView: View {
    var body: some View {
        List(placesss) { place in
            NavigationLink(destination: PlaceDetailView(place: place)) {
                HStack {
                    if let firstImage = place.imageName.first {
                        Image(firstImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 50, height: 50)
                            .cornerRadius(8)
                            .clipped()
                    }
                    
                    VStack(alignment: .leading) {
                        Text(place.name)
                            .font(.headline)
                        Text(place.age)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.leading, 8)
                }
                .padding(.vertical, 4)
            }
        }
        .navigationTitle("Gezilecek Yerler")
        .navigationBarTitleDisplayMode(.large)
    }
}
#Preview {
    NavigationStack {
        AllPlacesView()
    }
}
