//
//  AdminHotelView.swift
//  MesopotamiaTraveler
//
//  Created by Bilal AYDIN on 28.11.2025.
//

import SwiftUI
import PhotosUI

struct AdminHotelView: View {
    @State private var hotelName = ""
    @State private var selectedCity = "Mardin"
    @State private var selectedDistrict = "Artuklu"
    @State private var shortDescription = ""
    @State private var hotelDescription = ""
    @State private var selectedImages: [UIImage] = []
    @State private var starCount = 3
    @State private var rating = 0.0
    @State private var reviewCount = 0
    @State private var priceOnePerson = ""
    @State private var priceTwoPeople = ""
    @State private var latitude = ""
    @State private var longitude = ""
    @State private var phoneNumber = ""
    @State private var email = ""
    @State private var address = ""
    
    @State private var nextId = 4
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
    
    // Mevcut İlçeler
    var currentDistricts: [String] {
        districtsByCity[selectedCity] ?? ["Artuklu"]
    }
    
    // Olanaklar
    let amenitiesOptions = [
        "wifi", "parking", "breakfast", "pool",
        "spa", "fitness", "terrace", "airConditioning",
        "restaurant", "bar", "roomService", "laundry",
        "businessCenter", "concierge", "airportShuttle"
    ]
    
    @State private var selectedAmenities: [String] = []
    
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
                                    title: "Otel Adı *",
                                    text: $hotelName,
                                    placeholder: "Otel adını girin"
                                )
                                
                                CityDistrictPicker(
                                    selectedCity: $selectedCity,
                                    selectedDistrict: $selectedDistrict,
                                    cities: cities,
                                    districtsByCity: districtsByCity
                                )
                            }
                        }
                        
                        // AÇIKLAMALAR
                        CardView(title: "Açıklamalar") {
                            VStack(spacing: 16) {
                                CustomTextField(
                                    title: "Kısa Açıklama *",
                                    text: $shortDescription,
                                    placeholder: "Kısa ve öz açıklama",
                                    isMultiline: true
                                )
                                
                                CustomTextField(
                                    title: "Detaylı Açıklama *",
                                    text: $hotelDescription,
                                    placeholder: "Detaylı otel açıklaması",
                                    isMultiline: true
                                )
                            }
                        }
                        
                        // RESİM EKLEME
                        CardView(title: "Resimler") {
                            ImagePickerSection(selectedImages: $selectedImages, showingImagePicker: $showingImagePicker)
                        }
                        
                        // DEĞERLENDİRME
                        CardView(title: "Değerlendirme") {
                            VStack(spacing: 16) {
                                StarRatingView(starCount: $starCount)
                                
                                CustomSlider(
                                    title: "Puan: \(String(format: "%.1f", rating))",
                                    value: $rating,
                                    range: 0...5,
                                    step: 0.1
                                )
                                
                                CustomStepper(
                                    title: "Değerlendirme Sayısı",
                                    value: $reviewCount,
                                    range: 0...1000
                                )
                            }
                        }
                        
                        // FİYATLAR
                        CardView(title: "Fiyatlar (₺)") {
                            PriceSection(priceOnePerson: $priceOnePerson, priceTwoPeople: $priceTwoPeople)
                        }
                        
                        // KONUM BİLGİLERİ
                        CardView(title: "Konum Bilgileri") {
                            LocationSection(latitude: $latitude, longitude: $longitude, selectedCity: selectedCity)
                        }
                        
                        // İLETİŞİM BİLGİLERİ
                        CardView(title: "İletişim Bilgileri") {
                            ContactSection(phoneNumber: $phoneNumber, email: $email, address: $address)
                        }
                        
                        // OLANAKLAR
                        CardView(title: "Olanaklar") {
                            AmenitiesSelectionView(
                                selectedAmenities: $selectedAmenities,
                                options: amenitiesOptions
                            )
                        }
                    }
                    .padding(.horizontal)
                    
                    // EKLE BUTONU
                    VStack(spacing: 12) {
                        Button(action: addHotel) {
                            if isProcessing {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .frame(height: 20)
                            } else {
                                HStack {
                                    Image(systemName: "plus.circle.fill")
                                    Text("Otel Ekle")
                                        .fontWeight(.semibold)
                                }
                            }
                        }
                        .disabled(!isFormValid || isProcessing)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(isFormValid ? Color.blue : Color.gray)
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
            .navigationTitle("Yeni Otel Ekle")
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
                Text("Otel başarıyla eklendi!\nID: \(nextId - 1)")
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
        !hotelName.isEmpty &&
        !selectedDistrict.isEmpty &&
        !shortDescription.isEmpty &&
        !hotelDescription.isEmpty &&
        !selectedImages.isEmpty &&
        !priceOnePerson.isEmpty &&
        !priceTwoPeople.isEmpty &&
        !latitude.isEmpty &&
        !longitude.isEmpty &&
        !phoneNumber.isEmpty &&
        !email.isEmpty &&
        !address.isEmpty
    }
    
    func addHotel() {
        guard validateForm() else {
            return
        }
        
        isProcessing = true
        
        // Burada Firebase'e kaydetme işlemi yapılacak
        // Önce resimleri Firebase Storage'a yükle
        // Sonra otel bilgilerini Firestore'a kaydet
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            // ID'yi artır
            nextId += 1
            
            // Başarı mesajı göster
            showSuccessAlert = true
            
            // Formu temizle
            clearForm()
            
            isProcessing = false
        }
    }
    
    func validateForm() -> Bool {
        // Temel validasyonlar
        if hotelName.isEmpty {
            validationMessage = "Otel adı boş olamaz"
            showValidationError = true
            return false
        }
        
        if selectedImages.isEmpty {
            validationMessage = "En az 1 resim eklemelisiniz"
            showValidationError = true
            return false
        }
        
        guard let price1 = Double(priceOnePerson),
              let price2 = Double(priceTwoPeople) else {
            validationMessage = "Geçerli fiyat giriniz"
            showValidationError = true
            return false
        }
        
        if price2 <= price1 {
            validationMessage = "2 kişilik fiyat, 1 kişilikten yüksek olmalı"
            showValidationError = true
            return false
        }
        
        guard let _ = Double(latitude),
              let _ = Double(longitude) else {
            validationMessage = "Geçerli koordinat giriniz"
            showValidationError = true
            return false
        }
        
        if !email.contains("@") || !email.contains(".") {
            validationMessage = "Geçerli bir email adresi giriniz"
            showValidationError = true
            return false
        }
        
        if phoneNumber.count < 10 {
            validationMessage = "Geçerli bir telefon numarası giriniz"
            showValidationError = true
            return false
        }
        
        return true
    }
    
    func clearForm() {
        hotelName = ""
        selectedCity = "Mardin"
        selectedDistrict = "Artuklu"
        shortDescription = ""
        hotelDescription = ""
        selectedImages.removeAll()
        starCount = 3
        rating = 0.0
        reviewCount = 0
        priceOnePerson = ""
        priceTwoPeople = ""
        latitude = ""
        longitude = ""
        phoneNumber = ""
        email = ""
        address = ""
        selectedAmenities.removeAll()
    }
}

