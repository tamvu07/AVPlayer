//
//  RowMenu.swift
//  AVPlayer1
//
//  Created by Vu Minh Tam on 4/20/21.
//

import SwiftUI

struct RowMenu: View {
    var music: Music
    var body: some View {
        HStack {
            music.image
                .resizable()
                .frame(width: 50, height: 50)
            Text(music.name)
        }
    }
}

struct RowMenu_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            RowMenu(music: ListMusic().musics[0])
                .previewLayout(.fixed(width: 300, height: 70))
            RowMenu(music: ListMusic().musics[1])
                .previewLayout(.fixed(width: 300, height: 70))
        }
        .previewLayout(.fixed(width: 300, height: 70))
        
    }
}
