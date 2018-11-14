//
//  EditVideoViewController.swift
//  VideoAnalyzer
//
//  Created by Nguyễn Đức Thọ on 11/4/18.
//  Copyright © 2018 Nguyễn Đức Thọ. All rights reserved.
//

import UIKit
import AVKit
import MobileCoreServices
import AssetsLibrary

class EditVideoViewController: UIViewController {
    
    var videoUrl:URL! // use your own url
    var frames:[UIImage] = []
    private var generator:AVAssetImageGenerator!
    
    override func viewDidLoad() {
        
    }
    @IBAction func selectVideo(_ sender: Any) {
        VideoHelper.startMediaBrowser(delegate: self , sourceType: .savedPhotosAlbum)
    }
    
    func getAllFrames() {
        let asset:AVAsset = AVAsset(url:self.videoUrl)
        let duration:Float64 = CMTimeGetSeconds(asset.duration)
        self.generator = AVAssetImageGenerator(asset:asset)
        self.generator.appliesPreferredTrackTransform = true
        self.frames = []
        for index:Int in 0 ..< Int(duration) {
            self.getFrame(fromTime:Float64(index))
        }
        self.generator = nil
    }
    
    private func getFrame(fromTime:Float64) {
        let time:CMTime = CMTimeMakeWithSeconds(fromTime, preferredTimescale:600)
        let image:CGImage
        do {
            try image = self.generator.copyCGImage(at:time, actualTime:nil)
        } catch {
            return
        }
        self.frames.append(UIImage(cgImage:image))
    }
}

// MARK: - UIImagePickerControllerDelegate
var sampleVideoURL: URL!
extension EditVideoViewController: UIImagePickerControllerDelegate {
    
    @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let mediaType = info[UIImagePickerController.InfoKey.mediaType] as? String,
            mediaType == (kUTTypeMovie as String),
            let url = info[UIImagePickerController.InfoKey.mediaURL] as? URL
            else { return }
        dismiss(animated: true) {
            sampleVideoURL = url
            //self.editVideoFromURL(url)

        }
//        self.videoUrl = url
//        self.getAllFrames()
    }
}
extension EditVideoViewController : UIPopoverPresentationControllerDelegate {}
extension EditVideoViewController : UIVideoEditorControllerDelegate {
}
extension EditVideoViewController : UINavigationControllerDelegate {}

extension EditVideoViewController {
    func editVideoFromURL(_ url:URL){
        print(url.absoluteString)
        let videoAsset = AVAsset(url: url)
        // 2 - Create AVMutableComposition object. This object will hold your AVMutableCompositionTrack instances.
        let mixComposition =  AVMutableComposition()
        
        // 3 - Video track
        let videoTrack = mixComposition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid)
        let timeRange = CMTimeRange(start: .zero, duration: videoAsset.duration)
        do {
            try videoTrack?.insertTimeRange(timeRange, of: videoAsset.tracks(withMediaType: .video)[0], at: .zero)
            // 3.1 - Create AVMutableVideoCompositionInstruction
            let mainInstruction = AVMutableVideoCompositionInstruction()
            mainInstruction.timeRange = CMTimeRangeMake(start: CMTime.zero, duration: videoAsset.duration);
            // 3.2 - Create an AVMutableVideoCompositionLayerInstruction for the video track and fix the orientation.
            let videolayerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: videoTrack!)
            let videoAssetTrack = videoAsset.tracks(withMediaType: .video)[0]
            var videoAssetOrientation_ = UIImage.Orientation.up
            var isVideoAssetPortrait_ = false
            let videoTransform = videoAssetTrack.preferredTransform
            
