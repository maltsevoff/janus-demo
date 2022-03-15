//
//  WebRTCClient.swift
//  JanusDemo
//
//  Created by Aleksandr Maltsev on 11.02.2022.
//

import Foundation
import WebRTC

protocol WebRTCClientDelegate: AnyObject {
    func didGenerate(iceCandidate: RTCIceCandidate)
    func didCreate(offer: RTCSessionDescription)
    func didChange(state: RTCIceGatheringState)
}

class WebRTCClient: NSObject {
    
    static let factory: RTCPeerConnectionFactory = {
//        RTCInitializeSSL()
        let videoEncoderFactory = RTCDefaultVideoEncoderFactory()
        let videoDecoderFactory = RTCDefaultVideoDecoderFactory()
        return RTCPeerConnectionFactory(encoderFactory: videoEncoderFactory, decoderFactory: videoDecoderFactory)
    }()
    
    weak var delegate: WebRTCClientDelegate?
    
    private var peerConnection: RTCPeerConnection?
    private var localVideoSource: RTCVideoSource?
    private var localVideoTrack: RTCVideoTrack?
    private var videoCapturer: RTCVideoCapturer?
    private var remoteVideoTrack: RTCVideoTrack?
    
    private var defaultSTUNServer: RTCIceServer {
//        let array = ["stun:stun.l.google.com:19302"]
        let array = [
            "stun:stun.media.allright.com:3478",
//            "turn:global.turn.twilio.com:3478?transport=udp",
//            "turn:global.turn.twilio.com:3478?transport=tcp",
//            "turn:global.turn.twilio.com:443?transport=tcp"
        ]
        return RTCIceServer(urlStrings: array)
    }
    
    private let mediaConstraints: RTCMediaConstraints = {
        let constraints = [
            kRTCMediaConstraintsOfferToReceiveAudio: kRTCMediaConstraintsValueTrue,
            kRTCMediaConstraintsOfferToReceiveVideo: kRTCMediaConstraintsValueTrue
        ]
        return RTCMediaConstraints(mandatoryConstraints: constraints, optionalConstraints: nil)
    }()
    
    func setup() {
        let constraints = RTCMediaConstraints(mandatoryConstraints: nil, optionalConstraints: ["DtlsSrtpKeyAgreement": kRTCMediaConstraintsValueTrue])
        let config = RTCConfiguration()
        config.iceServers = [defaultSTUNServer]
        config.iceTransportPolicy = RTCIceTransportPolicy.all
        config.sdpSemantics = .unifiedPlan
        config.continualGatheringPolicy = .gatherOnce
        peerConnection = WebRTCClient.factory.peerConnection(with: config, constraints: constraints, delegate: self)
        
        createMediaSenders()
        configureAudioSession()
//        setLocalDescription()
    }
    
//    func setLocalDescription() {
//        guard let localDescription = peerConnection?.localDescription else { return }
//        dLog("Has local description \(localDescription)")
//        peerConnection?.setLocalDescription(localDescription, completionHandler: { error in
//            dLog("\(error)")
//        })
//    }
    
    func setRemoteDescription(sdp: RTCSessionDescription) {
        peerConnection?.setRemoteDescription(sdp, completionHandler: { error in
            dLog("\(error)")
        })
    }
    
    func set(remoteCandidate: RTCIceCandidate) {
        peerConnection?.add(remoteCandidate)
    }
    
    func createOffer() {
        peerConnection?.offer(for: mediaConstraints, completionHandler: { description, error in
            if error == nil,
               let description = description {
                self.peerConnection?.setLocalDescription(description, completionHandler: { error in
                    dLog("\(error)")
                })
                self.delegate?.didCreate(offer: description)
            }
        })
    }
    
    // MARK: - UI Handling
    
    func setupLocalRenderer(_ renderer: RTCVideoRenderer) {
        guard let localVideoTrack = localVideoTrack else {
            dLog("Check Local Video track")
            return
        }
        
        localVideoTrack.add(renderer)
    }
    
    func setupRemoteRenderer(_ renderer: RTCVideoRenderer) {
        guard let remoteVideoTrack = remoteVideoTrack else {
            dLog("Check Remote Video track")
            return
        }
        
        remoteVideoTrack.add(renderer)
    }
    
    func didCaptureLocalFrame(_ videoFrame: RTCVideoFrame) {
        guard let videoSource = localVideoSource,
            let videoCapturer = videoCapturer else { return }
        
        videoSource.capturer(videoCapturer, didCapture: videoFrame)
    }
    
    // MARK: - Private
    
    private func createMediaSenders() {
        guard let peerConnection = peerConnection else {
            dLog("Check PeerConnection")
            return
        }
        
        let constraints = RTCMediaConstraints(mandatoryConstraints: [:], optionalConstraints: nil)
        let audioSource = WebRTCClient.factory.audioSource(with: constraints)
        let audioTrack = WebRTCClient.factory.audioTrack(with: audioSource, trackId: "ARDAMSa0")
        
        let mediaTrackStreamIDs = ["ARDAMS"]
        
        peerConnection.add(audioTrack, streamIds: mediaTrackStreamIDs)
        
        let videoSource = WebRTCClient.factory.videoSource()
        localVideoSource = videoSource
        let videoTrack = WebRTCClient.factory.videoTrack(with: videoSource, trackId: "ARDAMSv0")
        localVideoTrack = videoTrack
        videoCapturer = RTCCameraVideoCapturer(delegate: videoSource)
        
        peerConnection.add(videoTrack, streamIds: mediaTrackStreamIDs)
                        
        remoteVideoTrack = peerConnection.transceivers.first { $0.mediaType == .video }?.receiver.track as? RTCVideoTrack
    }
    
    private func configureAudioSession() {
        let audioSession = RTCAudioSession.sharedInstance()
        
        audioSession.lockForConfiguration()
        do {
            try audioSession.setCategory(AVAudioSession.Category.playAndRecord.rawValue)
            try audioSession.setMode(AVAudioSession.Mode.voiceChat.rawValue)
            try audioSession.overrideOutputAudioPort(.speaker)
            try audioSession.setActive(true)
        } catch let error {
            dLog("Error changeing AVAudioSession category: \(error)")
        }
        audioSession.unlockForConfiguration()
    }
}

// MARK: - RTCPeerConnectionDelegate

extension WebRTCClient: RTCPeerConnectionDelegate {
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didChange stateChanged: RTCSignalingState) {
        dLog("\(stateChanged)")
    }
    
    func peerConnectionShouldNegotiate(_ peerConnection: RTCPeerConnection) {
        dLog("")
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didAdd stream: RTCMediaStream) {
        dLog("")
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didRemove stream: RTCMediaStream) {
        dLog("")
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didChange newState: RTCIceConnectionState) {
        dLog("\(newState)")
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didChange newState: RTCIceGatheringState) {
        dLog("\(newState)")
        delegate?.didChange(state: newState)
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didGenerate candidate: RTCIceCandidate) {
        dLog("")
        delegate?.didGenerate(iceCandidate: candidate)
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didRemove candidates: [RTCIceCandidate]) {
        dLog("")
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didOpen dataChannel: RTCDataChannel) {
        dLog("")
    }
    
}
