//
//  MGCameraViewController.swift
//  Camera
//
//  Created by Tung Tran on 6/22/18.
//  Copyright © 2018 Mingle. All rights reserved.
//

import UIKit
import AVFoundation
import GPUImage
import AVKit
import Photos

public protocol MGCameraViewControllerDelegate: class {
    func cameraController(cameraController: MGCameraViewController, didSelectImage image: UIImage)
    func cameraController(cameraController: MGCameraViewController, didSelectVideo videoURL: URL)
}

enum CameraState {
    case photo
    case video
    case recording
}

public final class MGCameraViewController: UIViewController {
    public weak var delegate: MGCameraViewControllerDelegate?
    
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet private weak var recordButton: UIButton!
    @IBOutlet private weak var previewView: UIView!
    @IBOutlet private weak var filtersView: UIView!
    @IBOutlet private weak var collectionView: FilterCollectionView!
    @IBOutlet private weak var videoButton: UIButton!
    @IBOutlet private weak var photoButton: UIButton!
    @IBOutlet weak var libraryPhotoButton: UIButton!
    @IBOutlet weak var filterButton: UIButton!
    @IBOutlet weak var bottomBarView: UIView!
    
    @IBOutlet weak var centerPhotoButtonConstraint: NSLayoutConstraint!
    @IBOutlet private weak var previewImageView: UIImageView!
    @IBOutlet private weak var filterViewBottomConstraint: NSLayoutConstraint!
    
    private var cameraState: CameraState = .photo
    private var videoTimer: Timer?
    private var timeDuration: Int = 0
    
    private let session: AVCaptureSession = {
        let captureSession = AVCaptureSession()
        captureSession.sessionPreset = UIScreen.main.bounds.size.height > 568 ? .high : .iFrame960x540
        return captureSession
    }()
    private let mediaWriter = MGWriter()
    private var position = AVCaptureDevice.Position.back
    private var isRecording = false
    var imageOrigin: UIImage?
    
    private let labelSelectedColor = UIColor(red: 192/255, green: 192/255, blue: 192/255, alpha: 1.0)
    private let labelColor = UIColor(red: 236/255, green: 236/255, blue: 236/255, alpha: 1.0)
    public static var instantiateViewController: MGCameraViewController {
        return MGCameraViewController(nibName: "MGCameraViewController", bundle: Bundle(for: self))
    }
    
    // MARK: - View Lifecycle
    deinit {
        session.stopRunning()
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        resetUI()
        setupCamera()
    }
    
