//
//  ViewController.swift
//  JanusDemo
//
//  Created by Aleksandr Maltsev on 09.02.2022.
//

import UIKit
import WebRTC
import SnapKit

fileprivate let studentId = "322098"
fileprivate let tutorId = "215330"

fileprivate let defaultSignalingServerUrl = URL(string: "ws://192.168.3.12:8080")!

class ViewController: UIViewController {
    
    private let localVideoView = UIView()
    private let remoteVideoView = UIView()
    
    private let offerButton: UIButton = {
        let btn = UIButton()
        btn.backgroundColor = .white
        btn.setTitle("Send offer", for: .normal)
        btn.setTitleColor(.black, for: .normal)
        return btn
    }()
    
    private let signalClient = SignalingClient(webSocket: StarscreamWebSocket(url: defaultSignalingServerUrl))
    
    private let janusSession = JanusSession()
    private let webRtcClient = WebRTCClient()
    private let cameraManager = CameraManager()
    private var ablyService: AblyService?
    
    private var trickleCandidates: [TrickleCandidate] = []
    private var offer: RTCSessionDescription?

    
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLayout()
        janusSession.delegate = self
        webRtcClient.delegate = self
        
        // Ping servers
        self.ablyService = AblyService(clientId: ClientIdGenerator.clientId, options: .init(studentId: studentId, tutorId: tutorId))
        self.ablyService?.delegate = self
//        performPingsEvaluation()
        
        webRtcClient.setup()
        janusSession.initVideoRoom()
        setupView()
        setupCamera()
        
//        signalClient.delegate = self
//        signalClient.connect()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        cameraManager.startCapture()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        cameraManager.stopCapture()
    }
    
    // MARK: - Actions
    
    @objc private func didTapSendOfferButton() {
        webRtcClient.createOffer()
    }
    
    // MARK: - Private
    
    private func setupLayout() {
        view.addSubview(remoteVideoView)
        remoteVideoView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.left.right.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
        
        view.addSubview(localVideoView)
        localVideoView.snp.makeConstraints {
            $0.left.equalToSuperview()
            $0.bottom.equalToSuperview()
            $0.height.equalTo(150)
            $0.width.equalTo(200)
        }
        
        view.addSubview(offerButton)
        offerButton.snp.makeConstraints {
            $0.bottom.equalTo(view.snp.bottomMargin).offset(-8)
            $0.width.equalTo(100)
            $0.height.equalTo(40)
            $0.centerX.equalToSuperview()
        }
        
        offerButton.addTarget(self, action: #selector(didTapSendOfferButton), for: .touchUpInside)
    }
    
    private func setupView() {
        #if arch(arm64)
            // Using metal (arm64 only)
            let localRenderer = RTCMTLVideoView(frame: self.localVideoView.frame)
            let remoteRenderer = RTCMTLVideoView(frame: self.remoteVideoView.frame)
            localRenderer.videoContentMode = .scaleAspectFill
            remoteRenderer.videoContentMode = .scaleAspectFill
                
        #else
            // Using OpenGLES for the rest
            let localRenderer = RTCEAGLVideoView(frame: self.localVideoView.frame)
            let remoteRenderer = RTCEAGLVideoView(frame: self.remoteVideoView.frame)
        #endif
        
        webRtcClient.setupLocalRenderer(localRenderer)
        webRtcClient.setupRemoteRenderer(remoteRenderer)
        
        localVideoView.addSubview(localRenderer)
        localRenderer.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        remoteVideoView.addSubview(remoteRenderer)
        remoteRenderer.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }

    private func setupCamera() {
        cameraManager.delegate = self
        cameraManager.setupCamera()
    }
    
    private func performPingsEvaluation() {
        BalancingService.getJanusServers { serversResponse in
            if let serversResponse = serversResponse {
                BalancingService.pingServers(serversResponse) { results in
                    dLog(results)
                    let pingResults = BalancingService.createPingResults(pings: results, serverResponse: serversResponse)
                    BalancingService.uploadPings(clientId: ClientIdGenerator.clientId, pingResults) {
                        self.janusSession.initVideoRoom()
                    }
                }
            }
        }
    }
}

// MARK: - JanusSessionDelegate

extension ViewController: JanusSessionDelegate {
    
    func didJoinRoom() {
        webRtcClient.createOffer()
    }
    
    func didGetRemoteDescription(jsep: [String: Any]) {
        let typeString = jsep["type"] as! String
        let sdp = jsep["sdp"] as! String
        let type = RTCSessionDescription.type(for: typeString)
        let description = RTCSessionDescription(type: type, sdp: sdp)
        webRtcClient.setRemoteDescription(sdp: description)
    }
    
    func didGetAbly(clientId: String) {
        
//        self.ablyService = AblyService(options: .init(studentId: studentId, tutorId: tutorId))
    }
    
    func getClientId() -> String {
        ClientIdGenerator.clientId
    }
}

// MARK: - WebRTCClientDelegate

extension ViewController: WebRTCClientDelegate {
    
    func didGenerate(iceCandidate: RTCIceCandidate) {
        guard let sdpMid = iceCandidate.sdpMid else { return }

        let candidate = TrickleCandidate(
            candidate: iceCandidate.sdp,
            sdpMid: sdpMid,
            sdpMLineIndex: Int(iceCandidate.sdpMLineIndex)
        )

        trickleCandidates.append(candidate)
        
        signalClient.send(candidate: iceCandidate)
    }
    
    func didCreate(offer: RTCSessionDescription) {
        self.offer = offer
//        signalClient.send(sdp: offer)
    }
    
    func didChange(state: RTCIceGatheringState) {
        if state == .complete {
            janusSession.sendTrickle(candidates: trickleCandidates)
            janusSession.sendTrickleCompleted(onSuccess: nil)
            if let offer = self.offer {
                let type = RTCSessionDescription.string(for: offer.type)
                self.janusSession.connectPublisher(type: type, sdp: offer.sdp)
            }
            trickleCandidates = []
        }
    }
}

// MARK: - CameraCaptureDelegate

extension ViewController: CameraCaptureDelegate {
    
    func captureVideoOutput(sampleBuffer: CMSampleBuffer) {
        if let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) {
            let rtcpixelBuffer = RTCCVPixelBuffer(pixelBuffer: pixelBuffer)
            let timeStampNs: Int64 = Int64(CMTimeGetSeconds(CMSampleBufferGetPresentationTimeStamp(sampleBuffer)) * 1000000000)
            let videoFrame = RTCVideoFrame(buffer: rtcpixelBuffer, rotation: RTCVideoRotation._0, timeStampNs: timeStampNs)
            
            webRtcClient.didCaptureLocalFrame(videoFrame)
        }
    }
    
}

// MARK: - SignalClientDelegate

extension ViewController: SignalClientDelegate {
    
    func signalClientDidConnect(_ signalClient: SignalingClient) {
        
    }
    
    func signalClientDidDisconnect(_ signalClient: SignalingClient) {
        
    }
    
    func signalClient(_ signalClient: SignalingClient, didReceiveRemoteSdp sdp: RTCSessionDescription) {
        webRtcClient.setRemoteDescription(sdp: sdp)
    }
    
    func signalClient(_ signalClient: SignalingClient, didReceiveCandidate candidate: RTCIceCandidate) {
        webRtcClient.set(remoteCandidate: candidate)
    }
    
}

// MARK: - AblyServiceDelegate

extension ViewController: AblyServiceDelegate {
    
    func requestPings() {
        performPingsEvaluation()
    }
    
    func didGetConnectionDetails() {
        janusSession.initVideoRoom()
    }
}
