//
//  JanusSession.swift
//  JanusDemo
//
//  Created by Aleksandr Maltsev on 09.02.2022.
//

import Foundation
import Starscream

fileprivate var wsUrl: URL {
    URL(string: "wss://fra1.media.allright.com:18989")!
}

fileprivate var kJanus = "janus"
fileprivate var globalTransactionId: Int = -1
// From request to video-chat-session
fileprivate let roomId: Int = 8432773998219622

protocol JanusSessionDelegate: AnyObject {
    func didJoinRoom()
    func didGetRemoteDescription(jsep: [String: Any])
    func didGetAbly(clientId: String)
    func getClientId() -> String
}

class JanusSession {
    
    var socket: WebSocket?
    weak var delegate: JanusSessionDelegate?
    
    private var isConnected: Bool = false
    private var transactionsDict: [String: JanusTransaction] = [:]
    
    private var sessionId: NSNumber?
    private var handleId: NSNumber?
    private var keepAliveTimer: Timer?
    
    private var transaction: String {
        globalTransactionId += 1
        return "\(globalTransactionId)"
    }
    
    // MARK: - Actions
    
    @objc private func didFireKeepAlive() {
        commitTransaction(body: [
            "janus": "keepalive",
            "session_id": sessionId!
        ], success: { dict in
        }, error: { dict in
        })
    }
    
    // MARK: - Public
    
    func initVideoRoom() {
        var request = URLRequest(url: wsUrl)
        request.timeoutInterval = 5
        request.setValue("janus-protocol", forHTTPHeaderField: "Sec-WebSocket-Protocol")
        socket = WebSocket(request: request)
        socket?.delegate = self
        socket?.connect()
    }
    
    func startSession() {
        createSession()
        createKeepAliveTimer()
    }
    
    // MARK: - Private
    
    private func commitTransaction(
        body: [String: Any],
        success: @escaping TransactionSuccessBlock,
        error: @escaping TransactionErrorBlock
    ) {
        let jt = JanusTransaction(tid: transaction)
        jt.success = success
        jt.error = error
        var filledBody = body
        filledBody["transaction"] = jt.tid
        transactionsDict[jt.tid] = jt
        
        print("WRITE: \(NSString(data: try! JSONSerialization.data(withJSONObject: filledBody, options: .prettyPrinted), encoding: String.Encoding.utf8.rawValue)!)")
        socket?.write(string: filledBody.toJsonString())
    }
    
    private func createKeepAliveTimer () {
        keepAliveTimer = Timer.scheduledTimer(timeInterval: 30, target: self, selector: #selector(didFireKeepAlive), userInfo: nil, repeats: true)
    }
    
    private func handleError(_ error: Error?) {
        if let e = error as? WSError {
            print("websocket encountered an error: \(e.message)")
        } else if let e = error {
            print("websocket encountered an error: \(e.localizedDescription)")
        } else {
            print("websocket encountered an error")
        }
    }
    
    private func handleMessage(_ dict: [String: Any]) {
        guard let transaction = dict["transaction"] as? String,
              let janusTransaction = transactionsDict[transaction] else { return }
        
        guard let message = dict["janus"] as? String,
              message != "ack" else { return }
        
        transactionsDict.removeValue(forKey: janusTransaction.tid)
        
        if message == "success" {
            janusTransaction.success?(dict)
        } else if message == "error" {
            janusTransaction.error?(dict)
        } else {
            janusTransaction.success?(dict)
        }
    }
    
    // MARK: - Messages
    
    private func createSession() {
        commitTransaction(body: [
            "janus": "create"
        ], success: { dict in
            self.sessionId = (dict?["data"] as! [String:Any])["id"] as? NSNumber
            self.getHandleId()
        }, error: { dict in
            
        })
    }
    
    private func getHandleId() {
        commitTransaction(body: [
            "janus": "attach",
            "plugin": "janus.plugin.videoroom",
            "session_id": sessionId!
        ], success: { dict in
            self.handleId = (dict?["data"] as! [String:Any])["id"] as? NSNumber
            self.joinRoom()
        }, error: { dict in
            
        })
    }
    
    private func joinRoom() {
        commitTransaction(body: [
            "janus": "message",
            "session_id": sessionId!,
            "handle_id": handleId!,
            "body": [
                "request": "join",
                "room": roomId,
                "ptype": "publisher",
                "display": delegate?.getClientId() ?? ""
                ]
        ], success: { dict in
            self.delegate?.didJoinRoom()
//            do {
//                let data = try JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted)
//                let videoRoomJoined = try JSONDecoder().decode(VideoRoomJoined.self, from: data)
//                self.delegate?.didJoinRoom()
//                if let clientId = videoRoomJoined.pluginData.data.publishers.first?.ablyClientId {
//                    self.delegate?.didGetAbly(clientId: clientId)
//                }
//            } catch let error {
//                dLog("\(error)")
//            }
        }, error: { dict in
            
        })
    }
    
    func connectPublisher(
        type: String,
        sdp: String
    ) {
        commitTransaction(body: [
            "janus": "message",
            "session_id": sessionId!,
            "handle_id": handleId!,
            "body": [
                "request": "publish",
                "audio": true,
                "video": true,
                "room": roomId,
            ],
            "jsep": [
                "type": type,
                "sdp": sdp
            ]
        ], success: { dict in
            let jsep = dict?["jsep"] as! [String: Any]
            self.delegate?.didGetRemoteDescription(jsep: jsep)
        }, error: { dict in
            
        })
    }
    
    func sendTrickleCompleted(onSuccess: (() -> Void)?) {
        commitTransaction(body: [
            "janus": "trickle",
            "session_id": sessionId!,
            "handle_id": handleId!,
            "candidate": [
                "completed": true
            ]
        ], success: { dict in
            onSuccess?()
        }, error: { dict in
            
        })
    }
    
    // TODO: add complete state
    func sendTrickle(candidates: [TrickleCandidate]) {
        commitTransaction(body: [
            "janus": "trickle",
            "session_id": sessionId!,
            "handle_id": handleId!,
            "candidate": [
                candidates.map({ $0.toDict })
            ]
        ], success: { dict in
            
        }, error: { dict in
            
        })
    }
}

// MARK: - WebSocketDelegate

extension JanusSession: WebSocketDelegate {
    
    func didReceive(event: WebSocketEvent, client: WebSocket) {
//        dLog("Janus event: \(event)")
        switch event {
        case .connected(let headers):
            print("websocket is connected: \(headers)")
            isConnected = true
            startSession()
        case .disconnected(let reason, let code):
            isConnected = false
            print("websocket is disconnected: \(reason) with code: \(code)")
        case .text(let string):
            let json = string.toJSON() as! [String: Any]
            print("====onMessage====\n")
            print(json)
            print("\n====endMessage====\n")
            guard let _ = json[kJanus] as? String else {
                return
            }
            self.handleMessage(json)
        case .binary(let data):
            print("Received data: \(data.count)")
        case .cancelled:
            isConnected = false
        case .error(let error):
            isConnected = false
            handleError(error)
        case .viabilityChanged(_):
//            createSession()
            break
        default:
            break
        }
    }
    
}
