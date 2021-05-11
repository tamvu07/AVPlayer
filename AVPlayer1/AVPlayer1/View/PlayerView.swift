//
//  PlayerView.swift
//  AVPlayer
//
//  Created by Vu Minh Tam on 3/30/21.
//

import Foundation
import SwiftUI
import AVFoundation

class PlayerView: UIView {
    // Override UIView property
    override static var layerClass: AnyClass {
        return AVPlayerLayer.self
    }
    
    var playerLayer: AVPlayerLayer {
        return layer as! AVPlayerLayer
    }
    
    var player: AVPlayer? {
        get {
            return playerLayer.player
        }
        set {
            playerLayer.player = newValue
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "nameItem"), object: nil, userInfo: ["name" : "\(newValue?.currentItem?.description ?? "")"])
        }

    }
    
    init(player: AVPlayer) {
        super.init(frame: .zero)
        self.player = player
        self.backgroundColor = .black
        playerLayer.contentsGravity = .resizeAspectFill
        playerLayer.videoGravity = .resizeAspectFill
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

final class PlayerContainerView: UIViewRepresentable {
    
    typealias UIViewType = PlayerView
    
    let player: AVQueuePlayer
    
    init(player: AVQueuePlayer) {
        self.player = player
    }
    
    func makeUIView(context: Context) -> PlayerView {
        return PlayerView(player: player)
    }
    
    func updateUIView(_ uiView: PlayerView, context: Context) {
        uiView.player = self.player
    }
}

struct ActivityIndicator: UIViewRepresentable {
    @Binding var isAnimating: Bool
    let style: UIActivityIndicatorView.Style

    func makeUIView(context: UIViewRepresentableContext<ActivityIndicator>) -> UIActivityIndicatorView {
        return UIActivityIndicatorView(style: style)
    }

    func updateUIView(_ uiView: UIActivityIndicatorView, context: UIViewRepresentableContext<ActivityIndicator>) {
        isAnimating ? uiView.startAnimating() : uiView.stopAnimating()
    }
}
