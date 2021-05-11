//
//  LoadingView.swift
//  AVPlayer1
//
//  Created by Vu Minh Tam on 4/13/21.
//

import SwiftUI

struct LoadingView<Content>: View where Content: View {
    
    @Binding var isShowing: Bool
    var content: () -> Content
    
    var body: some View {
            GeometryReader { geometry in
                ZStack(alignment: .center) {

                    self.content()
                        .disabled(self.isShowing)
                        .blur(radius: self.isShowing ? 3 : 0)

                    VStack {
                        Text("Loading...")
                        ActivityIndicator(isAnimating: .constant(true), style: .large)
                    }
                    .frame(width: geometry.size.width,
                           height: geometry.size.height)
                    .background(Color.secondary.colorInvert())
                    .foregroundColor(Color.primary)
                    .cornerRadius(20)
                    .opacity(self.isShowing ? 1 : 0)
                }
            }
        }
}
