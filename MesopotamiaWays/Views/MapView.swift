//
//  MapView.swift
//  MesopotamiaWays
//
//  Created by Bilal AYDIN on 24.11.2025.
//

import SwiftUI
import MapKit

// MARK: - Birleşik Model
struct MapAnnotationItem: Identifiable {
    let id: String
    let name: String
    let coordinate: CLLocationCoordinate2D
    let color: Color
    let iconName: String
    let category: String
    var place: PlacesModel?
    var hotel: HotelsModel?
    var restaurant: RestaurantsModel?
}

// MARK: - Harita Görünümü
struct MapView: View {
    let places: [PlacesModel]
    let hotels: [HotelsModel]
    let restaurants: [RestaurantsModel]
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.3132, longitude: 40.7353),
        span: MKCoordinateSpan(latitudeDelta: 0.3, longitudeDelta: 0.3)
    )
    @State private var showLegend = false
    @State private var selectedHotel: HotelsModel?
    @State private var selectedRestaurant: RestaurantsModel?
    
    // Tüm annotation'ları birleştir
    var allAnnotations: [MapAnnotationItem] {
        var items: [MapAnnotationItem] = []
        
        // Tarihi yerler - KIRMIZI
        for place in places {
            items.append(MapAnnotationItem(
                id: "place_\(place.id)",
                name: place.name,
                coordinate: place.locationCordinates,
                color: .red,
                iconName: "building.columns.fill",
                category: "Tarihi Yer",
                place: place,
                hotel: nil,
                restaurant: nil
            ))
        }
        
        // Oteller - YEŞİL
        for hotel in hotels {
            items.append(MapAnnotationItem(
                id: "hotel_\(hotel.id)",
                name: hotel.hotelName,
                coordinate: hotel.location,
                color: .green,
                iconName: "bed.double.fill",
                category: "Otel",
                place: nil,
                hotel: hotel,
                restaurant: nil
            ))
        }
        
        // Restoranlar - TURUNCU
        for restaurant in restaurants {
            items.append(MapAnnotationItem(
                id: "restaurant_\(restaurant.id)",
                name: restaurant.name,
                coordinate: restaurant.location,
                color: .orange,
                iconName: "fork.knife",
                category: "Restoran",
                place: nil,
                hotel: nil,
                restaurant: restaurant
            ))
        }
        
        return items
    }
    
    var body: some View {
        ZStack {
            // HARİTA
            Map(coordinateRegion: $region, annotationItems: allAnnotations) { item in
                MapAnnotation(coordinate: item.coordinate) {
                    // Tarihi yerler için NavigationLink
                    if item.category == "Tarihi Yer", let place = item.place {
                        NavigationLink(destination: PlaceDetailView(place: place)) {
                            AnnotationView(item: item)
                        }
                    } else {
                        // Otel ve Restoranlar için Button
                        Button(action: {
                            handleAnnotationTap(item: item)
                        }) {
                            AnnotationView(item: item)
                        }
                    }
                }
            }
            
            // LEGEND POPUP
            if showLegend {
                Color.black.opacity(0.3)
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        withAnimation(.spring()) {
                            showLegend = false
                        }
                    }
                
                LegendView(showLegend: $showLegend)
                    .transition(.scale.combined(with: .opacity))
            }
        }
        .navigationTitle("Harita")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            // LEGEND BUTONU - NavigationBar'a ekle
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    withAnimation(.spring()) {
                        showLegend.toggle()
                    }
                }) {
                    Image(systemName: "info.circle.fill")
                        .font(.title3)
                        .foregroundColor(.blue)
                }
            }
        }
        .sheet(item: $selectedHotel) { hotel in
            HotelDetailView(hotel: hotel)
        }
        .sheet(item: $selectedRestaurant) { restaurant in
            RestaurantDetailView(restaurant: restaurant)
        }
    }
    
    private func handleAnnotationTap(item: MapAnnotationItem) {
        if item.category == "Otel", let hotel = item.hotel {
            selectedHotel = hotel
        } else if item.category == "Restoran", let restaurant = item.restaurant {
            selectedRestaurant = restaurant
        }
    }
}

// MARK: - Annotation Görünümü (Yeniden Kullanılabilir)
struct AnnotationView: View {
    let item: MapAnnotationItem
    
    var body: some View {
        VStack(spacing: 2) {
            ZStack {
                Circle()
                    .fill(item.color)
                    .frame(width: 32, height: 32)
                
                Image(systemName: item.iconName)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
            }
            
            Text(item.name)
                .font(.system(size: 10, weight: .medium))
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(Color.white)
                .cornerRadius(8)
                .shadow(radius: 1)
                .fixedSize(horizontal: true, vertical: false)
        }
    }
}

// MARK: - Legend (Açıklama) Görünümü
struct LegendView: View {
    @Binding var showLegend: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Harita Açıklamaları")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Button(action: {
                    withAnimation(.spring()) {
                        showLegend = false
                    }
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.bottom, 8)
            
            // AÇIKLAMA MADDELERİ
            LegendItem(color: .red, icon: "building.columns.fill", text: "Tarihi Yerler")
            LegendItem(color: .green, icon: "bed.double.fill", text: "Oteller")
            LegendItem(color: .orange, icon: "fork.knife", text: "Restoranlar")
            LegendItem(color: .brown, icon: "camera.fill", text: "Fotoğraf Noktaları")
            
            Text("Renkler ve ikonlar ile farklı kategorileri kolayca ayırt edebilirsiniz.")
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.top, 8)
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(radius: 10)
        .padding(.horizontal, 20)
        .frame(maxWidth: 300)
    }
}

// MARK: - Legend Öğesi
struct LegendItem: View {
    let color: Color
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(color)
                    .frame(width: 32, height: 32)
                
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
            }
            
            Text(text)
                .font(.subheadline)
                .foregroundColor(.primary)
            
            Spacer()
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    NavigationView {
        MapView(places: placesss, hotels: hotels, restaurants: resturans)
    }
}
