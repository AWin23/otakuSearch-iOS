//
//  ToastManager.swift
//  otakuSearch-iOS
//
//  Created by Andrew Nguyen on 6/3/25.
//

import Foundation
import UIKit

class ToastManager {
    static let shared = ToastManager()

    private init() {}
    
    func show(message: String, duration: TimeInterval = 3.0) {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else { return }

        let toastLabel = UILabel()
        toastLabel.text = message
        toastLabel.textColor = .white
        toastLabel.textAlignment = .center
        toastLabel.font = UIFont.systemFont(ofSize: 14)
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        toastLabel.layer.cornerRadius = 8
        toastLabel.clipsToBounds = true
        toastLabel.alpha = 0
        
        // Border color and scheme
        toastLabel.layer.borderWidth = 1.5
        toastLabel.layer.borderColor = UIColor.otakuPink.cgColor
        
        // Enable multiline text
        toastLabel.numberOfLines = 2
        toastLabel.lineBreakMode = .byWordWrapping


        let padding: CGFloat = 16
        let height: CGFloat = 55 // Increased height for multiline
        toastLabel.frame = CGRect(
            x: padding,
            y: window.safeAreaInsets.top + padding,
            width: window.frame.width - (padding * 2),
            height: height
        )

        window.addSubview(toastLabel)

        UIView.animate(withDuration: 0.5, animations: {
            toastLabel.alpha = 1
        }) { _ in
            UIView.animate(withDuration: 0.5, delay: duration, options: [], animations: {
                toastLabel.alpha = 0
            }) { _ in
                toastLabel.removeFromSuperview()
            }
        }
    }

}
