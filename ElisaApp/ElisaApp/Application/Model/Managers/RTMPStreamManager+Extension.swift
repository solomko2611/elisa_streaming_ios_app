//
//  RTMPStreamManager+Extension.swift
//  ElisaApp
//
//  Created by alexandr galkin on 22.11.2022.
//

import HaishinKit
import Foundation
import AVFAudio
import AVFoundation

extension RTMPStreamManagerImpl: RTMPStreamDelegate {
    func rtmpStream(_ stream: HaishinKit.RTMPStream, publishInsufficientBWOccured connection: HaishinKit.RTMPConnection) {
        adjustBitrate(decrease: true, stream: stream)
    }
    
    func rtmpStream(_ stream: HaishinKit.RTMPStream, publishSufficientBWOccured connection: HaishinKit.RTMPConnection) {
        adjustBitrate(decrease: false, stream: stream)
    }
    
    func rtmpStream(_ stream: HaishinKit.RTMPStream, didOutput audio: AVAudioBuffer, presentationTimeStamp: CMTime) {
        
    }
    
    func rtmpStream(_ stream: HaishinKit.RTMPStream, didOutput video: CMSampleBuffer) {
        
    }
    
    func rtmpStream(_ stream: HaishinKit.RTMPStream, updatedStats connection: HaishinKit.RTMPConnection) {
        
    }
    
    func rtmpStream(_ stream: HaishinKit.RTMPStream, sessionWasInterrupted session: AVCaptureSession, reason: AVCaptureSession.InterruptionReason) {
        
    }
    
    func rtmpStream(_ stream: HaishinKit.RTMPStream, sessionInterruptionEnded session: AVCaptureSession, reason: AVCaptureSession.InterruptionReason) {
        
    }
    
    func rtmpStream(_ stream: HaishinKit.RTMPStream, videoCodecErrorOccurred error: HaishinKit.VideoCodec.Error) {
        
    }
    
    func rtmpStreamDidClear(_ stream: HaishinKit.RTMPStream) {
        
    }
}
