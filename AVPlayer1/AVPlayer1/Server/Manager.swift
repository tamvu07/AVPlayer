//
//  Manager.swift
//  AVPlayer1
//
//  Created by Vu Minh Tam on 4/15/21.
//

import Foundation
import Alamofire

class Reachability {
    static var shared = Reachability()
    var isConnectedToInternet: Bool {
        return NetworkReachabilityManager()?.isReachable ?? false
    }
}
