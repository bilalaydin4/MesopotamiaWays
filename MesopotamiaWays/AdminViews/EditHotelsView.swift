//
//  EditHotelsView.swift
//  MesopotamiaWays
//
//  Admin panelinden otelleri düzenleme/silme sayfası
//

import SwiftUI
import SDWebImageSwiftUI
import PhotosUI
import FirebaseFirestore
import FirebaseStorage
import Combine

struct EditHotelsView: View {
    @StateObject private var vm = EditHotelsViewModel()
    
    var body: some View {
        ZStack {
            Color(.systemGroupedBackground).ignoresSafeArea()
            
            if vm.isLoading {
                ProgressView("Oteller yükleniyor...")
                    .padding()
            } else if vm.hotels.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "bed.double")
                        .font(.system(size: 50))
                        .foregroundColor(.secondary)
                    Text("Henüz otel eklenmemiş")
                        .font(.headline)
                        .foregroundColor(.secondary)
                }
            } else {
                List {
                    ForEach(vm.hotels) { hotel in
                        NavigationLink(destination: EditHotelDetailView(hotel: hotel, onUpdate: { vm.fetchHotels() })) {
                            HotelListRow(hotel: hotel)
                        }
                    }
                    .onDelete { indexSet in
                        for index in indexSet {
                            vm.deleteHotel(vm.hotels[index])
                        }
                    }
                }
                .listStyle(.insetGrouped)
            }
        }
        .navigationTitle("Otelleri Düzenle")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { vm.fetchHotels() }
        .alert("Hata", isPresented: $vm.showError) {
            Button("Tamam", role: .cancel) {}
        } message: {
            Text(vm.errorMessage)
        }
    }
}

// MARK: - Otel Liste Satırı
struct HotelListRow: View {
    let hotel: HotelsModel
    
    var body: some View {
        HStack(spacing: 12) {
            if let firstImage = hotel.hotelImage.first, let url = URL(string: firstImage) {
                WebImage(url: url)
                    .resizable()
                    .indicator(.activity)
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 60, height: 60)
                    .cornerRadius(8)
                    .clipped()
            } else {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 60, height: 60)
                    .overlay(Image(systemName: "photo").foregroundColor(.gray))
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(hotel.hotelName)
                    .font(.headline)
                    .lineLimit(1)
                Text("\(hotel.district), \(hotel.city)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                HStack(spacing: 2) {
                    ForEach(0..<hotel.starCount, id: \.self) { _ in
                        Image(systemName: "star.fill")
                            .font(.caption2)
                            .foregroundColor(.orange)
                    }
                }
            }
            
            Spacer()
            
            Text("\(hotel.hotelImage.count) 📷")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Otel Düzenleme Detay
struct EditHotelDetailView: View {
    let hotel: HotelsModel
    let onUpdate: () -> Void
    
    @State private var hotelName: String = ""
    @State private var city: String = ""
    @State private var district: String = ""
    @State private var shortDescription: String = ""
    @State private var hotelDescription: String = ""
    @State private var starCount: Int = 3
    @State private var rating: Double = 0.0
    @State private var reviewCount: Int = 0
    @State private var priceOnePerson: String = ""
    @State private var priceTwoPeople: String = ""
    @State private var latitude: String = ""
    @State private var longitude: String = ""
    @State private var phoneNumber: String = ""
    @State private var email: String = ""
    @State private var address: String = ""
    @State private var amenities: [String] = []
    @State private var existingImages: [String] = []
    @State private var newImages: [UIImage] = []
    
