//
//  PlaceCard.swift
//  MesopotamiaWays
//
//  Created by Bilal AYDIN on 24.11.2025.
//


import SwiftUI
import SDWebImageSwiftUI

// MARK: - Yer Kartı Bileşeni
struct PlaceCard: View {
    let place: PlacesModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if let firstImage = place.imageName.first, let url = URL(string: firstImage) {
                WebImage(url: url)
                    .resizable()
                    .indicator(.activity)
                    .transition(.fade(duration: 0.5))
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
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 160)
                    .overlay(Image(systemName: "photo").foregroundColor(.gray))
            }
            
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
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(12)
        .shadow(color: Color.primary.opacity(0.15), radius: 4, x: 0, y: 2)
    }
}

// #Preview {
//     PlaceCard(place: mardin)
//         .padding()
//         .previewLayout(.sizeThatFits)
// }
