//
//  HotelsView.swift
//  MesopotamiaTraveler
//
//  Created by Bilal AYDIN on 28.11.2025.
//

import SwiftUI
import MapKit
import FirebaseAuth
import SDWebImageSwiftUI

struct HotelsView: View {
    // let hotels: [HotelsModel] = [buyukMardinOteli, midyatSarayi, yayGrand]
    @EnvironmentObject var viewModel: MainViewModel
    @State private var searchText = ""
    @State private var selectedDistrict = "Tümü"
    @State private var selectedHotel: HotelsModel?
    @State private var showHotelDetail = false
    
    var mardinDistricts: [String] {
        let allDistricts = ["Tümü"] + Array(Set(viewModel.hotels.map { $0.district })).sorted()
        return allDistricts
    }
    
    var filteredHotels: [HotelsModel] {
        var result = viewModel.hotels
        
        // İlçe filtresi
        if selectedDistrict != "Tümü" {
            result = result.filter { $0.district == selectedDistrict }
        }
        
        // Arama filtresi
        if !searchText.isEmpty {
            result = result.filter { hotel in
                hotel.hotelName.localizedCaseInsensitiveContains(searchText) ||
                hotel.shortDescription.localizedCaseInsensitiveContains(searchText) ||
                hotel.district.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        return result
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // ARAMA ÇUBUĞU
            VStack(spacing: 12) {
                // Arama Bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)
                    
                    TextField("Otel veya ilçe ara...", text: $searchText)
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
                
                // İLÇE FİLTRE CHIPS
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(mardinDistricts, id: \.self) { district in
                            DistrictChip(
                                title: district,
                                isSelected: selectedDistrict == district,
                                action: {
                                    selectedDistrict = district
                                }
                            )
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.bottom, 8)
                
                // Arama sonuç sayısı
                if !searchText.isEmpty || selectedDistrict != "Tümü" {
                    HStack {
                        Text("\(filteredHotels.count) otel bulundu")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        if !searchText.isEmpty || selectedDistrict != "Tümü" {
                            Button("Filtreleri Temizle") {
                                searchText = ""
                                selectedDistrict = "Tümü"
                            }
                            .font(.caption)
                            .foregroundColor(.blue)
                        }
                        Spacer()
                    }
                    .padding(.horizontal)
                }
            }
            .background(Color(.systemBackground))
            
            // OTEL LİSTESİ
            ScrollView {
                VStack(alignment: .leading) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Mardin'deki Oteller")
                                .font(.title2)
                                .fontWeight(.semibold)
                            
                            if selectedDistrict != "Tümü" {
                                Text("\(selectedDistrict) İlçesi")
                                    .font(.subheadline)
                                    .foregroundColor(.blue)
                            }
                        }
                        
                        Spacer()
                        
                        Text("\(filteredHotels.count) otel")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                    }
                    .padding(.horizontal)
                    .padding(.top, 20)
                    
                    // OTEL KARTLARI
                    if filteredHotels.isEmpty {
                        VStack(spacing: 16) {
                            Image(systemName: "building.2")
                                .font(.system(size: 50))
                                .foregroundColor(.secondary)
                            
                            if selectedDistrict != "Tümü" && searchText.isEmpty {
                                Text("\(selectedDistrict) ilçesinde otel bulunamadı")
                                    .font(.headline)
                                    .foregroundColor(.secondary)
                            } else {
                                Text("'\(searchText)' için otel bulunamadı")
                                    .font(.headline)
                                    .foregroundColor(.secondary)
                                
                                Text("Farklı bir anahtar kelime deneyin")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .frame(height: 200)
                        .padding()
                    } else {
                        LazyVStack(spacing: 16) {
                            ForEach(Array(filteredHotels.enumerated()), id: \.element.id) { index, hotel in
                                HotelCard(hotel: hotel)
                                    .staggeredFadeIn(index: index)
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
                .refreshable {
                    viewModel.fetchAllData()
                }
            }
            .background(Color(.systemGroupedBackground))
        }
        .navigationTitle("Konaklama")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(item: $selectedHotel) { hotel in
            HotelDetailView(hotel: hotel)
        }
    }
}

// MARK: - İlçe Chip Bileşeni
struct DistrictChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                if title == "Tümü" {
                    Image(systemName: "building.2")
                        .font(.caption)
                } else if title == "Artuklu" {
                    Image(systemName: "building.columns")
                        .font(.caption)
                } else if title == "Midyat" {
                    Image(systemName: "house")
                        .font(.caption)
                } else {
                    Image(systemName: "mappin.circle")
                        .font(.caption)
                }
                
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(isSelected ? Color.blue : Color(.systemGray5))
            .foregroundColor(isSelected ? .white : .primary)
            .cornerRadius(20)
        }
    }
}

// MARK: - Otel Kartı Bileşeni
struct HotelCard: View {
    let hotel: HotelsModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // GÖRSEL SLIDER
            ZStack(alignment: .topLeading) {
                TabView {
                    ForEach(hotel.hotelImage.prefix(3), id: \.self) { imageName in
                        if let url = URL(string: imageName) {
                            WebImage(url: url)
                                .resizable()
                                .indicator(.activity)
                                .transition(.fade(duration: 0.5))
                                .aspectRatio(contentMode: .fill)
                                .frame(height: 180)
                                .clipped()
                        }
                    }
                }
                .frame(height: 180)
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
                .cornerRadius(12)
                
                // İLÇE ETİKETİ
                HStack {
                    HStack(spacing: 4) {
                        Image(systemName: "mappin.circle.fill")
                            .font(.caption2)
                        Text(hotel.district)
                            .font(.caption2)
                            .fontWeight(.semibold)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.blue.opacity(0.9))
                    .foregroundColor(.white)
                    .cornerRadius(6)
                    
                    Spacer()
                    
                    // YILDIZLAR
                    HStack(spacing: 2) {
                        ForEach(0..<hotel.starCount, id: \.self) { _ in
                            Image(systemName: "star.fill")
                                .font(.caption2)
                                .foregroundColor(.orange)
                        }
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.black.opacity(0.6))
                    .cornerRadius(6)
                }
                .padding(8)
            }
            .frame(height: 180)
            
