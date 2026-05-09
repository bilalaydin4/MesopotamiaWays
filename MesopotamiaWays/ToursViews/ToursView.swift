//
//  ToursView.swift
//  MesopotamiaWays
//
//  Created by Bilal AYDIN on 4.12.2025.
//



import SwiftUI
import MapKit

struct ToursView: View {
    @EnvironmentObject var viewModel: MainViewModel
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Tab 1: Ana Sayfa / Turlar
            NavigationView {
                ToursListView(tours: viewModel.tours)
            }
            .tabItem {
                Label("Turlar", systemImage: "map.fill")
            }
            .tag(0)
            
            // Tab 2: Keşfet (Tüm Yerler)
            NavigationView {
                AllPlacesView()
            }
            .tabItem {
                Label("Keşfet", systemImage: "binoculars.fill")
            }
            .tag(1)
            
         
            
            // Tab 4: Profil/Ayarlar
            NavigationView {
                ProfileView()
            }
            .tabItem {
                Label("Profil", systemImage: "person.fill")
            }
            .tag(2)
        }
        .accentColor(.blue) // Tab bar rengi
    }
}


// Yer Detay View (Keşfet sekmesi için)
struct PlaceDetailViewTour: View {
    let place: PlacesModel
    @State private var region: MKCoordinateRegion
    
    init(place: PlacesModel) {
        self.place = place
        // Region'ı init'te oluştur
        self._region = State(initialValue: MKCoordinateRegion(
            center: place.locationCordinates,
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        ))
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Resim Galerisi
                TabView {
                    ForEach(place.imageName, id: \.self) { imageName in
                        Image(imageName)
                            .resizable()
                            .scaledToFill()
                            .frame(height: 250)
                            .clipped()
                    }
                }
                .frame(height: 250)
                .tabViewStyle(PageTabViewStyle())
                
                // Yer Bilgileri
                VStack(alignment: .leading, spacing: 15) {
                    Text(place.name)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    HStack {
                        Image(systemName: "clock.arrow.circlepath")
                            .foregroundColor(.orange)
                        Text("Tarih:")
                            .fontWeight(.semibold)
                        Text(place.age)
                    }
                    .font(.subheadline)
                    
                    Divider()
                    
                    Text("Tarihçe")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text(place.history)
                        .font(.body)
                        .lineSpacing(4)
                    
                    // Harita - iOS 16 ve öncesi için
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Konum")
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding(.top)
                        
                        // iOS 16 ve öncesi için Map kullanımı
                        Map(coordinateRegion: $region,
                            annotationItems: [place]) { place in
                            MapAnnotation(coordinate: place.locationCordinates) {
                                VStack {
                                    Image(systemName: "mappin.circle.fill")
                                        .font(.title)
                                        .foregroundColor(.red)
                                    Text(place.name)
                                        .font(.caption)
                                        .padding(4)
                                        .background(Color.white.opacity(0.8))
                                        .cornerRadius(4)
                                }
                            }
                        }
                        .frame(height: 200)
                        .cornerRadius(12)
                    }
                    
                    // Video Linki (eğer varsa)
                    if !place.videoUrl.isEmpty {
                        Button(action: {
                            // Video açma işlemi
                            if let url = URL(string: place.videoUrl) {
                                UIApplication.shared.open(url)
                            }
                        }) {
                            HStack {
                                Image(systemName: "play.circle.fill")
                                Text("Video İzle")
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        }
                        .padding(.top)
                    }
                }
                .padding()
                
                Spacer()
            }
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
    }
}



// Önizleme
#Preview {
    NavigationStack {
        ToursView()
    }
}

