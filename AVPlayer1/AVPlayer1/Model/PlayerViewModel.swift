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
 
    
    override init() {
    }
    
    func initalMp4() {
        let mp4First = File.init(url: "https://c4-ex-swe.nixcdn.com/PreNCT18/CuocSongXaNhaLyricVideo-MinhVuongM4U-6246814.mp4?st=EIc660IbW_Xb8Kck6DW8Kg&e=1618545952", name: "Episode One", imageName: "tv.music.note.fill")
        let mp4Second = File.init(url: "https://vredir.nixcdn.com/PreNCT14/NhoGiaDinh-LeBaoBinh-5412176.mp4?st=9OAY9tIPtbgUjP2w8sO0-g&e=1618546099", name: "Episode Two", imageName: "tv.music.note.fill")
        let mp4Three = File.init(url: "https://vredir.nixcdn.com/PreNCT14/DemLangThang-DinhPhuoc-5468044.mp4?st=auRGlK6NAnVy2QgW9p999Q&e=1618546221", name: "Episode Three", imageName: "tv.music.note.fill")
        ListMp4.append(mp4First)
        ListMp4.append(mp4Second)
        ListMp4.append(mp4Three)
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
        for i in 0 ..< ListMp4.count {
            if let url = URL(string: self.ListMp4[i].url) {
                let asset = AVAsset(url: url)
                let playerItem = AVPlayerItem(asset: asset)
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
                let playerItem = AVPlayerItem(asset: asset)
                playerItems.append(playerItem)
            }
        }
        self.player =  AVQueuePlayer(items: playerItems)
    }
    
    func setNotification() {
        
        player.addObserver(self, forKeyPath: "timeControlStatus", options: [.old, .new], context: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(changeIndexPlayer), name: NSNotification.Name(rawValue: "nameItem"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(playerEndedPlaying), name: Notification.Name("AVPlayerItemDidPlayToEndTimeNotification"), object: nil)
        addPeriodicTimeObserver()
       
    }
    
    func addPeriodicTimeObserver() {
        // Notify every half second
        let timeScale = CMTimeScale(NSEC_PER_SEC)
        let time = CMTime(seconds: 0.5, preferredTimescale: timeScale)

        timeObserverToken = player.addPeriodicTimeObserver(forInterval: time,
                                                          queue: .main) {
            [weak self] time in
            // update player transport UI
        }
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
        print("\(player.currentItem)")
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
  
//        if !isPopUpInternet {
//            let name = notification.userInfo?["name"] as? String
//           
//            let index =  findIndexPlayerItems(name: name!)
//            
//            switch index {
//            case 0:
//                DispatchQueue.main.async {
//                    self.isHideBack = false
//                    self.isHideNext = true
//                }
//            case 1:
//                DispatchQueue.main.async {
//                    self.isHideBack = true
//                    self.isHideNext = true
//                }
//            case 2:
//                DispatchQueue.main.async {
//                    self.isHideNext = false
//                    self.isHideBack = true
//                }
//            default:
//                break
//            }
//            
//            DispatchQueue.main.async {
//                self.indexPlayer = index ?? 0
//            }
//        }
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
    
//    func findIndexPlayerItems(name: String) -> Int? {
//        for i in 0...audio.count - 1 {
//              if audio[i] == name {
//                 return i
//              }
//           }
//        return nil
//    }
    
    func checkStatusPlayer() -> Bool {
        if player.currentItem?.status == .readyToPlay {
            return true
        }
        return false
    }
    
    // set merge audio and mp3
    func mergeUrl(indexAudio: Int, indexMp3: Int) {
        let mp4Url: NSURL = NSURL(fileURLWithPath: ListMp4[indexAudio].url)
        let mp3Url: NSURL = NSURL(fileURLWithPath: ListMp3[indexMp3].url)
        mergeFilesWithUrl(videoUrl: mp4Url.baseURL as! NSURL, audioUrl: mp3Url)
    }
    
    // merge audio
    func mergeFilesWithUrl(videoUrl:NSURL, audioUrl:NSURL) {
        let mixComposition : AVMutableComposition = AVMutableComposition()
        var mutableCompositionVideoTrack : [AVMutableCompositionTrack] = []
        var mutableCompositionAudioTrack : [AVMutableCompositionTrack] = []
        let totalVideoCompositionInstruction : AVMutableVideoCompositionInstruction = AVMutableVideoCompositionInstruction()


        //start merge

        let aVideoAsset : AVAsset = AVAsset(url: videoUrl as URL)
        let aAudioAsset : AVAsset = AVAsset(url: audioUrl as URL)

        mutableCompositionVideoTrack.append(mixComposition.addMutableTrack(withMediaType: AVMediaType.video, preferredTrackID: kCMPersistentTrackID_Invalid)!)
        mutableCompositionAudioTrack.append( mixComposition.addMutableTrack(withMediaType: AVMediaType.audio, preferredTrackID: kCMPersistentTrackID_Invalid)!)

        let aVideoAssetTrack : AVAssetTrack = aVideoAsset.tracks(withMediaType: AVMediaType.video)[0]
        let aAudioAssetTrack : AVAssetTrack = aAudioAsset.tracks(withMediaType: AVMediaType.audio)[0]

        do{
            try mutableCompositionVideoTrack[0].insertTimeRange(CMTimeRangeMake(start: CMTime.zero, duration: aVideoAssetTrack.timeRange.duration), of: aVideoAssetTrack, at: CMTime.zero)

            //In my case my audio file is longer then video file so i took videoAsset duration
            //instead of audioAsset duration

            try mutableCompositionAudioTrack[0].insertTimeRange(CMTimeRangeMake(start: CMTime.zero, duration: aVideoAssetTrack.timeRange.duration), of: aAudioAssetTrack, at: CMTime.zero)

            //Use this instead above line if your audiofile and video file's playing durations are same

            //            try mutableCompositionAudioTrack[0].insertTimeRange(CMTimeRangeMake(kCMTimeZero, aVideoAssetTrack.timeRange.duration), ofTrack: aAudioAssetTrack, atTime: kCMTimeZero)

        }catch{

        }

        totalVideoCompositionInstruction.timeRange = CMTimeRangeMake(start: CMTime.zero,duration: aVideoAssetTrack.timeRange.duration )

        let mutableVideoComposition : AVMutableVideoComposition = AVMutableVideoComposition()
        mutableVideoComposition.frameDuration = CMTimeMake(value: 1, timescale: 30)

        mutableVideoComposition.renderSize = CGSize(width: 1280,height: 720)

        //        playerItem = AVPlayerItem(asset: mixComposition)
        //        player = AVPlayer(playerItem: playerItem!)
        //
        //
        //        AVPlayerVC.player = player



        //find your video on this URl
        let savePathUrl : NSURL = NSURL(fileURLWithPath: NSHomeDirectory() + "/Documents/newVideo123.mp4")

        let assetExport: AVAssetExportSession = AVAssetExportSession(asset: mixComposition, presetName: AVAssetExportPresetHighestQuality)!
        assetExport.outputFileType = AVFileType.mp4
        assetExport.outputURL = savePathUrl as URL
        assetExport.shouldOptimizeForNetworkUse = true

        assetExport.exportAsynchronously { [self] () -> Void in
            switch assetExport.status {

            case AVAssetExportSessionStatus.completed:
                //let assetsLib = ALAssetsLibrary()
                //assetsLib.writeVideoAtPathToSavedPhotosAlbum(savePathUrl, completionBlock: nil)

                print("success")
                
                let fileName = String((savePathUrl.lastPathComponent!)) as NSString
                // Create destination URL
                let documentsUrl:URL =  (FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first as URL?)!
                let destinationFileUrl = documentsUrl.appendingPathComponent("\(fileName)")
                //Create URL to the source file you want to download
//                let sessionConfig = URLSessionConfiguration.default
//                let session = URLSession(configuration: sessionConfig)
//                let request = URLRequest(url: URL(string: savePathUrl.relativeString)!)
                do {
                    let contents  = try FileManager.default.contentsOfDirectory(at: documentsUrl, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
                    for indexx in 0..<contents.count {
                        if contents[indexx].lastPathComponent == destinationFileUrl.lastPathComponent {
                            
                            DispatchQueue.main.async {
                                self.activityItem = [contents[indexx]]
                            }
                        }
                    }
                }
                catch (let err) {
                    print("error: \(err)")
                }
            case  AVAssetExportSessionStatus.failed:
                print("failed \(String(describing: assetExport.error))")
            case AVAssetExportSessionStatus.cancelled:
                print("cancelled \(String(describing: assetExport.error))")
            default:
                print("complete")
            }
        }
    }
}