            // OTEL BİLGİLERİ
            VStack(alignment: .leading, spacing: 8) {
                // OTEL ADI VE PUAN
                HStack {
                    Text(hotel.hotelName)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .font(.caption)
                            .foregroundColor(.orange)
                        Text(String(format: "%.1f", hotel.rating))
                            .font(.caption)
                            .fontWeight(.semibold)
                        Text("(\(hotel.reviewCount))")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
                
                // KISA AÇIKLAMA
                Text(hotel.shortDescription)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                
                // OLANAKLAR (AMENITIES)
                if !hotel.amenities.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(hotel.amenities.prefix(4), id: \.self) { amenity in
                                AmenityChip(amenity: amenity)
                            }
                        }
                    }
                }
                
                // FİYAT BİLGİSİ
                VStack(spacing: 4) {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Kişi Başı")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                            
                            Text("₺\(Int(hotel.oneNightPriceForOnePerson))")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("2 Kişilik Oda")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                            
                            HStack(alignment: .firstTextBaseline, spacing: 2) {
                                Text("₺\(Int(hotel.oneNightPriceForTwoPeople))")
                                    .font(.title3)
                                    .fontWeight(.bold)
                                    .foregroundColor(.blue)
                                Text("/gece")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    
                    // ADRES
                    HStack {
                        Image(systemName: "location.fill")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(hotel.address)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                }
            }
            .padding(.horizontal, 12)
            .padding(.bottom, 12)
        }
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 2)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(.systemGray5), lineWidth: 1)
        )
    }
}

// MARK: - Olanak Chip Bileşeni
struct AmenityChip: View {
    let amenity: String
    
    var iconName: String {
        switch amenity.lowercased() {
        case "wifi": return "wifi"
        case "parking": return "car.fill"
        case "breakfast": return "fork.knife"
        case "pool": return "figure.pool.swim"
        case "spa": return "leaf.fill"
        case "fitness": return "dumbbell.fill"
        case "terrace": return "sun.max.fill"
        default: return "checkmark.circle.fill"
        }
    }
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: iconName)
                .font(.caption2)
            Text(amenity.localizedCapitalized)
                .font(.caption2)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color.blue.opacity(0.1))
        .foregroundColor(.blue)
        .cornerRadius(12)
    }
}

