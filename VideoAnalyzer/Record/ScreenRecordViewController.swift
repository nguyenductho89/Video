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
import LLSimpleCamera

class ScreenRecordViewController: UIViewController {
    
    @IBOutlet weak var shouldRecordView: UIView!
    
    var noNeedToRecordView: UIView?
    @IBOutlet weak var lblShouldRecord: UILabel!
    
    @IBOutlet weak var btnStart: UIButton!
    
    @IBOutlet weak var playerContainerView: UIView!
    let playerVC = AVPlayerViewController()
    
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
            print(fileURL.absoluteString)
            let player = AVPlayer(url: fileURL)
            let playerViewController = AVPlayerViewController()
            playerViewController.player = player
            self.present(playerViewController, animated: true) { () -> Void in
                player.play()
            }
        }
    }
    func addNoNeedRecordView () {
        if self.noNeedToRecordView == nil {
            self.noNeedToRecordView = UIView(frame: CGRect(x: 50, y: 250, width: 250, height: 35))
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
        
        
        playerVC.view.embed(intoContainerView: playerContainerView)
        playerVC.player = AVPlayer(url: URL(string: "http://techslides.com/demos/sample-videos/small.mp4")!)
        playerVC.player?.play()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        beginSession()
    }
    
    
    let captureSession = AVCaptureSession()
    var previewLayer: CALayer?
    var captureDevice: AVCaptureDevice!
    func beginSession() {
        captureSession.sessionPreset = AVCaptureSession.Preset.iFrame960x540
        let availableDevice = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: AVMediaType.video, position: .back
            ).devices
        captureDevice = availableDevice.first
        
        guard let captureDeviceInput = try? AVCaptureDeviceInput(device: captureDevice) else { return }
        captureSession.addInput(captureDeviceInput)
        
        let previewlayer = AVCaptureVideoPreviewLayer(session: self.captureSession)
        self.previewLayer = previewlayer
        previewlayer.frame = CGRect(x: 150, y: 50, width: 250, height: 250)
        self.view.layer.insertSublayer(self.previewLayer!, below: self.view.layer)
        captureSession.startRunning()
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

