//
//  StarscreamWebSockets.swift
//  JanusDemo
//
//  Created by Aleksandr Maltsev on 21.02.2022.
//

import Foundation
import Starscream

class StarscreamWebSocket: WebSocketProvider {

    var delegate: WebSocketProviderDelegate?
    private let socket: WebSocket
    
    init(url: URL) {
        let request = URLRequest(url: url)
        self.socket = WebSocket(request: request)
        self.socket.delegate = self
    }
    
    func connect() {
        self.socket.connect()
    }
    
    func send(data: Data) {
        self.socket.write(data: data)
    }
}

extension StarscreamWebSocket: Starscream.WebSocketDelegate {
    
    func didReceive(event: WebSocketEvent, client: WebSocket) {
        switch event {
        case .connected:
            self.delegate?.webSocketDidConnect(self)
        case .disconnected:
            self.delegate?.webSocketDidDisconnect(self)
        case .text:
            debugPrint("Warning: Expected to receive data format but received a string. Check the websocket server config.")
        case .binary(let data):
            self.delegate?.webSocket(self, didReceiveData: data)
        default:
            break
        }
    }
    
}
