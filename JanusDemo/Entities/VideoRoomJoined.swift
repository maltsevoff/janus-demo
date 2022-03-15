//
//  VideoRoomJoined.swift
//  JanusDemo
//
//  Created by Aleksandr Maltsev on 17.02.2022.
//

import Foundation

struct VideoRoomJoined: Codable {
    
    let sender: Int?
    let sessionId: Int?
    let pluginData: PluginData
    
    enum CodingKeys: String, CodingKey {
        case sender
        case sessionId = "session_id"
        case pluginData = "plugindata"
    }
}

extension VideoRoomJoined {
    
    struct Publisher: Codable {
        let display: String?
        
        var ablyClientId: String? {
            (display?.toJSON() as? [String: String])?["connectionId"]
        }
    }
    
    struct Data: Codable {
        let description: String?
        let id: Int?
        let publishers: [Publisher]
    }
    
    struct PluginData: Codable {
        let data: Data
    }
    
}
