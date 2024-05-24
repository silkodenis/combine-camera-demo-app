//
//  CaptureVideoPreviewLayer.swift
//  SuperVisionCamera
//
//  Created by Denis Silko on 25.09.2022.
//

import UIKit
import SwiftUI
import AVFoundation

// MARK: - SwiftUI

struct CameraVideoPreviewLayer: View {
    private let session: AVCaptureSession
    private let videoGravity: AVLayerVideoGravity
    
    init(session: AVCaptureSession, videoGravity: AVLayerVideoGravity = .resizeAspectFill) {
        self.session = session
        self.videoGravity = videoGravity
    }
    
    var body: some View {
        if case .resizeAspectFill = videoGravity {
            layer.ignoresSafeArea()
        } else {
            layer.frame(alignment: .center)
        }
    }
    
    private var layer: some View {
        RepresentedVideoPreviewLayer(captureSession: session, videoGravity: videoGravity)
    }
}

struct RepresentedVideoPreviewLayer: UIViewRepresentable {
    let captureSession: AVCaptureSession
    let videoGravity: AVLayerVideoGravity
    
    func makeUIView(context: Context) -> UIView {
        return VideoPreviewLayer(captureSession: captureSession, 
                                 videoGravity: videoGravity)
    }

    func updateUIView(_ uiView: UIView, context: Context) {}
}

// MARK: - UIKit

final class VideoPreviewLayer: UIView {
    private let captureSession: AVCaptureSession
    private let videoGravity: AVLayerVideoGravity
    
    init(captureSession: AVCaptureSession, videoGravity: AVLayerVideoGravity) {
        self.captureSession = captureSession
        self.videoGravity = videoGravity
        
        super.init(frame: .zero)
    }
    
    override class var layerClass: AnyClass {
        AVCaptureVideoPreviewLayer.self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var videoPreviewLayer: AVCaptureVideoPreviewLayer {
        return layer as! AVCaptureVideoPreviewLayer
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        if nil != self.superview {
            self.videoPreviewLayer.session = captureSession
            self.videoPreviewLayer.videoGravity = videoGravity
        }
    }
}
