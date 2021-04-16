//
//  PlayerViewModel.swift
//  AVPlayer
//
//  Created by Vu Minh Tam on 3/30/21.
// https://tainhac365.org/video/30782/video-nhac-cuoc-song-xa-nha-lyric-video-mien-phi.html
// https://c4-ex-swe.nixcdn.com/PreNCT18/CuocSongXaNhaLyricVideo-MinhVuongM4U-6246814.mp4?st=EIc660IbW_Xb8Kck6DW8Kg&e=1618545952
// https://vredir.nixcdn.com/PreNCT14/NhoGiaDinh-LeBaoBinh-5412176.mp4?st=9OAY9tIPtbgUjP2w8sO0-g&e=1618546099
// https://vredir.nixcdn.com/PreNCT14/DemLangThang-DinhPhuoc-5468044.mp4?st=auRGlK6NAnVy2QgW9p999Q&e=1618546221

import Foundation
import AVFoundation
import SwiftUI

protocol CheckNetWorkDelegate {
    func checkNetWork()
}

class PlayerViewModel: NSObject, ObservableObject {
    
    var player: AVQueuePlayer = AVQueuePlayer()
    
    var status:Float = 0.0
    var films = ["https://c4-ex-swe.nixcdn.com/PreNCT18/CuocSongXaNhaLyricVideo-MinhVuongM4U-6246814.mp4?st=EIc660IbW_Xb8Kck6DW8Kg&e=1618545952",
                 "https://vredir.nixcdn.com/PreNCT14/NhoGiaDinh-LeBaoBinh-5412176.mp4?st=9OAY9tIPtbgUjP2w8sO0-g&e=1618546099",
                 "https://vredir.nixcdn.com/PreNCT14/DemLangThang-DinhPhuoc-5468044.mp4?st=auRGlK6NAnVy2QgW9p999Q&e=1618546221",
    ]
    var episode = ["Episode One","Episode Two","Episode Three"]
    var fileName = ""
    private var urls: [URL] = []
    var playerItems: [AVPlayerItem] = []
    @Published var isLoading: Bool = false
    @Published var indexPlayer: Int = 0
    @Published var isHideBack = false
    @Published var isHideNext = false
    @Published var isRepeat: Bool = false
    @Published var isPopUpInternet: Bool = false
    var playerLooper: AVPlayerLooper?
    var checkNetWorkDelegate: CheckNetWorkDelegate?
    
    override init() {
    }
    
    func setUrlItems() {
        for i in 0 ..< films.count {
            if let url = URL(string: self.films[i]) {
                let asset = AVAsset(url: url)
                let playerItem = AVPlayerItem(asset: asset)
                playerItems.append(playerItem)
            }
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
                if !Reachability.shared.isConnectedToInternet {
                    self.isPopUpInternet = true
                    checkNetWorkDelegate?.checkNetWork()
                } else {
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
    }
    
    @objc func changeIndexPlayer(notification: NSNotification) {
  
        if !isPopUpInternet {
            let name = notification.userInfo?["name"] as? String
           
            let index =  findIndexPlayerItems(name: name!)
            
            switch index {
            case 0:
                DispatchQueue.main.async {
                    self.isHideBack = false
                    self.isHideNext = true
                }
            case 1:
                DispatchQueue.main.async {
                    self.isHideBack = true
                    self.isHideNext = true
                }
            case 2:
                DispatchQueue.main.async {
                    self.isHideNext = false
                    self.isHideBack = true
                }
            default:
                break
            }
            
            DispatchQueue.main.async {
                self.indexPlayer = index ?? 0
            }
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
    
    func findIndexPlayerItems(name: String) -> Int? {
        for i in 0...films.count - 1 {
              if films[i] == name {
                 return i
              }
           }
        return nil
    }
    
    func checkStatusPlayer() -> Bool {
        if player.currentItem?.status == .readyToPlay {
            return true
        }
        return false
    }
    
}
