//
//  MGVideoPreviewViewController.swift
//  Camera
//
//  Created by Ha Ho on 7/4/18.
//  Copyright © 2018 Mingle. All rights reserved.
//

import UIKit
import AVKit


class MGVideoPreviewViewController: UIViewController {
    
    enum VideoState {
        case playing
        case pause
        case normal
    }

    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet private weak var rightBarButton: UIButton!
    @IBOutlet private weak var playButton: UIButton!
    @IBOutlet private weak var stickerButton: UIButton!
    @IBOutlet private weak var filterButton: UIButton!
    @IBOutlet private weak var recordButton: UIButton!
    @IBOutlet private weak var previewView: UIView!
    @IBOutlet private weak var filtersView: UIView!
    @IBOutlet private weak var collectionView: FilterCollectionView!
    @IBOutlet weak var bottomBarView: UIView!
    @IBOutlet private weak var previewImageView: UIImageView!
    @IBOutlet private weak var filterViewBottomConstraint: NSLayoutConstraint!
    
    private var videoTimer: Timer?
    private var player: AVPlayer?
    private var playerLayer: AVPlayerLayer?
    private var avAsset: AVAsset?
    private var vidComp: AVVideoComposition = AVVideoComposition()
    private var videoState: VideoState = .normal
    private var currentImagePlay: UIImage!
    
    weak var cameraViewController: MGCameraViewController?
    var imagePhoto: UIImage!
    var videoURL: URL?
    var selectedIndexPath: IndexPath!
    
    private let videoURLPath: URL = {
        let documentPath = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        return documentPath.appendingPathComponent("MovieFiltered.mov")
    }()
    
