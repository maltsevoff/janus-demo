//
//  ServerPingResult.swift
//  JanusDemo
//
//  Created by Aleksandr Maltsev on 08.03.2022.
//

import Foundation

fileprivate enum LostResult {
    static let max = 100
    static let min = 0
}

struct ServerPingResult {
    
    private enum Parameter {
        static let server = "server"
        static let ping = "ping"
        static let lost = "lost"
    }
    
    let server: String
    let ping: Int?
    
    var lost: Int {
        guard let ping = ping else { return LostResult.max }
        return ping > maxPing ? LostResult.max : LostResult.min
    }
    
    var json: [String: Any] {
        var dict: [String: Any] = [:]
        dict[Parameter.server] = server
        dict[Parameter.lost] = lost
        if let ping = self.ping {
            dict[Parameter.ping] = ping
        }
        return dict
    }
    
    private let maxPing: Int
    
    init?(
        server: String?,
        ping: Int?,
        maxPing: Int
    ) {
        guard let server = server else { return nil }
        
        self.server = server
        self.ping = ping
        self.maxPing = maxPing
    }
}
