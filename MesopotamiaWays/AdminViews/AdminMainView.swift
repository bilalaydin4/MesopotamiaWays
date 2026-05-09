//
//  AdminMainView.swift
//  MesopotamiaWays
//
//  Created by Bilal AYDIN on 22.12.2025.
//

import SwiftUI

struct AdminMainView: View {
    var body: some View {
        List {
            Section(header: Text("Veri Ekleme")) {
                NavigationLink(destination: AdminPlacesView()) {
                    Label("Mekan Ekle", systemImage: "plus.circle.fill")
                        .foregroundColor(.brown)
                }
                
                NavigationLink(destination: AdminHotelView()) {
                    Label("Otel Ekle", systemImage: "plus.circle.fill")
                        .foregroundColor(.blue)
                }
                
                NavigationLink(destination: AdminRestaurantsView()) {
                    Label("Restoran Ekle", systemImage: "plus.circle.fill")
                        .foregroundColor(.orange)
                }
                
                NavigationLink(destination: AdminToursView()) {
                    Label("Tur Ekle", systemImage: "plus.circle.fill")
                        .foregroundColor(.green)
                }
            }
            
            Section(header: Text("Veri Düzenleme / Silme")) {
                NavigationLink(destination: EditPlacesView()) {
                    Label("Mekanları Düzenle", systemImage: "pencil.circle.fill")
                        .foregroundColor(.brown)
                }
                
                NavigationLink(destination: EditHotelsView()) {
                    Label("Otelleri Düzenle", systemImage: "pencil.circle.fill")
                        .foregroundColor(.blue)
                }
                
                NavigationLink(destination: EditRestaurantsView()) {
                    Label("Restoranları Düzenle", systemImage: "pencil.circle.fill")
                        .foregroundColor(.orange)
                }
            }
        }
        .navigationTitle("Admin Paneli")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    AdminMainView()
}
