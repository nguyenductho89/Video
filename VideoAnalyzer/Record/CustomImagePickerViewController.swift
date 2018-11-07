//
//  CustomImagePickerViewController.swift
//  VideoAnalyzer
//
//  Created by Nguyễn Đức Thọ on 11/5/18.
//  Copyright © 2018 Nguyễn Đức Thọ. All rights reserved.
//

import UIKit
import MobileCoreServices

class CustomImagePickerViewController: UIImagePickerController {
    
    lazy var mainImageView : UIImageView = {
        let imgView = UIImageView()
        imgView.center = self.view.center
        imgView.bounds.size = self.view.bounds.size
        imgView.backgroundColor = .clear
        return imgView
    }()
    lazy var tempImageView : UIImageView = {
        let imgView = UIImageView()
        imgView.center = self.view.center
        imgView.bounds.size = self.view.bounds.size
        imgView.backgroundColor = .clear
        return imgView
    }()
    
    var lastPoint = CGPoint.zero
    var color = UIColor.green
    var brushWidth: CGFloat = 10.0
    var opacity: CGFloat = 1.0
    var swiped = false

    override func viewDidLoad() {
        super.viewDidLoad()
        //self.hideDefaultVideoControls()
        

        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 30))
        label.backgroundColor = .red
        label.text = "Video Analysis"
        self.view.addSubview(label)
        self.view.addSubview(mainImageView)
        self.view.addSubview(tempImageView)
        // Do any additional setup after loading the view.
    }
    
    private func hideDefaultVideoControls(){
        self.showsCameraControls = false
    }
    
    func drawLine(from fromPoint: CGPoint, to toPoint: CGPoint) {
        UIGraphicsBeginImageContext(view.frame.size)
        guard let context = UIGraphicsGetCurrentContext() else {
            return
        }
        tempImageView.image?.draw(in: view.bounds)
        
        context.move(to: fromPoint)
        context.addLine(to: toPoint)
        
        context.setLineCap(.round)
        context.setBlendMode(.normal)
        context.setLineWidth(brushWidth)
        context.setStrokeColor(color.cgColor)
        
        context.strokePath()
        
        tempImageView.image = UIGraphicsGetImageFromCurrentImageContext()
        tempImageView.alpha = opacity
        
        UIGraphicsEndImageContext()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        swiped = false
        lastPoint = touch.location(in: view)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        swiped = true
        let currentPoint = touch.location(in: view)
        drawLine(from: lastPoint, to: currentPoint)
        
        lastPoint = currentPoint
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !swiped {
            // draw a single point
            drawLine(from: lastPoint, to: lastPoint)
        }
        
        // Merge tempImageView into mainImageView
        UIGraphicsBeginImageContext(mainImageView.frame.size)
        mainImageView.image?.draw(in: view.bounds, blendMode: .normal, alpha: 1.0)
        tempImageView.image?.draw(in: view.bounds, blendMode: .normal, alpha: opacity)
        mainImageView.image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        tempImageView.image = nil
    }

}
extension CustomImagePickerViewController : UIImagePickerControllerDelegate {
}
