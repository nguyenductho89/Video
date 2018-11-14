
//
//  Recorder.swift
//  aninative
//
//  Created by Andy Drizen on 03/01/2015.
//  Copyright (c) 2015 Andy Drizen. All rights reserved.
//
//https://github.com/andydrizen/UIViewRecorder
import UIKit
import AVKit

public class Recorder: NSObject {
    
    var displayLink : CADisplayLink!

    var recordedImagesPath = [String]()
    var imageCounter = 0
    public var view : UIView?
    public var avplayer: AVPlayer?
    var outputPath : NSString?
    var referenceDate : NSDate?
    public var name = "image"
    public var outputJPG = false
    
    let serialQueue = DispatchQueue(label: "videoAnalyzer.Recoder.serialQueue")
    
    var playerItemVideoOutput: AVPlayerItemVideoOutput!
    
    override init() {
        super.init()
        displayLink = CADisplayLink(target: self, selector: #selector(displayLinkCallback(_:)))
        displayLink.add(to: RunLoop.main, forMode: RunLoop.Mode.common)
        displayLink.isPaused = true
        let attributes = [kCVPixelBufferPixelFormatTypeKey as String : Int(kCVPixelFormatType_32BGRA)]
        self.playerItemVideoOutput =  AVPlayerItemVideoOutput(pixelBufferAttributes: attributes)
        self.playerItemVideoOutput.setDelegate(self, queue: self.serialQueue)
    }
    
    public func start() {
        
        if (view == nil && avplayer == nil) {
            NSException(name: NSExceptionName(rawValue: "No view set"), reason: "You must set a view before calling start.", userInfo: nil).raise()
        }
        else {
            displayLink.isPaused = false
            referenceDate = NSDate()
        }
    }
    
    public func stop() {
        displayLink.invalidate()
        
        let seconds = referenceDate?.timeIntervalSinceNow
        if (seconds != nil) {
            print("Recorded: \(imageCounter) frames\nDuration: \(-1 * seconds!) seconds\nStored in: \(outputPathString())")
        }
        //isRecording = false
    }
    
    lazy var applicationDocumentsDirectory: NSURL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "uk.co.andydrizen.test" in the application's documents Application Support directory.
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[urls.count - 1] as NSURL
    }()
    
    @objc func displayLinkCallback(_ sender : CADisplayLink) {
        if (avplayer != nil && view == nil) {
            createImageFromAVplayer(self.avplayer)
        }
        if (avplayer == nil && view != nil) {
            createImageFromView(captureView: view!)
        }
    }
    
    func outputPathString() -> String {
        if (outputPath != nil) {
            return outputPath! as String
        }
        else {
            return applicationDocumentsDirectory.absoluteString!
        }
    }