// MARK: - Image Picker
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var images: [UIImage]
    @Environment(\.presentationMode) var presentationMode
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.filter = .images
        config.selectionLimit = 10
        config.preferredAssetRepresentationMode = .current
        
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            parent.presentationMode.wrappedValue.dismiss()
            
            for result in results {
                result.itemProvider.loadObject(ofClass: UIImage.self) { (object, error) in
                    if let image = object as? UIImage {
                        DispatchQueue.main.async {
                            self.parent.images.append(image)
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Bölümler (Sections)

struct ImagePickerSection: View {
    @Binding var selectedImages: [UIImage]
    @Binding var showingImagePicker: Bool
    
    var body: some View {
        VStack(spacing: 12) {
            // Seçilen resimler grid
            if !selectedImages.isEmpty {
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 8) {
                    ForEach(0..<selectedImages.count, id: \.self) { index in
                        Image(uiImage: selectedImages[index])
                            .resizable()
                            .scaledToFill()
                            .frame(width: 80, height: 80)
                            .cornerRadius(8)
                            .clipped()
                            .overlay(
                                Button(action: {
                                    selectedImages.remove(at: index)
                                }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.red)
                                        .background(Color.white)
                                        .clipShape(Circle())
                                }
                                .offset(x: 8, y: -8),
                                alignment: .topTrailing
                            )
                    }
                }
                .padding(.bottom, 8)
            }
            
            // Resim Ekle Butonu
            Button(action: {
                showingImagePicker = true
            }) {
                HStack {
                    Image(systemName: "photo.on.rectangle")
                    Text("Resim Ekle")
                        .fontWeight(.medium)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(Color.blue.opacity(0.1))
                .foregroundColor(.blue)
                .cornerRadius(8)
            }
            
            Text("\(selectedImages.count) resim seçildi")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

struct PriceSection: View {
    @Binding var priceOnePerson: String
    @Binding var priceTwoPeople: String
    
    var body: some View {
        VStack(spacing: 12) {
            CustomTextField(
                title: "1 Kişilik Fiyat *",
                text: $priceOnePerson,
                placeholder: "0.00",
                keyboardType: .decimalPad
            )
            
            CustomTextField(
                title: "2 Kişilik Fiyat *",
                text: $priceTwoPeople,
                placeholder: "0.00",
                keyboardType: .decimalPad
            )
            
            if !priceOnePerson.isEmpty && !priceTwoPeople.isEmpty {
                let price1 = Double(priceOnePerson) ?? 0
                let price2 = Double(priceTwoPeople) ?? 0
                
                if price2 <= price1 {
                    Text("⚠️ 2 kişilik fiyat, 1 kişilikten yüksek olmalı")
                        .font(.caption)
                        .foregroundColor(.red)
                }
            }
        }
    }
}

struct LocationSection: View {
    @Binding var latitude: String
    @Binding var longitude: String
    let selectedCity: String
    
    var body: some View {
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
}

struct ContactSection: View {
    @Binding var phoneNumber: String
    @Binding var email: String
    @Binding var address: String
    
    var body: some View {
        VStack(spacing: 16) {
            CustomTextField(
                title: "Telefon *",
                text: $phoneNumber,
                placeholder: "+90 555 123 4567",
                keyboardType: .phonePad
            )
            
            CustomTextField(
                title: "Email *",
                text: $email,
                placeholder: "info@otel.com",
                keyboardType: .emailAddress
            )
            
            CustomTextField(
                title: "Adres *",
                text: $address,
                placeholder: "Mahalle, Cadde, No, İlçe/Şehir",
                isMultiline: true
            )
        }
    }
}

// MARK: - Özel Bileşenler

struct CardView<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
                .foregroundColor(.primary)
                .padding(.horizontal, 4)
            
            content
                .padding(16)
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
        }
    }
}

struct CustomTextField: View {
    let title: String
    @Binding var text: String
    let placeholder: String
    var keyboardType: UIKeyboardType = .default
    var isMultiline: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.primary)
            
            if isMultiline {
                TextEditor(text: $text)
                    .frame(minHeight: 80, maxHeight: 120)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color(.systemGray4), lineWidth: 1)
                    )
                    .overlay(
                        Group {
                            if text.isEmpty {
                                Text(placeholder)
                                    .foregroundColor(.gray)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 8)
                            }
                        },
                        alignment: .topLeading
                    )
            } else {
                TextField(placeholder, text: $text)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(keyboardType)
            }
        }
    }
}

