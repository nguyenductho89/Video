//
//  VideoPlayerViewController.swift
//  VideoAnalyzer
//
//  Created by Nguyễn Đức Thọ on 11/7/18.
//  Copyright © 2018 Nguyễn Đức Thọ. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit
//exprotvideo.mp4

class SAVideoPlayerViewController: AVPlayerViewController {
    let recorder = Recorder()
    //var controlsView : RecordControls?
//    lazy var controlsView : RecordControls = {
//        let controlsView = RecordControls()
//        controlsView.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 130)
//        controlsView.backgroundColor = .clear
//        return controlsView
//    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //Bind controls view with player controls
        
    }
    
    func makeMovie(_ completion:@escaping (URL) -> ()){
        var images = [UIImage]()
        recorder.recordedImagesPath.forEach { (imagePath) in
            guard let image = UIImage(contentsOfFile: URL.urlInDocumentsDirectory(with: imagePath).path) else {
                return
            }
            images.append(image)
        }
        guard images.count > 0 else {
            return
        }
        let settings = CXEImagesToVideo.videoSettings(codec: AVVideoCodecType.h264.rawValue, width: (images[0].cgImage?.width)!, height: (images[0].cgImage?.height)!)
        let movieMaker = CXEImagesToVideo(videoSettings: settings)
        movieMaker.createMovieFrom(images: images){ (fileURL:URL) in
            completion(fileURL)
        }

    }
}

class ListVideoViewController: UIViewController {
    
    @IBOutlet weak var imageViewTemp: UIImageView!
    var playerViewController : SAVideoPlayerViewController?
    override func viewDidLoad() {
        super.viewDidLoad()
    }


    //open sample video and record
    @IBAction func replayVideo(_ sender: Any) {
        // Create an av asset for the given url.
        let asset = AVURLAsset(url: sampleVideoURL)
        
        // Create a av player item from the asset.
        let playerItem = AVPlayerItem(asset: asset)
        
 
        
        let player = AVPlayer(url: sampleVideoURL)//URL.urlInDocumentsDirectory(with: "exportvideo.mp4"))
        let playerViewController = SAVideoPlayerViewController()
        self.playerViewController = playerViewController
        playerViewController.showsPlaybackControls = false
        playerViewController.player = player
        let controlsView = RecordControls()
        controlsView.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 120)
        playerViewController.contentOverlayView?.addSubview(controlsView)
        controlsView.startPlayer = {player.play()}
        controlsView.pausePlayer = {player.pause()}
        controlsView.startRecording = {playerViewController.recorder.start()}
        controlsView.stopRecording = {self.stropRecord()}
        controlsView.close = {playerViewController.dismiss(animated: true, completion: nil)}
        playerViewController.recorder.avplayer = playerViewController.player
        // Add the player item video output to the player item.
        playerItem.add(playerViewController.recorder.playerItemVideoOutput)
        
        // Add the player item to the player.
        player.replaceCurrentItem(with: playerItem)
        self.present(playerViewController, animated: true) { () -> Void in
            self.imageViewTemp.image = UIImage(contentsOfFile: URL.urlInDocumentsDirectory(with: "image-1.png").path)
//            //self.playerViewController.player?.play()
//            let vc = PlayerControlViewController()
//            playerViewController.recorder.view = vc.view
//            vc.view.backgroundColor = .red
////            vc.view.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 130)
////            vc.definesPresentationContext = true
////            vc.providesPresentationContextTransitionStyle = true
//            vc.modalPresentationStyle = .custom
//            vc.modalTransitionStyle = .crossDissolve
//            vc.startPlayer = {print("2start player");self.playVideo()}
//            vc.startRecord = {self.startRecord()}
//            vc.stopRecord = {self.stropRecord()}
//            vc.dismiss = {playerViewController.dismiss(animated: true, completion: nil)}
//            playerViewController.present(vc, animated: true, completion: nil)
        }
    }
    // open recorded video
    @IBAction func editAndRecord(_ sender: Any) {
        let player = AVPlayer(url: URL.urlInDocumentsDirectory(with: "exportvideo1.mp4"))
        let playerViewController = SAVideoPlayerViewController()
        self.playerViewController = playerViewController
        //playerViewController.showsPlaybackControls = false
        playerViewController.player = player
        let controlsView = RecordControls()
        controlsView.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 120)
       ///playerViewController.contentOverlayView?.addSubview(controlsView)
        self.present(playerViewController, animated: true) { () -> Void in
//            //self.playerViewController.player?.play()
//            let vc = PlayerControlViewController()
//            //vc.view.backgroundColor = .clear
//            //            vc.view.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 130)
//            //            vc.definesPresentationContext = true
//            //            vc.providesPresentationContextTransitionStyle = true
//            vc.modalPresentationStyle = .custom
//            vc.modalTransitionStyle = .crossDissolve
//            vc.startPlayer = {print("2start player");self.playVideo()}
//            vc.startRecord = {self.startRecord()}
//            vc.stopRecord = {self.stropRecord()}
//            vc.dismiss = {playerViewController.dismiss(animated: true, completion: nil)}
//            playerViewController.present(vc, animated: true, completion: nil)
        }
    }
    
    func playVideo() {
        self.playerViewController?.player?.play()
    }
    func startRecord() {
        self.playerViewController?.recorder.start()
    }
    func stropRecord() {
        self.playerViewController?.recorder.stop()
        self.playerViewController?.makeMovie({ (url) in
            print(url.absoluteString)
        })
    }
}

class PlayerControlViewController : UIViewController {
    
    var startPlayer: (() -> ()) = { }
    var startRecord: (() -> ()) = { }
    var stopRecord: (() -> ()) = { }
    
    var dismiss: (() -> ()) = { }
    
    
    lazy var controlsView : RecordControls = {
        let controlsView = RecordControls()
//        controlsView.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 120)
        return controlsView
    }()
    
    override func viewDidLoad() {
        self.view.addSubview(controlsView)
        controlsView.translatesAutoresizingMaskIntoConstraints = false
        let topConstraint = NSLayoutConstraint(item: controlsView, attribute: NSLayoutConstraint.Attribute.top, relatedBy: NSLayoutConstraint.Relation.equal, toItem: view, attribute: NSLayoutConstraint.Attribute.top, multiplier: 1, constant: 0)
        let centerHorizontalConstraint = NSLayoutConstraint(item: controlsView, attribute: NSLayoutConstraint.Attribute.centerX, relatedBy: NSLayoutConstraint.Relation.equal, toItem: view, attribute: NSLayoutConstraint.Attribute.centerX, multiplier: 1, constant: 0)
        let widthConstraint = NSLayoutConstraint(item: controlsView, attribute: NSLayoutConstraint.Attribute.width, relatedBy: NSLayoutConstraint.Relation.equal, toItem: view, attribute: NSLayoutConstraint.Attribute.width, multiplier: 1, constant: 0)
        let heightConstraint = NSLayoutConstraint(item: controlsView, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: 120)
        self.view.addConstraints([topConstraint, centerHorizontalConstraint, widthConstraint, heightConstraint])
        controlsView.startPlayer = {print("start player"); self.startPlayer()}
        controlsView.pausePlayer = {print("pause player")}
        
        controlsView.stopRecording = {self.stopRecord()}
        controlsView.startRecording = {self.startRecord()}
        controlsView.close = {self.dismiss(animated: false, completion: nil);self.dismiss()}
    }
}
