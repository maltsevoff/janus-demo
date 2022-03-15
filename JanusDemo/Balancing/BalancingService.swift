//
//  BalancingService.swift
//  JanusDemo
//
//  Created by Aleksandr Maltsev on 22.02.2022.
//

import Foundation
import Starscream

fileprivate let serversListUrl: URL = URL(string: "https://test.allright.com/api/v1/video-chat-servers")!
// Check session ID
fileprivate let uploadPingsUrl: URL = URL(string: "https://test.allright.com/api/v1/video-chat-sessions/73428/resolve-server")!

fileprivate let sessionId = "73428"

class BalancingService {
    
    typealias ServersResponseHandler = (JanusServersResponse?) -> ()
    typealias PingResultHandler = ([Int?]) -> ()
    
    static let queue = DispatchQueue(label: "BalancingServicePing", qos: .userInteractive)
    
    static func getJanusServers(_ handler: ServersResponseHandler?) {
        let task = URLSession.shared.dataTask(with: serversListUrl) { data, response, error in
            guard let data = data,
             error == nil else { return }

            do {
                let result = try JSONDecoder().decode(JanusServersResponse.self, from: data)
                print(result)
                handler?(result)
            } catch {
                print(error)
                handler?(nil)
            }
        }
        
        task.resume()
    }
    
    static func uploadPings(clientId: String, _ pings: [ServerPingResult], _ handler: () -> ()) {
        var request = URLRequest(url: uploadPingsUrl)
        request.setValue("application/vnd.api+json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        let parameters: [String: Any] = [
            "uid": clientId,
            "pings": pings.map({ $0.json }),
            "session_id": sessionId,
            "media_server": "janus",
            "student_id": "322098",
            "tutor_id": "215330"
        ]
        request.httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data,
             error == nil else { return }

            dLog("Ping upload result: \(String(bytes: data, encoding: .utf8))")
        }
        
        task.resume()
    }
    
    static func createPingResults(pings: [Int?], serverResponse: JanusServersResponse) -> [ServerPingResult] {
        var results: [ServerPingResult] = []
        
        guard let maxPing = serverResponse.meta.maxPing else { return results }
        
        for (ping, serverData) in zip(pings, serverResponse.data) {
            if let pingResult = ServerPingResult(
                server: serverData.attributes?.name,
                ping: ping,
                maxPing: maxPing
            ) {
                results.append(pingResult)
            }
        }
        
        return results
    }
    
    static func pingServers(_ serversResponse: JanusServersResponse, handler: PingResultHandler?) {
        queue.async {
            let servers = serversResponse.data
            var result: [Int?] = []
            let semaphore = DispatchSemaphore(value: 1)
            
            for server in servers {
                semaphore.wait()
                if let url = server.attributes?.wssUrl {
                    pingServer(url: url) { ping in
                        result.append(ping)
                        semaphore.signal()
                    }
                } else {
                    result.append(nil)
                    semaphore.signal()
                }
            }
            
            handler?(result)
        }
    }
    
    static private func pingServer(url: URL, handler: ((Int?) -> Void)?) {
        var request = URLRequest(url: url)
        request.setValue("janus-protocol", forHTTPHeaderField: "Sec-WebSocket-Protocol")
        let socket = WebSocket(request: request)
        let transaction = "\(Date())-ws-ping"
        
        let message = [
            "janus": "ping",
            "transaction": transaction
        ]
        
        func finish(ping: Int?) {
            socket.disconnect()
            handler?(ping)
        }
        
        var start: Date!
        
        socket.onEvent = { event in
            dLog("Event: \(event)")
            switch event {
            case .connected:
                start = Date()
                socket.write(string: message.toJsonString())
            case .text(let string):
                let message = string.toJSON() as? [String: String]
                
                if message?["janus"] == "pong" && message?["transaction"] == transaction {
                    let latencyTimeInterval = Float(Date().timeIntervalSince(start)) * 1000
                    let latency = Int(round(latencyTimeInterval))
                    finish(ping: latency)
                }
            case .error(let error):
                print(error)
                finish(ping: nil)
            case .cancelled:
                finish(ping: nil)
            default:
                break
            }
        }
        
        socket.connect()
    }
}
