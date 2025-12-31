//
//  PlaceDetailView.swift (SABİT BOYUTLU VIDEO)
//  MesopotamiaWays
//

import SwiftUI
import MapKit
import YouTubeiOSPlayerHelper

struct PlaceDetailView: View {
    let place: PlacesModel
    @State private var currentImageIndex = 0
    @State private var showFullScreenMap = false
    @State private var region: MKCoordinateRegion
    
    init(place: PlacesModel) {
        self.place = place
        self._region = State(initialValue: MKCoordinateRegion(
            center: place.locationCordinates,
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        ))
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                // IMAGE SLIDER - Geliştirilmiş
                ZStack(alignment: .bottom) {
                    TabView(selection: $currentImageIndex) {
                        ForEach(0..<place.imageName.count, id: \.self) { index in
                            Image(place.imageName[index])
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(height: 320)
                                .clipped()
                                .tag(index)
                        }
                    }
                    .frame(height: 320)
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                    
                    // Gradient overlay
                    LinearGradient(
                        gradient: Gradient(colors: [.clear, .black.opacity(0.1)]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(height: 80)
                    
                    // Resim sayacı
                    VStack {
                        HStack {
                            // Sol üst: Etiket
                            HStack(spacing: 8) {
                                Image(systemName: "photo.on.rectangle.angled")
                                    .font(.caption)
                                Text("\(currentImageIndex + 1)/\(place.imageName.count)")
                                    .font(.caption)
                                    .fontWeight(.medium)
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(Color.black.opacity(0.6))
                            .cornerRadius(12)
                            
                            Spacer()
                        }
                        .padding(.horizontal)
                        .padding(.top, 16)
                        
                        Spacer()
                        
                        // Sayfa noktaları
                        HStack(spacing: 8) {
                            ForEach(0..<place.imageName.count, id: \.self) { index in
                                Capsule()
                                    .fill(index == currentImageIndex ? Color.white : Color.white.opacity(0.4))
                                    .frame(width: index == currentImageIndex ? 24 : 8, height: 4)
                                    .animation(.spring(), value: currentImageIndex)
                            }
                        }
                        .padding(.bottom, 20)
                    }
                }
                .frame(height: 320)
                
                // İÇERİK
                VStack(alignment: .leading, spacing: 24) {
                    // Başlık ve dönem bilgisi
                    VStack(alignment: .leading, spacing: 8) {
                        Text(place.name)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        
                        HStack(spacing: 12) {
                            Label(place.age, systemImage: "clock.fill")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            Divider()
                                .frame(height: 16)
                            
                            Label("Tarihi Alan", systemImage: "building.columns.fill")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.bottom, 8)
                    
                    // Tarihçe bölümü
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "scroll.fill")
                                .foregroundColor(.orange)
                            Text("Tarihçe")
                                .font(.title3)
                                .fontWeight(.semibold)
                        }
                        
                        Text(place.history)
                            .font(.body)
                            .lineSpacing(6)
                            .foregroundColor(.primary)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.orange.opacity(0.05))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.orange.opacity(0.2), lineWidth: 1)
                            )
                    )
                    
                    // YOUTUBE VİDEO BÖLÜMÜ - ESKİ HALİ
                    if !place.videoUrl.isEmpty, let videoID = extractYouTubeID(from: place.videoUrl) {
                        VStack(spacing: 0) {
                            // Video Başlığı
                            HStack {
                                HStack(spacing: 8) {
                                    Image(systemName: "play.circle.fill")
                                        .foregroundColor(.red)
                                    Text("Tanıtım Videosu")
                                        .font(.headline)
                                }
                                
                                Spacer()
                                
                                // YouTube'a Aç Butonu
                                if let url = URL(string: "https://www.youtube.com/watch?v=\(videoID)") {
                                    Link(destination: url) {
                                        Image(systemName: "arrow.up.right.square")
                                            .font(.subheadline)
                                            .foregroundColor(.red)
                                            .padding(6)
                                            .background(Color(.systemGray6))
                                            .clipShape(Circle())
                                    }
                                }
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 10)
                            .background(Color(.systemGray6))
                            .cornerRadius(12, corners: [.topLeft, .topRight])
                            
                            // YouTube Player - Sabit boyut
                            YouTubePlayerSimpleView(videoID: videoID)
                                .frame(height: 220) // Sabit yükseklik
                                .cornerRadius(0)
                        }
                        .background(Color.white)
                        .cornerRadius(12)
                        .shadow(color: .gray.opacity(0.2), radius: 4, x: 0, y: 2)
                        .padding(.vertical, 16)
                    }
                    
