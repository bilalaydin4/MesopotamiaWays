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
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // IMAGE SLIDER
                ZStack(alignment: .bottom) {
                    TabView(selection: $currentImageIndex) {
                        ForEach(0..<place.imageName.count, id: \.self) { index in
                            Image(place.imageName[index])
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(height: 250)
                                .clipped()
                                .tag(index)
                        }
                    }
                    .frame(height: 250)
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                    
                    HStack(spacing: 6) {
                        ForEach(0..<place.imageName.count, id: \.self) { index in
                            Circle()
                                .fill(index == currentImageIndex ? Color.white : Color.white.opacity(0.5))
                                .frame(width: 8, height: 8)
                        }
                    }
                    .padding(.bottom, 16)
                }
                .frame(height: 250)
                
                // İÇERİK
                VStack(alignment: .leading, spacing: 12) {
                    Text(place.name)
                        .font(.title)
                        .fontWeight(.bold)
                    
                    HStack {
                        Image(systemName: "clock")
                        Text(place.age)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    Text("Tarihçe")
                        .font(.headline)
                        .padding(.top, 8)
                    
                    Text(place.history)
                        .font(.body)
                        .lineSpacing(4)
                    
                    // YOUTUBE VİDEO BÖLÜMÜ - SABİT BOYUT
                    if !place.videoUrl.isEmpty, let videoID = extractYouTubeID(from: place.videoUrl) {
                        YouTubeFixedPlayer(videoID: videoID)
                            .padding(.top, 16)
                    }
                    
                    // Harita önizleme
                    VStack(alignment: .leading) {
                        HStack {
                            Text("Konum")
                                .font(.headline)
                            Spacer()
                            Button("Haritada Gör") {
                                showFullScreenMap = true
                            }
                            .font(.caption)
                            .foregroundColor(.blue)
                        }
                        .padding(.bottom, 8)
                        
                        Button(action: {
                            showFullScreenMap = true
                        }) {
                            Map(coordinateRegion: .constant(
                                MKCoordinateRegion(
                                    center: place.locationCordinates,
                                    span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                                )
                            ))
                            .frame(height: 200)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        // NAVİGASYON BUTONU
                        Button(action: {
                            openInMapsForNavigation()
                        }) {
                            HStack {
                                Image(systemName: "location.circle.fill")
                                Text("Buraya Navigasyon Başlat")
                                Spacer()
                                Image(systemName: "chevron.right")
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .cornerRadius(12)
                        }
                        .padding(.top, 8)
                    }
                    .padding(.top, 16)
                }
                .padding()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .fullScreenCover(isPresented: $showFullScreenMap) {
            FullScreenMapView(place: place, isPresented: $showFullScreenMap)
        }
    }
    
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

// MARK: - Sabit Boyutlu YouTube Player
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
