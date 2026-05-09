//
//  AdminRestaurantsView.swift
//  MesopotamiaWays
//
//  Created by Bilal AYDIN on 22.12.2025.
//

//
//  AdminRestaurantsView.swift
//  MesopotamiaTraveler
//
//  Created by Bilal AYDIN on 1.12.2025.
//

import SwiftUI
import PhotosUI
import FirebaseFirestore

struct AdminRestaurantsView: View {
    @State private var restaurantName = ""
    @State private var selectedCity = "Mardin"
    @State private var selectedDistrict = "Artuklu"
    @State private var restaurantDescription = ""
    @State private var selectedImages: [UIImage] = []
    @State private var latitude = ""
    @State private var longitude = ""
    @State private var phoneNumber = ""
    @State private var email = ""
    @State private var address = ""
    @State private var category = "Lokanta"
    @State private var priceRange = "₺₺"
    @State private var openingHours = ""
    @State private var website = ""
    @State private var rating = 0.0
    @State private var reviewCount = 0
    @State private var selectedFeatures: [String] = []
    
    @State private var nextId = 3
    @State private var showSuccessAlert = false
    @State private var showValidationError = false
    @State private var validationMessage = ""
    @State private var showingImagePicker = false
    @State private var isProcessing = false
    
    // Şehir ve İlçe Verileri
    let cities = ["Mardin", "Diyarbakır", "Şanlıurfa"]
    
    let districtsByCity: [String: [String]] = [
        "Mardin": ["Artuklu", "Midyat", "Nusaybin", "Kızıltepe", "Derik", "Mazıdağı", "Dargeçit", "Savur", "Ömerli", "Yeşilli"],
        "Diyarbakır": ["Bağlar", "Kayapınar", "Sur", "Yenişehir", "Bismil", "Çermik", "Çınar", "Çüngüş", "Dicle", "Eğil", "Ergani", "Hani", "Hazro", "Kocaköy", "Kulp", "Lice", "Silvan"],
        "Şanlıurfa": ["Haliliye", "Eyyübiye", "Karaköprü", "Akçakale", "Birecik", "Bozova", "Ceylanpınar", "Halfeti", "Harran", "Hilvan", "Siverek", "Suruç", "Viranşehir"]
    ]
    
    // Kategoriler
    let categories = [
        "Lokanta", "Restoran", "Kafe", "Pastane", "Fast Food",
        "Kahvaltı", "Kebap", "Tatlı", "Deniz Ürünleri", "Dünya Mutfağı"
    ]
    
    // Fiyat Aralıkları
    let priceRanges = ["₺", "₺₺", "₺₺₺", "₺₺₺₺"]
    
