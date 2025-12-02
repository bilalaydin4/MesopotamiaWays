//
//  HotelsView.swift
//  MesopotamiaTraveler
//
//  Created by Bilal AYDIN on 28.11.2025.
//

import SwiftUI
import MapKit

struct HotelsView: View {
    let hotels: [HotelsModel] = [buyukMardinOteli, yayGrand]
    @State private var searchText = ""
    @State private var selectedHotel: HotelsModel?
    @State private var showHotelDetail = false
    
    var filteredHotels: [HotelsModel] {
        if searchText.isEmpty {
            return hotels
        } else {
            return hotels.filter { hotel in
                hotel.hotelName.localizedCaseInsensitiveContains(searchText) ||
                hotel.hotelDescription.localizedCaseInsensitiveContains(searchText)
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
                        
                        TextField("Otel ara...", text: $searchText)
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
                    //.padding(.horizontal)
                    .padding()
                    
                    // Arama sonuç sayısı
                    if !searchText.isEmpty {
                        HStack {
                            Text("\(filteredHotels.count) otel bulundu")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Spacer()
                        }
                        .padding(.horizontal)
                    }
                }
                .background(Color.white)
                
                // OTEL LİSTESİ
                ScrollView {
                    VStack(alignment: .leading) {
                        HStack {
                            Text(searchText.isEmpty ? "Konaklama Yerleri" : "Arama Sonuçları")
                                .font(.title2)
                                .fontWeight(.semibold)
                            
                            Spacer()
                            
                            Text("\(filteredHotels.count) otel")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(.horizontal)
                        .padding(.top, 20)
                        
                        // OTEL KARTLARI
                        if filteredHotels.isEmpty && !searchText.isEmpty {
                            VStack(spacing: 16) {
                                Image(systemName: "building.2")
                                    .font(.system(size: 50))
                                    .foregroundColor(.secondary)
                                
                                Text("'\(searchText)' için otel bulunamadı")
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
                                ForEach(filteredHotels) { hotel in
                                    HotelCard(hotel: hotel)
                                        .onTapGesture {
                                            selectedHotel = hotel
                                            showHotelDetail = true
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
            .navigationTitle("Oteller")
            .sheet(item: $selectedHotel) { hotel in
                HotelDetailView(hotel: hotel)
            }
        
    }
}

// MARK: - Otel Kartı Bileşeni
struct HotelCard: View {
    let hotel: HotelsModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // GÖRSEL SLIDER
            ZStack(alignment: .bottom) {
                TabView {
                    ForEach(hotel.hotelImage.prefix(3), id: \.self) { imageName in
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
                
                // FİYAT ETİKETİ
                VStack {
                    HStack {
                        Spacer()
                        VStack(spacing: 2) {
                            Text("₺\(hotel.oneNightPriceForTwoPeople, specifier: "%.0f")")
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            Text("2 kişilik")
                                .font(.caption2)
                                .foregroundColor(.white.opacity(0.9))
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.blue)
                        .cornerRadius(8)
                    }
                    Spacer()
                }
                .padding(8)
            }
            .frame(height: 160)
            
            // OTEL BİLGİLERİ
            VStack(alignment: .leading, spacing: 8) {
                Text(hotel.hotelName)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Text(hotel.hotelDescription)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                
                // FİYAT BİLGİSİ
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("1 Kişi: ₺\(hotel.oneNightPriceForOnePerson, specifier: "%.0f")")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text("2 Kişi: ₺\(hotel.oneNightPriceForTwoPeople, specifier: "%.0f")")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.primary)
                    }
                    
                    Spacer()
                    
                    HStack {
                        Image(systemName: "star.fill")
                            .font(.caption2)
                            .foregroundColor(.orange)
                        Text("4.5")
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                    .padding(6)
                    .background(Color.orange.opacity(0.1))
                    .cornerRadius(6)
                }
                
                // KONUM
                HStack {
                    Image(systemName: "location.circle")
                        .foregroundColor(.orange)
                    Text("\(hotel.coordinate.latitude, specifier: "%.4f"), \(hotel.coordinate.longitude, specifier: "%.4f")")
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

// MARK: - Otel Detay Sayfası
struct HotelDetailView: View {
    let hotel: HotelsModel
    @State private var currentImageIndex = 0
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // IMAGE SLIDER
                    ZStack(alignment: .bottom) {
                        TabView(selection: $currentImageIndex) {
                            ForEach(0..<hotel.hotelImage.count, id: \.self) { index in
                                Image(hotel.hotelImage[index])
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
                            ForEach(0..<hotel.hotelImage.count, id: \.self) { index in
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
                                Text("\(currentImageIndex + 1)/\(hotel.hotelImage.count)")
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
                    
                    // OTEL BİLGİLERİ
                    VStack(alignment: .leading, spacing: 16) {
                        Text(hotel.hotelName)
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Text(hotel.hotelDescription)
                            .font(.body)
                            .foregroundColor(.secondary)
                            .lineSpacing(4)
                        
                        // FİYAT BİLGİLERİ
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Fiyatlar")
                                .font(.headline)
                            
                            HStack {
                                VStack(alignment: .leading) {
                                    Text("1 Gece - 1 Kişi")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    Text("₺\(hotel.oneNightPriceForOnePerson, specifier: "%.0f")")
                                        .font(.title2)
                                        .fontWeight(.bold)
                                        .foregroundColor(.primary)
                                }
                                
                                Spacer()
                                
                                VStack(alignment: .leading) {
                                    Text("1 Gece - 2 Kişi")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    Text("₺\(hotel.oneNightPriceForTwoPeople, specifier: "%.0f")")
                                        .font(.title2)
                                        .fontWeight(.bold)
                                        .foregroundColor(.primary)
                                }
                            }
                        }
                        .padding()
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(12)
                        
                        // REZERVASYON BUTONU
                        Button(action: {
                            // Rezervasyon işlemi
                            makeReservation()
                        }) {
                            HStack {
                                Image(systemName: "calendar.badge.plus")
                                Text("Rezervasyon Yap")
                                Spacer()
                                Image(systemName: "chevron.right")
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .cornerRadius(12)
                        }
                        .padding(.top, 8)
                        
                        // HARİTA
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Konum")
                                .font(.headline)
                            
                            Map(coordinateRegion: .constant(
                                MKCoordinateRegion(
                                    center: hotel.location,
                                    span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                                )
                            ))
                            .frame(height: 200)
                            .cornerRadius(12)
                            
                            Button(action: {
                                openInMapsForNavigation()
                            }) {
                                HStack {
                                    Image(systemName: "location.circle.fill")
                                    Text("Buraya Navigasyon Başlat")
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                }
                                .font(.subheadline)
                                .foregroundColor(.blue)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.blue.opacity(0.1))
                                .cornerRadius(12)
                            }
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
        }
    }
    
    private func makeReservation() {
        // Rezervasyon işlemi burada yapılacak
        print("Rezervasyon yapılıyor: \(hotel.hotelName)")
        // Burada rezervasyon API'si çağrılabilir veya telefon/email açılabilir
    }
    
    private func openInMapsForNavigation() {
        let coordinate = hotel.location
        let placemark = MKPlacemark(coordinate: coordinate)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = hotel.hotelName
        
        let options = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
        mapItem.openInMaps(launchOptions: options)
    }
}

// MARK: - ÖNİZLEME
struct HotelsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            HotelsView()
        }
        
    }
}
