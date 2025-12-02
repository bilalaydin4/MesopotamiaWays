//
//  PlaceDetailView.swift
//  MesopotamiaWays
//
//  Created by Bilal AYDIN on 24.11.2025.
//


import SwiftUI
import MapKit

struct PlaceDetailView: View {
    let place: PlacesModel
    @State private var showFullScreenMap = false
    @State private var currentImageIndex = 0
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // IMAGE SLIDER
                ZStack(alignment: .bottom) {
                    // ANA GÖRSELLER
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
                    .edgesIgnoringSafeArea(.top)
                    
                    // SLIDER INDICATOR
                    HStack(spacing: 6) {
                        ForEach(0..<place.imageName.count, id: \.self) { index in
                            Circle()
                                .fill(index == currentImageIndex ? Color.white : Color.white.opacity(0.5))
                                .frame(width: 8, height: 8)
                        }
                    }
                    .padding(.bottom, 16)
                    
                    // RESİM SAYACI
                    VStack {
                        HStack {
                            Spacer()
                            Text("\(currentImageIndex + 1)/\(place.imageName.count)")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .padding(6)
                                .background(Color.black.opacity(0.6))
                                .cornerRadius(8)
                        }
                        Spacer()
                    }
                    .padding()
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
                    
                    // Harita önizleme - TIKLANABİLİR
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
                        
                        // Tıklanabilir harita
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
    
    // HARİTA UYGULAMASINI AÇ ve NAVİGASYON BAŞLAT
    private func openInMapsForNavigation() {
        let coordinate = place.locationCordinates
        let placemark = MKPlacemark(coordinate: coordinate)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = place.name
        
        // Navigasyon modunda aç
        let options = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
        mapItem.openInMaps(launchOptions: options)
    }
}



#Preview {
    NavigationView {
        PlaceDetailView(place: mardin)
    }
}



