//
//  TrickleCandidate.swift
//  JanusDemo
//
//  Created by Aleksandr Maltsev on 16.02.2022.
//

import Foundation

struct TrickleCandidate: Codable {
    
    let candidate: String
    let sdpMid: String
    let sdpMLineIndex: Int
    
    var toDict: [AnyHashable: Any] {
        [
            "candidate": candidate,
            "sdpMid": sdpMid,
            "sdpMLineIndex": sdpMLineIndex
        ]
    }
}
