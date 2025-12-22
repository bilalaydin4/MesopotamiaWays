//
//  ProfileView.swift
//  MesopotamiaWays
//
//  Created by Bilal AYDIN on 4.12.2025.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct UserProfile {
    let firstName: String
    let lastName: String
    let email: String
    let isActive: Bool
}

struct ProfileView: View {
    @State private var userProfile: UserProfile?
    @State private var isLoading = true
    @State private var errorMessage = ""
    @State private var showLoginView = false
    
    var body: some View {
        Form {
            if isLoading {
                Section(header: Text("Hesap Bilgileri")) {
                    HStack {
                        ProgressView()
                            .padding(.trailing)
                        Text("Yükleniyor...")
                    }
                    .padding(.vertical, 8)
                }
            } else if let profile = userProfile {
                // Giriş yapmış kullanıcı görünümü
                Section(header: Text("Hesap Bilgileri")) {
                    HStack {
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.blue)
                            .padding(.trailing)
                        
                        VStack(alignment: .leading) {
                            Text("\(profile.firstName) \(profile.lastName)")
                                .font(.headline)
                            Text(profile.email)
                                .font(.caption)
                                .foregroundColor(.gray)
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
                    
                    if profile.isActive {
                        NavigationLink(destination: Text("Admin Paneli")) {
                            Label("Admin Paneli", systemImage: "gearshape.fill")
                                .foregroundColor(.blue)
                        }
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
                    
                    Button(action: logout) {
                        Label("Çıkış Yap", systemImage: "rectangle.portrait.and.arrow.right")
                            .foregroundColor(.red)
                    }
                }
                
                if !errorMessage.isEmpty {
                    Section {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                }
            } else {
                // Giriş yapmamış kullanıcı görünümü
                Section(header: Text("Hesap Bilgileri")) {
                    HStack {
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                            .padding(.trailing)
                        
                        VStack(alignment: .leading) {
                            Text("Misafir Kullanıcı")
                                .font(.headline)
                            Text("Giriş yapın veya kaydolun")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                    .padding(.vertical, 8)
                }
                
                Section {
                    Button(action: {
                        showLoginView = true
                    }) {
                        Label("Giriş Yap / Kayıt Ol", systemImage: "person.fill")
                            .foregroundColor(.blue)
                            .frame(maxWidth: .infinity, alignment: .leading)
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
                }
            }
        }
        .navigationTitle("Profil")
        .sheet(isPresented: $showLoginView, onDismiss: {
            // Modal kapandığında profil sayfasını yeniden yükle
            fetchUserProfile()
        }) {
            // Sade ve temiz modal açılış
            LoginView(isPresented: $showLoginView)
                .presentationDetents([.large]) // Tam ekran modal
                .presentationDragIndicator(.visible)
        }
        .onAppear {
            fetchUserProfile()
        }
        .onChange(of: Auth.auth().currentUser) { _ in
            fetchUserProfile()
        }
    }
    
    private func fetchUserProfile() {
        guard let currentUser = Auth.auth().currentUser else {
            self.userProfile = nil
            self.isLoading = false
            return
        }
        
        let db = Firestore.firestore()
        let userRef = db.collection("users").document(currentUser.uid)
        
        userRef.getDocument { document, error in
            self.isLoading = false
            
            if let error = error {
                self.errorMessage = "Kullanıcı bilgileri yüklenemedi: \(error.localizedDescription)"
                return
            }
            
            guard let document = document, document.exists,
                  let data = document.data() else {
                self.errorMessage = "Kullanıcı bilgileri bulunamadı"
                return
            }
            
            if let firstName = data["firstName"] as? String,
               let lastName = data["lastName"] as? String,
               let email = data["email"] as? String,
               let isActive = data["isActive"] as? Bool {
                
                self.userProfile = UserProfile(
                    firstName: firstName,
                    lastName: lastName,
                    email: email,
                    isActive: isActive
                )
                self.errorMessage = ""
            }
        }
    }
    
    private func logout() {
        do {
            try Auth.auth().signOut()
            self.userProfile = nil
            self.isLoading = true
            // Kısa bir süre sonra yeniden yükle
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.fetchUserProfile()
            }
        } catch {
            self.errorMessage = "Çıkış yapılırken hata oluştu: \(error.localizedDescription)"
        }
    }
}

#Preview {
    NavigationStack {
        ProfileView()
    }
}
