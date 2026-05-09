//
//  TourDetailView.swift
//  MesopotamiaWays
//
//  Created by Bilal AYDIN on 4.12.2025.
//
//


import SwiftUI
import CoreLocation
import MapKit

struct TourDetailView: View {
    let tour: ToursModel
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Üst kısım - Logo ve Başlık
                VStack(alignment: .center, spacing: 15) {
                    Image(tour.logoImage)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 120)
                        .padding(.top)
                    
                    Text(tour.name)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.primary)
                    
                    HStack {
                        Image(systemName: "calendar")
                            .foregroundColor(.blue)
                        Text("Tur Tarihi:")
                            .fontWeight(.semibold)
                        Text(tour.timeToGo)
                    }
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                }
                .padding(.horizontal)
                .frame(maxWidth: .infinity)
                
                Divider()
                    .padding(.horizontal)
                
                // Gidilecek Yerler Listesi
                VStack(alignment: .leading, spacing: 15) {
                    Text("Gidilecek Yerler")
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.horizontal)
                    
                    ForEach(tour.placesToGo) { place in
                        PlaceCardView(place: place)
                    }
                }
                
                Divider()
                    .padding(.horizontal)
                
                // Harita Gösterimi
                VStack(alignment: .leading, spacing: 15) {
                    Text("Tur Lokasyonu")
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.horizontal)
                    
                    // Harita için region oluştur
                    let region = MKCoordinateRegion(
                        center: tour.location,
                        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                    )
                    
                    // iOS 17+ Map kullanımı
                    Map(coordinateRegion: .constant(region),
                        annotationItems: [tour]) { tour in
                        MapAnnotation(coordinate: tour.location) {
                            VStack {
                                Image(systemName: "flag.circle.fill")
                                    .font(.title)
                                    .foregroundColor(.blue)
                                
                                Text("Tur Başlangıç")
                                    .font(.caption2)
                                    .padding(4)
                                    .background(Color(.systemBackground).opacity(0.8))
                                    .cornerRadius(4)
                            }
                        }
                    }
                        .frame(height: 200)
                        .cornerRadius(12)
                        .padding(.horizontal)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                }
                
                // Başlangıç Noktası
                VStack(alignment: .leading, spacing: 10) {
                    Text("Başlangıç Noktası")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .padding(.horizontal)
                    
                    HStack {
                        Image(systemName: "mappin.circle.fill")
                            .foregroundColor(.red)
                        VStack(alignment: .leading) {
                            Text(tour.startPointCoordinates.title)
                                .font(.body)
                            Text("\(String(format: "%.6f", tour.startPointCoordinates.latitude)), \(String(format: "%.6f", tour.startPointCoordinates.longitude))")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.horizontal)
                }
                
                // Butonlar
                VStack(spacing: 15) {
                    // İletişime Geç Butonu
                    Button(action: {
                        // İletişim fonksiyonu buraya gelecek
                        print("İletişime Geç butonuna tıklandı")
                    }) {
                        HStack {
                            Image(systemName: "phone.circle.fill")
                            Text("İletişime Geç")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                    
                    // Rezervasyon Butonu
                    Button(action: {
                        // Rezervasyon fonksiyonu buraya gelecek
                        print("Rezervasyon Yap butonuna tıklandı")
                    }) {
                        HStack {
                            Image(systemName: "calendar.badge.plus")
                            Text("Rezervasyon Yap")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                }
                .padding(.horizontal)
                .padding(.top, 10)
                
                Spacer(minLength: 30)
            }
            .padding(.vertical)
        }
        .navigationTitle("Tur Detayları")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// Place Card View Component
struct PlaceCardView: View {
    let place: PlacesModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top, spacing: 15) {
                // Yer resmi
                if let firstImage = place.imageName.first {
                    Image(firstImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 80, height: 80)
                        .cornerRadius(8)
                        .clipped()
                }
                
                // Yer bilgileri
                VStack(alignment: .leading, spacing: 5) {
                    Text(place.name)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(place.age)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(place.history.prefix(100) + "...")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                
                Spacer()
                
                // Detay ok işareti
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
                    .padding(.trailing, 5)
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
            .padding(.horizontal)
        }
    }
}

// Tur Listesi View'ı
struct ToursListView: View {
    let tours: [ToursModel]
    
    var body: some View {
        List(tours) { tour in
            NavigationLink(destination: TourDetailView(tour: tour)) {
                TourRowView(tour: tour)
            }
        }
        .navigationTitle("Turlar")
    }
}

// Tur Satır View Component
struct TourRowView: View {
    let tour: ToursModel
    
    var body: some View {
        HStack(spacing: 15) {
            // Tur logosu
            Image(tour.logoImage)
                .resizable()
                .scaledToFill()
                .frame(width: 60, height: 60)
                .cornerRadius(10)
                .clipped()
            
            // Tur bilgileri
            VStack(alignment: .leading, spacing: 5) {
                Text(tour.name)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text("\(tour.placesToGo.count) yer")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                HStack {
                    Image(systemName: "calendar")
                        .font(.caption2)
                    Text(tour.timeToGo)
                        .font(.caption)
                }
                .foregroundColor(.blue)
            }
            
            Spacer()
            
            // Detay ok işareti
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
        }
        .padding(.vertical, 5)
    }
}

// Önizleme
// struct TourDetailView_Previews: PreviewProvider {
//     static var previews: some View {
//         NavigationView {
//             TourDetailView(tour: mardinGap)
//         }
//     }
// }
// 
// struct ToursListView_Previews: PreviewProvider {
//     static var previews: some View {
//         NavigationView {
//             ToursListView(tours: [mardinGap])
//         }
//     }
// }
// 
// #Preview {
//     NavigationStack {
//         TourDetailView(tour: mardinGap)
//     }
// }
