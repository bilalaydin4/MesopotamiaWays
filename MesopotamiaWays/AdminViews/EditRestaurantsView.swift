//
//  EditRestaurantsView.swift
//  MesopotamiaWays
//
//  Admin panelinden restoranları düzenleme/silme sayfası
//

import SwiftUI
import SDWebImageSwiftUI
import PhotosUI
import FirebaseFirestore
import FirebaseStorage
import Combine

struct EditRestaurantsView: View {
    @StateObject private var vm = EditRestaurantsViewModel()
    
    var body: some View {
        ZStack {
            Color(.systemGroupedBackground).ignoresSafeArea()
            
            if vm.isLoading {
                ProgressView("Restoranlar yükleniyor...")
                    .padding()
            } else if vm.restaurants.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "fork.knife")
                        .font(.system(size: 50))
                        .foregroundColor(.secondary)
                    Text("Henüz restoran eklenmemiş")
                        .font(.headline)
                        .foregroundColor(.secondary)
                }
            } else {
                List {
                    ForEach(vm.restaurants) { restaurant in
                        NavigationLink(destination: EditRestaurantDetailView(restaurant: restaurant, onUpdate: { vm.fetchRestaurants() })) {
                            RestaurantListRow(restaurant: restaurant)
                        }
                    }
                    .onDelete { indexSet in
                        for index in indexSet {
                            vm.deleteRestaurant(vm.restaurants[index])
                        }
                    }
                }
                .listStyle(.insetGrouped)
            }
        }
        .navigationTitle("Restoranları Düzenle")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { vm.fetchRestaurants() }
        .alert("Hata", isPresented: $vm.showError) {
            Button("Tamam", role: .cancel) {}
        } message: {
            Text(vm.errorMessage)
        }
    }
}

// MARK: - Restoran Liste Satırı
struct RestaurantListRow: View {
    let restaurant: RestaurantsModel
    