    override public func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
         session.stopRunning()
    }
    override public var prefersStatusBarHidden: Bool {
        return true
    }
    
    // MARK: - Actions
    @IBAction private func backButtonTapped(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction private func galleryButtonTapped(_ sender: UIButton) {
        // open gallery images
        let galleryPhotoVC = LibraryPhotoViewController.libraryPhotoViewController
        self.navigationController?.pushViewController(galleryPhotoVC, animated: true)
        
    }
    
    @IBAction private func photoButtonTapped(_ sender: UIButton) {
        UIView.animate(withDuration: 0.5, animations: {
            self.centerPhotoButtonConstraint.constant = 0
            self.bottomBarView.layoutIfNeeded()
            self.photoButton.titleLabel?.font = UIFont.systemFont(ofSize: 20)
            self.photoButton.setTitleColor(self.labelSelectedColor, for: .normal)
            self.videoButton.titleLabel?.font = UIFont.systemFont(ofSize: 14)
            self.videoButton.setTitleColor(self.labelColor, for: .normal)
        }) { (bool) in
            self.recordButton.setImage(UIImage(named: "ic_camera"), for: .normal)
            self.cameraState = .photo
        }
    }
    
    @IBAction private func videoButtonTapped(_ sender: UIButton) {
        UIView.animate(withDuration: 0.5, animations: {
            self.centerPhotoButtonConstraint.constant = -100
            self.bottomBarView.layoutIfNeeded()
            self.videoButton.titleLabel?.font = UIFont.systemFont(ofSize: 20)
            self.videoButton.setTitleColor(self.labelSelectedColor, for: .normal)
            self.photoButton.titleLabel?.font = UIFont.systemFont(ofSize: 14)
            self.photoButton.setTitleColor(self.labelColor, for: .normal)
        }){ (bool) in
            self.recordButton.setImage(UIImage(named: "ic_video"), for: .normal)
            self.cameraState = .video
        }
    }
    
    @IBAction private func switchCameraButtonTapped(_ sender: Any) {
        session.stopRunning()
        position = position == .front ? .back : .front
        setupCamera()
    }
    
    @IBAction private func filterButtonTapped(_ sender: UIButton) {
        toggleFilterView(isHidden: !filtersView.isHidden, animated: true)
    }
    
    @IBAction func captureButtonTapped(_ sender: UIButton) {
        switch cameraState {
        case .photo:
            guard let image = imageOrigin else { return }
            self.takePhoto(image: image)
        case .video:
            self.startRecordingVideo()
            self.cameraState = .recording
            self.recordButton.setImage(UIImage(named: "ic_recording"), for: .normal)
        case .recording:
            self.stopRecordingVideo()
        }
    }
    
    // MARK: - Private
    private func setupUI() {
        recordButton.layer.cornerRadius = recordButton.frame.size.height / 2
        setupFiltersView()
    }
    
    private func takePhoto(image: UIImage) {
        let vc = MGPhotoReviewViewController.instantiateViewController
        vc.imagePhoto = image
        vc.selectedIndexPath = collectionView.indexPathsForSelectedItems?.first ?? IndexPath(row: 0, section: 0)
        vc.cameraController = self
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    private func hideButtons() {
        photoButton.isHidden = true
        videoButton.isHidden = true
        filterButton.isHidden = true
        libraryPhotoButton.isHidden = true
        toggleFilterView(isHidden: true, animated: false)
    }
    
    private func resetUI() {
        photoButton.isHidden = false
        videoButton.isHidden = false
        filterButton.isHidden = false
        libraryPhotoButton.isHidden = false
        isRecording = false
        timeDuration = 0
        timerLabel.isHidden = true
        self.photoButtonTapped(UIButton())
    }
}

// MARK: - Record Video
extension MGCameraViewController {
    private func startRecordingVideo() {
        isRecording = true
        mediaWriter.startRecording()
        timerLabel.isHidden = false
        hideButtons()
        videoTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateTimerLabel), userInfo: nil, repeats: true)
    }
    
    private func stopRecordingVideo() {
        isRecording = false
        videoTimer?.invalidate()
        mediaWriter.finishRecording { [weak self] (videoURL) in
            guard let strongSelf = self else { return }
            strongSelf.session.stopRunning()
            DispatchQueue.main.async {
                guard let image = strongSelf.imageOrigin else { return }
                let vc = MGVideoPreviewViewController.instantiateViewController
                vc.imagePhoto = image
                vc.videoURL = videoURL
                vc.selectedIndexPath = strongSelf.collectionView.indexPathsForSelectedItems?.first ?? IndexPath(row: 0, section: 0)
                vc.cameraViewController = self
                strongSelf.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    @objc func updateTimerLabel() {
        timeDuration += 1
        let hours = timeDuration / 3600
        let minutes = timeDuration / 60 % 60
        let seconds = timeDuration % 60
        timerLabel.text = String(format:"%02i:%02i:%02i", hours, minutes, seconds)
    }
}

// MARK: - Camera Preview
extension MGCameraViewController {
    private func cameraDevice(position: AVCaptureDevice.Position) -> AVCaptureDevice? {
        return AVCaptureDevice.devices(for: .video).first { $0.position == position }
    }
    
    private func setupInputs() {
        setupCameraInput()
        setupMicrophoneInput()
    }
    
    private func setupCameraInput() {
        guard let camera = cameraDevice(position: position) else { return }
        
        let captureDeviceInputs = session.inputs.filter {
            ($0 as? AVCaptureDeviceInput)?.device.hasMediaType(.video) ?? false
        }
        captureDeviceInputs.forEach { self.session.removeInput($0) }
        do {
            let input = try AVCaptureDeviceInput(device: camera)
            if session.canAddInput(input) {
                session.addInput(input)
            }
        } catch {
            print("Camera error: \(error.localizedDescription)")
        }
    }
    
    private func setupMicrophoneInput() {
        guard let microphone = AVCaptureDevice.devices(for: .audio).first else { return }
        
        let microphoneDeviceInputs = session.inputs.filter {
            ($0 as? AVCaptureDeviceInput)?.device.hasMediaType(.audio) ?? false
        }
        
        guard microphoneDeviceInputs.isEmpty else { return }
        do {
            let microphoneInput = try AVCaptureDeviceInput(device: microphone)
            if session.canAddInput(microphoneInput) {
                session.addInput(microphoneInput)
            }
        } catch {
            print("Camera microphone error: \(error.localizedDescription)")
        }
    }
    
    private func setupOutput() {
        if session.outputs.isEmpty {
            let videoOutput = AVCaptureVideoDataOutput()
            videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "MGCameraVideoQueue", attributes: .concurrent))
            if session.canAddOutput(videoOutput) {
                session.addOutput(videoOutput)
            }
            
            let audioOutput = AVCaptureAudioDataOutput()
            audioOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "MGCameraAudioQueue", attributes: .concurrent))
            if session.canAddOutput(audioOutput) {
                session.addOutput(audioOutput)
            }
        }
        session.outputs.forEach {
            $0.connection(with: .video)?.videoOrientation = .portrait
        }
    }
    
    private func setupCamera() {
        session.beginConfiguration()
        setupInputs()
        setupOutput()
        session.commitConfiguration()
        session.startRunning()
    }
    
    private func handleVideoDataOutput(sampleBuffer: CMSampleBuffer) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        
        let ciImage = CIImage(cvImageBuffer: pixelBuffer)
        guard let cgImage = ciImage.convertToCGImage() else { return }
        
        imageOrigin = UIImage(cgImage: cgImage)
        DispatchQueue.main.async {
            let selectedIndexPath = self.collectionView.indexPathsForSelectedItems?.first ?? IndexPath(item: 0, section: 0)
            guard let image = self.imageOrigin else { return }
            FilterManager.sharedInstance.filterPatterns[selectedIndexPath.item].applyFilter(image: image) { [weak self] (filterImage) in
                guard let strongSelf = self else { return }
                strongSelf.previewImageView.image = filterImage
                if strongSelf.isRecording {
                    strongSelf.mediaWriter.appendVideo(image: ciImage, sampleBuffer: sampleBuffer)
                }
            }
        }
    }
    
    private func handleAudioDataOutput(sampleBuffer: CMSampleBuffer) {
        guard isRecording else { return }
        mediaWriter.appendAudio(sampleBuffer: sampleBuffer)
    }
}

// MARK: AVCaptureVideoDataOutputSampleBufferDelegate
extension MGCameraViewController: AVCaptureVideoDataOutputSampleBufferDelegate, AVCaptureAudioDataOutputSampleBufferDelegate {
    public func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        switch output {
        case is AVCaptureVideoDataOutput:
            handleVideoDataOutput(sampleBuffer: sampleBuffer)
        case is AVCaptureAudioDataOutput:
            handleAudioDataOutput(sampleBuffer: sampleBuffer)
        default:
            return
        }
    }
}

// MARK: - Filters
extension MGCameraViewController {
    private func setupFiltersView() {
        if self == nil {
            print("nil controller")
        }
        
        if self.collectionView == nil {
            print("collection nil")
        }
        self.collectionView.setupFiltersView()
        toggleFilterView(isHidden: true, animated: false)
    }
    
    private func toggleFilterView(isHidden: Bool, animated: Bool) {
        self.filtersView.isHidden = false
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
            self.filterViewBottomConstraint.constant = isHidden ? -self.filtersView.frame.size.height : 6
            self.view.layoutIfNeeded()
        }, completion: { (finished) in
            self.filtersView.isHidden = isHidden
            self.filterButton.isSelected = !isHidden
        })
    }
}
