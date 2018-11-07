//
//  ScreenRecordViewController.swift
//  VideoAnalyzer
//
//  Created by Nguyễn Đức Thọ on 11/5/18.
//  Copyright © 2018 Nguyễn Đức Thọ. All rights reserved.
//

import UIKit
import ReplayKit
import AVKit

class ScreenRecordViewController: UIViewController {
    
    @IBOutlet weak var shouldRecordView: UIView!
    
    var noNeedToRecordView: UIView?
    @IBOutlet weak var lblShouldRecord: UILabel!
    
    @IBOutlet weak var btnStart: UIButton!
    
    @IBOutlet weak var btnStop: UIButton!
    
    @IBOutlet weak var btnPlay: UIButton!
    let recorder = Recorder()
    @IBAction func playVideo(_ sender: Any) {
        var images = [UIImage]()
        recorder.recordedImagesPath.forEach { (imagePath) in
            guard let image = UIImage(contentsOfFile: URL.urlInDocumentsDirectory(with: imagePath).path) else {
                return
            }
            images.append(image)
        }
        let settings = CXEImagesToVideo.videoSettings(codec: AVVideoCodecType.h264.rawValue, width: (images[0].cgImage?.width)!, height: (images[0].cgImage?.height)!)
        let movieMaker = CXEImagesToVideo(videoSettings: settings)
        movieMaker.createMovieFrom(images: images){[unowned self] (fileURL:URL) in
            let player = AVPlayer(url: fileURL)
            let playerViewController = AVPlayerViewController()
            playerViewController.player = player
            self.present(playerViewController, animated: true) { () -> Void in
                player.play()
            }
        }
        
        //        if ScreenRecordViewController.record == 0 {
        //            let screenRecord = ScreenRecordCoordinator()
        //            screenRecord.viewOverlay.stopButtonColor = UIColor.red
        //            let randomNumber = arc4random_uniform(9999);
        //            screenRecord.startRecording(withFileName: "coolScreenRecording\(randomNumber)", recordingHandler: { (error) in
        //                print("Recording in progress")
        //            }) { (error) in
        //                print("Recording Complete")
        //            }
        //            ScreenRecordViewController.record = 1
        //        } else {
        //            let videoURL: URL = URL(fileURLWithPath: "file:///private/var/mobile/Containers/Data/Application/B8AE9F96-DA25-43C8-B7C8-B2541B623159/Documents/Replays/coolScreenRecording2722.mp4")
        //            let player = AVPlayer(url: videoURL)
        //            let playerViewController = AVPlayerViewController()
        //            playerViewController.player = player
        //            present(playerViewController, animated: true) { () -> Void in
        //                player.play()
        //            }
        //            ScreenRecordViewController.record = 0
        //        }
    }
    func addNoNeedRecordView () {
        if self.noNeedToRecordView == nil {
            self.noNeedToRecordView = UIView(frame: CGRect(x: 50, y: 250, width: 300, height: 350))
            self.noNeedToRecordView!.backgroundColor = .white
            let label = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 50))
            label.text = "Do not record this view"
            self.noNeedToRecordView?.addSubview(label)
            self.view.addSubview(self.noNeedToRecordView!)
        }
        
    }
    
    @IBAction func start(_ sender: Any) {
        recorder.start()
    }
    
    @IBAction func stop(_ sender: Any) {
        recorder.stop()
        addNoNeedRecordView()
        //self.timer.invalidate()
    }
    var timer: Timer!
    override func viewDidLoad() {
        super.viewDidLoad()
        addNoNeedRecordView()
        self.shouldRecordView.shouldRecord = true
        self.noNeedToRecordView?.shouldRecord = false
        self.lblShouldRecord.shouldRecord = true
//        self.btnPlay.shouldRecord = true
//        self.btnStop.shouldRecord = true
//        self.btnStart.shouldRecord = true
        recorder.view = self.shouldRecordView
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(update), userInfo: nil, repeats: true)
        UIView.animate(withDuration: 1, delay: 0.0, options:[UIView.AnimationOptions.repeat, UIView.AnimationOptions.autoreverse], animations: {
           
        }, completion: nil)
    }
    @objc func update() {
        UIView.animate(withDuration: 1.0, animations: {
            self.shouldRecordView.backgroundColor = self.randomColor()
        })
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        recorder.stop()
        addNoNeedRecordView()
        //self.timer.invalidate()
        playVideo(self)
    }
    
    func randomColor() -> UIColor {
        let randomRed:CGFloat = CGFloat(drand48())
        let randomGreen:CGFloat = CGFloat(drand48())
        let randomBlue:CGFloat = CGFloat(drand48())
        
        return UIColor(red: randomRed, green: randomGreen, blue: randomBlue,
                       alpha: 1.0)
    }
}

extension ScreenRecordViewController : RPPreviewViewControllerDelegate {
    
}

extension URL {
    static var documentsDirectory: URL {
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[urls.count - 1] as URL
    }
    
    static func urlInDocumentsDirectory(with filename: String) -> URL {
        return documentsDirectory.appendingPathComponent(filename)
    }
}