    @State private var isProcessing = false
    @State private var showSuccess = false
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var showImagePicker = false
    @State private var showDeleteConfirm = false
    
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        Form {
            imageSection
            basicInfoSection
            descriptionSection
            priceAndRatingSection
            locationSection
            contactSection
            actionButtonsSection
        }
        .navigationTitle("Otel Düzenle")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { loadData() }
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(images: $newImages)
        }
        .alert("Başarılı", isPresented: $showSuccess) {
            Button("Tamam") {
                onUpdate()
                presentationMode.wrappedValue.dismiss()
            }
        } message: {
            Text("Otel başarıyla güncellendi!")
        }
        .alert("Hata", isPresented: $showError) {
            Button("Tamam", role: .cancel) {}
        } message: {
            Text(errorMessage)
        }
        .alert("Oteli Sil", isPresented: $showDeleteConfirm) {
            Button("Sil", role: .destructive) { deleteHotel() }
            Button("İptal", role: .cancel) {}
        } message: {
            Text("'\(hotelName)' oteli kalıcı olarak silinecek. Emin misiniz?")
        }
    }
    
    // MARK: - Subviews
    
    private var imageSection: some View {
        Group {
            Section(header: Text("Mevcut Resimler (\(existingImages.count))")) {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(existingImages, id: \.self) { imageUrl in
                            ZStack(alignment: .topTrailing) {
                                if let url = URL(string: imageUrl) {
                                    WebImage(url: url)
                                        .resizable()
                                        .indicator(.activity)
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 120, height: 90)
                                        .cornerRadius(8)
                                        .clipped()
                                }
                                
                                Button(action: {
                                    withAnimation {
                                        existingImages.removeAll { $0 == imageUrl }
                                    }
                                }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .font(.title3)
                                        .foregroundColor(.white)
                                        .background(Circle().fill(Color.red))
                                }
                                .offset(x: 6, y: -6)
                            }
                        }
                    }
                    .padding(.vertical, 8)
                }
            }
            
            Section(header: Text("Yeni Resim Ekle")) {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(Array(newImages.enumerated()), id: \.offset) { index, uiImage in
                            ZStack(alignment: .topTrailing) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 120, height: 90)
                                    .cornerRadius(8)
                                    .clipped()
                                
                                Button(action: {
                                    withAnimation { removeNewImage(at: index) }
                                }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .font(.title3)
                                        .foregroundColor(.white)
                                        .background(Circle().fill(Color.red))
                                }
                                .offset(x: 6, y: -6)
                            }
                        }
                        
                        Button(action: { showImagePicker = true }) {
                            VStack {
                                Image(systemName: "plus.circle.fill")
                                    .font(.title)
                                    .foregroundColor(.blue)
                                Text("Ekle")
                                    .font(.caption)
                                    .foregroundColor(.blue)
                            }
                            .frame(width: 120, height: 90)
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(8)
                        }
                    }
                    .padding(.vertical, 8)
                }
            }
        }
    }
    
    private var basicInfoSection: some View {
        Section(header: Text("Temel Bilgiler")) {
            TextField("Otel Adı", text: $hotelName)
            TextField("Şehir", text: $city)
            TextField("İlçe", text: $district)
            Stepper("Yıldız: \(starCount)", value: $starCount, in: 1...5)
        }
    }
    
    private var descriptionSection: some View {
        Section(header: Text("Açıklamalar")) {
            TextField("Kısa Açıklama", text: $shortDescription)
            TextEditor(text: $hotelDescription)
                .frame(minHeight: 100)
        }
    }
    
    private var priceAndRatingSection: some View {
        Section(header: Text("Fiyat & Değerlendirme")) {
            TextField("1 Kişi Fiyat (₺)", text: $priceOnePerson)
                .keyboardType(.decimalPad)
            TextField("2 Kişi Fiyat (₺)", text: $priceTwoPeople)
                .keyboardType(.decimalPad)
            HStack {
                Text("Puan:")
                Slider(value: $rating, in: 0...5, step: 0.1)
                Text(String(format: "%.1f", rating))
                    .foregroundColor(.orange)
            }
            Stepper("Yorum Sayısı: \(reviewCount)", value: $reviewCount, in: 0...10000)
        }
    }
    
    private var locationSection: some View {
        Section(header: Text("Konum")) {
            TextField("Enlem (Latitude)", text: $latitude)
                .keyboardType(.decimalPad)
            TextField("Boylam (Longitude)", text: $longitude)
                .keyboardType(.decimalPad)
        }
    }
    
    private var contactSection: some View {
        Section(header: Text("İletişim")) {
            TextField("Telefon", text: $phoneNumber)
                .keyboardType(.phonePad)
            TextField("Email", text: $email)
                .keyboardType(.emailAddress)
            TextField("Adres", text: $address)
        }
    }
    
    private var actionButtonsSection: some View {
        Group {
            Section {
                Button(action: updateHotel) {
                    HStack {
                        Spacer()
                        if isProcessing {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Image(systemName: "arrow.triangle.2.circlepath")
                            Text("Güncelle")
                                .fontWeight(.semibold)
                        }
                        Spacer()
                    }
                    .padding(.vertical, 4)
                }
                .listRowBackground(Color.blue)
                .foregroundColor(.white)
                .disabled(isProcessing)
            }
            
            Section {
                Button(action: { showDeleteConfirm = true }) {
                    HStack {
                        Spacer()
                        Image(systemName: "trash.fill")
                        Text("Bu Oteli Sil")
                            .fontWeight(.semibold)
                        Spacer()
                    }
                    .padding(.vertical, 4)
                }
                .listRowBackground(Color.red)
                .foregroundColor(.white)
            }
        }
    }
    
    func loadData() {
        hotelName = hotel.hotelName
        city = hotel.city
        district = hotel.district
        shortDescription = hotel.shortDescription
        hotelDescription = hotel.hotelDescription
        starCount = hotel.starCount
        rating = hotel.rating
        reviewCount = hotel.reviewCount
        priceOnePerson = String(hotel.oneNightPriceForOnePerson)
        priceTwoPeople = String(hotel.oneNightPriceForTwoPeople)
        latitude = String(hotel.coordinate.latitude)
        longitude = String(hotel.coordinate.longitude)
        phoneNumber = hotel.phoneNumber
        email = hotel.email
        address = hotel.address
        amenities = hotel.amenities
        existingImages = hotel.hotelImage
    }
    
    func updateHotel() {
        guard let hotelId = hotel.id else { return }
        isProcessing = true
        
        if newImages.isEmpty {
            saveToFirestore(hotelId: hotelId, imageUrls: existingImages)
        } else {
            StorageManager.shared.uploadImages(images: newImages, folder: "hotels") { newUrls in
                let allImages = self.existingImages + newUrls
                self.saveToFirestore(hotelId: hotelId, imageUrls: allImages)
            }
        }
    }
    
    func saveToFirestore(hotelId: String, imageUrls: [String]) {
        let db = Firestore.firestore()
        
        let data: [String: Any] = [
            "hotelName": hotelName,
            "city": city,
            "district": district,
            "shortDescription": shortDescription,
            "hotelDescription": hotelDescription,
            "hotelImage": imageUrls,
            "starCount": starCount,
            "rating": rating,
            "reviewCount": reviewCount,
            "oneNightPriceForOnePerson": Double(priceOnePerson) ?? 0.0,
            "oneNightPriceForTwoPeople": Double(priceTwoPeople) ?? 0.0,
            "coordinate": [
                "latitude": Double(latitude) ?? 0.0,
                "longitude": Double(longitude) ?? 0.0
            ],
            "phoneNumber": phoneNumber,
            "email": email,
            "address": address,
            "amenities": amenities
        ]
        
        db.collection("hotels").document(hotelId).setData(data) { error in
            DispatchQueue.main.async {
                self.isProcessing = false
                if let error = error {
                    self.errorMessage = error.localizedDescription
                    self.showError = true
                } else {
                    self.showSuccess = true
                }
            }
        }
    }
    
    func deleteHotel() {
        guard let hotelId = hotel.id else { return }
        isProcessing = true
        let db = Firestore.firestore()
        db.collection("hotels").document(hotelId).delete { error in
            DispatchQueue.main.async {
                self.isProcessing = false
                if let error = error {
                    self.errorMessage = error.localizedDescription
                    self.showError = true
                } else {
                    onUpdate()
                    presentationMode.wrappedValue.dismiss()
                }
            }
        }
    }

    func removeNewImage(at index: Int) {
        if index < newImages.count {
            newImages.remove(at: index)
        }
    }
}

// MARK: - ViewModel
class EditHotelsViewModel: ObservableObject {
    @Published var hotels: [HotelsModel] = []
    @Published var isLoading = false
    @Published var showError = false
    @Published var errorMessage = ""
    
    func fetchHotels() {
        isLoading = true
        Firestore.firestore().collection("hotels").getDocuments { snapshot, error in
            DispatchQueue.main.async {
                self.isLoading = false
                if let error = error {
                    self.errorMessage = error.localizedDescription
                    self.showError = true
                } else if let snapshot = snapshot {
                    self.hotels = snapshot.documents.compactMap { doc in
                        try? doc.data(as: HotelsModel.self)
                    }
                }
            }
        }
    }
    
    func deleteHotel(_ hotel: HotelsModel) {
        guard let id = hotel.id else { return }
        Firestore.firestore().collection("hotels").document(id).delete { error in
            if error == nil {
                DispatchQueue.main.async {
                    self.hotels.removeAll { $0.id == id }
                }
            }
        }
    }
}
