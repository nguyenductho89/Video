
//
//  Recorder.swift
//  aninative
//
//  Created by Andy Drizen on 03/01/2015.
//  Copyright (c) 2015 Andy Drizen. All rights reserved.
//
//https://github.com/andydrizen/UIViewRecorder
import UIKit

@objc public class Recorder: NSObject {
    var displayLink : CADisplayLink?
    var recordedImages = [UIImage]()
    var imageCounter = 0
    public var view : UIView?
    var outputPath : NSString?
    var referenceDate : NSDate?
    public var name = "image"
    public var outputJPG = false
    
    public func start() {
        
        if (view == nil) {
            NSException(name: NSExceptionName(rawValue: "No view set"), reason: "You must set a view before calling start.", userInfo: nil).raise()
        }
        else {
            print("1 count subview: %d",self.view!.subviews.count)
            for subview in self.view!.subviews{
                if subview.shouldRecord == false {
                    subview.removeFromSuperview()
                }
            }
            displayLink = CADisplayLink(target: self, selector: #selector(handleDisplayLink(displayLink:)))
            displayLink!.add(to: RunLoop.main, forMode: RunLoop.Mode.common)
            
            referenceDate = NSDate()
        }
    }
    
    public func stop() {
        displayLink?.invalidate()
        
        let seconds = referenceDate?.timeIntervalSinceNow
        if (seconds != nil) {
            print("Recorded: \(imageCounter) frames\nDuration: \(-1 * seconds!) seconds\nStored in: \(outputPathString())")
        }
    }
    
    lazy var applicationDocumentsDirectory: NSURL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "uk.co.andydrizen.test" in the application's documents Application Support directory.
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[urls.count - 1] as NSURL
    }()
    
    @objc func handleDisplayLink(displayLink : CADisplayLink) {
        if (view != nil) {
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
        
        recordedImages.append(image!)
        imageCounter = imageCounter + 1
        
        if let imageRaw = data {
            do {
                print("video link: \(path)")
            try imageRaw.write(to: NSURL(string: path)! as URL, options: .atomic)
            }catch {
                print("cannot save image")
            }
        }
        
        UIGraphicsEndImageContext();
    }
}

extension UIView {
    private struct storedProperties {
        static var shouldRecord = false
    }
    var shouldRecord: Bool? {
        get {
            guard let shouldRecord = objc_getAssociatedObject(self, &storedProperties.shouldRecord) as? Bool else {
                return false
            }
            return shouldRecord
        }
        set {
            objc_setAssociatedObject(self, &storedProperties.shouldRecord, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
    }
}
