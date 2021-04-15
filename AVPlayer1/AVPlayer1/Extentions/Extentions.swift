//
//  Extentions.swift
//  AVPlayer1
//
//  Created by Vu Minh Tam on 4/12/21.
//

import Foundation

class FormatDuation {
    func formatMinuteSeconds(_ totalSeconds: Int) -> String {

        let seconds: Int = totalSeconds % 60
        let minutes: Int = (totalSeconds / 60) % 60

            return String(format:"%02d:%02d", minutes, seconds);
        }
}
