//
//  FullScreenMapView.swift
//  MesopotamiaWays
//
//  Created by Bilal AYDIN on 24.11.2025.
//


import SwiftUI
import MapKit

// TAM EKRAN HARİTA GÖRÜNÜMÜ
struct FullScreenMapView: View {
    let place: PlacesModel
    @Binding var isPresented: Bool
    @State private var region: MKCoordinateRegion
    
    
    init(place: PlacesModel, isPresented: Binding<Bool>) {
        self.place = place
        self._isPresented = isPresented
        self._region = State(initialValue: MKCoordinateRegion(
            center: place.locationCordinates,
            span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
        ))
    }
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .topLeading) {
                // HARİTA
                Map(coordinateRegion: $region, annotationItems: [place]) { place in
                    MapAnnotation(coordinate: place.locationCordinates) {
                        Button(action: {
                            openInMapsForNavigation()
                        }) {
                            VStack {
                                Image(systemName: "mappin.circle.fill")
                                    .font(.title)
                                    .foregroundColor(.red)
                                
                                Text(place.name)
                                    .font(.caption)
                                    .padding(6)
                                    .background(Color.white)
                                    .cornerRadius(6)
                                    .shadow(radius: 3)
                            }
                        }
                    }
                }
                .edgesIgnoringSafeArea(.all)
                
                // KAPATMA BUTONU
                Button(action: {
                    isPresented = false
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.white)
                        .padding(8)
                        .background(Color.black.opacity(0.7))
                        .clipShape(Circle())
                }
                .padding()
            }
            .navigationTitle(place.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Navigasyon") {
                        openInMapsForNavigation()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Kapat") {
                        isPresented = false
                    }
                }
            }
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


