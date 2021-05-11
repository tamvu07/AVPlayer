//
//  SettingPlayer.swift
//  AVPlayer1
//
//  Created by Vu Minh Tam on 4/20/21.
//

import SwiftUI

struct SettingPlayer: View {
    
    let listMusic = ListMusic.share.musics
    @State var nameAudio: String = "Mp4"
    @State private var nameMp3 = "Mp3"
    @State private var nameAction = "Action"
    @State var idAudio = 0
    @State var indexAudio = 0
    @State var indexMp3 = 0
    @State var isMergeCurrent: Bool = false
    
    static let onAudioSelect = { (key: String) in
        print("\(key)")
    }
    
    static let onMp3Select = { key in
        
        print(key)
    }
    
    static let onActionSelect = { key in
        print(key)
    }
    
    static let audios = [
        DropdownOption(key: "1audioone", val: "Episode One"), DropdownOption(key: "2audiotwo", val: "Episode Two"), DropdownOption(key: "3audiothree", val: "Episode Three")
    ]
    static let mp3s = [
        DropdownOption(key: "1mp3one", val: "Mp3 One"), DropdownOption(key: "2mp3two", val: "Mp3 Two"), DropdownOption(key: "3mp3three", val: "Mp3 Three")
    ]
    static let actions = [
        DropdownOption(key: "merge", val: "Merge")
    ]
    var body: some View {
        ZStack {
            
            VStack {
                HStack {
                    Spacer()
                    Text(self.nameAudio)
                        .padding()
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.blue, lineWidth: 2)
                        )
                        .foregroundColor(.red)
                    Spacer()
                    Text(self.nameMp3)
                        .padding()
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.blue, lineWidth: 2)
                        )
                        .foregroundColor(.red)
                    Spacer()
                }
                Divider()
                VStack {
                    DropdownButton(shouldShowDropdown: false, displayText: .constant("\(nameAudio)"), options: SettingPlayer.audios, onSelect: SettingPlayer.onAudioSelect, delegate: self)
                   
                    DropdownButton(shouldShowDropdown: false, displayText: .constant("\(nameMp3)"), options: SettingPlayer.mp3s, onSelect: SettingPlayer.onMp3Select, delegate: self)
                }
                
                DropdownButton(shouldShowDropdown: false, displayText: .constant("\(nameAction)"), options: SettingPlayer.actions, onSelect: SettingPlayer.onActionSelect, delegate: self)
            }
            
            // activity
            GeometryReader { (geometry) in
                ActivityIndicator(isAnimating: .constant(isMergeCurrent), style: .large)
                .frame(width: geometry.size.width, height: geometry.size.height)
                .cornerRadius(15)
            }
            .padding(.top)
            
        }
        
    }
}

extension SettingPlayer: DropdownButtonDelegate {
    
    func onSelect(key: String) {
        if key.contains("mp3") {
            for i in SettingPlayer.mp3s {
                if i.key == key {
                    nameMp3 = i.val
                    indexMp3 = Int(i.key.first?.description ?? "") ?? 0
                }
            }
        } else {
            for i in SettingPlayer.audios {
                if i.key == key {
                    nameAudio = i.val
                    indexAudio = Int(i.key.first?.description ?? "") ?? 0
                }
            }
        }
        if key == "merge" {
            isMergeCurrent = true
            PlayerViewModel.share.mergeUrl(videoUrl: indexAudio, audioUrl: indexMp3, success: {(merge) in
                isMergeCurrent = false
            }, failure: { (merge) in
                isMergeCurrent = false
            })
        }
    }
}

struct SettingPlayer_Previews: PreviewProvider {
    static var previews: some View {
        SettingPlayer()
    }
}
