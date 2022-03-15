//
//  JanusServersResponse.swift
//  JanusDemo
//
//  Created by Aleksandr Maltsev on 22.02.2022.
//

import Foundation

struct JanusServersResponse: Codable {
    let data: [JanusServersResponseData]
    let meta: JanusServersResponseMeta
}

struct JanusServersResponseData: Codable {
    
    struct Attributes: Codable {
        let name: String?
        let https: String?
        let wss: String?
        
        var wssUrl: URL? {
            guard let urlString = wss else { return nil }
            return URL(string: urlString)
        }
    }
    
    let type: String?
    let attributes: Attributes?
    
}

struct JanusServersResponseMeta: Codable {
    
    let maxPing: Int?
    
    enum CodingKeys: String, CodingKey {
        case maxPing = "max_ping"
    }
}
