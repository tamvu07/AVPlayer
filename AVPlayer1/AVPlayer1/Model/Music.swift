//
//  Music.swift
//  AVPlayer1
//
//  Created by Vu Minh Tam on 4/20/21.
//

import Foundation
import  SwiftUI





struct Music: Identifiable {
    let id = UUID()
    var name: String
    var imageName: String
    
    var image: Image {
        Image(systemName: imageName)
    }
}

class ListMusic {
    
    static let share = ListMusic()
    
    var musics: [Music] = []
    var images = ["tv.music.note.fill", "music.note", "rectangle.and.paperclip"]
    var names = ["audio", "mp3", "setting"]
    
    init() {
        for i in 0 ..< names.count  {
            musics.append(Music(name: names[i], imageName: images[i]))
        }
    }
}
//
//class ListMp4 {
//    static let share = ListMp4()
//
//    var audios: [Music] = []
//    init() {
//        for i in 0 ..< PlayerViewModel.share.audio.count  {
//            audios.append(Music(name: PlayerViewModel.share.episode[i], imageName: "tv.music.note.fill"))
//        }
//    }
//}
//
//class ListMp3 {
//    static let share = ListMp3()
//
//    var mp3s: [Music] = []
//    init() {
//        for i in 0 ..< PlayerViewModel.share.mp3.count  {
//            mp3s.append(Music(name: PlayerViewModel.share.song[i], imageName: "music.note"))
//        }
//    }
//}