// Oteller detay sayfası - Sadece HARİTA kısmı güncellendi
struct HotelDetailView: View {
    let hotel: HotelsModel
    @State private var currentImageIndex = 0
    @State private var showLoginView = false
    @State private var showAmenitiesSheet = false
    @State private var region: MKCoordinateRegion
    @Environment(\.presentationMode) var presentationMode
    
    // MARK: - Init
    init(hotel: HotelsModel) {
        self.hotel = hotel
        // Harita bölgesini state olarak ayarla
        self._region = State(initialValue: MKCoordinateRegion(
            center: hotel.location,
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        ))
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    // IMAGE SLIDER (Aynı)
                    ZStack(alignment: .bottom) {
                        TabView(selection: $currentImageIndex) {
                            ForEach(0..<hotel.hotelImage.count, id: \.self) { index in
                                if let url = URL(string: hotel.hotelImage[index]) {
                                    WebImage(url: url)
                                        .resizable()
                                        .indicator(.activity)
                                        .transition(.fade(duration: 0.5))
                                        .aspectRatio(contentMode: .fill)
                                        .frame(height: 300)
                                        .clipped()
                                        .tag(index)
                                }
                            }
                        }
                        .frame(height: 300)
                        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                        
                        // Sadece sayfa noktaları
                        VStack {
                            Spacer()
                            
                            HStack(spacing: 6) {
                                ForEach(0..<hotel.hotelImage.count, id: \.self) { index in
                                    Circle()
                                        .fill(currentImageIndex == index ? Color.white : Color.white.opacity(0.5))
                                        .frame(width: 8, height: 8)
                                }
                            }
                            .padding(.bottom, 10)
                        }
                        
                        // SOL ÜST KÖŞE: YILDIZ VE BÖLGE
                        VStack {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    HStack(spacing: 4) {
                                        ForEach(0..<hotel.starCount, id: \.self) { _ in
                                            Image(systemName: "star.fill")
                                                .font(.caption)
                                                .foregroundColor(.orange)
                                        }
                                    }
                                    
                                    Text(hotel.district)
                                        .font(.caption)
                                        .fontWeight(.medium)
                                        .foregroundColor(.white)
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(Color.black.opacity(0.7))
                                .cornerRadius(12)
                                
                                Spacer()
                            }
                            .padding(.horizontal)
                            .padding(.top, 10)
                            
                            Spacer()
                        }
                    }
                    .frame(height: 300)
                    
