//
//  RowMenuDetail.swift
//  AVPlayer1
//
//  Created by vuminhtam on 4/30/21.
//

import SwiftUI

struct RowMenuDetail: View {
    var file: File
    var body: some View {
        HStack {
            file.image?
                .resizable()
                .frame(width: 50, height: 50)
            Text(file.name)
        }
    }
}

struct RowMenuDetail_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            RowMenuDetail(file: PlayerViewModel.share.ListMp4[0])
                .previewLayout(.fixed(width: 300, height: 70))
            RowMenuDetail(file: PlayerViewModel.share.ListMp4[0])
                .previewLayout(.fixed(width: 300, height: 70))
        }
        .previewLayout(.fixed(width: 300, height: 70))
        
    }
}
