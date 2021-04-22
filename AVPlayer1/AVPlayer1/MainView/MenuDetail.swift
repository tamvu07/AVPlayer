//
//  MenuDetail.swift
//  AVPlayer1
//
//  Created by Vu Minh Tam on 4/20/21.
//

import SwiftUI

struct MenuDetail: View {
    var musicDetail: Music
    let audios: [Music] = ListAudio.share.audios
    let mp3s: [Music] = ListMp3.share.mp3s
    @State private var musics: [Music] = []
    @State var isAudio = true
   
    var body: some View {
            List(musics) { music in
                NavigationLink(
                    destination:  MusicPlayer(music: music, isAudio: isAudio)) {
                    RowMenu(music: music)
                }
            }
        .onAppear {
            if musicDetail.name == ListMusic.share.names[0] {
               musics = audios
                isAudio = true
                PlayerViewModel.share.setURLAudio()
            } else if musicDetail.name == ListMusic.share.names[1] {
                musics =  mp3s
                isAudio = false
                PlayerViewModel.share.setURLMp3()
            } 
        }
    }
}

struct MenuDetail_Previews: PreviewProvider {
    static var previews: some View {
        MenuDetail(musicDetail: ListAudio.share.audios[0])
    }
}
