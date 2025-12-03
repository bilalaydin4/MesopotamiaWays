//
//  YouTubePlayerView.swift
//  MesopotamiaWays
//
//  Created by Bilal AYDIN on 3.12.2025.
//
//  YouTubePlayerView.swift (TAM ÇALIŞAN)
//  MesopotamiaWays
//

import SwiftUI
import YouTubeiOSPlayerHelper

struct YouTubePlayerView: UIViewRepresentable {
    let videoID: String
    @Binding var playerState: YTPlayerState
    var onPlayerReady: (() -> Void)?
    
    func makeUIView(context: Context) -> YTPlayerView {
        let playerView = YTPlayerView()
        playerView.delegate = context.coordinator
        
        // Referans örneğe göre player vars
        let playerVars: [AnyHashable: Any] = [
            "playsinline": 1,
            "controls": 1, // YouTube kontrollerini göster
            "showinfo": 0,
            "modestbranding": 1,
            "rel": 0,
            "iv_load_policy": 3,
            "fs": 1, // Tam ekran butonunu göster
            "autoplay": 0,
            "enablejsapi": 1
        ]
        
        playerView.load(withVideoId: videoID, playerVars: playerVars)
        return playerView
    }
    
    func updateUIView(_ uiView: YTPlayerView, context: Context) {
        // Değişiklik yok
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, YTPlayerViewDelegate {
        let parent: YouTubePlayerView
        
        init(_ parent: YouTubePlayerView) {
            self.parent = parent
        }
        
        func playerViewDidBecomeReady(_ playerView: YTPlayerView) {
            print("✅ YouTube Player hazır")
            parent.onPlayerReady?()
        }
        
        func playerView(_ playerView: YTPlayerView, didChangeTo state: YTPlayerState) {
            DispatchQueue.main.async {
                self.parent.playerState = state
                print("🎬 Player state: \(state.rawValue)")
            }
        }
        
        func playerView(_ playerView: YTPlayerView, receivedError error: YTPlayerError) {
            print("❌ YouTube Player Error: \(error)")
        }
    }
}
