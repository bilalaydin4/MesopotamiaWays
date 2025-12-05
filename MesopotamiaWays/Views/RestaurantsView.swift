//
//  RestaurantsView.swift
//  MesopotamiaWays
//
//  Created by Bilal AYDIN on 1.12.2025.
//

//
//  RestaurantsView.swift
//  MesopotamiaWays
//
//  Created by Bilal AYDIN on 1.12.2025.
//

import SwiftUI
import MapKit

struct RestaurantsView: View {
    let restaurants: [RestaurantsModel] = [HamdaniRestaurant, leyli]
    @State private var searchText = ""
    @State private var selectedRestaurant: RestaurantsModel?
    
    var filteredRestaurants: [RestaurantsModel] {
        if searchText.isEmpty {
            return restaurants
        } else {
            return restaurants.filter { restaurant in
                restaurant.name.localizedCaseInsensitiveContains(searchText) ||
                restaurant.description.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var body: some View {
        
            VStack(spacing: 0) {
                // ARAMA ÇUBUĞU
                VStack(spacing: 16) {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.secondary)
                        
                        TextField("Restoran ara...", text: $searchText)
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
                    .padding()
                    
                    // Arama sonuç sayısı
                    if !searchText.isEmpty {
                        HStack {
                            Text("\(filteredRestaurants.count) restoran bulundu")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Spacer()
                        }
                        .padding(.horizontal)
                    }
                }
                .background(Color.white)
                
                // RESTORAN LİSTESİ
                ScrollView {
                    VStack(alignment: .leading) {
                        HStack {
                            Text(searchText.isEmpty ? "Restoranlar" : "Arama Sonuçları")
                                .font(.title2)
                                .fontWeight(.semibold)
                            
                            Spacer()
                            
                            Text("\(filteredRestaurants.count) restoran")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(.horizontal)
                        .padding(.top, 20)
                        
                        // RESTORAN KARTLARI
                        if filteredRestaurants.isEmpty && !searchText.isEmpty {
                            VStack(spacing: 16) {
                                Image(systemName: "fork.knife")
                                    .font(.system(size: 50))
                                    .foregroundColor(.secondary)
                                
                                Text("'\(searchText)' için restoran bulunamadı")
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
                                ForEach(filteredRestaurants) { restaurant in
                                    RestaurantCard(restaurant: restaurant)
                                        .onTapGesture {
                                            selectedRestaurant = restaurant
                                        }
                                }
                            }
                            .padding(.horizontal)
                            .padding(.top, 8)
                        }
                    }
                }
                .background(Color(.systemGroupedBackground))
            }
            .navigationTitle("Restoranlar")
            .sheet(item: $selectedRestaurant) { restaurant in
                RestaurantDetailView(restaurant: restaurant)
            }
        }
}

// MARK: - Restoran Kartı Bileşeni
struct RestaurantCard: View {
    let restaurant: RestaurantsModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // GÖRSEL SLIDER
            ZStack(alignment: .bottom) {
                TabView {
                    ForEach(restaurant.image.prefix(3), id: \.self) { imageName in
                        Image(imageName)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 160)
                            .clipped()
                    }
                }
                .frame(height: 160)
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
                .cornerRadius(12)
                
                // RATING ETİKETİ
                VStack {
                    HStack {
                        Spacer()
                        HStack(spacing: 2) {
                            Image(systemName: "star.fill")
                                .font(.caption)
                                .foregroundColor(.orange)
                            Text("4.2")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Color.black.opacity(0.7))
                        .cornerRadius(8)
                    }
                    Spacer()
                }
                .padding(8)
            }
            .frame(height: 160)
            
            // RESTORAN BİLGİLERİ
            VStack(alignment: .leading, spacing: 8) {
                Text(restaurant.name)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Text(restaurant.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                
                // KATEGORİ VE FİYAT
                HStack {
                    HStack {
                        Image(systemName: "tag.fill")
                            .font(.caption2)
                            .foregroundColor(.orange)
                        Text("Geleneksel")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(6)
                    .background(Color.orange.opacity(0.1))
                    .cornerRadius(6)
                    
                    Spacer()
                    
                    HStack(spacing: 4) {
                        ForEach(0..<3) { _ in
                            Text("₺")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Text("₺")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                // KONUM
                HStack {
                    Image(systemName: "location.circle")
                        .foregroundColor(.orange)
                    Text("\(restaurant.coordinate.latitude, specifier: "%.4f"), \(restaurant.coordinate.longitude, specifier: "%.4f")")
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

// MARK: - Restoran Detay Sayfası
struct RestaurantDetailView: View {
    let restaurant: RestaurantsModel
    @State private var currentImageIndex = 0
    @Environment(\.presentationMode) var presentationMode
    @State private var showFullScreenMap = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // IMAGE SLIDER
                    ZStack(alignment: .bottom) {
                        TabView(selection: $currentImageIndex) {
                            ForEach(0..<restaurant.image.count, id: \.self) { index in
                                Image(restaurant.image[index])
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(height: 250)
                                    .clipped()
                                    .tag(index)
                            }
                        }
                        .frame(height: 250)
                        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                        
                        // SLIDER INDICATOR
                        HStack(spacing: 6) {
                            ForEach(0..<restaurant.image.count, id: \.self) { index in
                                Circle()
                                    .fill(index == currentImageIndex ? Color.white : Color.white.opacity(0.5))
                                    .frame(width: 8, height: 8)
                            }
                        }
                        .padding(.bottom, 16)
                        
                        // RESİM SAYACI
                        VStack {
                            HStack {
                                Spacer()
                                Text("\(currentImageIndex + 1)/\(restaurant.image.count)")
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                                    .padding(6)
                                    .background(Color.black.opacity(0.6))
                                    .cornerRadius(8)
                            }
                            Spacer()
                        }
                        .padding()
                    }
                    .frame(height: 250)
                    
                    // RESTORAN BİLGİLERİ
                    VStack(alignment: .leading, spacing: 16) {
                        Text(restaurant.name)
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Text(restaurant.description)
                            .font(.body)
                            .foregroundColor(.secondary)
                            .lineSpacing(4)
                        
                        // KATEGORİLER
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                CategoryTag(icon: "flame.fill", text: "Geleneksel", color: .orange)
                                CategoryTag(icon: "leaf.fill", text: "Taze Malzeme", color: .green)
                                CategoryTag(icon: "person.2.fill", text: "Aile Dostu", color: .blue)
                                CategoryTag(icon: "clock.fill", text: "Hızlı Servis", color: .purple)
                            }
                        }
                        .padding(.vertical, 8)
                        
                        // ÇALIŞMA SAATLERİ
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Çalışma Saatleri")
                                .font(.headline)
                            
                            HStack {
                                VStack(alignment: .leading) {
                                    Text("Pazartesi - Cuma")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    Text("09:00 - 23:00")
                                        .font(.body)
                                        .fontWeight(.medium)
                                        .foregroundColor(.primary)
                                }
                                
                                Spacer()
                                
                                VStack(alignment: .leading) {
                                    Text("Hafta Sonu")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    Text("10:00 - 00:00")
                                        .font(.body)
                                        .fontWeight(.medium)
                                        .foregroundColor(.primary)
                                }
                            }
                        }
                        .padding()
                        .background(Color.orange.opacity(0.1))
                        .cornerRadius(12)
                        
                        // YOL TARİFİ BUTONU
                        Button(action: {
                            openInMapsForNavigation()
                        }) {
                            HStack {
                                Image(systemName: "location.circle.fill")
                                Text("Buraya Navigasyon Başlat")
                                Spacer()
                                Image(systemName: "chevron.right")
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.orange)
                            .cornerRadius(12)
                        }
                        .padding(.top, 8)
                        
                        // HARİTA - Restoranın İlk Resmi ile Annotation
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("Konum")
                                    .font(.headline)
                                Spacer()
                                Button("Haritada Gör") {
                                    showFullScreenMap = true
                                }
                                .font(.caption)
                                .foregroundColor(.blue)
                            }
                            .padding(.bottom, 8)
                            
                            // Tıklanabilir harita - Restoranın ilk resmi annotation olarak
                            Button(action: {
                                showFullScreenMap = true
                            }) {
                                ZStack {
                                    Map(coordinateRegion: .constant(
                                        MKCoordinateRegion(
                                            center: restaurant.location,
                                            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                                        )
                                    ))
                                    .frame(height: 200)
                                    .cornerRadius(12)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                    )
                                    
                                    // RESTORAN ANNOTATION'ı - Restoranın İlk Resmi
                                    if !restaurant.image.isEmpty {
                                        VStack {
                                            Image(restaurant.image.first ?? "placeholder")
                                                .resizable()
                                                .aspectRatio(contentMode: .fill)
                                                .frame(width: 50, height: 50)
                                                .clipShape(Circle())
                                                .overlay(
                                                    Circle()
                                                        .stroke(Color.white, lineWidth: 3)
                                                )
                                                .shadow(radius: 5)
                                            
                                            Text(restaurant.name)
                                                .font(.caption)
                                                .fontWeight(.bold)
                                                .foregroundColor(.white)
                                                .padding(.horizontal, 8)
                                                .padding(.vertical, 4)
                                                .background(Color.black.opacity(0.7))
                                                .cornerRadius(6)
                                        }
                                        .offset(y: -25)
                                    }
                                }
                                .frame(height: 200)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                        .padding(.top, 16)
                    }
                    .padding()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Kapat") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
            .fullScreenCover(isPresented: $showFullScreenMap) {
                FullScreenRestaurantMapView(restaurant: restaurant, isPresented: $showFullScreenMap)
            }
        }
    }
    
    private func openInMapsForNavigation() {
        let coordinate = restaurant.location
        let placemark = MKPlacemark(coordinate: coordinate)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = restaurant.name
        
        let options = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
        mapItem.openInMaps(launchOptions: options)
    }
}


    
// MARK: - Tam Ekran Restoran Harita Görünümü - ALTERNATİF
struct FullScreenRestaurantMapView: View {
    let restaurant: RestaurantsModel
    @Binding var isPresented: Bool
    @State private var region: MKCoordinateRegion
    
    init(restaurant: RestaurantsModel, isPresented: Binding<Bool>) {
        self.restaurant = restaurant
        self._isPresented = isPresented
        self._region = State(initialValue: MKCoordinateRegion(
            center: restaurant.location,
            span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
        ))
    }
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .topLeading) {
                // HARİTA - Eski yöntem (iOS 16 ve altı için)
                Map(coordinateRegion: $region, annotationItems: [restaurant]) { _ in
                    MapAnnotation(coordinate: restaurant.location) {
                        VStack(spacing: 4) {
                            if !restaurant.image.isEmpty {
                                Image(restaurant.image.first ?? "placeholder")
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 60, height: 60)
                                    .clipShape(Circle())
                                    .overlay(
                                        Circle()
                                            .stroke(Color.white, lineWidth: 4)
                                    )
                                    .shadow(radius: 10)
                            }
                            
                            Text(restaurant.name)
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.black.opacity(0.8))
                                .cornerRadius(10)
                                .shadow(radius: 5)
                        }
                    }
                }
                .edgesIgnoringSafeArea(.all)
                
                // KAPATMA BUTONU
                Button(action: {
                    isPresented = false
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.white)
                        .padding(8)
                        .background(Color.black.opacity(0.7))
                        .clipShape(Circle())
                }
                .padding()
            }
            .navigationTitle(restaurant.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Navigasyon") {
                        openInMapsForNavigation()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Kapat") {
                        isPresented = false
                    }
                }
            }
        }
    }
    
    private func openInMapsForNavigation() {
        let coordinate = restaurant.location
        let placemark = MKPlacemark(coordinate: coordinate)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = restaurant.name
        
        let options = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
        mapItem.openInMaps(launchOptions: options)
    }
}
// MARK: - Kategori Etiketi
struct CategoryTag: View {
    let icon: String
    let text: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption2)
                .foregroundColor(color)
            
            Text(text)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.primary)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(color.opacity(0.1))
        .cornerRadius(8)
    }
}

// MARK: - ÖNİZLEME
#Preview {
    NavigationStack {
        RestaurantsView()
    }
}
