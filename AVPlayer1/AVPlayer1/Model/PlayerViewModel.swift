//
//  PlayerViewModel.swift
//  AVPlayer
//
//  Created by Vu Minh Tam on 3/30/21.
// https://tainhac365.org/video/30782/video-nhac-cuoc-song-xa-nha-lyric-video-mien-phi.html
// https://c4-ex-swe.nixcdn.com/PreNCT18/CuocSongXaNhaLyricVideo-MinhVuongM4U-6246814.mp4?st=EIc660IbW_Xb8Kck6DW8Kg&e=1618545952
// https://vredir.nixcdn.com/PreNCT14/NhoGiaDinh-LeBaoBinh-5412176.mp4?st=9OAY9tIPtbgUjP2w8sO0-g&e=1618546099
// https://vredir.nixcdn.com/PreNCT14/DemLangThang-DinhPhuoc-5468044.mp4?st=auRGlK6NAnVy2QgW9p999Q&e=1618546221
// mp3
import Foundation
import AVFoundation
import SwiftUI
import UIKit
import AVKit
import AssetsLibrary

protocol CheckNetWorkDelegate {
    func checkNetWork()
}

struct File: Identifiable, Hashable {
    static func == (lhs: File, rhs: File) -> Bool {
        return false
    }
    
    let id = UUID()
    var url: String
    var name: String
    var imageName: String
    
    var image: Image? {
        Image(systemName: imageName)
    }
    
    init(url: String, name: String, imageName: String) {
        self.url = url
        self.name = name
        self.imageName = imageName
    }
}

class PlayerViewModel: NSObject, ObservableObject {
    
  
    var player: AVQueuePlayer = AVQueuePlayer()
    static let share = PlayerViewModel()
    let id = UUID()
    var status:Float = 0.0
    
    var ListMp4: [File] = []
    var ListMp3: [File] = []
    
    var fileName = ""
    private var urls: [URL] = []
    var playerItems: [AVPlayerItem] = []
    @Published var isLoading: Bool = false
    @Published var indexPlayer: Int = 0
    @Published var isHideBack = false
    @Published var isHideNext = false
    @Published var isRepeat: Bool = false
    @Published var isPopUpInternet: Bool = false
    var checkNetWorkDelegate: CheckNetWorkDelegate?
    var timeObserverToken: Any?
    @Published var activityItem: [Any] = []
    var ismp4: Bool = false
    let listmp4DB = DBManage.sharedInstance.getDataFromDB()
    var arrMp4: [String] = []
    var arrMp3: [String] = []
    
    override init() {
    }
    
    func initalMp4() {
        let mp4First = File.init(url: "video", name: "Episode One", imageName: "tv.music.note.fill")
        let mp4Second = File.init(url: "video1", name: "Episode Two", imageName: "tv.music.note.fill")
        let mp4Three = File.init(url: "video2", name: "Episode Three", imageName: "tv.music.note.fill")
        ListMp4.append(mp4First)
        ListMp4.append(mp4Second)
        ListMp4.append(mp4Three)
        for i in 0 ..< listmp4DB.count {
            let mp4 = File.init(url: listmp4DB[i].url, name: listmp4DB[i].name, imageName: listmp4DB[i].imageName)
            ListMp4.append(mp4)
        }
    }
    
    func initalMp3() {
        let mp3First = File.init(url: "mp31", name: "Song One", imageName: "music.note")
        let mp3Second = File.init(url: "mp32", name: "Song Two", imageName: "music.note")
        let mp3Three = File.init(url: "mp33", name: "Song Three", imageName: "music.note")
        ListMp3.append(mp3First)
        ListMp3.append(mp3Second)
        ListMp3.append(mp3Three)
    }
    
    func setPlayerItemsMp4() {
        playerItems.removeAll()
        self.player.removeAllItems()
        for i in 0 ..< ListMp4.count - listmp4DB.count {
            if let url = Bundle.main.path(forResource: self.ListMp4[i].url, ofType: "mp4") {
                let asset = AVAsset(url: URL(fileURLWithPath: url))
                let assetSubtitle = setSubtitle(localVideoAsset: asset)
                let playerItem = AVPlayerItem(asset: assetSubtitle)
                arrMp4.append("\(playerItem.description)")
                playerItems.append(playerItem)
            }
        }
        for i in ListMp4.count - listmp4DB.count ..< ListMp4.count {
            if let url = URL(string: self.ListMp4[i].url) {
                let asset = AVAsset(url: url)
                let assetSubtitle = setSubtitle(localVideoAsset: asset)
                let playerItem = AVPlayerItem(asset: assetSubtitle)
                arrMp4.append("\(playerItem.description)")
                playerItems.append(playerItem)
            }
        }
        self.player =  AVQueuePlayer(items: playerItems)
    }
    
