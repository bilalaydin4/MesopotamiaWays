import SwiftUI
import MapKit

struct ContentView: View {
    @EnvironmentObject var viewModel: MainViewModel
    @State private var searchText = ""
    
    var body: some View {
        TabView {
            // TAB 1: ANA SAYFA (KEŞFET)
            NavigationView {
                ZStack {
                    // Arka Plan Rengi
                    Color(.systemGroupedBackground).ignoresSafeArea()
                    
                    List {
                        // 1. HERO SECTION (Karşılama)
                        Section {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Mezopotamya'yı")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.secondary)
                                
                                Text("Keşfetmeye Hazır Mısın?")
                                    .font(.system(size: 28, weight: .bold))
                                    .foregroundColor(.primary)
                            }
                            .padding(.vertical, 10)
                            .listRowBackground(Color.clear)
                        }
                        .listRowSeparator(.hidden)

                        // 2. ARAMA ÇUBUĞU
                        Section {
                            HStack {
                                Image(systemName: "magnifyingglass")
                                    .foregroundColor(.secondary)
                                TextField("Nereyi arıyorsun?", text: $searchText)
                                if !searchText.isEmpty {
                                    Button(action: { searchText = "" }) {
                                        Image(systemName: "xmark.circle.fill").foregroundColor(.secondary)
                                    }
                                }
                            }
                            .padding(12)
                            .background(Color(.secondarySystemGroupedBackground))
                            .cornerRadius(12)
                            .listRowBackground(Color.clear)
                            .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 10, trailing: 16))
                        }
                        .listRowSeparator(.hidden)

                        // 3. KATEGORİLER (Hızlı Erişim)
                        Section {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 20) {
                                    NavigationLink(destination: HotelsView()) {
                                        CategoryView(icon: "building.2.fill", title: "Oteller", color: .orange)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                    
                                    NavigationLink(destination: RestaurantsView()) {
                                        CategoryView(icon: "fork.knife", title: "Restoranlar", color: .red)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                    
                                    NavigationLink(destination: ToursListView(tours: viewModel.tours)) {
                                        CategoryView(icon: "flag.fill", title: "Turlar", color: .blue)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                    
                                    NavigationLink(destination: MapView(places: viewModel.places, hotels: viewModel.hotels, restaurants: viewModel.restaurants)) {
                                        CategoryView(icon: "map.fill", title: "Harita", color: .green)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                                .padding(.horizontal, 4)
                            }
                            .listRowBackground(Color.clear)
                        }
                        .listRowSeparator(.hidden)

                        // 4. KEŞFEDİLECEK YERLER
                        Section(header: Text("Sana Özel Yerler").font(.headline).foregroundColor(.primary).textCase(nil)) {
                            let results = filteredPlaces
                            if results.isEmpty {
                                Text("Sonuç bulunamadı").foregroundColor(.secondary).padding()
                            } else {
                                ForEach(results) { place in
                                    NavigationLink(destination: PlaceDetailView(place: place)) {
                                        PlaceCard(place: place)
                                    }
                                    .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                                    .listRowBackground(Color.clear)
                                }
                            }
                        }
                        .listRowSeparator(.hidden)
                    }
                    .listStyle(.plain)
                    .refreshable {
                        await viewModel.fetchAllData()
                    }
                }
                .navigationBarHidden(true) // Daha modern bir görünüm için bar gizlendi
            }
            .tabItem {
                Label("Keşfet", systemImage: "safari.fill")
            }
            
            // DİĞER TABLAR (Aynı Mantıkla)
            NavigationView {
                MapView(places: viewModel.places, hotels: viewModel.hotels, restaurants: viewModel.restaurants)
                    .navigationTitle("Harita")
            }
            .tabItem { Label("Harita", systemImage: "map.fill") }
            
            NavigationView {
                ToursListView(tours: viewModel.tours)
                    .navigationTitle("Turlar")
            }
            .tabItem { Label("Turlar", systemImage: "flag.fill") }
            
            NavigationView {
                ProfileView()
                    .navigationTitle("Profil")
            }
            .tabItem { Label("Profil", systemImage: "person.fill") }
        }
        .accentColor(.orange)
    }
    
    var filteredPlaces: [PlacesModel] {
        if searchText.isEmpty { return viewModel.places }
        return viewModel.places.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }
}

// MARK: - Kategori Bileşeni
struct CategoryView: View {
    let icon: String
    let title: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 64, height: 64)
                
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
            }
            
            Text(title)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.primary)
        }
    }
}

// Önizleme
#Preview {
    ContentView()
}
