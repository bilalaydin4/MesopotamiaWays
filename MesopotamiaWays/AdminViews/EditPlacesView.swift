//
//  EditPlacesView.swift
//  MesopotamiaWays
//
//  Admin panelinden yerleri düzenleme/silme sayfası
//

import SwiftUI
import SDWebImageSwiftUI
import PhotosUI
import FirebaseFirestore
import FirebaseStorage
import Combine

struct EditPlacesView: View {
    @StateObject private var vm = EditPlacesViewModel()
    
    var body: some View {
        ZStack {
            Color(.systemGroupedBackground).ignoresSafeArea()
            
            if vm.isLoading {
                ProgressView("Yerler yükleniyor...")
                    .padding()
            } else if vm.places.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "building.columns")
                        .font(.system(size: 50))
                        .foregroundColor(.secondary)
                    Text("Henüz yer eklenmemiş")
                        .font(.headline)
                        .foregroundColor(.secondary)
                }
            } else {
                List {
                    ForEach(vm.places) { place in
                        NavigationLink(destination: EditPlaceDetailView(place: place, onUpdate: { vm.fetchPlaces() })) {
                            PlaceListRow(place: place)
                        }
                    }
                    .onDelete { indexSet in
                        for index in indexSet {
                            vm.deletePlace(vm.places[index])
                        }
                    }
                }
                .listStyle(.insetGrouped)
            }
        }
        .navigationTitle("Yerleri Düzenle")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { vm.fetchPlaces() }
        .alert("Hata", isPresented: $vm.showError) {
            Button("Tamam", role: .cancel) {}
        } message: {
            Text(vm.errorMessage)
        }
    }
}

// MARK: - Yer Liste Satırı
struct PlaceListRow: View {
    let place: PlacesModel
    