                    // Harita bölümü - Geliştirilmiş
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Image(systemName: "map.fill")
                                .foregroundColor(.blue)
                            Text("Konum")
                                .font(.title3)
                                .fontWeight(.semibold)
                            
                            Spacer()
                            
                            Button(action: {
                                showFullScreenMap = true
                            }) {
                                HStack(spacing: 6) {
                                    Text("Tam Ekran")
                                    Image(systemName: "arrow.up.left.and.arrow.down.right")
                                }
                                .font(.subheadline)
                                .foregroundColor(.blue)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.blue.opacity(0.1))
                                .cornerRadius(10)
                            }
                        }
                        
                        // Harita with annotation
                        ZStack(alignment: .topTrailing) {
                            Map(coordinateRegion: $region,
                                annotationItems: [place]) { place in
                                MapAnnotation(coordinate: place.locationCordinates) {
                                    VStack(spacing: 2) {
                                        // Annotation işaretçisi
                                        ZStack {
                                            Circle()
                                                .fill(Color.red)
                                                .frame(width: 36, height: 36)
                                            
                                            Image(systemName: "location.north.fill")
                                                .font(.system(size: 16))
                                                .foregroundColor(.white)
                                                .rotationEffect(.degrees(45))
                                        }
                                        .shadow(color: .black.opacity(0.3), radius: 3, x: 0, y: 2)
                                        
                                        // Etiket balonu
                                        Text(place.name)
                                            .font(.caption2)
                                            .fontWeight(.bold)
                                            .foregroundColor(.white)
                                            .padding(.horizontal, 10)
                                            .padding(.vertical, 4)
                                            .background(Color.red)
                                            .cornerRadius(8)
                                            .shadow(color: .black.opacity(0.2), radius: 2, x: 0, y: 1)
                                    }
                                    .offset(y: -15)
                                }
                            }
                            .frame(height: 220)
                            .cornerRadius(16)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                            )
                            
                            // Zoom kontrolleri
                            VStack(spacing: 8) {
                                Button(action: zoomIn) {
                                    Image(systemName: "plus.circle.fill")
                                        .font(.title3)
                                        .foregroundColor(.blue)
                                        .background(Color.white)
                                        .clipShape(Circle())
                                }
                                
                                Button(action: zoomOut) {
                                    Image(systemName: "minus.circle.fill")
                                        .font(.title3)
                                        .foregroundColor(.blue)
                                        .background(Color.white)
                                        .clipShape(Circle())
                                }
                                
                                Button(action: resetRegion) {
                                    Image(systemName: "location.fill")
                                        .font(.title3)
                                        .foregroundColor(.blue)
                                        .background(Color.white)
                                        .clipShape(Circle())
                                }
                            }
                            .padding(8)
                            .background(Color.white.opacity(0.9))
                            .cornerRadius(12)
                            .shadow(radius: 2)
                            .padding(12)
                        }
                        
                        // Adres ve navigasyon
                        VStack(alignment: .leading, spacing: 12) {
                            HStack(alignment: .top, spacing: 12) {
                                Image(systemName: "mappin.circle.fill")
                                    .font(.title2)
                                    .foregroundColor(.blue)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Konum Bilgisi")
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                    
                                    Text("Tarihi alan bu konumda bulunmaktadır")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                            }
                            
                            // Navigasyon butonları
                            HStack(spacing: 12) {
                                Button(action: {
                                    openInMapsForNavigation()
                                }) {
                                    HStack {
                                        Image(systemName: "car.fill")
                                            .font(.headline)
                                        Text("Araçla Git")
                                            .fontWeight(.semibold)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(LinearGradient(
                                        colors: [.blue, .blue.opacity(0.8)],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    ))
                                    .foregroundColor(.white)
                                    .cornerRadius(12)
                                }
                                
                                Button(action: {
                                    showFullScreenMap = true
                                }) {
                                    HStack {
                                        Image(systemName: "map.fill")
                                            .font(.headline)
                                        Text("Haritada Gör")
                                            .fontWeight(.semibold)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.blue.opacity(0.1))
                                    .foregroundColor(.blue)
                                    .cornerRadius(12)
                                }
                            }
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.blue.opacity(0.05))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(Color.blue.opacity(0.1), lineWidth: 1)
                                )
                        )
                    }
                    .padding(.vertical, 8)
                }
                .padding()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .fullScreenCover(isPresented: $showFullScreenMap) {
            FullScreenMapView(place: place, isPresented: $showFullScreenMap)
        }
    }
    
    // MARK: - Harita Fonksiyonları
    private func zoomIn() {
        withAnimation(.spring()) {
            region.span.latitudeDelta = max(region.span.latitudeDelta / 1.5, 0.002)
            region.span.longitudeDelta = max(region.span.longitudeDelta / 1.5, 0.002)
        }
    }
    
    private func zoomOut() {
        withAnimation(.spring()) {
            region.span.latitudeDelta = min(region.span.latitudeDelta * 1.5, 0.1)
            region.span.longitudeDelta = min(region.span.longitudeDelta * 1.5, 0.1)
        }
    }
    
    private func resetRegion() {
        withAnimation(.spring()) {
            region = MKCoordinateRegion(
                center: place.locationCordinates,
                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            )
        }
    }
    
    // Diğer fonksiyonlar aynı...
    private func extractYouTubeID(from url: String) -> String? {
        let patterns = [
            #"v=([a-zA-Z0-9_-]{11})"#,
            #"youtu\.be\/([a-zA-Z0-9_-]{11})"#,
            #"embed\/([a-zA-Z0-9_-]{11})"#
        ]
        
        for pattern in patterns {
            if let regex = try? NSRegularExpression(pattern: pattern),
               let match = regex.firstMatch(in: url, range: NSRange(url.startIndex..., in: url)),
               let range = Range(match.range(at: 1), in: url) {
                return String(url[range])
            }
        }
        return nil
    }
    
    private func openInMapsForNavigation() {
        let coordinate = place.locationCordinates
        let placemark = MKPlacemark(coordinate: coordinate)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = place.name
        
        let options = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
        mapItem.openInMaps(launchOptions: options)
    }
}



// MARK: - YouTube Player (Eski hali korundu)
struct YouTubeFixedPlayer: View {
    let videoID: String
    
    var body: some View {
        VStack(spacing: 0) {
            // Video Başlığı
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: "play.circle.fill")
                        .foregroundColor(.red)
                    Text("Tanıtım Videosu")
                        .font(.headline)
                }
                
                Spacer()
                
                // YouTube'a Aç Butonu
                if let url = URL(string: "https://www.youtube.com/watch?v=\(videoID)") {
                    Link(destination: url) {
                        Image(systemName: "arrow.up.right.square")
                            .font(.subheadline)
                            .foregroundColor(.red)
                            .padding(6)
                            .background(Color(.systemGray6))
                            .clipShape(Circle())
                    }
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(Color(.systemGray6))
            .cornerRadius(12, corners: [.topLeft, .topRight])
            
            // YouTube Player - Sabit boyut
            YouTubePlayerSimpleView(videoID: videoID)
                .frame(height: 220) // Sabit yükseklik
                .cornerRadius(0)
            
          
        }
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .gray.opacity(0.2), radius: 4, x: 0, y: 2)
    }
}

#Preview {
    NavigationView {
        PlaceDetailView(place: mardin)
    }
}
