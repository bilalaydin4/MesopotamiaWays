//
//  LoginPopupView.swift
//  MesopotamiaWays
//
//  Created by Bilal AYDIN on 14.12.2025.
//

import SwiftUI

// MARK: - Popup Login View
struct LoginView: View {
    @Binding var isPresented: Bool
    @State private var email = ""
    @State private var password = ""
    @State private var isShowingSignUp = false
    @State private var isPasswordVisible = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 25) {
                    // BAŞLIK
                    VStack(spacing: 15) {
                        Image(systemName: "building.columns.fill")
                            .font(.system(size: 45))
                            .foregroundColor(Color(red: 0.85, green: 0.48, blue: 0.27))
                        
                        Text("Mesopotami Ways")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text(isShowingSignUp ? "Yeni Hesap Oluştur" : "Hesabınıza Giriş Yapın")
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 20)
                    
                    // FORM
                    VStack(spacing: 20) {
                        // EMAIL
                        VStack(alignment: .leading, spacing: 8) {
                            Text("E-posta")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            
                            TextField("ornek@email.com", text: $email)
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(10)
                                .keyboardType(.emailAddress)
                                .autocapitalization(.none)
                        }
                        
                        // PASSWORD
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Şifre")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            
                            HStack {
                                if isPasswordVisible {
                                    TextField("Şifreniz", text: $password)
                                } else {
                                    SecureField("Şifreniz", text: $password)
                                }
                                
                                Button(action: {
                                    isPasswordVisible.toggle()
                                }) {
                                    Image(systemName: isPasswordVisible ? "eye.slash" : "eye")
                                        .foregroundColor(.gray)
                                }
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                        }
                        
                        // SIGN UP MODE
                        if isShowingSignUp {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Şifre Tekrar")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                
                                SecureField("Şifrenizi tekrar girin", text: $password)
                                    .padding()
                                    .background(Color(.systemGray6))
                                    .cornerRadius(10)
                            }
                        }
                        
                        // BUTONLAR
                        VStack(spacing: 15) {
                            // Giriş/Kayıt Butonu
                            Button(action: {
                                if isShowingSignUp {
                                    // Kayıt ol işlemi
                                    signUp()
                                } else {
                                    // Giriş yap işlemi
                                    signIn()
                                }
                            }) {
                                Text(isShowingSignUp ? "Hesap Oluştur" : "Giriş Yap")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color(red: 0.85, green: 0.48, blue: 0.27))
                                    .cornerRadius(10)
                            }
                            
                            // Mod Değiştirme Butonu
                            Button(action: {
                                withAnimation {
                                    isShowingSignUp.toggle()
                                }
                            }) {
                                Text(isShowingSignUp ? "Zaten hesabınız var mı? Giriş Yap" : "Hesabınız yok mu? Kayıt Ol")
                                    .font(.subheadline)
                                    .foregroundColor(Color(red: 0.85, green: 0.48, blue: 0.27))
                            }
                        }
                    }
                    .padding(.horizontal, 25)
                    
                    // SOSYAL MEDYA GİRİŞİ (opsiyonel)
                    VStack(spacing: 15) {
                        Text("veya")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        HStack(spacing: 20) {
                            Button(action: {
                                // Google ile giriş
                            }) {
                                HStack {
                                    Image(systemName: "g.circle.fill")
                                        .foregroundColor(.red)
                                    Text("Google")
                                        .font(.subheadline)
                                }
                                .padding(.horizontal, 20)
                                .padding(.vertical, 10)
                                .background(Color(.systemGray6))
                                .cornerRadius(8)
                            }
                            
                            Button(action: {
                                // Apple ile giriş
                            }) {
                                HStack {
                                    Image(systemName: "apple.logo")
                                    Text("Apple")
                                        .font(.subheadline)
                                }
                                .padding(.horizontal, 20)
                                .padding(.vertical, 10)
                                .background(Color(.systemGray6))
                                .cornerRadius(8)
                            }
                        }
                    }
                    .padding(.top, 10)
                    
                    Spacer()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                trailing: Button("Kapat") {
                    isPresented = false
                }
            )
        }
    }
    
    private func signIn() {
        // Firebase giriş işlemi - SİZ TAMAMLARSINIZ
        print("Giriş yapılıyor: \(email)")
        // Auth.auth().signIn(withEmail: email, password: password) { ... }
        
        // Başarılı giriş sonrası kapat
        isPresented = false
    }
    
    private func signUp() {
        // Firebase kayıt işlemi - SİZ TAMAMLARSINIZ
        print("Kayıt olunuyor: \(email)")
        // Auth.auth().createUser(withEmail: email, password: password) { ... }
        
        // Başarılı kayıt sonrası kapat
        isPresented = false
    }
}

#Preview {
    
    @State var t = true
    LoginView(isPresented: $t)
}
