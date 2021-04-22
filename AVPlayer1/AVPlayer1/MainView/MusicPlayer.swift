//
//  MusicPlayer.swift
//  AVPlayer1
//
//  Created by Vu Minh Tam on 4/20/21.
//

import SwiftUI
import AVFoundation


struct MusicPlayer_Previews: PreviewProvider {
    static var previews: some View {
        MusicPlayer(music: ListAudio.share.audios[0], isAudio: true)
    }
}

struct MusicPlayer: View, CheckNetWorkDelegate {
    func checkNetWork() {
        popUpInternet()
    }
    
    var music: Music
    var isAudio: Bool
    
//    @ObservedObject var PlayerViewModel.share: PlayerViewModel = PlayerViewModel()
    @State var width : CGFloat = 0
    @State var finish = false
    @State var isPause = false
    @State var timer: Timer?
    @State private var timeCurrent: Float64 = 0.0
    @State private var timeDuration: Float64 = 0.0
    
    var body: some View {
//        Button(action: {
//
//            let activityViewController = UIActivityViewController(activityItems: model.activityItem, applicationActivities: nil)
//            UIApplication.shared.windows.first?.rootViewController?.present(activityViewController, animated: true, completion: nil)
//
//        }) {
//            Image(systemName: "square.and.arrow.up")
//                .padding(.top, 30)
//        }
        
        ZStack {
            VStack(spacing: 20) {
                
                // activity
                GeometryReader { (geometry) in
                    Spacer()
                    LoadingView(isShowing: .constant(PlayerViewModel.share.isLoading)) {
                        PlayerContainerView(player: PlayerViewModel.share.player)
                    }
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .cornerRadius(15)
                }
                .padding(.top)
                
                // line repeat
                HStack {
                    // setting sound
                    Button(action: {
                        PlayerViewModel.share.isMuted.toggle()
                    }) {
                        Image(systemName: PlayerViewModel.share.isMuted ? "speaker.slash.fill" : "speaker.slash")
                            .padding(.top, 30)
                    }
                    Spacer()
//                    let name = isAudio ? PlayerViewModel.share.episode[PlayerViewModel.share.indexPlayer] : PlayerViewModel.share.song[PlayerViewModel.share.indexPlayer]
                    Text("\(music.name)").font(.title).padding(.top)
                    Spacer()
                    // replay
                    Button(action: {
                        PlayerViewModel.share.isRepeat.toggle()
                    }) {
                        Image(systemName: "repeat")
                            .foregroundColor(Color.white)
                            .padding(.top, 30)
                            .colorMultiply(PlayerViewModel.share.isRepeat ? Color.orange : Color.blue)
                    }
                }
                
                // time line
                ZStack(alignment: .leading) {
                    Capsule().fill(Color.black.opacity(0.08)).frame(height: 8)
                    Capsule().fill(Color.red).frame(width: self.width, height: 8)
                        .gesture(DragGesture()
                                    .onChanged({(value) in
                                        let x = value.location.x
                                        self.width = x
                                    }).onEnded({ (value) in
                                        let x = value.location.x
                                        let screen = UIScreen.main.bounds.width - 30
                                        let percent = x / screen
                                        let time = Double(percent) * CMTimeGetSeconds((PlayerViewModel.share.player.currentItem?.duration as CMTime?)!)
                                        PlayerViewModel.share.player.seek(to: CMTime(value: CMTimeValue(time * 1000), timescale: 1000))
                                    })
                        )
                    
                }.padding(.top)
                
                // pause and play
                HStack {
                    let resultCurrent = String(timeCurrent).components(separatedBy: ".")
                    let timeCurrent = PlayerViewModel.share.checkStatusPlayer() ? Int(resultCurrent[0])! : 0
                    let durationCurrent = FormatDuation().formatMinuteSeconds(timeCurrent)
                    Text("\(durationCurrent)")
                    Spacer()
                    let resultDuration = String(timeDuration).components(separatedBy: ".")
                    let timeDuration = PlayerViewModel.share.checkStatusPlayer() ? Int(resultDuration[0]) : 0
                    let result = timeDuration ?? 0 - timeCurrent
                    let durationDuration = FormatDuation().formatMinuteSeconds(result)
                    Text("\(durationDuration)")
                }
                .padding(.top, -20)
                
                HStack(spacing: UIScreen.main.bounds.width / 5 - 30){
                    
                    // set button back
                    Button(action: {
                        if PlayerViewModel.share.isPopUpInternet {
                            popUpInternet()
                        } else {
                            if !PlayerViewModel.share.isHideBack {
                                return
                            }
                            if PlayerViewModel.share.indexPlayer >= 1 {
                                PlayerViewModel.share.indexPlayer -= 1
                                PlayerViewModel.share.playItemAtPosition(at: PlayerViewModel.share.indexPlayer)
                            }
                        }
                        
                    }) {
                        Image(systemName: "backward.fill").font(.title)
                    }
                    .opacity(PlayerViewModel.share.isHideBack ? 1 : 0.1)
                    // set gobackward 15
                    Button(action: {
                        PlayerViewModel.share.rewindVideo(by: 15)
                        
                    }) {
                        Image(systemName: "gobackward.15").font(.title)
                    }
                    
                    // set play
                    Button(action: {
                        if !Reachability.shared.isConnectedToInternet {
                            popUpInternet()
                        } else {
                            PlayerViewModel.share.isPlaying.toggle()
                            if PlayerViewModel.share.isPlaying {
                                isPause = false
                            } else {
                                isPause = true
                            }
                            if self.finish {
                                self.width = 0
                                self.finish = false
                                PlayerViewModel.share.player.currentItem?.seek(to: .zero, completionHandler: nil)
                            }
                        }
                    }) {
                        Image(systemName: PlayerViewModel.share.isPlaying && !self.finish ? "pause.fill" : "play.fill").font(.title)
                    }
                    
                    // set gobackward 15
                    Button(action: {
                        
                        PlayerViewModel.share.forwardVideo(by: 15)
                        
                    }) {
                        Image(systemName: "goforward.15").font(.title)
                    }
                    
                    // set forward
                    Button(action: {
                        if !Reachability.shared.isConnectedToInternet {
                            PlayerViewModel.share.isPopUpInternet = true
                            popUpInternet()
                        } else {
                            PlayerViewModel.share.isPopUpInternet = false
                            if !PlayerViewModel.share.isHideNext {
                                return
                            }
                            if PlayerViewModel.share.indexPlayer < PlayerViewModel.share.audio.count - 1 {
                                PlayerViewModel.share.indexPlayer += 1
                                PlayerViewModel.share.playItemAtPosition(at: PlayerViewModel.share.indexPlayer)
                            }
                        }
                    }) {
                        Image(systemName: "forward.fill").font(.title)
                    }
                    .opacity(PlayerViewModel.share.isHideNext ? 1 : 0.1)
                }
            }.padding()
        }
            .onAppear {
//                self.model = PlayerViewModel()
                try! AVAudioSession.sharedInstance().setCategory(.playback)
                PlayerViewModel.share.checkNetWorkDelegate = self
                if !Reachability.shared.isConnectedToInternet {
                    PlayerViewModel.share.isPopUpInternet = true
                } else {
                    PlayerViewModel.share.isPopUpInternet = false
                }
                
                if PlayerViewModel.share.isPopUpInternet {
                    popUpInternet()
                }
                setData()
            }
//        .onDisappear() {
//            model.
//        }
        }

