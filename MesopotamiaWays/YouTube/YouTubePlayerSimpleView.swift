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


// MARK: - Basit YouTube Player View
struct YouTubePlayerSimpleView: UIViewRepresentable {
    let videoID: String
    
    func makeUIView(context: Context) -> YTPlayerView {
        let playerView = YTPlayerView()
        
        // YouTube'un kendi kontrollerini göster
        let playerVars: [AnyHashable: Any] = [
            "playsinline": 1,
            "controls": 1, // YouTube kontrollerini göster
            "showinfo": 0,
            "modestbranding": 1,
            "rel": 0,
            "iv_load_policy": 3,
            "fs": 1, // Tam ekran butonu
            "autoplay": 0
        ]
        
        playerView.load(withVideoId: videoID, playerVars: playerVars)
        return playerView
    }
    
    func updateUIView(_ uiView: YTPlayerView, context: Context) {
        // Değişiklik gerekmiyor
    }
}



// MARK: - Corner Radius Extension
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}