            if (videoTransform.a == 0 && videoTransform.b == 1.0 && videoTransform.c == -1.0 && videoTransform.d == 0) {
                videoAssetOrientation_ = UIImage.Orientation.right;
                isVideoAssetPortrait_ = true;
            }
            if (videoTransform.a == 0 && videoTransform.b == -1.0 && videoTransform.c == 1.0 && videoTransform.d == 0) {
                videoAssetOrientation_ =  UIImage.Orientation.left;
                isVideoAssetPortrait_ = true;
            }
            if (videoTransform.a == 1.0 && videoTransform.b == 0 && videoTransform.c == 0 && videoTransform.d == 1.0) {
                videoAssetOrientation_ =  UIImage.Orientation.up;
            }
            if (videoTransform.a == -1.0 && videoTransform.b == 0 && videoTransform.c == 0 && videoTransform.d == -1.0) {
                videoAssetOrientation_ = UIImage.Orientation.down;
            }
            
            videolayerInstruction.setTransform(videoAssetTrack.preferredTransform, at: .zero)
            videolayerInstruction.setOpacity(0.0, at: videoAsset.duration)
            
            
            // 3.3 - Add instructions
            mainInstruction.layerInstructions = [videolayerInstruction]
            let mainCompositionInst = AVMutableVideoComposition()
            var naturalSize: CGSize!
            if isVideoAssetPortrait_ {
                naturalSize = CGSize(width: videoAssetTrack.naturalSize.width, height: videoAssetTrack.naturalSize.height)
            } else {
                naturalSize = videoAssetTrack.naturalSize
            }
            let renderWidth = naturalSize.width;
            let renderHeight = naturalSize.height;
            mainCompositionInst.renderSize = CGSize(width: renderWidth, height: renderHeight)
            mainCompositionInst.instructions = [mainInstruction]
            mainCompositionInst.frameDuration = CMTime(seconds: 1, preferredTimescale: 30)
            
            applyVideoEffectsToComposition(composition: mainCompositionInst, size: naturalSize)
            // 4 - Get path
            let paths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
            let documentsDirectory = paths[0]
            let randomTime = arc4random()%1000
            let myPathDocs = documentsDirectory + "/" + "\(String(format: "FinalVideo-%d.mov",randomTime ))"
            let outputUrl = URL.init(fileURLWithPath: myPathDocs)
            // 5 - Create exporter
            let exporter = AVAssetExportSession(asset: mixComposition, presetName: AVAssetExportPresetHighestQuality)
            exporter?.outputURL = outputUrl
            exporter?.outputFileType = AVFileType.mov;
            exporter?.shouldOptimizeForNetworkUse = true;
            exporter?.videoComposition = mainCompositionInst;
            exporter?.exportAsynchronously(completionHandler: {
                DispatchQueue.main.async {
                    self.exportDidFinish(session: exporter!)
                }
            })
            
            
        }catch {
            print("videoTrack insert time range error")
        }
        
    }
    func applyVideoEffectsToComposition(composition: AVMutableVideoComposition,  size: CGSize)
    {
        let overlayLayer = CALayer()
        let overlayImage = UIImage(named: "Frame-3.png")
        overlayLayer.contents = overlayImage?.cgImage
        overlayLayer.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        overlayLayer.masksToBounds = true

        let parentLayer = CALayer()
        let videoLayer = CALayer()
        parentLayer.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        videoLayer.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        parentLayer.addSublayer(videoLayer)
        parentLayer.addSublayer(overlayLayer)
        composition.animationTool = AVVideoCompositionCoreAnimationTool(postProcessingAsVideoLayer: videoLayer, in: parentLayer)
    }
    
    func exportDidFinish(session:AVAssetExportSession) {
        if (session.status == .completed) {
            let outputURL = session.outputURL
            let library = ALAssetsLibrary()
            if (library.videoAtPathIs(compatibleWithSavedPhotosAlbum: outputURL)) {
                library.writeVideoAtPath(toSavedPhotosAlbum: outputURL) { (assetURL, error) in
                    if error != nil {
                        print("fail to save video")
                    } else {
                        print("video success!")
                    }
                }
            }
            
        }
    }
}