struct CityDistrictPicker: View {
    @Binding var selectedCity: String
    @Binding var selectedDistrict: String
    let cities: [String]
    let districtsByCity: [String: [String]]
    
    var currentDistricts: [String] {
        districtsByCity[selectedCity] ?? []
    }
    
    var body: some View {
        VStack(spacing: 16) {
            // Şehir Picker
            VStack(alignment: .leading, spacing: 6) {
                Text("Şehir")
                    .font(.subheadline)
                    .foregroundColor(.primary)
                
                Picker("Şehir Seçin", selection: $selectedCity) {
                    ForEach(cities, id: \.self) { city in
                        Text(city).tag(city)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .onChange(of: selectedCity) { _ in
                    // Şehir değişince ilçeyi sıfırla
                    if let firstDistrict = currentDistricts.first {
                        selectedDistrict = firstDistrict
                    }
                }
            }
            
            // İlçe Picker
            VStack(alignment: .leading, spacing: 6) {
                Text("İlçe *")
                    .font(.subheadline)
                    .foregroundColor(.primary)
                
                Picker("İlçe Seçin", selection: $selectedDistrict) {
                    ForEach(currentDistricts, id: \.self) { district in
                        Text(district).tag(district)
                    }
                }
                .pickerStyle(MenuPickerStyle())
            }
        }
    }
}

struct StarRatingView: View {
    @Binding var starCount: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Yıldız Sayısı")
                .font(.subheadline)
                .foregroundColor(.primary)
            
            HStack(spacing: 4) {
                ForEach(1...5, id: \.self) { star in
                    Button(action: {
                        starCount = star
                    }) {
                        Image(systemName: star <= starCount ? "star.fill" : "star")
                            .font(.title2)
                            .foregroundColor(star <= starCount ? .orange : .gray)
                    }
                }
                
                Spacer()
                
                Text("\(starCount) Yıldız")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
}

struct CustomSlider: View {
    let title: String
    @Binding var value: Double
    let range: ClosedRange<Double>
    let step: Double
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.primary)
            
            Slider(value: $value, in: range, step: step)
            
            HStack {
                Text("\(range.lowerBound, specifier: "%.1f")")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text("\(range.upperBound, specifier: "%.1f")")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
}

struct CustomStepper: View {
    let title: String
    @Binding var value: Int
    let range: ClosedRange<Int>
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.primary)
            
            Stepper(value: $value, in: range) {
                Text("\(value)")
                    .font(.body)
                    .fontWeight(.medium)
            }
        }
    }
}