    func setPlayerItemsMp3() {
        playerItems.removeAll()
        self.player.removeAllItems()
        for i in 0 ..< ListMp3.count {
            if let url = Bundle.main.path(forResource: self.ListMp3[i].url, ofType: "mp3") {
                let asset = AVAsset(url: URL(fileURLWithPath: url))
                let assetSubtitle = setSubtitle(localVideoAsset: asset)
                let playerItem = AVPlayerItem(asset: assetSubtitle)
                arrMp3.append("\(playerItem.description)")
                playerItems.append(playerItem)
            }
        }
        self.player =  AVQueuePlayer(items: playerItems)
    }
    
    func setNotification() {
        
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
        player.advanceToPreviousItem(for: itemIndex, with: self.playerItems)
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
                            if let reason = self?.player.reasonForWaitingToPlay {

                                  switch reason {
                                  case .evaluatingBufferingRate:
                                      print("reasonForWaitingToPlay.evaluatingBufferingRate")

                                  case .toMinimizeStalls:
                                      print("reasonForWaitingToPlay.toMinimizeStalls")

                                  case .noItemToPlay:
                                      print("reasonForWaitingToPlay.noItemToPlay")

                                  default:
                                      print("Unknown \(reason)")
                                  }
                              }
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
            let indexPlayerCurrent = ismp4 ? ListMp4.count - 1 : ListMp3.count - 1
            switch index {
            case 0:
                DispatchQueue.main.async {
                    self.isHideBack = false
                    self.isHideNext = true
                }
            case indexPlayerCurrent:
                DispatchQueue.main.async {
                    self.isHideNext = false
                    self.isHideBack = true
                }
            default:
                DispatchQueue.main.async {
                    self.isHideBack = true
                    self.isHideNext = true
                }
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
        if ismp4 {
            let nameFinal = player.currentItem?.description
            for i in 0...arrMp4.count - 1 {
                if arrMp4[i] == nameFinal {
                     return i
                  }
               }
        } else {
            let nameFinal = player.currentItem?.description
            for i in 0...arrMp3.count - 1 {
                if arrMp3[i]  == nameFinal {
                     return i
                  }
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
    
    func getNamePlayer() -> String {
            if ismp4 {
                let nameFinal = player.currentItem?.description
                for i in 0 ..< arrMp4.count {
                    if arrMp4[i] == nameFinal {
                        return ListMp4[i].name
                    }
                }
            } else {
                let nameFinal = player.currentItem?.description
                for i in 0 ..< arrMp3.count {
                    if arrMp3[i] == nameFinal {
                        return ListMp3[i].name
                    }
                }
            }
        return ""
    }
    
    // set merge audio and mp3
    func mergeUrl(videoUrl: Int, audioUrl: Int, success: @escaping(Bool) -> (), failure: @escaping(Bool) -> ()) {
        let mp4Url: NSURL = NSURL(fileURLWithPath: Bundle.main.path(forResource: self.ListMp4[videoUrl - 1].url, ofType: "mp4")!)
        let mp3Url: NSURL = NSURL(fileURLWithPath: Bundle.main.path(forResource: self.ListMp3[audioUrl - 1].url, ofType: "mp3")!)
        mergeFilesWithUrl(videoUrl: mp4Url, audioUrl: mp3Url, name: "\(videoUrl)\(audioUrl)", success: {(merge) in
            success(merge)
        }, failure: { (merge) in
            failure(merge)
        })
    }
    
    func setSubtitle(localVideoAsset: AVAsset) -> AVMutableComposition {
        let videoPlusSubtitles = AVMutableComposition()

        let videoTrack = videoPlusSubtitles.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid)
        try? videoTrack?.insertTimeRange(CMTimeRangeMake(start: CMTime.zero, duration: localVideoAsset.duration),
                                         of: localVideoAsset.tracks(withMediaType: .audio)[0],
                                         at: CMTime.zero)
        if ismp4 {
            //Adds video track video
            let videoTrack = videoPlusSubtitles.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid)
            try? videoTrack?.insertTimeRange(CMTimeRangeMake(start: CMTime.zero, duration: localVideoAsset.duration),
                                             of: localVideoAsset.tracks(withMediaType: .video)[0],
                                             at: CMTime.zero)
        }
        //Adds subtitle track
        let subtitleAsset = AVURLAsset(url: Bundle.main.url(forResource: "trailer_720p", withExtension: ".vtt")!)
        
        let subtitleTrack = videoPlusSubtitles.addMutableTrack(withMediaType: .text, preferredTrackID: kCMPersistentTrackID_Invalid)
        
        try? subtitleTrack?.insertTimeRange(CMTimeRangeMake(start: CMTime.zero, duration: localVideoAsset.duration),
                                            of: subtitleAsset.tracks(withMediaType: .text)[0],
                                            at: CMTime.zero)
        return videoPlusSubtitles
    }
    
    // merge audio
    func mergeFilesWithUrl(videoUrl: NSURL, audioUrl: NSURL, name: String, success: @escaping(Bool) -> (), failure: @escaping(Bool) -> ()) {
        
        let mixComposition : AVMutableComposition = AVMutableComposition()
        var mutableCompositionVideoTrack: [AVMutableCompositionTrack] = []
        var mutableCompositionAudioTrack: [AVMutableCompositionTrack] = []

        //start merge
        let aVideoAsset: AVAsset = AVAsset(url: videoUrl as URL)
        let aAudioAsset: AVAsset = AVAsset(url: audioUrl as URL)
        
        let aVideoAssetTrack : AVAssetTrack = aVideoAsset.tracks(withMediaType: .video)[0]
        let aAudioAssetTrack : AVAssetTrack = aAudioAsset.tracks(withMediaType: .audio)[0]

        mutableCompositionVideoTrack.append(mixComposition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid)!)
        mutableCompositionAudioTrack.append(mixComposition.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid)!)

        do{
            try mutableCompositionVideoTrack[0].insertTimeRange(CMTimeRangeMake(start: CMTime.zero, duration: aVideoAssetTrack.timeRange.duration), of: aVideoAssetTrack, at: CMTime.zero)

            try mutableCompositionAudioTrack[0].insertTimeRange(CMTimeRangeMake(start: CMTime.zero, duration: aVideoAssetTrack.timeRange.duration), of: aAudioAssetTrack, at: CMTime.zero)

        } catch {
        }

        let nameMp4 = "Episode" + "\(name)\(Int.random(in: 0..<9))"
        let savePathUrl: NSURL = NSURL(fileURLWithPath: NSHomeDirectory() + "/Documents/\(nameMp4).mp4")
        
        do {
            try FileManager.default.removeItem(at: savePathUrl as URL)
            } catch { print(error.localizedDescription) }

        let assetExport: AVAssetExportSession = AVAssetExportSession(asset: mixComposition, presetName: AVAssetExportPresetHighestQuality)!
        assetExport.outputFileType = AVFileType.mp4
        assetExport.outputURL = savePathUrl as URL
        assetExport.shouldOptimizeForNetworkUse = true

        assetExport.exportAsynchronously { [self] () -> Void in
            switch assetExport.status {

            case AVAssetExportSessionStatus.completed:
                print("success")
                success(true)
                let item = Item()
                item.url = "\(savePathUrl)"
                item.name = nameMp4
                item.imageName = "tv.music.note.fill"
                DispatchQueue.main.async {
                    popMegerSuccess()
                    DBManage.sharedInstance.addData(object: item)
                }
            case  AVAssetExportSessionStatus.failed:
                print("failed \(String(describing: assetExport.error))")
                failure(false)
            case AVAssetExportSessionStatus.cancelled:
                print("cancelled \(String(describing: assetExport.error))")
                failure(false)
            default:
                print("complete")
                failure(false)
            }
        }
    }
    
    // set popup meger success
    func popMegerSuccess() {
        let alert = UIAlertController(title: "Meger", message: "Files were megered ", preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default) { (_) in
        }
        alert.addAction(ok)
        UIApplication.shared.windows.first?.rootViewController?.present(alert, animated: true, completion: {
        })
    }
}

extension AVQueuePlayer {
func advanceToPreviousItem(for currentItem: Int, with initialItems: [AVPlayerItem]) {
    self.removeAllItems()
    for i in currentItem..<initialItems.count {
        let obj: AVPlayerItem? = initialItems[i]
        if self.canInsert(obj!, after: nil) {
            obj?.seek(to: CMTime.zero, completionHandler: nil)
            self.insert(obj!, after: nil)
        }
    }
}
}
