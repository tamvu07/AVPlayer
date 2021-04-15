//
//  PlayerViewModel.swift
//  AVPlayer
//
//  Created by Vu Minh Tam on 3/30/21.
//

import Foundation
import AVFoundation
import SwiftUI

class PlayerViewModel: NSObject, ObservableObject {
    
    var player: AVQueuePlayer = AVQueuePlayer()
    
    var status:Float = 0.0
    var films = ["video","video1","video2"]
    var episode = ["Episode One","Episode Two","Episode Three"]
    var fileName = ""
    private var urls: [URL] = []
    var playerItems: [AVPlayerItem] = []
    @Published var isLoading: Bool = false
    @Published var indexPlayer: Int = 0
    @Published var isHideBack = false
    @Published var isHideNext = false
    @Published var isRepeat: Bool = false 
    var playerLooper: AVPlayerLooper?
    
    override init() {
    }
    
    func setUrlItems() {
        for i in 0 ..< films.count {
            let asset = AVAsset(url: Bundle.main.url(forResource: self.films[i], withExtension: "mp4")!)
            let playerItem = AVPlayerItem(asset: asset)
            playerItems.append(playerItem)
        }
        self.player =  AVQueuePlayer(items: playerItems)
        player.addObserver(self, forKeyPath: "timeControlStatus", options: [.old, .new], context: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(changeIndexPlayer), name: NSNotification.Name(rawValue: "nameItem"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(playerEndedPlaying), name: Notification.Name("AVPlayerItemDidPlayToEndTimeNotification"), object: nil)
    }
    
    @Published var isPlaying: Bool = false {
        didSet {
            if isPlaying {
                play()
            } else {
                pause()
            }
        }
    }
    
    @Published var isMuted: Bool = false {
        didSet {
            if isMuted {
                player.isMuted = isMuted
            } else {
                player.isMuted = isMuted
            }
        }
    }
    
    func rewindVideo(by seconds: Float64) {
        if let currentTime = player.currentTime() as CMTime? {
            var newTime = CMTimeGetSeconds(currentTime) - seconds
            if newTime <= 0 {
                newTime = 0
            }
            player.seek(to: CMTime(value: CMTimeValue(newTime * 1000), timescale: 1000))
        }
    }
    
    func forwardVideo(by seconds: Float64) {
        if let currentTime = player.currentTime() as CMTime?, let duration = player.currentItem?.duration as CMTime? {
            var newTime = CMTimeGetSeconds(currentTime) + seconds
            if newTime >= CMTimeGetSeconds(duration) {
                newTime = CMTimeGetSeconds(duration)
            }
            player.seek(to: CMTime(value: CMTimeValue(newTime * 1000), timescale: 1000))
        }
    }
    
    func play() {
        let currentItem = player.currentItem
        if currentItem?.currentTime() == currentItem?.duration {
            currentItem?.seek(to: .zero, completionHandler: nil)
        }
        player.play()
    }
    
    func pause() {
        player.pause()
    }
    
    func playItemAtPosition(at itemIndex: Int) {
        
        player.removeAllItems()
        
        for index in itemIndex...playerItems.count - 1 {
            let item = playerItems[index]
            if player.canInsert(item, after: nil) {
                item.seek(to: .zero, completionHandler: nil)
                player.insert(item, after: nil)
            }
        }
    }
    
    override public func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "timeControlStatus", let change = change, let newValue = change[NSKeyValueChangeKey.newKey] as? Int, let oldValue = change[NSKeyValueChangeKey.oldKey] as? Int {
            let oldStatus = AVPlayer.TimeControlStatus(rawValue: oldValue)
            let newStatus = AVPlayer.TimeControlStatus(rawValue: newValue)
            if newStatus != oldStatus {
                DispatchQueue.main.async {[weak self] in
                    if newStatus == .playing || newStatus == .paused {
                        self?.isLoading = false
                    } else {
                        self?.isLoading = true
                    }
                }
            }
        }
    }
    
    @objc func changeIndexPlayer(notification: NSNotification) {
        let name = notification.userInfo?["name"] as? String
        let finalName = name!.replacingOccurrences(of: ".mp4", with: "")
        var index: Int = 0
        switch finalName {
        case "video":
            index = 0
            DispatchQueue.main.async {
                self.isHideBack = true
                self.isHideNext = false
            }
        case "video1":
            index = 1
            DispatchQueue.main.async {
                self.isHideBack = false
                self.isHideNext = false
            }
        case "video2":
            index = 2
            DispatchQueue.main.async {
                self.isHideNext = true
                self.isHideBack = false
            }
        default:
            break
        }
        
        DispatchQueue.main.async {
            self.indexPlayer = index
        }
        
    }
    
    @objc func playerEndedPlaying(_ notification: Notification) {
        
        if indexPlayer == playerItems.count - 1 && !isRepeat {
            isPlaying = false
            playItemAtPosition(at: playerItems.count - 1 )
        } else {
            if isRepeat {
                player.removeAllItems()
                let item = playerItems[indexPlayer]
                if player.canInsert(item, after: nil) {
                    item.seek(to: .zero, completionHandler: nil)
                    player.insert(item, after: nil)
                }
            } else {
                let index = indexPlayer + 1
                if  index <= playerItems.count - 1 {
                    playItemAtPosition(at: index)
                } else {
                    player.removeAllItems()
                }
            }
        }
    }
}