    var currentDistricts: [String] {
        districtsByCity[selectedCity] ?? ["Artuklu"]
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Form Alanları
                    VStack(spacing: 16) {
                        // TEMEL BİLGİLER
                        CardView(title: "Temel Bilgiler") {
                            VStack(spacing: 16) {
                                CustomTextField(
                                    title: "Restoran Adı *",
                                    text: $restaurantName,
                                    placeholder: "Restoran adını girin"
                                )
                                
                                CityDistrictPicker(
                                    selectedCity: $selectedCity,
                                    selectedDistrict: $selectedDistrict,
                                    cities: cities,
                                    districtsByCity: districtsByCity
                                )
                                
                                // Kategori ve Fiyat Aralığı
                                HStack(spacing: 12) {
                                    VStack(alignment: .leading, spacing: 6) {
                                        Text("Kategori")
                                            .font(.subheadline)
                                            .foregroundColor(.primary)
                                        
                                        Picker("Kategori", selection: $category) {
                                            ForEach(categories, id: \.self) { cat in
                                                Text(cat).tag(cat)
                                            }
                                        }
                                        .pickerStyle(MenuPickerStyle())
                                    }
                                    
                                    VStack(alignment: .leading, spacing: 6) {
                                        Text("Fiyat Aralığı")
                                            .font(.subheadline)
                                            .foregroundColor(.primary)
                                        
                                        Picker("Fiyat", selection: $priceRange) {
                                            ForEach(priceRanges, id: \.self) { range in
                                                Text(range).tag(range)
                                            }
                                        }
                                        .pickerStyle(MenuPickerStyle())
                                    }
                                }
                            }
                        }
                        
                        // AÇIKLAMA
                        CardView(title: "Açıklama") {
                            CustomTextField(
                                title: "Restoran Açıklaması *",
                                text: $restaurantDescription,
                                placeholder: "Restoran hakkında detaylı açıklama",
                                isMultiline: true
                            )
                        }
                        
                        // RESİM EKLEME
                        CardView(title: "Restoran Görselleri") {
                            ImagePickerSection(
                                selectedImages: $selectedImages,
                                showingImagePicker: $showingImagePicker
                            )
                        }
                        
                        // DEĞERLENDİRME
                        CardView(title: "Değerlendirme") {
                            VStack(spacing: 16) {
                                CustomSlider(
                                    title: "Puan: \(String(format: "%.1f", rating))",
                                    value: $rating,
                                    range: 0...5,
                                    step: 0.1
                                )
                                
                                CustomStepper(
                                    title: "Değerlendirme Sayısı",
                                    value: $reviewCount,
                                    range: 0...10000
                                )
                            }
                        }
                        
                        // ÇALIŞMA SAATLERİ
                        CardView(title: "Çalışma Saatleri") {
                            CustomTextField(
                                title: "Çalışma Saatleri",
                                text: $openingHours,
                                placeholder: "Örn: 08:00 - 23:00",
                                keyboardType: .default
                            )
                        }
                        
                        // KONUM BİLGİLERİ
                        CardView(title: "Konum Bilgileri") {
                            VStack(spacing: 16) {
                                HStack(spacing: 12) {
                                    CustomTextField(
                                        title: "Enlem *",
                                        text: $latitude,
                                        placeholder: "37.3102",
                                        keyboardType: .numbersAndPunctuation
                                    )
                                    
                                    CustomTextField(
                                        title: "Boylam *",
                                        text: $longitude,
                                        placeholder: "40.7296",
                                        keyboardType: .numbersAndPunctuation
                                    )
                                }
                                
                                if !latitude.isEmpty || !longitude.isEmpty {
                                    CoordinateHelpView(city: selectedCity)
                                }
                            }
                        }
                        
                        // İLETİŞİM BİLGİLERİ
                        CardView(title: "İletişim Bilgileri") {
                            VStack(spacing: 16) {
                                CustomTextField(
                                    title: "Telefon *",
                                    text: $phoneNumber,
                                    placeholder: "+90 555 123 4567",
                                    keyboardType: .phonePad
                                )
                                
                                CustomTextField(
                                    title: "Email",
                                    text: $email,
                                    placeholder: "info@restoran.com",
                                    keyboardType: .emailAddress
                                )
                                
                                CustomTextField(
                                    title: "Website",
                                    text: $website,
                                    placeholder: "www.restoran.com",
                                    keyboardType: .URL
                                )
                                
                                CustomTextField(
                                    title: "Adres *",
                                    text: $address,
                                    placeholder: "Mahalle, Cadde, No, İlçe/Şehir",
                                    isMultiline: true
                                )
                            }
                        }
                        
                        // ÖZELLİKLER
                        CardView(title: "Restoran Özellikleri") {
                            RestaurantFeaturesView(selectedFeatures: $selectedFeatures)
                        }
                    }
                    .padding(.horizontal)
                    
                    // EKLE BUTONU
                    VStack(spacing: 12) {
                        Button(action: addRestaurant) {
                            if isProcessing {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .frame(height: 20)
                            } else {
                                HStack {
                                    Image(systemName: "fork.knife.circle.fill")
                                    Text("Restoran Ekle")
                                        .fontWeight(.semibold)
                                }
                            }
                        }
                        .disabled(!isFormValid || isProcessing)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(isFormValid ? Color.green : Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        .padding(.horizontal)
                        
                        if !isFormValid {
                            Text("Tüm zorunlu alanları doldurun (*)")
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                    }
                    .padding(.bottom, 30)
                }
                .padding(.top)
            }
            .navigationTitle("Yeni Restoran Ekle")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Temizle") {
                        clearForm()
                    }
                }
            }
            .sheet(isPresented: $showingImagePicker) {
                ImagePicker(images: $selectedImages)
            }
            .alert("Başarılı!", isPresented: $showSuccessAlert) {
                Button("Tamam", role: .cancel) { }
            } message: {
                Text("Restoran başarıyla eklendi!\nID: \(nextId - 1)")
            }
            .alert("Hata", isPresented: $showValidationError) {
                Button("Tamam", role: .cancel) { }
            } message: {
                Text(validationMessage)
            }
        }
    }
    
    // FORM VALIDATION
    var isFormValid: Bool {
        !restaurantName.isEmpty &&
        !selectedDistrict.isEmpty &&
        !restaurantDescription.isEmpty &&
        !selectedImages.isEmpty &&
        !latitude.isEmpty &&
        !longitude.isEmpty &&
        !phoneNumber.isEmpty &&
        !address.isEmpty
    }
    
    func addRestaurant() {
        guard validateForm() else {
            return
        }
        
        isProcessing = true
        
        StorageManager.shared.uploadImages(images: selectedImages, folder: "restaurants") { urls in
            if urls.isEmpty {
                self.validationMessage = "Resimler yüklenirken bir hata oluştu."
                self.showValidationError = true
                self.isProcessing = false
                return
            }
            
            let db = Firestore.firestore()
            let newRef = db.collection("restaurants").document()
            
            let restaurantData: [String: Any] = [
                // "id": newRef.documentID,
                "name": restaurantName,
                "description": restaurantDescription,
                "image": urls,
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
                "city": selectedCity,
                "district": selectedDistrict,
                "rating": rating,
                "reviewCount": reviewCount,
                "features": selectedFeatures
            ]
            
            newRef.setData(restaurantData) { error in
                DispatchQueue.main.async {
                    self.isProcessing = false
                    if let error = error {
                        self.validationMessage = "Firestore'a kaydedilirken hata oluştu: \(error.localizedDescription)"
                        self.showValidationError = true
                    } else {
                        self.showSuccessAlert = true
                        self.clearForm()
                    }
                }
            }
        }
    }
    
    func validateForm() -> Bool {
        // Temel validasyonlar
        if restaurantName.isEmpty {
            validationMessage = "Restoran adı boş olamaz"
            showValidationError = true
            return false
        }
        
        if selectedImages.isEmpty {
            validationMessage = "En az 1 resim eklemelisiniz"
            showValidationError = true
            return false
        }
        
        guard let _ = Double(latitude),
              let _ = Double(longitude) else {
            validationMessage = "Geçerli koordinat giriniz"
            showValidationError = true
            return false
        }
        
        if phoneNumber.count < 10 {
            validationMessage = "Geçerli bir telefon numarası giriniz"
            showValidationError = true
            return false
        }
        
        if !email.isEmpty && (!email.contains("@") || !email.contains(".")) {
            validationMessage = "Geçerli bir email adresi giriniz"
            showValidationError = true
            return false
        }
        
        return true
    }
    
    func clearForm() {
        restaurantName = ""
        selectedCity = "Mardin"
        selectedDistrict = "Artuklu"
        restaurantDescription = ""
        selectedImages.removeAll()
        latitude = ""
        longitude = ""
        phoneNumber = ""
        email = ""
        website = ""
        address = ""
        category = "Lokanta"
        priceRange = "₺₺"
        openingHours = ""
        rating = 0.0
        reviewCount = 0
    }
}

