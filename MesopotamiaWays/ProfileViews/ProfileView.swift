//
//  ProfileView.swift
//  MesopotamiaWays
//
//  Created by Bilal AYDIN on 4.12.2025.
//

import SwiftUI
import FirebaseAuth

// Profil View (Örnek)
struct ProfileView: View {
    
    let currentUser = Auth.auth().currentUser
    
    var body: some View {
        Form {
            Section(header: Text("Hesap Bilgileri")) {
                HStack {
                    Image(systemName: "person.circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.blue)
                        .padding(.trailing)
                    
                    VStack(alignment: .leading) {
                        Text("Misafir Kullanıcı")
                            .font(.headline)
                        Text("Giriş yapın veya kaydolun")
                            .font(.caption)
                            .foregroundColor(.blue)
                    }
                }
                .padding(.vertical, 8)
            }
            
            Section(header: Text("Ayarlar")) {
                NavigationLink(destination: Text("Bildirim Ayarları")) {
                    Label("Bildirimler", systemImage: "bell.fill")
                }
                
                NavigationLink(destination: Text("Dil Ayarları")) {
                    Label("Dil", systemImage: "globe")
                }
                
                NavigationLink(destination: Text("Tema Ayarları")) {
                    Label("Tema", systemImage: "paintpalette.fill")
                }
            }
            
            Section(header: Text("Hakkında")) {
                NavigationLink(destination: Text("Hakkında Sayfası")) {
                    Label("Hakkında", systemImage: "info.circle.fill")
                }
                
                NavigationLink(destination: Text("Gizlilik Politikası")) {
                    Label("Gizlilik Politikası", systemImage: "lock.shield.fill")
                }
                
                NavigationLink(destination: Text("Kullanım Koşulları")) {
                    Label("Kullanım Koşulları", systemImage: "doc.text.fill")
                }
            }
            
            Section {
                Button(action: {
                    // Yardım merkezi
                }) {
                    Label("Yardım Merkezi", systemImage: "questionmark.circle.fill")
                }
                
                Button(action: {
                    // Geri bildirim
                }) {
                    Label("Geri Bildirim", systemImage: "envelope.fill")
                }
                
                if (currentUser?.email) != nil {
                    Button {
                        // action
                    } label: {
                        Label("Admin Paneli", systemImage: "gearshape.fill")
                    }
                }
   
            }
        }
        .navigationTitle("Profil")
    }
}

#Preview {
    NavigationStack {
        ProfileView()

    }
}
