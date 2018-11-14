//
//  UIViewController+Extension.swift
//  VideoAnalyzer
//
//  Created by Miroslav Kutak on 14/11/2018.
//  Copyright © 2018 Nguyễn Đức Thọ. All rights reserved.
//

import Foundation
import UIKit

extension UIAlertController {
    
    static func okAlertWithTitle(_ title: String, message: String?, okTapped: (()->Void)? = nil) -> UIAlertController {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { action in
            okTapped?()
        }))
        return alertController
    }
    
    static func presentOKAlertWithTitle(_ title: String, message: String?, okTapped: (()->Void)? = nil) {
        let alertController = UIAlertController.okAlertWithTitle(title, message: message, okTapped: okTapped)
        UIViewController.topMostController().present(alertController, animated: true, completion: nil)
    }
    
    static func presentOKAlertWithError(_ error: NSError, okTapped: (()->Void)? = nil) {
        presentOKAlertWithTitle(error.domain, message: error.localizedDescription)
    }
}

extension UIViewController {
    
    static func instantiate(fromStoryboardName: String = "Main") -> UIViewController {
        let className = "\(type(of: self))"
        return UIStoryboard(name: fromStoryboardName, bundle: nil).instantiateViewController(withIdentifier:className)
    }
    
}

extension UIViewController {
    
    func addCloseButton() {
        let closeButtonItem = UIBarButtonItem(image: UIImage(named: "icons8-delete_sign"), style: .plain, target: self, action: #selector(UIViewController.cancelTapped))
        navigationItem.leftBarButtonItem = closeButtonItem
    }
    
    @IBAction func cancelTapped() {
        dismiss(animated: true, completion: nil)
    }
    
    func transitionAsNewRootViewController() {
        UIView.animate(withDuration: 0.3) {
            let delegate = UIApplication.shared.delegate as? AppDelegate
            delegate?.window?.rootViewController = self
        }
    }
    
    static func topMostController() -> UIViewController {
        
        let delegate = UIApplication.shared.delegate as? AppDelegate
        var topController: UIViewController = delegate!.window!.rootViewController!
        for _ in 0..<2 {
            while topController.presentedViewController != nil && topController.presentedViewController?.isKind(of: UIAlertController.self) == false {
                topController = topController.presentedViewController!
            }
            if (topController.isKind(of: UITabBarController.self)) {
                topController = ((topController as! UITabBarController)).selectedViewController!
            }
            if (topController.isKind(of: UINavigationController.self)) {
                topController = ((topController as! UINavigationController)).topViewController!
            }
        }
        return topController
    }
}

extension UIView {
    func embed(intoContainerView containerView: UIView) {
        translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(self)
        containerView.addConstraint(NSLayoutConstraint(item: self, attribute: .top, relatedBy: .equal, toItem: containerView, attribute: .top, multiplier: 1.0, constant: 0.0))
        containerView.addConstraint(NSLayoutConstraint(item: self, attribute: .bottom, relatedBy: .equal, toItem: containerView, attribute: .bottom, multiplier: 1.0, constant: 0.0))
        containerView.addConstraint(NSLayoutConstraint(item: self, attribute: .leading, relatedBy: .equal, toItem: containerView, attribute: .leading, multiplier: 1.0, constant: 0.0))
        containerView.addConstraint(NSLayoutConstraint(item: self, attribute: .trailing, relatedBy: .equal, toItem: containerView, attribute: .trailing, multiplier: 1.0, constant: 0.0))
        containerView.layoutIfNeeded()
    }
    
    func attach(aboveView view: UIView, height: CGFloat? = nil) {
        guard let containerView = view.superview else { return }
        
        translatesAutoresizingMaskIntoConstraints = false
        
        containerView.addSubview(self)
        
        // Height
        if let height = height {
            addConstraint(NSLayoutConstraint(item: self, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: height))
        }
        containerView.addConstraint(NSLayoutConstraint(item: self, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1.0, constant: 0.0))
        containerView.addConstraint(NSLayoutConstraint(item: self, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1.0, constant: 0.0))
        containerView.addConstraint(NSLayoutConstraint(item: self, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1.0, constant: 0.0))
        containerView.layoutIfNeeded()
    }
    
    func attach(belowView view: UIView, height: CGFloat? = nil) {
        guard let containerView = view.superview else { return }
        
        translatesAutoresizingMaskIntoConstraints = false
        
        containerView.addSubview(self)
        
        // Height
        if let height = height {
            addConstraint(NSLayoutConstraint(item: self, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: height))
        }
        containerView.addConstraint(NSLayoutConstraint(item: self, attribute: .top, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1.0, constant: 0.0))
        containerView.addConstraint(NSLayoutConstraint(item: self, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1.0, constant: 0.0))
        containerView.addConstraint(NSLayoutConstraint(item: self, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1.0, constant: 0.0))
        containerView.layoutIfNeeded()
    }
}