    func setData() {
        PlayerViewModel.share.setPlayerItems()
        PlayerViewModel.share.playItemAtPosition(at: findIndexPlayer())
        let screen = UIScreen.main.bounds.width - 30
        
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) {(_) in
            // check player.currentItem exists ?
            guard let _ =  PlayerViewModel.share.player.currentItem else { return }
            timeCurrent = CMTimeGetSeconds((PlayerViewModel.share.player.currentTime() as CMTime?)!)
            timeDuration = CMTimeGetSeconds((PlayerViewModel.share.player.currentItem?.duration as CMTime?)!)
            let value = timeCurrent / timeDuration
            if !isPause {
                if PlayerViewModel.share.player.status == .readyToPlay {
                    self.width = screen * CGFloat(value)
                }
            }
        }
    }
    
    func findIndexPlayer() -> Int {
        if isAudio {
            for i in 0...ListAudio.share.audios.count - 1 {
                if music.name == ListAudio.share.audios[i].name {
                    return i
                }
            }
        } else {
            for i in 0...ListMp3.share.mp3s.count - 1 {
                if music.name == ListMp3.share.mp3s[i].name {
                    return i
                }
            }
        }
        
        return 0
    }
    
    // set popup internet
    func popUpInternet() {
        PlayerViewModel.share.player.removeAllItems()
        let alert = UIAlertController(title: "NetWork", message: "Please check your network", preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default) { (_) in
            
            if !Reachability.shared.isConnectedToInternet {
                PlayerViewModel.share.isPopUpInternet = true
                popUpInternet()
            } else {
                PlayerViewModel.share.isPopUpInternet = false
                PlayerViewModel.share.playItemAtPosition(at: PlayerViewModel.share.indexPlayer)
            }
        }
        alert.addAction(ok)
        UIApplication.shared.windows.first?.rootViewController?.present(alert, animated: true, completion: {
        })
    }
}