                    // OTEL BİLGİLERİ (Diğer kısımlar aynı)
                    VStack(alignment: .leading, spacing: 24) {
                        // BAŞLIK VE PUAN (Aynı)
                        VStack(alignment: .leading, spacing: 12) {
                            Text(hotel.hotelName)
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            HStack(spacing: 16) {
                                // RATING
                                HStack(spacing: 4) {
                                    Image(systemName: "star.fill")
                                        .font(.caption)
                                        .foregroundColor(.orange)
                                    Text(String(format: "%.1f", hotel.rating))
                                        .fontWeight(.semibold)
                                    Text("(\(hotel.reviewCount))")
                                        .foregroundColor(.secondary)
                                }
                                
                                // KONUM
                                HStack(spacing: 4) {
                                    Image(systemName: "mappin.circle")
                                        .font(.caption)
                                        .foregroundColor(.blue)
                                    Text(hotel.district)
                                        .font(.caption)
                                }
                            }
                            .font(.subheadline)
                        }
                        
                        // KISA AÇIKLAMA (Aynı)
                        Text(hotel.shortDescription)
                            .font(.headline)
                            .foregroundColor(.blue)
                        
                        // UZUN AÇIKLAMA (Aynı)
                        Text(hotel.hotelDescription)
                            .font(.body)
                            .foregroundColor(.primary)
                            .lineSpacing(4)
                        
                        // OLANAKLAR (Aynı)
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Olanaklar")
                                .font(.headline)
                                .fontWeight(.semibold)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 16) {
                                    ForEach(hotel.amenities.prefix(5), id: \.self) { amenity in
                                        VStack(spacing: 8) {
                                            Image(systemName: AmenityChip(amenity: amenity).iconName)
                                                .font(.title3)
                                                .foregroundColor(.blue)
                                                .frame(width: 44, height: 44)
                                                .background(Color.blue.opacity(0.1))
                                                .cornerRadius(10)
                                            
                                            Text(amenity.localizedCapitalized)
                                                .font(.caption2)
                                                .multilineTextAlignment(.center)
                                                .frame(width: 60)
                                        }
                                    }
                                    
                                    if hotel.amenities.count > 5 {
                                        Button(action: {
                                            showAmenitiesSheet = true
                                        }) {
                                            VStack(spacing: 8) {
                                                Image(systemName: "ellipsis.circle")
                                                    .font(.title3)
                                                    .foregroundColor(.blue)
                                                    .frame(width: 44, height: 44)
                                                    .background(Color.blue.opacity(0.1))
                                                    .cornerRadius(10)
                                                
                                                Text("Daha Fazla")
                                                    .font(.caption2)
                                                    .multilineTextAlignment(.center)
                                                    .frame(width: 60)
                                            }
                                        }
                                    }
                                }
                                .padding(.horizontal, 4)
                            }
                        }
                        .padding(.vertical, 8)
                        
                        // FİYAT BİLGİLERİ (Aynı)
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Fiyat")
                                .font(.headline)
                                .fontWeight(.semibold)
                            
                            VStack(spacing: 16) {
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("1 Kişi")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                        Text("₺\(Int(hotel.oneNightPriceForOnePerson))")
                                            .font(.title3)
                                            .fontWeight(.semibold)
                                    }
                                    
                                    Spacer()
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("2 Kişi")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                        Text("₺\(Int(hotel.oneNightPriceForTwoPeople))")
                                            .font(.title2)
                                            .fontWeight(.bold)
                                            .foregroundColor(.blue)
                                    }
                                    
                                    Spacer()
                                    
                                    Text("/gece")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                
                                // REZERVASYON BUTONU (Aynı)
                                Button(action: {
                                    if Auth.auth().currentUser != nil {
                                        makeReservation()
                                    } else {
                                        showLoginView = true
                                    }
                                }) {
                                    HStack {
                                        Image(systemName: "calendar.badge.plus")
                                        Text("Rezervasyon Yap")
                                    }
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(Color.blue)
                                    .cornerRadius(12)
                                }
                            }
                        }
                        .padding()
                        .background(Color.blue.opacity(0.05))
                        .cornerRadius(12)
                        
                        // İLETİŞİM BİLGİLERİ (Aynı)
                        VStack(alignment: .leading, spacing: 12) {
                            Text("İletişim")
                                .font(.headline)
                                .fontWeight(.semibold)
                            
                            VStack(spacing: 8) {
                                ContactRow(
                                    icon: "phone.fill",
                                    text: hotel.phoneNumber,
                                    action: callHotel,
                                    actionIcon: "phone.arrow.up.right"
                                )
                                
                                ContactRow(
                                    icon: "envelope.fill",
                                    text: hotel.email,
                                    action: sendEmail,
                                    actionIcon: "square.and.pencil"
                                )
                                
                                ContactRow(
                                    icon: "location.fill",
                                    text: hotel.address,
                                    action: openInMapsForNavigation,
                                    actionIcon: "arrow.triangle.turn.up.right.circle.fill"
                                )
                            }
                        }
                        
                        // HARİTA (GÜNCELLENDİ - ANNOTATION EKLENDİ)
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Konum")
                                .font(.headline)
                                .fontWeight(.semibold)
                            
                            ZStack(alignment: .topTrailing) {
                                // Harita with annotation
                                Map(coordinateRegion: $region,
                                    annotationItems: [hotel]) { hotel in
                                    MapAnnotation(coordinate: hotel.location) {
                                        VStack(spacing: 4) {
                                            // Annotation işaretçisi
                                            ZStack {
                                                Circle()
                                                    .fill(Color.blue)
                                                    .frame(width: 30, height: 30)
                                                
                                                Image(systemName: "bed.double.fill")
                                                    .font(.system(size: 12))
                                                    .foregroundColor(.white)
                                            }
                                            
                                            // Otel adı balonu
                                            Text(hotel.hotelName)
                                                .font(.caption2)
                                                .fontWeight(.semibold)
                                                .foregroundColor(.white)
                                                .padding(.horizontal, 8)
                                                .padding(.vertical, 4)
                                                .background(Color.blue)
                                                .cornerRadius(6)
                                                .shadow(radius: 2)
                                        }
                                        .offset(y: -10)
                                    }
                                }
                                .frame(height: 200)
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color(.systemGray4), lineWidth: 1)
                                )
                                
                                // Zoom butonları
                                VStack(spacing: 8) {
                                    Button(action: zoomIn) {
                                        Image(systemName: "plus.magnifyingglass")
                                            .font(.caption)
                                            .foregroundColor(.blue)
                                            .frame(width: 32, height: 32)
                                            .background(Color.white)
                                            .cornerRadius(6)
                                            .shadow(radius: 1)
                                    }
                                    
                                    Button(action: zoomOut) {
                                        Image(systemName: "minus.magnifyingglass")
                                            .font(.caption)
                                            .foregroundColor(.blue)
                                            .frame(width: 32, height: 32)
                                            .background(Color.white)
                                            .cornerRadius(6)
                                            .shadow(radius: 1)
                                    }
                                }
                                .padding(8)
                            }
                            
                            // Navigasyon butonu
                            Button(action: {
                                openInMapsForNavigation()
                            }) {
                                HStack {
                                    Image(systemName: "location.circle.fill")
                                        .font(.headline)
                                    Text("Navigasyon ile Git")
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .font(.caption)
                                }
                                .foregroundColor(.blue)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.blue.opacity(0.1))
                                .cornerRadius(12)
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing:
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "xmark")
                        .font(.headline)
                        .foregroundColor(.primary)
                        .frame(width: 36, height: 36)
                        .background(Color(.systemGray6))
                        .clipShape(Circle())
                }
            )
            .sheet(isPresented: $showLoginView) {
                LoginView(isPresented: $showLoginView)
            }
            .sheet(isPresented: $showAmenitiesSheet) {
                AmenitiesSheetView(amenities: hotel.amenities)
            }
        }
    }
    
    // Yardımcı View (Aynı)
    struct ContactRow: View {
        let icon: String
        let text: String
        let action: () -> Void
        let actionIcon: String
        
        var body: some View {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.blue)
                    .frame(width: 20)
                Text(text)
                    .font(.subheadline)
                Spacer()
                Button(action: action) {
                    Image(systemName: actionIcon)
                        .foregroundColor(.blue)
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(10)
        }
    }
    
    // MARK: - Harita Fonksiyonları
    private func zoomIn() {
        withAnimation {
            region.span.latitudeDelta = max(region.span.latitudeDelta / 1.5, 0.001)
            region.span.longitudeDelta = max(region.span.longitudeDelta / 1.5, 0.001)
        }
    }
    
    private func zoomOut() {
        withAnimation {
            region.span.latitudeDelta = min(region.span.latitudeDelta * 1.5, 0.1)
            region.span.longitudeDelta = min(region.span.longitudeDelta * 1.5, 0.1)
        }
    }
    
    // MARK: - Diğer fonksiyonlar (Aynı)
    private func makeReservation() {
        guard let user = Auth.auth().currentUser else {
            showLoginView = true
            return
        }
        
        print("Rezervasyon yapılıyor - Otel: \(hotel.hotelName), Kullanıcı: \(user.uid)")
        // Rezervasyon işlemi
    }
    
    private func callHotel() {
        let phoneNumber = hotel.phoneNumber.replacingOccurrences(of: " ", with: "")
        if let url = URL(string: "tel://\(phoneNumber)") {
            UIApplication.shared.open(url)
        }
    }
    
    private func sendEmail() {
        if let url = URL(string: "mailto:\(hotel.email)") {
            UIApplication.shared.open(url)
        }
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


// MARK: - Olanaklar Sayfası
struct AmenitiesSheetView: View {
    let amenities: [String]
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            List {
                ForEach(amenities, id: \.self) { amenity in
                    HStack {
                        Image(systemName: AmenityChip(amenity: amenity).iconName)
                            .foregroundColor(.blue)
                            .frame(width: 30)
                        Text(amenity.localizedCapitalized)
                            .font(.body)
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("Olanaklar")
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
}

// MARK: - ÖNİZLEME
struct HotelsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            HotelsView()
        }
    }
}