    static var instantiateViewController: MGVideoPreviewViewController {
        return MGVideoPreviewViewController(nibName: "MGVideoPreviewViewController", bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        player?.pause()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    private func setupUI() {
        setupFiltersView()
        FilterManager.sharedInstance.filterPatterns[selectedIndexPath.row].applyFilter(image: imagePhoto) { [weak self] (filterImage) in
            guard let strongSelf = self else { return }
            strongSelf.previewImageView.image = filterImage
        }
        let gesture = UITapGestureRecognizer(target: self, action: #selector(videpPlayerPauseTap))
        self.previewImageView.addGestureRecognizer(gesture)
    }
    
    private func setupFiltersView() {
        collectionView.setupFiltersView()
        collectionView.collectionViewDelegate = self
        toggleFilterView(isHidden: true, animated: false)
        self.collectionView.selectItem(at: selectedIndexPath, animated: false, scrollPosition: .centeredHorizontally)
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
    
    @objc func updateTimerLabel() {
        let timeDuration = Int(player?.currentItem?.currentTime().seconds ?? 0)
        let hours = timeDuration / 3600
        let minutes = timeDuration / 60 % 60
        let seconds = timeDuration % 60
        timerLabel.text = String(format:"%02i:%02i:%02i", hours, minutes, seconds)
    }

    @objc func videpPlayerPauseTap() {
        guard let videoPlayer = player, videoPlayer.rate != 0, videoPlayer.error == nil else {
            return
        }
        videoState = .pause
        videoPlayer.pause()
        videoTimer?.invalidate()
        playButton.isHidden = false
    }
    
    // MARK: - Video Filter
    private func playVideoWithURL(url: URL) {
        if videoState == .pause {
            guard let videoPlayer = self.playerLayer else { return }
            videoState = .playing
            self.previewImageView.layer.sublayers?.forEach({ $0.removeFromSuperlayer()
            })
            self.previewImageView.layer.addSublayer(videoPlayer)
            playButton.isHidden = true
            player?.play()
            videoTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateTimerLabel), userInfo: nil, repeats: true)
            return
        }
        
        avAsset = AVAsset(url: url)
        vidComp = AVVideoComposition(asset: avAsset!) { (request) in
            let ciImage = request.sourceImage
            guard let cgImage = ciImage.convertToCGImage() else {
                print("error!!!!!!")
                return
            }
            self.currentImagePlay = UIImage(cgImage: cgImage)
            FilterManager.sharedInstance.filterPatterns[self.selectedIndexPath.row].applyFilter(image: self.currentImagePlay) { (filterImage) in
                guard let ciImageNew = CIImage(image: filterImage) else { return }
                let ciImage = ciImageNew.cropped(to: request.sourceImage.extent)
                request.finish(with: ciImage, context: nil)
            }
        }
        videoState = .playing
        let playerItem = AVPlayerItem(asset: avAsset!)
        playerItem.videoComposition = vidComp
        player = AVPlayer(playerItem: playerItem)
        NotificationCenter.default.addObserver(self, selector: #selector(playerDidFinishPlaying), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: playerItem)
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = self.previewImageView.bounds
        playerLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        self.previewImageView.layer.addSublayer(playerLayer)
        self.playerLayer = playerLayer
        player?.play()
        videoTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateTimerLabel), userInfo: nil, repeats: true)
    }
    
    // MARK: - IBAction
    @IBAction func rightBarButtonClicked(_ sender: Any) {
        // Test play video by url
    }
    
    @IBAction func playButtonClicked(_ sender: Any) {
        playButton.isHidden = true
        playVideoWithURL(url: videoURL!)
    }
    
    @objc func playerDidFinishPlaying() {
        player?.pause()
        playButton.isHidden = false
        self.previewImageView.layer.sublayers?.forEach({ $0.removeFromSuperlayer()
        })
        videoState = .normal
    }
    
    private func saveVideo() {
        removeVideoFile()
        if avAsset == nil {
            avAsset = AVAsset(url: videoURL!)
            vidComp = AVVideoComposition(asset: avAsset!) { (request) in
                let ciImage = request.sourceImage
                guard let cgImage = ciImage.convertToCGImage() else {
                    print("error!!!!!!")
                    return
                }
                let image = UIImage(cgImage: cgImage)
                FilterManager.sharedInstance.filterPatterns[self.selectedIndexPath.row].applyFilter(image: image) { (filterImage) in
                    var ciImageNew = CIImage(image: filterImage)
                    ciImageNew = ciImageNew?.cropped(to: request.sourceImage.extent)
                    request.finish(with: ciImageNew!, context: nil)
                }
            }
        }
        
        let export: AVAssetExportSession = AVAssetExportSession(asset: avAsset!, presetName: AVAssetExportPreset1920x1080)!
        export.outputFileType = AVFileType.mov
        export.outputURL = videoURLPath
        export.videoComposition = vidComp
        export.exportAsynchronously(completionHandler: {
            switch export.status {
            case  .failed:
                print("failed")
            case .cancelled:
                print("cancelled")
            case .completed:
                print("Save video successful")
                DispatchQueue.main.async {
                    guard let cameraVC = self.cameraViewController else {
                        print("not find vc")
                        return
                    }
                    self.dismiss(animated: true) {
                        cameraVC.delegate?.cameraController(cameraController: cameraVC, didSelectVideo: self.videoURLPath)
                    }
                }
            default:
                return
            }
        })
    }
    
    private func removeVideoFile() {
        guard FileManager.default.fileExists(atPath: videoURLPath.path) else { return }
        try? FileManager.default.removeItem(at: videoURLPath)
    }
    
    @IBAction func backButtonClicked(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func doneButtonClicked(_ sender: Any) {
        self.playerDidFinishPlaying()
        saveVideo()
    }
    
    @IBAction func stickerButtonClicked(_ sender: Any) {
        //TODO: test play video
        playVideoWithURL(url: videoURLPath)
    }
    
    @IBAction func filterButtonClicked(_ sender: Any) {
        toggleFilterView(isHidden: !filtersView.isHidden, animated: true)
    }
}

// MARK: UICollectionViewDataSource
extension MGVideoPreviewViewController: FilterCollectionViewDelegate {    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedIndexPath = indexPath
        switch videoState {
        case .pause:
            self.previewImageView.layer.sublayers?.forEach({ $0.removeFromSuperlayer()
            })
            FilterManager.sharedInstance.filterPatterns[indexPath.row].applyFilter(image: currentImagePlay) { [weak self] (filterImage) in
                guard let strongSelf = self else { return }
                strongSelf.previewImageView.image = filterImage
            }
        case .normal:
            FilterManager.sharedInstance.filterPatterns[indexPath.row].applyFilter(image: imagePhoto) { [weak self] (filterImage) in
                guard let strongSelf = self else { return }
                strongSelf.previewImageView.image = filterImage
            }
        default:
            return
        }
    }
}
