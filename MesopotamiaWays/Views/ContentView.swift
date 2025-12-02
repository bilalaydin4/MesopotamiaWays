//
//  ContentView.swift
//  MesopotamiaWays
//
//  Created by Bilal AYDIN on 24.11.2025.
//

import SwiftUI
import MapKit

struct ContentView: View {
    let places: [PlacesModel] = [mardin, dara, zinciriyeMedresesi, kasimiyeMedresesi]
    let hotels: [HotelsModel] = [buyukMardinOteli, yayGrand]
    let restaurants: [RestaurantsModel] = [HamdaniRestaurant, leyli]
    
    @State private var searchText = ""
    
    // Filtrelenmiş yerler
    var filteredPlaces: [PlacesModel] {
        if searchText.isEmpty {
            return places
        } else {
            return places.filter { place in
                place.name.localizedCaseInsensitiveContains(searchText) ||
                place.history.localizedCaseInsensitiveContains(searchText) ||
                place.age.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var body: some View {
        TabView {
            // TAB 1: KEŞFET
            NavigationView {
                ScrollView {
                    VStack(spacing: 20) {
                        
                        // ARAMA ÇUBUĞU
                        VStack(spacing: 16) {
                            HStack {
                                Image(systemName: "magnifyingglass")
                                    .foregroundColor(.secondary)
                                
                                TextField("Mardin, Dara, Medreseler...", text: $searchText)
                                    .textFieldStyle(PlainTextFieldStyle())
                                
                                if !searchText.isEmpty {
                                    Button(action: {
                                        searchText = ""
                                    }) {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }
                            .padding(12)
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                            .padding(.horizontal)
                            
                            // Arama sonuç sayısı
                            if !searchText.isEmpty {
                                HStack {
                                    Text("\(filteredPlaces.count) sonuç bulundu")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    Spacer()
                                }
                                .padding(.horizontal)
                            }
                        }
                        
                        // YAKININIZDAKİ YERLER
                        VStack(alignment: .leading) {
                            HStack {
                                Text(searchText.isEmpty ? "Keşfedilecek Yerler" : "Arama Sonuçları")
                                    .font(.title2)
                                    .fontWeight(.semibold)
                                
                                Spacer()
                                
                                Text("\(filteredPlaces.count) yer")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.horizontal)
                            
                            // SONUÇLAR
                            if filteredPlaces.isEmpty {
                                VStack(spacing: 16) {
                                    Image(systemName: "magnifyingglass")
                                        .font(.system(size: 50))
                                        .foregroundColor(.secondary)
                                    
                                    Text("'\(searchText)' için sonuç bulunamadı")
                                        .font(.headline)
                                        .foregroundColor(.secondary)
                                    
                                    Text("Farklı bir anahtar kelime deneyin")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                .frame(height: 200)
                                .padding()
                            } else {
                                LazyVStack(spacing: 16) {
                                    ForEach(filteredPlaces) { place in
                                        NavigationLink(destination: PlaceDetailView(place: place)) {
                                            PlaceCard(place: place)
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                    }
                }
                .navigationTitle("Mardin")
            }
            .tabItem {
                Image(systemName: "binoculars")
                Text("Keşfet")
            }
            
            // TAB 2: HARİTA
            NavigationView {
                MapView(places: places, hotels: hotels, restaurants: restaurants)
                    .navigationTitle("Harita")
                    .edgesIgnoringSafeArea(.bottom)
            }
            .tabItem {
                Image(systemName: "map")
                Text("Harita")
            }
            
            // TAB 3: OTEL
            NavigationView {
                HotelsView()
                    .navigationTitle("Oteller")
            }
            .tabItem {
                Image(systemName: "building.2")
                Text("Oteller")
            }
            
            // TAB 4: RESTORANLAR
            NavigationView {
                RestaurantsView()
                    .navigationTitle("Restoranlar")
            }
            .tabItem {
                Image(systemName: "fork.knife")
                Text("Restoranlar")
            }
        }
        .accentColor(Color(red: 0.85, green: 0.48, blue: 0.27))
    }
}

#Preview {
    ContentView()
}
