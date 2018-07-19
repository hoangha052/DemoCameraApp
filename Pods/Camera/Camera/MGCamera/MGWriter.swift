//
//  MGWriter.swift
//  Camera
//
//  Created by Tung Tran on 6/27/18.
//  Copyright © 2018 Mingle. All rights reserved.
//

import Foundation
import AVFoundation
import CoreImage
import CoreMedia

final class MGWriter {
    private let videoURL: URL = {
        let documentPath = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        return documentPath.appendingPathComponent("movie.mov")
    }()
    private let context: CIContext = {
        let eaglContext = EAGLContext(api: EAGLRenderingAPI.openGLES2)
        let options = [kCIContextWorkingColorSpace: CGColorSpaceCreateDeviceRGB()]
        return CIContext(eaglContext: eaglContext!, options: options)
    }()
    private var audioWriterInput: AVAssetWriterInput?
    private var videoWriterInput: AVAssetWriterInput?
    private var assetWriterInputPixelBufferAdaptor: AVAssetWriterInputPixelBufferAdaptor?
    private var assetWriter: AVAssetWriter?
    
    // MARK: - Internal
    func startRecording() {
        removePreviousVideo()
        clearWriters()
    }
    
    func finishRecording(completion: @escaping (URL) -> Void) {
        guard let assetWriter = assetWriter,
            assetWriter.status != .completed && assetWriter.status != .unknown
        else { return }
        
        assetWriter.finishWriting { [weak self] in
            guard let strongSelf = self else { return }
            completion(strongSelf.videoURL)
        }
    }
    
    func appendVideo(image: CIImage, sampleBuffer: CMSampleBuffer) {
        let sampleTime = CMSampleBufferGetOutputPresentationTimeStamp(sampleBuffer)
        if assetWriter == nil {
            setupWriters(sampleBuffer: sampleBuffer)
            startAssetWriter(sampleTime: sampleTime)
        }
        
        guard videoWriterInput?.isReadyForMoreMediaData ?? false,
            let assetWriterPixelBufferAdaptor = self.assetWriterInputPixelBufferAdaptor,
            let pixelBufferPool = assetWriterPixelBufferAdaptor.pixelBufferPool
        else { return }
        
        var pixelBuffer: CVPixelBuffer?
        CVPixelBufferPoolCreatePixelBuffer(nil, pixelBufferPool, &pixelBuffer)
        
        guard let pxlBuffer = pixelBuffer else { return }
        context.render(image, to: pxlBuffer)
        assetWriterPixelBufferAdaptor.append(pxlBuffer, withPresentationTime: sampleTime)
    }
    
    func appendAudio(sampleBuffer: CMSampleBuffer) {
        guard audioWriterInput?.isReadyForMoreMediaData ?? false else { return }
        let sampleTime = CMSampleBufferGetOutputPresentationTimeStamp(sampleBuffer)
        
        if assetWriter == nil {
            setupWriters(sampleBuffer: sampleBuffer)
            startAssetWriter(sampleTime: sampleTime)
        }
        audioWriterInput?.append(sampleBuffer)
    }
    
    // MARK: - Private
    private func removePreviousVideo() {
        guard FileManager.default.fileExists(atPath: videoURL.path) else { return }
        try? FileManager.default.removeItem(at: videoURL)
    }
    
    private func startAssetWriter(sampleTime: CMTime) {
        guard let assetWriter = assetWriter
        else { return }
        
        assetWriter.startWriting()
        assetWriter.startSession(atSourceTime: sampleTime)
    }
    
    private func setupWriters(sampleBuffer: CMSampleBuffer) {
        guard let assetWriter = try? AVAssetWriter(outputURL: videoURL, fileType: .mov) else { return }
        
        setupVideoWriter(sampleBuffer: sampleBuffer, assetWriter: assetWriter)
        setupAssetWriterInputPixelBufferAdaptor(sampleBuffer: sampleBuffer, videoWriterInput: videoWriterInput)
        setupAudioWriter(assetWriter: assetWriter)
        
        self.assetWriter = assetWriter
    }
    
    private func setupVideoWriter(sampleBuffer: CMSampleBuffer, assetWriter: AVAssetWriter?) {
        guard let formatDescription = CMSampleBufferGetFormatDescription(sampleBuffer) else { return }
        
        let videoDimension = CMVideoFormatDescriptionGetDimensions(formatDescription)
        let videoOutputSettings: [String: Any] = [
            AVVideoCodecKey: AVVideoCodecH264,
            AVVideoWidthKey: videoDimension.width,
            AVVideoHeightKey: videoDimension.height
        ]
        let videoWriterInput = AVAssetWriterInput(mediaType: .video, outputSettings: videoOutputSettings)
        videoWriterInput.expectsMediaDataInRealTime = true
        
        if assetWriter?.canAdd(videoWriterInput) ?? false {
            assetWriter?.add(videoWriterInput)
        }
        
        self.videoWriterInput = videoWriterInput
    }
    
    private func setupAudioWriter(assetWriter: AVAssetWriter?) {
        let audioOutputSettings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVNumberOfChannelsKey: 2,
            AVSampleRateKey: 44100.0,
            AVEncoderBitRateKey: 128000
        ]
        let audioWriterInput = AVAssetWriterInput(mediaType: .audio, outputSettings: audioOutputSettings)
        
        if assetWriter?.canAdd(audioWriterInput) ?? false {
            assetWriter?.add(audioWriterInput)
        }
        self.audioWriterInput = audioWriterInput
        
    }
    
    private func setupAssetWriterInputPixelBufferAdaptor(sampleBuffer: CMSampleBuffer, videoWriterInput: AVAssetWriterInput?) {
        guard let videoWriterInput = videoWriterInput,
            let formatDescription = CMSampleBufferGetFormatDescription(sampleBuffer)
        else { return }
        let videoDimension = CMVideoFormatDescriptionGetDimensions(formatDescription)
        
        let sourcePixelBufferAttributes: [String: Any] = [
            kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA,
            kCVPixelBufferWidthKey as String: videoDimension.width,
            kCVPixelBufferHeightKey as String: videoDimension.height,
            kCVPixelFormatOpenGLESCompatibility as String: kCFBooleanTrue
        ]
        
        self.assetWriterInputPixelBufferAdaptor = AVAssetWriterInputPixelBufferAdaptor(assetWriterInput: videoWriterInput, sourcePixelBufferAttributes: sourcePixelBufferAttributes)
    }
    
    private func clearWriters() {
        assetWriter = nil
        videoWriterInput = nil
        audioWriterInput = nil
        assetWriterInputPixelBufferAdaptor = nil
    }
}
