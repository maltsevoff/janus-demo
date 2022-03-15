//
//  AblyService.swift
//  JanusDemo
//
//  Created by Aleksandr Maltsev on 17.02.2022.
//

import Foundation
import Ably

fileprivate let apiKey = "ehd5ow.CYsWWA:edJyPO_EPjOavYFu"

protocol AblyServiceDelegate: AnyObject {
    func requestPings()
    func didGetConnectionDetails()
}

class AblyService {
    
    struct Options {
        let studentId: String
        let tutorId: String
    }
    
    enum Constants {
        static let newVideochatServer = "new-videochat-server"
        static let videochatLatency = "request-videochat-latency"
    }
    
    weak var delegate: AblyServiceDelegate?
    
    private(set) var isConnected: Bool = false
    
    private let client: ARTRealtime
    private var mainChannel: ARTRealtimeChannel?
    private var videochatServers: ARTRealtimeChannel?
    private var videochatLatency: ARTRealtimeChannel?
    private var quickstart: ARTRealtimeChannel?
    
    private lazy var stateHandler: (ARTConnectionStateChange) -> Void = { stateChange in
        switch stateChange.current {
        case .connected:
            self.isConnected = true
            dLog("Ably connected")
        case .failed:
            self.isConnected = false
            dLog("Ably disconnected")
        default:
            break
        }
    }
    
    private lazy var messageHandler: (ARTMessage) -> () = { message in
//        dLog(message)
        guard let data = message.data as? String else { return }
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: data.toJSON(), options: .prettyPrinted)
            guard let string = String(bytes: jsonData, encoding: .utf8) else { return }
            print("=========Ably message======")
            print(string)
            print("===========================")
            self.handleMessage(data: data.toJSON())
        } catch {
            
        }
        
    }
    
    init(clientId: String) {
        let options = ARTClientOptions(key: apiKey)
        options.clientId = clientId
        dLog("Ably client ID: \(clientId)")
        self.client = ARTRealtime(options: options)
        self.client.connection.on(stateHandler)
    }
    
    convenience init(clientId: String, options: Options) {
        self.init(clientId: clientId)
        
        let channelName = "channel-\(options.studentId)-\(options.tutorId)"
        mainChannel = client.channels.get(channelName)
        dLog("Ably main channel name: \(channelName)")
        videochatServers = client.channels.get(Constants.newVideochatServer)
        videochatLatency = client.channels.get(Constants.videochatLatency)
        mainChannel?.presence.enter(nil)
        videochatServers?.presence.enter(nil)
        videochatLatency?.presence.enter(nil)
        mainChannel?.subscribe(messageHandler)
        videochatServers?.subscribe(messageHandler)
        videochatLatency?.subscribe(messageHandler)
    }
    
    // MARK: - Private
    
    private func handleMessage(data: Any?) {
        guard let dict = data as? [String: Any] else { return }
        
        if dict["type"] as? String == "request-videochat-latency" &&
            (dict["data"] as? String)?.contains(self.client.clientId!) == true {
            delegate?.requestPings()
        }
        
        if dict["type"] as? String == "new-videochat-server" {
            delegate?.didGetConnectionDetails()
        }
    }
}
