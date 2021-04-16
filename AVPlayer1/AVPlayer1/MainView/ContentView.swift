//
//  ContentView.swift
//  AVPlayer1
//
//  Created by Vu Minh Tam on 4/8/21.
//

import SwiftUI
import AVFoundation

struct ContentView: View {
    var body: some View {
        
        MusicPlayer()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct MusicPlayer: View, CheckNetWorkDelegate {
    func checkNetWork() {
        popUpInternet()
    }
    
    @ObservedObject var model: PlayerViewModel
    @State var width : CGFloat = 0
    @State var finish = false
    @State var isPause = false
    @State var timer: Timer?
    @State private var timeCurrent: Float64 = 0.0
    @State private var timeDuration: Float64 = 0.0
    
    
    init() {
        model = PlayerViewModel()
        model.checkNetWorkDelegate = self
    }
    var body: some View {
        
        ZStack {
            
            VStack(spacing: 20) {
                
                // activity
                GeometryReader { (geometry) in
                    Spacer()
                    LoadingView(isShowing: .constant(model.isLoading)) {
                        PlayerContainerView(player: self.model.player)
                    }
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .cornerRadius(15)
                }
                .padding(.top)
                
                // line repeat
                HStack {
                    // setting sound
                    Button(action: {
                        self.model.isMuted.toggle()
                    }) {
                        Image(systemName: self.model.isMuted ? "speaker.slash.fill" : "speaker.slash")
                            .padding(.top, 30)
                    }
                    Spacer()
                    Text("\(model.episode[model.indexPlayer])").font(.title).padding(.top)
                    Spacer()
                    // replay
                    Button(action: {
                        self.model.isRepeat.toggle()
                    }) {
                        Image(systemName: "repeat")
                            .foregroundColor(Color.white)
                            .padding(.top, 30)
                            .colorMultiply(self.model.isRepeat ? Color.orange : Color.blue)
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
                                        let time = Double(percent) * CMTimeGetSeconds((model.player.currentItem?.duration as CMTime?)!)
                                        model.player.seek(to: CMTime(value: CMTimeValue(time * 1000), timescale: 1000))
                                    })
                        )
                    
                }.padding(.top)
                
                // pause and play
                HStack {
                    let resultCurrent = String(timeCurrent).components(separatedBy: ".")
                    let timeCurrent = model.checkStatusPlayer() ? Int(resultCurrent[0])! : 0
                    let durationCurrent = FormatDuation().formatMinuteSeconds(timeCurrent)
                    Text("\(durationCurrent)")
                    Spacer()
                    let resultDuration = String(timeDuration).components(separatedBy: ".")
                    let timeDuration = model.checkStatusPlayer() ? Int(resultDuration[0])! : 0
                    let result = timeDuration - timeCurrent
                    let durationDuration = FormatDuation().formatMinuteSeconds(result)
                    Text("\(durationDuration)")
                }
                .padding(.top, -20)
                
                HStack(spacing: UIScreen.main.bounds.width / 5 - 30){
                    
                    // set button back
                    Button(action: {
                        if model.isPopUpInternet {
                            popUpInternet()
                        } else {
                            if !model.isHideBack {
                                return
                            }
                            if model.indexPlayer >= 1 {
                                model.indexPlayer -= 1
                                model.playItemAtPosition(at: model.indexPlayer)
                            }
                        }
                        
                    }) {
                        Image(systemName: "backward.fill").font(.title)
                    }
                    .opacity(model.isHideBack ? 1 : 0.1)
                    // set gobackward 15
                    Button(action: {
                        model.rewindVideo(by: 15)
                        
                    }) {
                        Image(systemName: "gobackward.15").font(.title)
                    }
                    
                    // set play
                    Button(action: {
                        if !Reachability.shared.isConnectedToInternet {
                            popUpInternet()
                        } else {
                            model.isPlaying.toggle()
                            if model.isPlaying {
                                isPause = false
                            } else {
                                isPause = true
                            }
                            if self.finish {
                                self.width = 0
                                self.finish = false
                                model.player.currentItem?.seek(to: .zero, completionHandler: nil)
                            }
                        }
                    }) {
                        Image(systemName: model.isPlaying && !self.finish ? "pause.fill" : "play.fill").font(.title)
                    }
                    
                    // set gobackward 15
                    Button(action: {
                        
                        model.forwardVideo(by: 15)
                        
                    }) {
                        Image(systemName: "goforward.15").font(.title)
                    }
                    
                    // set forward
                    Button(action: {
                        if !Reachability.shared.isConnectedToInternet {
                            model.isPopUpInternet = true
                            popUpInternet()
                        } else {
                            model.isPopUpInternet = false
                            if !model.isHideNext {
                                return
                            }
                            if model.indexPlayer < model.films.count - 1 {
                                model.indexPlayer += 1
                                model.playItemAtPosition(at: model.indexPlayer)
                            }
                        }
                    }) {
                        Image(systemName: "forward.fill").font(.title)
                    }
                    .opacity(model.isHideNext ? 1 : 0.1)
                }
            }.padding()
        }
            .onAppear {
                if !Reachability.shared.isConnectedToInternet {
                    model.isPopUpInternet = true
                } else {
                    model.isPopUpInternet = false
                }
                
                if model.isPopUpInternet {
                    popUpInternet()
                }
                setData()
            }
        }
    
    func setData() {
        model.setUrlItems()
        let screen = UIScreen.main.bounds.width - 30
        
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) {(_) in
            // check player.currentItem exists ?
            guard let _ =  model.player.currentItem else { return }
            timeCurrent = CMTimeGetSeconds((model.player.currentTime() as CMTime?)!)
            timeDuration = CMTimeGetSeconds((model.player.currentItem?.duration as CMTime?)!)
            let value = timeCurrent / timeDuration
            if !isPause {
                if model.player.status == .readyToPlay {
                    self.width = screen * CGFloat(value)
                }
            }
        }
    }
    
    // set popup internet
    func popUpInternet() {
        model.player.removeAllItems()
        let alert = UIAlertController(title: "NetWork", message: "Please check your network", preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default) { (_) in
            
            if !Reachability.shared.isConnectedToInternet {
                model.isPopUpInternet = true
                popUpInternet()
            } else {
                model.isPopUpInternet = false
                model.playItemAtPosition(at: model.indexPlayer)
            }
        }
        alert.addAction(ok)
        UIApplication.shared.windows.first?.rootViewController?.present(alert, animated: true, completion: {
        })
    }
}