    var body: some View {
        HStack(spacing: 12) {
            if let firstImage = place.imageName.first, let url = URL(string: firstImage) {
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
                Text(place.name)
                    .font(.headline)
                    .lineLimit(1)
                Text(place.age)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(place.category ?? "Kategori yok")
                    .font(.caption2)
                    .foregroundColor(.orange)
            }
            
            Spacer()
            
            Text("\(place.imageName.count) 📷")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Yer Düzenleme Detay
struct EditPlaceDetailView: View {
    let place: PlacesModel
    let onUpdate: () -> Void
    
    @State private var placeName: String = ""
    @State private var history: String = ""
    @State private var age: String = ""
    @State private var videoUrl: String = ""
    @State private var category: String = ""
    @State private var entranceFee: String = ""
    @State private var visitingHours: String = ""
    @State private var website: String = ""
    @State private var phoneNumber: String = ""
    @State private var address: String = ""
    @State private var interestingFact: String = ""
    @State private var latitude: String = ""
    @State private var longitude: String = ""
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
    
    let allFeatures = [
        "Rehberli Tur", "Wifi", "Otopark", "Kafe/Restoran",
        "Hediyelik Eşya", "Engelli Erişimi", "Fotoğraf Çekimi",
        "Müze", "Manzara Noktası", "Tarihi Yapı"
    ]
    
    var body: some View {
        Form {
            imageSection
            basicInfoSection
            historySection
            visitInfoSection
            locationSection
            contactSection
            featuresSection
            actionButtonsSection
        }
        .navigationTitle("Yer Düzenle")
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
            Text("Yer başarıyla güncellendi!")
        }
        .alert("Hata", isPresented: $showError) {
            Button("Tamam", role: .cancel) {}
        } message: {
            Text(errorMessage)
        }
        .alert("Yeri Sil", isPresented: $showDeleteConfirm) {
            Button("Sil", role: .destructive) { deletePlace() }
            Button("İptal", role: .cancel) {}
        } message: {
            Text("'\(placeName)' yeri kalıcı olarak silinecek. Emin misiniz?")
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
                                    .foregroundColor(.brown)
                                Text("Ekle")
                                    .font(.caption)
                                    .foregroundColor(.brown)
                            }
                            .frame(width: 120, height: 90)
                            .background(Color.brown.opacity(0.1))
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
            TextField("Yer Adı", text: $placeName)
            TextField("Yaş/Dönem", text: $age)
            TextField("Kategori", text: $category)
        }
    }
    
    private var historySection: some View {
        Group {
            Section(header: Text("Tarihçe")) {
                TextEditor(text: $history)
                    .frame(minHeight: 120)
            }
            
            Section(header: Text("İlginç Bilgi")) {
                TextEditor(text: $interestingFact)
                    .frame(minHeight: 60)
            }
        }
    }
    
    private var visitInfoSection: some View {
        Section(header: Text("Ziyaret Bilgileri")) {
            TextField("Giriş Ücreti", text: $entranceFee)
            TextField("Ziyaret Saatleri", text: $visitingHours)
        }
    }
    
    private var locationSection: some View {
        Section(header: Text("Konum")) {
            TextField("Adres", text: $address)
            TextField("Enlem (Latitude)", text: $latitude)
                .keyboardType(.decimalPad)
            TextField("Boylam (Longitude)", text: $longitude)
                .keyboardType(.decimalPad)
        }
    }
    
    private var contactSection: some View {
        Section(header: Text("İletişim & Bağlantılar")) {
            TextField("Telefon", text: $phoneNumber)
                .keyboardType(.phonePad)
            TextField("Website", text: $website)
                .keyboardType(.URL)
            TextField("Video URL (YouTube)", text: $videoUrl)
                .keyboardType(.URL)
        }
    }
    
    private var featuresSection: some View {
        Section(header: Text("Özellikler")) {
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                ForEach(allFeatures, id: \.self) { feature in
                    Button(action: {
                        if features.contains(feature) {
                            features.removeAll { $0 == feature }
                        } else {
                            features.append(feature)
                        }
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: features.contains(feature) ? "checkmark.circle.fill" : "circle")
                                .foregroundColor(features.contains(feature) ? .green : .gray)
                            Text(feature)
                                .font(.caption)
                                .foregroundColor(.primary)
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
        }
    }
    
    private var actionButtonsSection: some View {
        Group {
            Section {
                Button(action: updatePlace) {
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
                .listRowBackground(Color.brown)
                .foregroundColor(.white)
                .disabled(isProcessing)
            }
            
            Section {
                Button(action: { showDeleteConfirm = true }) {
                    HStack {
                        Spacer()
                        Image(systemName: "trash.fill")
                        Text("Bu Yeri Sil")
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
        placeName = place.name
        history = place.history
        age = place.age
        videoUrl = place.videoUrl
        category = place.category ?? ""
        entranceFee = place.entranceFee ?? ""
        visitingHours = place.visitingHours ?? ""
        website = place.website ?? ""
        phoneNumber = place.phoneNumber ?? ""
        address = place.address ?? ""
        interestingFact = place.interestingFact ?? ""
        latitude = String(place.coordinates.latitude)
        longitude = String(place.coordinates.longitude)
        features = place.features ?? []
        existingImages = place.imageName
    }
    
    func updatePlace() {
        guard let placeId = place.id else { return }
        isProcessing = true
        
        if newImages.isEmpty {
            saveToFirestore(placeId: placeId, imageUrls: existingImages)
        } else {
            StorageManager.shared.uploadImages(images: newImages, folder: "places") { newUrls in
                let allImages = self.existingImages + newUrls
                self.saveToFirestore(placeId: placeId, imageUrls: allImages)
            }
        }
    }
    
    func saveToFirestore(placeId: String, imageUrls: [String]) {
        let db = Firestore.firestore()
        
        let data: [String: Any] = [
            "name": placeName,
            "history": history,
            "age": age,
            "imageName": imageUrls,
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
            "features": features
        ]
        
        db.collection("places").document(placeId).setData(data) { error in
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
    
    func deletePlace() {
        guard let placeId = place.id else { return }
        isProcessing = true
        let db = Firestore.firestore()
        db.collection("places").document(placeId).delete { error in
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
class EditPlacesViewModel: ObservableObject {
    @Published var places: [PlacesModel] = []
    @Published var isLoading = false
    @Published var showError = false
    @Published var errorMessage = ""
    
    func fetchPlaces() {
        isLoading = true
        Firestore.firestore().collection("places").getDocuments { snapshot, error in
            DispatchQueue.main.async {
                self.isLoading = false
                if let error = error {
                    self.errorMessage = error.localizedDescription
                    self.showError = true
                } else if let snapshot = snapshot {
                    self.places = snapshot.documents.compactMap { doc in
                        try? doc.data(as: PlacesModel.self)
                    }
                }
            }
        }
    }
    
    func deletePlace(_ place: PlacesModel) {
        guard let id = place.id else { return }
        Firestore.firestore().collection("places").document(id).delete { error in
            if error == nil {
                DispatchQueue.main.async {
                    self.places.removeAll { $0.id == id }
                }
            }
        }
    }
}
