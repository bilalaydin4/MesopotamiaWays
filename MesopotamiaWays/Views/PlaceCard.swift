//
//  PlaceCard.swift
//  MesopotamiaWays
//
//  Created by Bilal AYDIN on 24.11.2025.
//


import SwiftUI

// MARK: - Yer Kartı Bileşeni
struct PlaceCard: View {
    let place: PlacesModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // GÖRSEL
            Image(place.imageName[0])
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(height: 160)
                .clipped()
                .overlay(
                    LinearGradient(
                        gradient: Gradient(colors: [.clear, .black.opacity(0.3)]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .overlay(
                    VStack {
                        Spacer()
                        HStack {
                            Text(place.age)
                                .font(.caption)
                                .padding(6)
                                .background(Color.black.opacity(0.7))
                                .foregroundColor(.white)
                                .cornerRadius(4)
                            Spacer()
                        }
                        .padding(8)
                    }
                )
            
            // İÇERİK
            VStack(alignment: .leading, spacing: 8) {
                Text(place.name)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Text(place.history.prefix(120) + "...")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(3)
                
                HStack {
                    Image(systemName: "location.circle")
                        .foregroundColor(.orange)
                    Text("\(place.coordinates.latitude, specifier: "%.4f"), \(place.coordinates.longitude, specifier: "%.4f")")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal, 12)
            .padding(.bottom, 12)
        }
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .gray.opacity(0.2), radius: 4, x: 0, y: 2)
    }
}

#Preview {
    PlaceCard(place: mardin)
}

