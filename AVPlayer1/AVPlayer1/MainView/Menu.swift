//
//  Menu.swift
//  AVPlayer1
//
//  Created by Vu Minh Tam on 4/20/21.
//

import SwiftUI

struct Menu: View {
    let listMusic = ListMusic.share.musics
    @State var isSetting = false
    
    var body: some View {
        NavigationView {
            List(listMusic) { music in
                    NavigationLink(
                        destination: destinationView(music: music)) {
                        RowMenu(music: music)
                    }
            }
            .navigationTitle("AVPlayer")
            .onAppear {
            }
        }
        .onAppear() {
            PlayerViewModel.share.initalMp4()
            PlayerViewModel.share.initalMp3()
        }
    }
    
    func destinationView(music: Music) -> some View {
        return Group {
            if music.name == "setting" {
                SettingPlayer()
            } else {
                MenuDetail(musicDetail: music)
            }
        }
    }
    
}

struct Menu_Previews: PreviewProvider {
    static var previews: some View {
        Menu()
    }
}
