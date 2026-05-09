//
//  AdminPlacesView.swift
//  MesopotamiaWays
//
//  Created by Bilal AYDIN on 22.12.2025.
//

import SwiftUI
import PhotosUI
import FirebaseFirestore

struct AdminPlacesView: View {
    @State private var placeName = ""
    @State private var selectedCity = "Mardin"
    @State private var selectedDistrict = "Artuklu"
    @State private var history = ""
    @State private var age = ""
    @State private var selectedImages: [UIImage] = []
    @State private var latitude = ""
    @State private var longitude = ""
    @State private var videoUrl = ""
    @State private var category = "Tarihi Yapı"
    @State private var entranceFee = ""
    @State private var visitingHours = ""
    @State private var website = ""
    @State private var phoneNumber = ""
    @State private var address = ""
    @State private var interestingFact = ""
    @State private var selectedFeatures: [String] = []
    
    
    @State private var nextId = 5
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
        "Tarihi Yapı", "Antik Kent", "Medrese", "Kale",
        "Kilise", "Cami", "Müze", "Doğal Güzellik",
        "Manastır", "Arkeolojik Alan", "Meydan", "Çarşı"
    ]
    
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
                                    title: "Yer Adı *",
                                    text: $placeName,
                                    placeholder: "Yer adını girin"
                                )
                                
                                CityDistrictPicker(
                                    selectedCity: $selectedCity,
                                    selectedDistrict: $selectedDistrict,
                                    cities: cities,
                                    districtsByCity: districtsByCity
                                )
                                
                                // Kategori
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
                                
                                CustomTextField(
                                    title: "Yaş/Tarih *",
                                    text: $age,
                                    placeholder: "Örn: Yaklaşık 3.000 yaşında",
                                    keyboardType: .default
                                )
                            }
                        }
                        
                        // TARİHİ BİLGİLER
                        CardView(title: "Tarih ve Açıklama") {
                            VStack(spacing: 16) {
                                CustomTextField(
                                    title: "Tarihi Bilgi *",
                                    text: $history,
                                    placeholder: "Yer hakkında detaylı tarihi bilgi",
                                    isMultiline: true
                                )
                                
                                CustomTextField(
                                    title: "İlginç Bilgi",
                                    text: $interestingFact,
                                    placeholder: "Yer hakkında ilginç bir bilgi ekleyin",
                                    isMultiline: true
                                )
                            }
                        }
                        
                        // RESİM EKLEME
                        CardView(title: "Görseller") {
                            ImagePickerSection(
                                selectedImages: $selectedImages,
                                showingImagePicker: $showingImagePicker
                            )
                        }
                        
                        // VİDEO BAĞLANTISI
                        CardView(title: "Video Bağlantısı") {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Video URL")
                                    .font(.subheadline)
                                    .foregroundColor(.primary)
                                
                                HStack {
                                    Image(systemName: "play.circle.fill")
                                        .foregroundColor(.purple)
                                    
                                    TextField("YouTube veya video bağlantısı", text: $videoUrl)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                        .keyboardType(.URL)
                                        .autocapitalization(.none)
                                }
                                
                                if !videoUrl.isEmpty {
                                    Text("YouTube URL örneği: https://youtube.com/watch?v=...")
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                        .padding(.top, 4)
                                }
                            }
                        }
                        
                        // ZİYARET BİLGİLERİ
                        CardView(title: "Ziyaret Bilgileri") {
                            VStack(spacing: 16) {
                                CustomTextField(
                                    title: "Giriş Ücreti",
                                    text: $entranceFee,
                                    placeholder: "Örn: Ücretsiz veya 50₺",
                                    keyboardType: .default
                                )
                                
                                CustomTextField(
                                    title: "Ziyaret Saatleri",
                                    text: $visitingHours,
                                    placeholder: "Örn: 08:00 - 19:00",
                                    keyboardType: .default
                                )
                                
                                CustomTextField(
                                    title: "Website",
                                    text: $website,
                                    placeholder: "www.ornek.com",
                                    keyboardType: .URL
                                )
                                
                                CustomTextField(
                                    title: "Telefon",
                                    text: $phoneNumber,
                                    placeholder: "+90 555 123 4567",
                                    keyboardType: .phonePad
                                )
                            }
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
                                
                                CustomTextField(
                                    title: "Adres",
                                    text: $address,
                                    placeholder: "Mahalle, Cadde, No, İlçe/Şehir",
                                    isMultiline: true
                                )
                            }
                        }
                        
                        // ÖZELLİKLER
                        CardView(title: "Yer Özellikleri") {
                            PlaceFeaturesView(selectedFeatures: $selectedFeatures)
                        }
                    }
                    .padding(.horizontal)
                    
                    // EKLE BUTONU
                    VStack(spacing: 12) {
                        Button(action: addPlace) {
                            if isProcessing {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .frame(height: 20)
                            } else {
                                HStack {
                                    Image(systemName: "building.columns.circle.fill")
                                    Text("Yer Ekle")
                                        .fontWeight(.semibold)
                                }
                            }
                        }
                        .disabled(!isFormValid || isProcessing)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(isFormValid ? Color.purple : Color.gray)
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
            .navigationTitle("Yeni Tarihi Yer Ekle")
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
                Text("Tarihi yer başarıyla eklendi!\nID: \(nextId - 1)")
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
        !placeName.isEmpty &&
        !selectedDistrict.isEmpty &&
        !history.isEmpty &&
        !age.isEmpty &&
        !selectedImages.isEmpty &&
        !latitude.isEmpty &&
        !longitude.isEmpty
    }
    
    func addPlace() {
        guard validateForm() else {
            return
        }
        
        isProcessing = true
        
        StorageManager.shared.uploadImages(images: selectedImages, folder: "places") { urls in
            if urls.isEmpty {
                self.validationMessage = "Resimler yüklenirken bir hata oluştu."
                self.showValidationError = true
                self.isProcessing = false
                return
            }
            
            let db = Firestore.firestore()
            let newPlaceRef = db.collection("places").document()
            
            let placeData: [String: Any] = [
                // "id": newPlaceRef.documentID,
                "name": placeName,
                "history": history,
                "age": age,
                "imageName": urls,
                "coordinates": [
                    "latitude": Double(latitude) ?? 0.0,
                    "longitude": Double(longitude) ?? 0.0
                ],
                "videoUrl": videoUrl,
                "category": category,
                "entranceFee": entranceFee,
                "visitingHours": visitingHours,
                "website": website,
                "phoneNumber": phoneNumber,
                "address": address,
                "interestingFact": interestingFact,
                "features": selectedFeatures
            ]
            
            newPlaceRef.setData(placeData) { error in
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
        if placeName.isEmpty {
            validationMessage = "Yer adı boş olamaz"
            showValidationError = true
            return false
        }
        
        if history.isEmpty {
            validationMessage = "Tarihi bilgi boş olamaz"
            showValidationError = true
            return false
        }
        
        if age.isEmpty {
            validationMessage = "Yaş/tarih bilgisi boş olamaz"
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
        
        let trimmedVideoUrl = videoUrl.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmedVideoUrl.isEmpty && !isValidURL(trimmedVideoUrl) {
            validationMessage = "Geçerli bir video URL'si giriniz"
            showValidationError = true
            return false
        }
        
        let trimmedWebsite = website.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmedWebsite.isEmpty && !isValidURL(trimmedWebsite) {
            validationMessage = "Geçerli bir website URL'si giriniz"
            showValidationError = true
            return false
        }
        
        return true
    }
    
    func isValidURL(_ string: String) -> Bool {
        let trimmedString = string.trimmingCharacters(in: .whitespacesAndNewlines)
        // Eğer kullanıcı http:// eklemeyi unuttuysa ama geçerli bir metinse onu kurtarmaya çalışalım
        let urlString = trimmedString.lowercased().hasPrefix("http") ? trimmedString : "https://\(trimmedString)"
        guard let url = URL(string: urlString) else { return false }
        return url.scheme == "http" || url.scheme == "https"
    }
    
    func clearForm() {
        placeName = ""
        selectedCity = "Mardin"
        selectedDistrict = "Artuklu"
        history = ""
        age = ""
        selectedImages.removeAll()
        latitude = ""
        longitude = ""
        videoUrl = ""
        category = "Tarihi Yapı"
        entranceFee = ""
        visitingHours = ""
        website = ""
        phoneNumber = ""
        address = ""
        interestingFact = ""
    }
}

// MARK: - Yer Özellikleri Bileşeni
struct PlaceFeaturesView: View {
    @Binding var selectedFeatures: [String]
    
    let features = [
        ("Rehberli Tur", "person.fill"),
        ("Sesli Rehber", "headphones"),
        ("Fotoğraf Çekimi", "camera.fill"),
        ("Gece Aydınlatması", "lightbulb.fill"),
        ("Park Alanı", "car.fill"),
        ("Kafe/Restoran", "fork.knife"),
        ("Hediyelik Eşya", "bag.fill"),
        ("Tuvalet", "toilet.fill"),
        ("Engelsiz Erişim", "figure.roll"),
        ("Wi-Fi", "wifi"),
        ("Grup Ziyareti", "person.3.fill"),
        ("Öğrenci İndirimi", "graduationcap.fill"),
        ("Aile Dostu", "heart.fill"),
        ("Kredi Kartı", "creditcard.fill"),
        ("Nakit Ödeme", "banknote.fill")
    ]
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Yer Özellikleri")
                .font(.subheadline)
                .foregroundColor(.primary)
            
            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(features, id: \.0) { feature in
                    PlaceFeatureChip(
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

struct PlaceFeatureChip: View {
    let title: String
    let iconName: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: iconName)
                    .font(.caption)
                    .foregroundColor(isSelected ? .white : .purple)
                    .frame(width: 32, height: 32)
                    .background(isSelected ? Color.purple : Color.purple.opacity(0.1))
                    .cornerRadius(8)
                
                Text(title)
                    .font(.caption2)
                    .multilineTextAlignment(.center)
                    .foregroundColor(isSelected ? .purple : .primary)
                    .lineLimit(2)
            }
            .frame(maxWidth: .infinity)
        }
    }
}



// MARK: - Önizleme
struct AdminPlacesView_Previews: PreviewProvider {
    static var previews: some View {
        AdminPlacesView()
    }
}
