//
//  YouTubeFullScreenPlayer.swift
//  MesopotamiaWays
//
//  Created by Bilal AYDIN on 3.12.2025.
//

//
//  YouTubeFullScreenPlayer.swift (GÜNCELLENMİŞ)
//  MesopotamiaWays
//
//
//  YouTubeFullScreenPlayer.swift (TAM ÇALIŞAN)
//  MesopotamiaWays
//

import SwiftUI
import YouTubeiOSPlayerHelper

struct YouTubeFullScreenPlayer: View {
    let videoID: String
    let placeName: String
    @Binding var isPresented: Bool
    
    @State private var playerState: YTPlayerState = .unknown
    @State private var playerView: YTPlayerView?
    @State private var showControls = false
    @State private var isPlayerReady = false
    
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 0) {
                // ÜST BAR - Sadece geri butonu
                HStack {
                    Button(action: {
                        isPresented = false
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: "chevron.left")
                                .font(.title3)
                                .foregroundColor(.white)
                            Text("Geri")
                                .font(.headline)
                                .foregroundColor(.white)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(Color.black.opacity(0.7))
                        .cornerRadius(20)
                    }
                    
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.top, 50)
                
                Spacer()
                
                // YOUTUBE PLAYER
                YouTubePlayerView(
                    videoID: videoID,
                    playerState: $playerState,
                    onPlayerReady: {
                        isPlayerReady = true
                        print("🎬 Player hazır, video başlatılabilir")
                    }
                )
                .frame(height: 300)
                .cornerRadius(12)
                .padding(.horizontal)
                .shadow(radius: 10)
                
                Spacer()
                
                // ALT KONTROLLER
                VStack(spacing: 20) {
                    // Video Başlığı
                    Text(placeName)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    // Kontrol Butonları
                    HStack(spacing: 30) {
                        // YouTube'a Aç
                        Button(action: {
                            openInYouTube()
                        }) {
                            VStack {
                                Image(systemName: "arrow.up.right.square")
                                    .font(.title2)
                                Text("YouTube'da aç")
                                    .font(.caption)
                            }
                            .foregroundColor(.white)
                        }
                        
                        // Paylaş
                        Button(action: {
                            shareVideo()
                        }) {
                            VStack {
                                Image(systemName: "square.and.arrow.up")
                                    .font(.title2)
                                Text("Paylaş")
                                    .font(.caption)
                            }
                            .foregroundColor(.white)
                        }
                        
                        // Hız Kontrolü
                        Menu {
                            Button("0.5x Hız") { setPlaybackRate(0.5) }
                            Button("0.75x Hız") { setPlaybackRate(0.75) }
                            Button("Normal (1x)") { setPlaybackRate(1.0) }
                            Button("1.25x Hız") { setPlaybackRate(1.25) }
                            Button("1.5x Hız") { setPlaybackRate(1.5) }
                            Button("2x Hız") { setPlaybackRate(2.0) }
                        } label: {
                            VStack {
                                Image(systemName: "speedometer")
                                    .font(.title2)
                                Text("Hız")
                                    .font(.caption)
                            }
                            .foregroundColor(.white)
                        }
                    }
                    
                    // Kapat Butonu
                    Button(action: {
                        isPresented = false
                    }) {
                        Text("Kapat")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.red)
                            .cornerRadius(15)
                    }
                    .padding(.horizontal, 40)
                    .padding(.bottom, 30)
                }
                .padding(.top, 30)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [.black, .black.opacity(0.8)]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            }
        }
        .statusBar(hidden: true)
        .onAppear {
            // 2 saniye sonra kontrolleri göster
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                withAnimation {
                    showControls = true
                }
            }
        }
    }
    
    // MARK: - Kontrol Fonksiyonları
    
    private func openInYouTube() {
        if let url = URL(string: "https://www.youtube.com/watch?v=\(videoID)") {
            UIApplication.shared.open(url)
        }
    }
    
    private func shareVideo() {
        let url = URL(string: "https://www.youtube.com/watch?v=\(videoID)")!
        let activityVC = UIActivityViewController(
            activityItems: ["\(placeName) videosunu izle: ", url],
            applicationActivities: nil
        )
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootViewController = windowScene.windows.first?.rootViewController {
            rootViewController.present(activityVC, animated: true)
        }
    }
    
    private func setPlaybackRate(_ rate: Float) {
        // Burada JavaScript ile playback rate ayarlanabilir
        print("🎚️ Playback rate: \(rate)x")
        // Gerçek implementasyon için JavaScript gerekir
    }
}

// MARK: - Basit PlaceDetailView YouTube Bölümü
struct YouTubeVideoSection: View {
    let videoID: String
    let placeName: String
    @Binding var showYouTubePlayer: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Tanıtım Videosu")
                    .font(.headline)
                
                Spacer()
                
                // YouTube İkonu
                Image(systemName: "play.circle.fill")
                    .foregroundColor(.red)
            }
            
            // Video Thumbnail
            Button(action: {
                showYouTubePlayer = true
            }) {
                ZStack {
                    // YouTube Thumbnail
                    AsyncImage(url: URL(string: "https://img.youtube.com/vi/\(videoID)/mqdefault.jpg")) { image in
                        image
                            .resizable()
                            .aspectRatio(16/9, contentMode: .fill)
                            .frame(height: 180)
                            .clipped()
                            .cornerRadius(12)
                    } placeholder: {
                        Rectangle()
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [.gray.opacity(0.3), .gray.opacity(0.1)]),
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .frame(height: 180)
                            .cornerRadius(12)
                            .overlay(
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .red))
                            )
                    }
                    
                    // Oynat Butonu
                    Image(systemName: "play.circle.fill")
                        .font(.system(size: 50))
                        .foregroundColor(.white)
                        .shadow(radius: 10)
                }
                .frame(height: 180)
            }
            .buttonStyle(PlainButtonStyle())
            
            // Açıklama
            VStack(alignment: .leading, spacing: 4) {
                Text("YouTube Player ile izle")
                    .font(.subheadline)
                    .foregroundColor(.primary)
                
                Text("YouTube'un kendi kontrolleri ile tam ekran izleme")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
        }
        .padding(.vertical, 8)
    }
}