    func createImageFromAVplayerTest(_ avplayer : AVPlayer?) {
        
        guard let avplayer = avplayer else {
            return
        }
        guard let asset = avplayer.currentItem?.asset else {
                return
        }

        let currentTime: CMTime = avplayer.currentTime() // step 1.
        let actionTime: CMTime = currentTime
        print(currentTime.seconds)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        imageGenerator.appliesPreferredTrackTransform = true // prevent image rotation
        
        do{
            let imageRef =  try imageGenerator.copyCGImage(at: actionTime, actualTime: nil)

            let recordedImage = UIImage(cgImage: imageRef)
            var fileExtension = "png"
            var data : Data?
            if (self.outputJPG) {
                data = recordedImage.jpegData(compressionQuality: 1) as Data?
                fileExtension = "jpg"
            }
            else {
                data = recordedImage.pngData() as Data?
            }

            var path = self.outputPathString()
            path = "\(path)/\(self.name)-\(self.imageCounter).\(fileExtension)"



            if(FileManager.default.fileExists(atPath: path)){
                guard (try? FileManager.default.removeItem(atPath: path)) != nil else {
                    print("remove path failed")
                    return
                }
            }


            self.imageCounter = self.imageCounter + 1

            if let imageRaw = data {
                do {
                    print("video link: \(path)")
                    try imageRaw.write(to: NSURL(string: path)! as URL, options: .atomic)
                    self.recordedImagesPath.append("\(self.name)-\(self.imageCounter).\(fileExtension)")
                }catch {
                    print("cannot save image")
                }
            }
        }catch let err as NSError{
            print(err.localizedDescription)
        }
    }
    func createImageFromAVplayer(_ avplayer : AVPlayer?) {
        
        var currentTime = CMTime.invalid
        let nextVSync = displayLink.timestamp + displayLink.duration
        currentTime = playerItemVideoOutput.itemTime(forHostTime: nextVSync)
        if playerItemVideoOutput.hasNewPixelBuffer(forItemTime: currentTime), let pixelBuffer = playerItemVideoOutput.copyPixelBuffer(forItemTime: currentTime, itemTimeForDisplay: nil){
            let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
            let ciContext = CIContext(options: nil)
            let imageRef = ciContext.createCGImage(ciImage, from: CGRect(x: 0, y: 0, width: CVPixelBufferGetWidth(pixelBuffer), height: CVPixelBufferGetHeight(pixelBuffer)))
            let recordedImage = UIImage(cgImage: imageRef!)
            var fileExtension = "png"
            var data : Data?
            if (self.outputJPG) {
                data = recordedImage.jpegData(compressionQuality: 1) as Data?
                fileExtension = "jpg"
            }
            else {
                data = recordedImage.pngData() as Data?
            }
            
            var path = self.outputPathString()
            path = "\(path)/\(self.name)-\(self.imageCounter).\(fileExtension)"
            
            
            
            if(FileManager.default.fileExists(atPath: path)){
                guard (try? FileManager.default.removeItem(atPath: path)) != nil else {
                    print("remove path failed")
                    return
                }
            }
            
            
            self.imageCounter = self.imageCounter + 1
            
            if let imageRaw = data {
                do {
                    print("video link: \(path)")
                    try imageRaw.write(to: NSURL(string: path)! as URL, options: .atomic)
                    self.recordedImagesPath.append("\(self.name)-\(self.imageCounter).\(fileExtension)")
                }catch {
                    print("cannot save image")
                }
            }        }
        
        
        
    }

    func createImageFromView(captureView : UIView) {
        print("count subview: %d",captureView.subviews.count)
        UIGraphicsBeginImageContextWithOptions(captureView.bounds.size, false, 0)
        
        captureView.drawHierarchy(in: captureView.bounds, afterScreenUpdates: false)
        
        let image = UIGraphicsGetImageFromCurrentImageContext();
        
        var fileExtension = "png"
        var data : Data?
        if (outputJPG) {
            data = image!.jpegData(compressionQuality: 1) as Data?
            fileExtension = "jpg"
        }
        else {
            data = image!.pngData() as Data?
        }

       var path = outputPathString()
        path = "\(path)/\(name)-\(imageCounter).\(fileExtension)"
        
        imageCounter = imageCounter + 1
        
        if let imageRaw = data {
            do {
                print("video link: \(path)")
            try imageRaw.write(to: NSURL(string: path)! as URL, options: .atomic)
                recordedImagesPath.append("\(name)-\(imageCounter).\(fileExtension)")
            }catch {
                print("cannot save image")
            }
        }
        
        UIGraphicsEndImageContext();
    }
}
extension Recorder: AVPlayerItemOutputPullDelegate {
    private func outputMediaDataWillChange(_ sender: AVPlayerItemOutput) {
        //Restart display link
        print("@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@")
        self.displayLink.isPaused = false
    }
}
extension UIView {
    private struct storedProperties {
        static var shouldRecord = true
    }
    var shouldRecord: Bool? {
        get {
            guard let shouldRecord = objc_getAssociatedObject(self, &storedProperties.shouldRecord) as? Bool else {
                return true
            }
            return shouldRecord
        }
        set {
            objc_setAssociatedObject(self, &storedProperties.shouldRecord, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
    }
}
