//
//  HotelsView.swift
//  MesopotamiaTraveler
//
//  Created by Bilal AYDIN on 28.11.2025.
//

import SwiftUI
import MapKit
import FirebaseAuth

struct HotelsView: View {
    let hotels: [HotelsModel] = [buyukMardinOteli, midyatSarayi, yayGrand]
    @State private var searchText = ""
    @State private var selectedDistrict = "Tümü"
    @State private var selectedHotel: HotelsModel?
    @State private var showHotelDetail = false
    
    var mardinDistricts: [String] {
        let allDistricts = ["Tümü"] + Array(Set(hotels.map { $0.district })).sorted()
        return allDistricts
    }
    
    var filteredHotels: [HotelsModel] {
        var result = hotels
        
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
            .background(Color.white)
            
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
                        Image(imageName)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 180)
                            .clipped()
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
        .background(Color.white)
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

// MARK: - Otel Detay Sayfası (Güncellenmiş)
struct HotelDetailView: View {
    let hotel: HotelsModel
    @State private var currentImageIndex = 0
    @State private var showLoginView = false
    @State private var showAmenitiesSheet = false
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    // IMAGE SLIDER
                    ZStack(alignment: .bottom) {
                        TabView(selection: $currentImageIndex) {
                            ForEach(0..<hotel.hotelImage.count, id: \.self) { index in
                                Image(hotel.hotelImage[index])
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(height: 300)
                                    .clipped()
                                    .tag(index)
                            }
                        }
                        .frame(height: 300)
                        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                        
                        // GRADIENT OVERLAY
                        LinearGradient(
                            gradient: Gradient(colors: [.clear, .black.opacity(0.3)]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        .frame(height: 80)
                        .offset(y: 30)
                        
                        // RESİM SAYACI
                        VStack {
                            HStack {
                                // YILDIZ VE İLÇE
                                HStack(spacing: 4) {
                                    ForEach(0..<hotel.starCount, id: \.self) { _ in
                                        Image(systemName: "star.fill")
                                            .font(.caption)
                                            .foregroundColor(.orange)
                                    }
                                    
                                    Text("•")
                                        .foregroundColor(.white.opacity(0.7))
                                        .font(.caption)
                                    
                                    Text(hotel.district)
                                        .font(.caption)
                                        .fontWeight(.medium)
                                        .foregroundColor(.white)
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.black.opacity(0.5))
                                .cornerRadius(12)
                                
                                Spacer()
                                
                                // RESİM SAYACI
                                Text("\(currentImageIndex + 1)/\(hotel.hotelImage.count)")
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 5)
                                    .background(Color.black.opacity(0.5))
                                    .cornerRadius(12)
                            }
                            .padding(.horizontal)
                            .padding(.top, 10)
                            
                            Spacer()
                        }
                    }
                    .frame(height: 300)
                    
                    // OTEL BİLGİLERİ
                    VStack(alignment: .leading, spacing: 20) {
                        // BAŞLIK VE PUAN
                        VStack(alignment: .leading, spacing: 8) {
                            Text(hotel.hotelName)
                                .font(.title)
                                .fontWeight(.bold)
                            
                            HStack(spacing: 12) {
                                // RATING
                                HStack(spacing: 4) {
                                    Image(systemName: "star.fill")
                                        .foregroundColor(.orange)
                                    Text(String(format: "%.1f", hotel.rating))
                                        .fontWeight(.semibold)
                                    Text("(\(hotel.reviewCount) değerlendirme)")
                                        .foregroundColor(.secondary)
                                }
                                
                                Divider()
                                    .frame(height: 16)
                                
                                // KONUM
                                HStack(spacing: 4) {
                                    Image(systemName: "mappin.circle.fill")
                                        .foregroundColor(.blue)
                                    Text(hotel.district)
                                        .fontWeight(.medium)
                                }
                            }
                            .font(.subheadline)
                        }
                        
                        // KISA AÇIKLAMA
                        Text(hotel.shortDescription)
                            .font(.headline)
                            .foregroundColor(.blue)
                        
                        // UZUN AÇIKLAMA
                        Text(hotel.hotelDescription)
                            .font(.body)
                            .foregroundColor(.primary)
                            .lineSpacing(4)
                        
                        // OLANAKLAR
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("Olanaklar")
                                    .font(.title3)
                                    .fontWeight(.semibold)
                                
                                Spacer()
                                
                                Button("Tümünü Gör") {
                                    showAmenitiesSheet = true
                                }
                                .font(.subheadline)
                                .foregroundColor(.blue)
                            }
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(hotel.amenities, id: \.self) { amenity in
                                        VStack(spacing: 8) {
                                            Image(systemName: AmenityChip(amenity: amenity).iconName)
                                                .font(.title2)
                                                .foregroundColor(.blue)
                                                .frame(width: 50, height: 50)
                                                .background(Color.blue.opacity(0.1))
                                                .cornerRadius(12)
                                            
                                            Text(amenity.localizedCapitalized)
                                                .font(.caption)
                                                .multilineTextAlignment(.center)
                                                .frame(width: 70)
                                        }
                                    }
                                }
                                .padding(.horizontal, 4)
                            }
                        }
                        .padding(.vertical, 8)
                        
                        // FİYAT BİLGİLERİ
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Fiyatlar")
                                .font(.title3)
                                .fontWeight(.semibold)
                            
                            VStack(spacing: 12) {
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("1 Kişilik Oda")
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                        HStack(alignment: .firstTextBaseline, spacing: 2) {
                                            Text("₺\(Int(hotel.oneNightPriceForOnePerson))")
                                                .font(.title2)
                                                .fontWeight(.bold)
                                            Text("/gece")
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                    
                                    Spacer()
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("2 Kişilik Oda")
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                        HStack(alignment: .firstTextBaseline, spacing: 2) {
                                            Text("₺\(Int(hotel.oneNightPriceForTwoPeople))")
                                                .font(.title)
                                                .fontWeight(.bold)
                                                .foregroundColor(.blue)
                                            Text("/gece")
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                }
                                
                                // REZERVASYON BUTONU
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
                            }
                        }
                        .padding()
                        .background(Color.blue.opacity(0.05))
                        .cornerRadius(16)
                        
                        // İLETİŞİM BİLGİLERİ
                        VStack(alignment: .leading, spacing: 12) {
                            Text("İletişim Bilgileri")
                                .font(.title3)
                                .fontWeight(.semibold)
                            
                            VStack(spacing: 12) {
                                HStack {
                                    Image(systemName: "phone.fill")
                                        .foregroundColor(.blue)
                                        .frame(width: 30)
                                    Text(hotel.phoneNumber)
                                    Spacer()
                                    Button(action: {
                                        callHotel()
                                    }) {
                                        Image(systemName: "phone.arrow.up.right")
                                            .foregroundColor(.blue)
                                    }
                                }
                                
                                HStack {
                                    Image(systemName: "envelope.fill")
                                        .foregroundColor(.blue)
                                        .frame(width: 30)
                                    Text(hotel.email)
                                    Spacer()
                                    Button(action: {
                                        sendEmail()
                                    }) {
                                        Image(systemName: "square.and.pencil")
                                            .foregroundColor(.blue)
                                    }
                                }
                                
                                HStack(alignment: .top) {
                                    Image(systemName: "location.fill")
                                        .foregroundColor(.blue)
                                        .frame(width: 30)
                                    Text(hotel.address)
                                        .font(.subheadline)
                                        .foregroundColor(.primary)
                                    Spacer()
                                    Button(action: {
                                        openInMapsForNavigation()
                                    }) {
                                        Image(systemName: "arrow.triangle.turn.up.right.circle.fill")
                                            .foregroundColor(.blue)
                                    }
                                }
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                        }
                        
                        // HARİTA
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Konum")
                                .font(.title3)
                                .fontWeight(.semibold)
                            
                            Map(coordinateRegion: .constant(
                                MKCoordinateRegion(
                                    center: hotel.location,
                                    span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                                )
                            ))
                            .frame(height: 200)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color(.systemGray4), lineWidth: 1)
                            )
                            
                            Button(action: {
                                openInMapsForNavigation()
                            }) {
                                HStack {
                                    Image(systemName: "location.circle.fill")
                                    Text("Navigasyon ile Git")
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
                    }
                    .padding()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.white)
                            .font(.title3)
                    }
                }
            }
            .sheet(isPresented: $showLoginView) {
                LoginView(isPresented: $showLoginView)
            }
            .sheet(isPresented: $showAmenitiesSheet) {
                AmenitiesSheetView(amenities: hotel.amenities)
            }
        }
    }
    
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