    var body: some View {
        HStack(spacing: 12) {
            if let firstImage = restaurant.image.first, let url = URL(string: firstImage) {
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
                Text(restaurant.name)
                    .font(.headline)
                    .lineLimit(1)
                Text(restaurant.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            
            Spacer()
            
            Text("\(restaurant.image.count) 📷")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Restoran Düzenleme Detay
struct EditRestaurantDetailView: View {
    let restaurant: RestaurantsModel
    let onUpdate: () -> Void
    
    @State private var restaurantName: String = ""
    @State private var restaurantDescription: String = ""
    @State private var category: String = ""
    @State private var priceRange: String = ""
    @State private var openingHours: String = ""
    @State private var phoneNumber: String = ""
    @State private var email: String = ""
    @State private var website: String = ""
    @State private var address: String = ""
    @State private var city: String = ""
    @State private var district: String = ""
    @State private var latitude: String = ""
    @State private var longitude: String = ""
    @State private var rating: Double = 0.0
    @State private var reviewCount: Int = 0
    @State private var features: [String] = []
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
            locationSection
            contactSection
            ratingSection
            actionButtonsSection
        }
        .navigationTitle("Restoran Düzenle")
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
            Text("Restoran başarıyla güncellendi!")
        }
        .alert("Hata", isPresented: $showError) {
            Button("Tamam", role: .cancel) {}
        } message: {
            Text(errorMessage)
        }
        .alert("Restoranı Sil", isPresented: $showDeleteConfirm) {
            Button("Sil", role: .destructive) { deleteRestaurant() }
            Button("İptal", role: .cancel) {}
        } message: {
            Text("'\(restaurantName)' restoranı kalıcı olarak silinecek. Emin misiniz?")
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
                                    withAnimation { existingImages.removeAll { $0 == imageUrl } }
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
                                    .foregroundColor(.orange)
                                Text("Ekle")
                                    .font(.caption)
                                    .foregroundColor(.orange)
                            }
                            .frame(width: 120, height: 90)
                            .background(Color.orange.opacity(0.1))
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
            TextField("Restoran Adı", text: $restaurantName)
            TextEditor(text: $restaurantDescription)
                .frame(minHeight: 80)
            TextField("Kategori", text: $category)
            TextField("Fiyat Aralığı", text: $priceRange)
            TextField("Çalışma Saatleri", text: $openingHours)
        }
    }
    
    private var locationSection: some View {
        Section(header: Text("Konum")) {
            TextField("Şehir", text: $city)
            TextField("İlçe", text: $district)
            TextField("Adres", text: $address)
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
            TextField("Website", text: $website)
                .keyboardType(.URL)
        }
    }
    
    private var ratingSection: some View {
        Section(header: Text("Değerlendirme")) {
            HStack {
                Text("Puan:")
                Slider(value: $rating, in: 0...5, step: 0.1)
                Text(String(format: "%.1f", rating))
                    .foregroundColor(.orange)
            }
            Stepper("Yorum Sayısı: \(reviewCount)", value: $reviewCount, in: 0...10000)
        }
    }
    
    private var actionButtonsSection: some View {
        Group {
            Section {
                Button(action: updateRestaurant) {
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
                .listRowBackground(Color.orange)
                .foregroundColor(.white)
                .disabled(isProcessing)
            }
            
            Section {
                Button(action: { showDeleteConfirm = true }) {
                    HStack {
                        Spacer()
                        Image(systemName: "trash.fill")
                        Text("Bu Restoranı Sil")
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
        restaurantName = restaurant.name
        restaurantDescription = restaurant.description
        category = restaurant.category ?? ""
        priceRange = restaurant.priceRange ?? ""
        openingHours = restaurant.openingHours ?? ""
        phoneNumber = restaurant.phoneNumber ?? ""
        email = restaurant.email ?? ""
        website = restaurant.website ?? ""
        address = restaurant.address ?? ""
        city = restaurant.city ?? ""
        district = restaurant.district ?? ""
        latitude = String(restaurant.coordinate.latitude)
        longitude = String(restaurant.coordinate.longitude)
        rating = restaurant.rating ?? 0.0
        reviewCount = restaurant.reviewCount ?? 0
        features = restaurant.features ?? []
        existingImages = restaurant.image
    }
    
    func updateRestaurant() {
        guard let restaurantId = restaurant.id else { return }
        isProcessing = true
        
        if newImages.isEmpty {
            saveToFirestore(restaurantId: restaurantId, imageUrls: existingImages)
        } else {
            StorageManager.shared.uploadImages(images: newImages, folder: "restaurants") { newUrls in
                let allImages = self.existingImages + newUrls
                self.saveToFirestore(restaurantId: restaurantId, imageUrls: allImages)
            }
        }
    }
    
    func saveToFirestore(restaurantId: String, imageUrls: [String]) {
        let db = Firestore.firestore()
        
        let data: [String: Any] = [
            "name": restaurantName,
            "description": restaurantDescription,
            "image": imageUrls,
            "coordinate": [
                "latitude": Double(latitude) ?? 0.0,
                "longitude": Double(longitude) ?? 0.0
            ],
            "category": category,
            "priceRange": priceRange,
            "openingHours": openingHours,
            "phoneNumber": phoneNumber,
            "email": email,
            "website": website,
            "address": address,
            "city": city,
            "district": district,
            "rating": rating,
            "reviewCount": reviewCount,
            "features": features
        ]
        
        db.collection("restaurants").document(restaurantId).setData(data) { error in
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
    
    func deleteRestaurant() {
        guard let restaurantId = restaurant.id else { return }
        isProcessing = true
        let db = Firestore.firestore()
        db.collection("restaurants").document(restaurantId).delete { error in
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
class EditRestaurantsViewModel: ObservableObject {
    @Published var restaurants: [RestaurantsModel] = []
    @Published var isLoading = false
    @Published var showError = false
    @Published var errorMessage = ""
    
    func fetchRestaurants() {
        isLoading = true
        Firestore.firestore().collection("restaurants").getDocuments { snapshot, error in
            DispatchQueue.main.async {
                self.isLoading = false
                if let error = error {
                    self.errorMessage = error.localizedDescription
                    self.showError = true
                } else if let snapshot = snapshot {
                    self.restaurants = snapshot.documents.compactMap { doc in
                        try? doc.data(as: RestaurantsModel.self)
                    }
                }
            }
        }
    }
    
    func deleteRestaurant(_ restaurant: RestaurantsModel) {
        guard let id = restaurant.id else { return }
        Firestore.firestore().collection("restaurants").document(id).delete { error in
            if error == nil {
                DispatchQueue.main.async {
                    self.restaurants.removeAll { $0.id == id }
                }
            }
        }
    }
}