// MARK: - Restoran Özellikleri Bileşeni
struct RestaurantFeaturesView: View {
    @Binding var selectedFeatures: [String]
    
    let features = [
        ("Wi-Fi", "wifi"),
        ("Park", "car.fill"),
        ("Teras", "sun.max.fill"),
        ("Açık Hava", "leaf.fill"),
        ("Aile Dostu", "person.2.fill"),
        ("Romantik", "heart.fill"),
        ("İş Toplantısı", "briefcase.fill"),
        ("Doğum Günü", "birthday.cake.fill"),
        ("Canlı Müzik", "music.note"),
        ("Alkollü", "wineglass.fill"),
        ("Sigara Alanı", "smoke.fill"),
        ("Engelsiz", "figure.roll"),
        ("Otopark", "parkingsign"),
        ("Kredi Kartı", "creditcard.fill"),
        ("Nakit", "banknote.fill")
    ]
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Restoran Özellikleri")
                .font(.subheadline)
                .foregroundColor(.primary)
            
            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(features, id: \.0) { feature in
                    FeatureChip(
                        title: feature.0,
                        iconName: feature.1,
                        isSelected: selectedFeatures.contains(feature.0),
                        action: {
                            if selectedFeatures.contains(feature.0) {
                                selectedFeatures.removeAll { $0 == feature.0 }
                            } else {
                                selectedFeatures.append(feature.0)
                            }
                        }
                    )
                }
            }
            
            if !selectedFeatures.isEmpty {
                Text("Seçilenler: \(selectedFeatures.joined(separator: ", "))")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.top, 4)
            }
        }
    }
}

struct FeatureChip: View {
    let title: String
    let iconName: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: iconName)
                    .font(.caption)
                    .foregroundColor(isSelected ? .white : .green)
                    .frame(width: 32, height: 32)
                    .background(isSelected ? Color.green : Color.green.opacity(0.1))
                    .cornerRadius(8)
                
                Text(title)
                    .font(.caption2)
                    .multilineTextAlignment(.center)
                    .foregroundColor(isSelected ? .green : .primary)
                    .lineLimit(2)
            }
            .frame(maxWidth: .infinity)
        }
    }
}

// MARK: - Önizleme
struct AdminRestaurantsView_Previews: PreviewProvider {
    static var previews: some View {
        AdminRestaurantsView()
    }
}
