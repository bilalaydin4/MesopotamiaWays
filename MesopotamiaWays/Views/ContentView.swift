import SwiftUI
import MapKit

struct ContentView: View {
    // let places: [PlacesModel] = [mardin, dara, zinciriyeMedresesi, kasimiyeMedresesi]
    // let hotels: [HotelsModel] = [buyukMardinOteli, yayGrand]
    // let restaurants: [RestaurantsModel] = [HamdaniRestaurant, leyli]
    
    @EnvironmentObject var viewModel: MainViewModel
    
    @State private var searchText = ""
    
    var filteredPlaces: [PlacesModel] {
        if searchText.isEmpty {
            return viewModel.places
        } else {
            return viewModel.places.filter { place in
                place.name.localizedCaseInsensitiveContains(searchText) ||
                place.history.localizedCaseInsensitiveContains(searchText) ||
                place.age.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var body: some View {
        TabView {
            // TAB 1: KEŞFET (Ana Sayfa)
            NavigationView {
                ScrollView {
                    VStack(spacing: 20) {
                        
                        // ARAMA ÇUBUĞU
                        VStack(spacing: 16) {
                            HStack {
                                Image(systemName: "magnifyingglass")
                                    .foregroundColor(.secondary)
                                
                                TextField("Mardin, Dara, Medreseler...", text: $searchText)
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
                            
                            // Arama sonuç sayısı
                            if !searchText.isEmpty {
                                HStack {
                                    Text("\(filteredPlaces.count) sonuç bulundu")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    Spacer()
                                }
                                .padding(.horizontal)
                            }
                        }
                        
                        // HIZLI ERİŞİM BUTONLARI - EKLENDİ
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Hızlı Erişim")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .padding(.horizontal)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 15) {
                                    NavigationLink(destination: HotelsView()) {
                                        QuickAccessButton(icon: "building.2", title: "Oteller")
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                    
                                    NavigationLink(destination: RestaurantsView()) {
                                        QuickAccessButton(icon: "fork.knife", title: "Restoranlar")
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                    
                                    NavigationLink(destination: ToursListView(tours: viewModel.tours)) {
                                        QuickAccessButton(icon: "flag.fill", title: "Turlar")
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                    
                                    NavigationLink(destination: MapView(places: viewModel.places, hotels: viewModel.hotels, restaurants: viewModel.restaurants)) {
                                        QuickAccessButton(icon: "map.fill", title: "Harita")
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                                .padding(.horizontal)
                            }
                        }
                        .padding(.top, 5)
                        
                        // YAKININIZDAKİ YERLER
                        VStack(alignment: .leading) {
                            HStack {
                                Text(searchText.isEmpty ? "Keşfedilecek Yerler" : "Arama Sonuçları")
                                    .font(.title2)
                                    .fontWeight(.semibold)
                                
                                Spacer()
                                
                                Text("\(filteredPlaces.count) yer")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.horizontal)
                            
                            // SONUÇLAR
                            if filteredPlaces.isEmpty {
                                VStack(spacing: 16) {
                                    Image(systemName: "magnifyingglass")
                                        .font(.system(size: 50))
                                        .foregroundColor(.secondary)
                                    
                                    Text("'\(searchText)' için sonuç bulunamadı")
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
                                    ForEach(filteredPlaces) { place in
                                        NavigationLink(destination: PlaceDetailView(place: place)) {
                                            PlaceCard(place: place)
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                    }
                    .padding(.vertical)
                }
                .refreshable {
                    viewModel.fetchAllData()
                }
                .navigationTitle("Mardin")
            }
            .tabItem {
                Image(systemName: "house.fill")
                Text("Ana Sayfa")
            }
            
            // TAB 2: HARİTA
            NavigationView {
                MapView(places: viewModel.places, hotels: viewModel.hotels, restaurants: viewModel.restaurants)
                    .navigationTitle("Harita")
                    .edgesIgnoringSafeArea(.bottom)
            }
            .tabItem {
                Image(systemName: "map.fill")
                Text("Harita")
            }
            
            // TAB 3: TURLAR
            NavigationView {
                ToursListView(tours: viewModel.tours)
                    .navigationTitle("Turlar")
            }
            .tabItem {
                Image(systemName: "flag.fill")
                Text("Turlar")
            }
            
            // TAB 4: PROFİL
            NavigationView {
                ProfileView()
                    .navigationTitle("Profil")
            }
            .tabItem {
                Image(systemName: "person.fill")
                Text("Profil")
            }
        }
        .accentColor(Color(red: 0.85, green: 0.48, blue: 0.27))
    }
}

// Hızlı Erişim Butonu Bileşeni
struct QuickAccessButton: View {
    let icon: String
    let title: String
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(Color(red: 0.85, green: 0.48, blue: 0.27))
                    .frame(width: 60, height: 60)
                
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(.white)
            }
            
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.primary)
                .frame(width: 70)
                .multilineTextAlignment(.center)
        }
    }
}

// Önizleme
#Preview {
    ContentView()
}
