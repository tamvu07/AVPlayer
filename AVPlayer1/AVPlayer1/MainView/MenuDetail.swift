//
//  MenuDetail.swift
//  AVPlayer1
//
//  Created by Vu Minh Tam on 4/20/21.
//

import SwiftUI

struct MenuDetail: View {
    var musicDetail: Music
    @State  var files: [File]  = []
    @State var ismp4 = false
    var body: some View {
        List(files.indexed(), id: \.1.id) { index, file in
                NavigationLink(
                    destination:  MusicPlayer(ismp4: ismp4, index: index, LisFile: files)) {
                    RowMenuDetail(file: file)
                }
            }
        .onAppear {
            if musicDetail.name == ListMusic.share.names[0] {
                files = PlayerViewModel.share.ListMp4
                ismp4 = true
                PlayerViewModel.share.setPlayerItemsMp4()
            } else if musicDetail.name == ListMusic.share.names[1] {
                files =  PlayerViewModel.share.ListMp3
                ismp4 = false
                PlayerViewModel.share.setPlayerItemsMp3()
            } 
        }
    }
}

struct MenuDetail_Previews: PreviewProvider {
    static var previews: some View {
        MenuDetail(musicDetail: ListMusic.share.musics[0])
    }
}


// This is taken from the Release Notes, with a typo correction, marked below
struct IndexedCollection<Base: RandomAccessCollection>: RandomAccessCollection {
    typealias Index = Base.Index
    typealias Element = (index: Index, element: Base.Element)

    let base: Base

    var startIndex: Index { base.startIndex }

   // corrected typo: base.endIndex, instead of base.startIndex
    var endIndex: Index { base.endIndex }

    func index(after i: Index) -> Index {
        base.index(after: i)
    }

    func index(before i: Index) -> Index {
        base.index(before: i)
    }

    func index(_ i: Index, offsetBy distance: Int) -> Index {
        base.index(i, offsetBy: distance)
    }

    subscript(position: Index) -> Element {
        (index: position, element: base[position])
    }
}

extension RandomAccessCollection {
    func indexed() -> IndexedCollection<Self> {
        IndexedCollection(base: self)
    }
}

