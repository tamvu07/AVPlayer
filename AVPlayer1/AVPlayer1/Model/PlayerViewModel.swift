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

class PlayerViewModel: NSObject, ObservableObject {
    
    var player: AVQueuePlayer = AVQueuePlayer()
    static let share = PlayerViewModel()
    let id = UUID()
    var status:Float = 0.0
    var audio = ["https://c4-ex-swe.nixcdn.com/PreNCT18/CuocSongXaNhaLyricVideo-MinhVuongM4U-6246814.mp4?st=EIc660IbW_Xb8Kck6DW8Kg&e=1618545952",
                 "https://vredir.nixcdn.com/PreNCT14/NhoGiaDinh-LeBaoBinh-5412176.mp4?st=9OAY9tIPtbgUjP2w8sO0-g&e=1618546099",
                 "https://vredir.nixcdn.com/PreNCT14/DemLangThang-DinhPhuoc-5468044.mp4?st=auRGlK6NAnVy2QgW9p999Q&e=1618546221",
    ]
    var mp3 = ["https://109a15170.vws.vegacdn.vn//U86v-OprSNK2DCewvsoB9w//1618953112//media1//song//web1//32//262676//262676.mp3?v=3",
               "https://109a15170.vws.vegacdn.vn//5BfcNgZ_4R5nRw-gG6AQ4g//1618953112//media1//song//web1//35//288987//288987.mp3?v=3",
               "https://109a15170.vws.vegacdn.vn//gO5xPtJvkkyC34oKSGvHOA//1618953112//media1//song//web1//41//339858//339858.mp3?v=3",
    ]
    
    var episode = ["Episode One","Episode Two","Episode Three"]
    var song = ["Song One","Song Two","Song Three"]
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
    var timeObserverToken: Any?
    @Published var activityItem: [Any] = []
 
    
    override init() {
    }
    
    func setURLAudio() {
        playerItems.removeAll()
        self.player.removeAllItems()
        for i in 0 ..< audio.count {
            if let url = URL(string: self.audio[i]) {
                let asset = AVAsset(url: url)
                let playerItem = AVPlayerItem(asset: asset)
                playerItems.append(playerItem)
            }
        }
        self.player =  AVQueuePlayer(items: playerItems)
    }
    
    func setURLMp3() {
        playerItems.removeAll()
        self.player.removeAllItems()
        for i in 0 ..< mp3.count {
            if let url = URL(string: self.mp3[i]) {
                let asset = AVAsset(url: url)
                let playerItem = AVPlayerItem(asset: asset)
                playerItems.append(playerItem)
            }
        }
        self.player =  AVQueuePlayer(items: playerItems)
    }
    
    func setPlayerItems() {
//        playerItems.removeAll()
//        player.removeAllItems()
//        for i in 0 ..< audio.count {
//            if let url = URL(string: self.audio[i]) {
//                let asset = AVAsset(url: url)
//                let playerItem = AVPlayerItem(asset: asset)
//                playerItems.append(playerItem)
//            }
//        }
        
//        self.player =  AVQueuePlayer(items: playerItems)
        
        player.addObserver(self, forKeyPath: "timeControlStatus", options: [.old, .new], context: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(changeIndexPlayer), name: NSNotification.Name(rawValue: "nameItem"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(playerEndedPlaying), name: Notification.Name("AVPlayerItemDidPlayToEndTimeNotification"), object: nil)
        addPeriodicTimeObserver()
        
//        let videoUrl: NSURL = NSURL(fileURLWithPath: films[0])
//        let videoUrl : NSURL =  NSURL(fileURLWithPath: Bundle.main.path(forResource: "video", ofType: "mp4")!)
//        let audioUrl: NSURL = NSURL(fileURLWithPath: mp3[0])
//        mergeFilesWithUrl(videoUrl: videoUrl, audioUrl: audioUrl)
       
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
        for i in 0...audio.count - 1 {
              if audio[i] == name {
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

                //Uncomment this if u want to store your video in asset

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
                print("failed \(assetExport.error)")
            case AVAssetExportSessionStatus.cancelled:
                print("cancelled \(assetExport.error)")
            default:
                print("complete")
            }
        }


    }
    
}