struct CoordinateHelpView: View {
    let city: String
    
    var sampleCoordinates: (String, String) {
        switch city {
        case "Mardin":
            return ("37.31", "40.72")
        case "Diyarbakır":
            return ("37.91", "40.24")
        case "Şanlıurfa":
            return ("37.16", "38.80")
        default:
            return ("0", "0")
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Örnek koordinatlar (\(city)):")
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text("Merkez: \(sampleCoordinates.0), \(sampleCoordinates.1)")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
    }
}

struct AmenitiesSelectionView: View {
    @Binding var selectedAmenities: [String]
    let options: [String]
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(options, id: \.self) { amenity in
                    AdminAmenityChip(
                        amenity: amenity,
                        isSelected: selectedAmenities.contains(amenity),
                        action: {
                            if selectedAmenities.contains(amenity) {
                                selectedAmenities.removeAll { $0 == amenity }
                            } else {
                                selectedAmenities.append(amenity)
                            }
                        }
                    )
                }
            }
            
            if !selectedAmenities.isEmpty {
                Text("Seçilenler: \(selectedAmenities.joined(separator: ", "))")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
}

struct AdminAmenityChip: View {
    let amenity: String
    let isSelected: Bool
    let action: () -> Void
    
    var iconName: String {
        switch amenity.lowercased() {
        case "wifi": return "wifi"
        case "parking": return "car.fill"
        case "breakfast": return "fork.knife"
        case "pool": return "figure.pool.swim"
        case "spa": return "leaf.fill"
        case "fitness": return "dumbbell.fill"
        case "terrace": return "sun.max.fill"
        case "airconditioning": return "snowflake"
        case "restaurant": return "fork.knife.circle"
        case "bar": return "wineglass"
        case "roomservice": return "bell.fill"
        case "laundry": return "washer.fill"
        case "businesscenter": return "briefcase.fill"
        case "concierge": return "person.fill"
        case "airportshuttle": return "bus.fill"
        default: return "checkmark.circle.fill"
        }
    }
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: iconName)
                    .font(.caption)
                    .foregroundColor(isSelected ? .white : .blue)
                    .frame(width: 32, height: 32)
                    .background(isSelected ? Color.blue : Color.blue.opacity(0.1))
                    .cornerRadius(8)
                
                Text(amenity.localizedCapitalized)
                    .font(.caption2)
                    .multilineTextAlignment(.center)
                    .foregroundColor(isSelected ? .blue : .primary)
                    .lineLimit(2)
            }
            .frame(maxWidth: .infinity)
        }
    }
}

// MARK: - Önizleme
struct AdminHotelView_Previews: PreviewProvider {
    static var previews: some View {
        AdminHotelView()
    }
}
