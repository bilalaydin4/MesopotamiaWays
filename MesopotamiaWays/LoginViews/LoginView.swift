//
//  LoginPopupView.swift
//  MesopotamiaWays
//
//  Created by Bilal AYDIN on 14.12.2025.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

// MARK: - Popup Login View
struct LoginView: View {
    @Binding var isPresented: Bool
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var isShowingSignUp = false
    @State private var isPasswordVisible = false
    @State private var showAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var isLoading = false
    
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
                        // Kayıt ol modunda isim ve soyisim alanları
                        if isShowingSignUp {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Ad")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                
                                TextField("Adınız", text: $firstName)
                                    .padding()
                                    .background(Color(.systemGray6))
                                    .cornerRadius(10)
                                    .disabled(isLoading)
                            }
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Soyad")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                
                                TextField("Soyadınız", text: $lastName)
                                    .padding()
                                    .background(Color(.systemGray6))
                                    .cornerRadius(10)
                                    .disabled(isLoading)
                            }
                        }
                        
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
                                .disabled(isLoading)
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
                            .disabled(isLoading)
                        }
                        
                        // SIGN UP MODE - Şifre Tekrarı
                        if isShowingSignUp {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Şifre Tekrar")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                
                                SecureField("Şifrenizi tekrar girin", text: $confirmPassword)
                                    .padding()
                                    .background(Color(.systemGray6))
                                    .cornerRadius(10)
                                    .disabled(isLoading)
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
                                if isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                } else {
                                    Text(isShowingSignUp ? "Hesap Oluştur" : "Giriş Yap")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                }
                            }
                            .background(Color(red: 0.85, green: 0.48, blue: 0.27))
                            .cornerRadius(10)
                            .disabled(isLoading)
                            
                            // Mod Değiştirme Butonu
                            Button(action: {
                                withAnimation {
                                    isShowingSignUp.toggle()
                                    // Formu temizle
                                    password = ""
                                    confirmPassword = ""
                                    firstName = ""
                                    lastName = ""
                                }
                            }) {
                                Text(isShowingSignUp ? "Zaten hesabınız var mı? Giriş Yap" : "Hesabınız yok mu? Kayıt Ol")
                                    .font(.subheadline)
                                    .foregroundColor(Color(red: 0.85, green: 0.48, blue: 0.27))
                            }
                            .disabled(isLoading)
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
                .disabled(isLoading)
            )
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text(alertTitle),
                    message: Text(alertMessage),
                    dismissButton: .default(Text("Tamam"))
                )
            }
            .overlay {
                if isLoading {
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                        .overlay(
                            ProgressView("İşleminiz yapılıyor...")
                                .padding()
                                .background(Color.white)
                                .cornerRadius(10)
                                .shadow(radius: 10)
                        )
                }
            }
        }
    }
    
    private func validateFields() -> Bool {
        // Kayıt ol modunda isim ve soyisim kontrolü
        if isShowingSignUp {
            if firstName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                showAlert(title: "Hata", message: "Ad alanı boş olamaz.")
                return false
            }
            
            if lastName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                showAlert(title: "Hata", message: "Soyad alanı boş olamaz.")
                return false
            }
        }
        
        // E-posta kontrolü
        if email.isEmpty {
            showAlert(title: "Hata", message: "E-posta alanı boş olamaz.")
            return false
        }
        
        // Basit e-posta formatı kontrolü
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        if !emailPredicate.evaluate(with: email) {
            showAlert(title: "Hata", message: "Geçerli bir e-posta adresi giriniz.")
            return false
        }
        
        // Şifre kontrolü
        if password.isEmpty {
            showAlert(title: "Hata", message: "Şifre alanı boş olamaz.")
            return false
        }
        
        // Kayıt ol modunda şifre tekrar kontrolü
        if isShowingSignUp {
            if confirmPassword.isEmpty {
                showAlert(title: "Hata", message: "Şifre tekrar alanı boş olamaz.")
                return false
            }
            
            if password != confirmPassword {
                showAlert(title: "Hata", message: "Şifreler birbiriyle eşleşmiyor.")
                return false
            }
            
            // Şifre uzunluğu kontrolü (en az 6 karakter)
            if password.count < 6 {
                showAlert(title: "Hata", message: "Şifre en az 6 karakter olmalıdır.")
                return false
            }
        }
        
        return true
    }
    
    private func signIn() {
        // Input validation
        if !validateFields() {
            return
        }
        
        isLoading = true
        
        // Firebase giriş işlemi
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            isLoading = false
            
            if let error = error {
                let errorMessage = self.getAuthErrorMessage(error)
                self.showAlert(title: "Giriş Hatası", message: errorMessage)
                return
            }
            
            // Başarılı giriş - DİREKT KAPAT
            print("✅ Giriş başarılı, popup kapatılıyor...")
            self.isPresented = false
        }
    }
    
    private func signUp() {
        // Input validation
        if !validateFields() {
            return
        }
        
        isLoading = true
        
        // Firebase Authentication ile kullanıcı oluştur
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let error = error {
                self.isLoading = false
                let errorMessage = self.getAuthErrorMessage(error)
                self.showAlert(title: "Kayıt Hatası", message: errorMessage)
                return
            }
            
            // Auth başarılı, şimdi Firestore'a kullanıcı bilgilerini kaydet
            guard let userId = authResult?.user.uid else {
                self.isLoading = false
                self.showAlert(title: "Hata", message: "Kullanıcı ID alınamadı.")
                return
            }
            
            self.saveUserToFirestore(userId: userId)
        }
    }
    
    private func saveUserToFirestore(userId: String) {
        let db = Firestore.firestore()
        
        // Kullanıcı verisi
        let userData: [String: Any] = [
            "userId": userId,
            "firstName": firstName.trimmingCharacters(in: .whitespacesAndNewlines),
            "lastName": lastName.trimmingCharacters(in: .whitespacesAndNewlines),
            "email": email.lowercased(),
            "createdAt": Timestamp(date: Date()),
            "updatedAt": Timestamp(date: Date()),
            "isActive": true
        ]
        
        // Firestore'a kaydet
        db.collection("users").document(userId).setData(userData) { error in
            self.isLoading = false
            
            if let error = error {
                self.showAlert(title: "Firestore Hatası", message: "Kullanıcı bilgileri kaydedilemedi: \(error.localizedDescription)")
                
                // Firestore kaydı başarısız oldu, kullanıcıyı silelim (opsiyonel)
                self.deleteUserOnFirestoreFailure(userId: userId)
                return
            }
            
            // Tüm işlemler başarılı - DİREKT KAPAT
            print("✅ Kayıt başarılı, Firestore'a kaydedildi, popup kapatılıyor...")
            self.isPresented = false
        }
    }
    
    private func deleteUserOnFirestoreFailure(userId: String) {
        // Firestore kaydı başarısız olduğunda kullanıcıyı sil (opsiyonel)
        let user = Auth.auth().currentUser
        
        user?.delete { error in
            if let error = error {
                print("Kullanıcı silinemedi: \(error.localizedDescription)")
            } else {
                print("Firestore hatası nedeniyle kullanıcı silindi")
            }
        }
    }
    
    private func getAuthErrorMessage(_ error: Error) -> String {
        let nsError = error as NSError
        
        switch nsError.code {
        case AuthErrorCode.invalidEmail.rawValue:
            return "Geçersiz e-posta adresi."
        case AuthErrorCode.emailAlreadyInUse.rawValue:
            return "Bu e-posta adresi zaten kullanımda."
        case AuthErrorCode.weakPassword.rawValue:
            return "Şifre çok zayıf. Daha güçlü bir şifre deneyin."
        case AuthErrorCode.wrongPassword.rawValue:
            return "Yanlış şifre."
        case AuthErrorCode.userNotFound.rawValue:
            return "Bu e-posta adresiyle kayıtlı kullanıcı bulunamadı."
        case AuthErrorCode.userDisabled.rawValue:
            return "Bu hesap devre dışı bırakıldı."
        case AuthErrorCode.networkError.rawValue:
            return "Ağ hatası. İnternet bağlantınızı kontrol edin."
        case AuthErrorCode.tooManyRequests.rawValue:
            return "Çok fazla deneme yapıldı. Lütfen daha sonra tekrar deneyin."
        default:
            return "Giriş/Kayıt sırasında bir hata oluştu: \(error.localizedDescription)"
        }
    }
    
    private func showAlert(title: String, message: String) {
        alertTitle = title
        alertMessage = message
        showAlert = true
    }
}

#Preview {
    @State var t = true
    LoginView(isPresented: $t)
}
