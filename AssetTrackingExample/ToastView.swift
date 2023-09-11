//
//  ToastView.swift
//  AssetTrackingExample
//
//  Created by Jia on 5/7/23.
//

import Foundation
import UIKit

class ToastView: UIView {
    private let messageLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 14)
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    init(message: String) {
        super.init(frame: CGRect.zero)
        
        backgroundColor = UIColor.black.withAlphaComponent(0.7)
        layer.cornerRadius = 8
        
        addSubview(messageLabel)
        
        messageLabel.text = message
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        messageLabel.frame = bounds.inset(by: UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8))
    }
    
    func show(duration: TimeInterval = 2.0) {
        guard let keyWindow = UIApplication.shared.keyWindow else {
            return
        }
        
        keyWindow.addSubview(self)
        frame = CGRect(x: keyWindow.bounds.midX - 150, y: keyWindow.bounds.height - 100, width: 300, height: 50)
        
        alpha = 0
        transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        
        UIView.animate(withDuration: 0.3, animations: {
            self.alpha = 1
            self.transform = .identity
        }) { (_) in
            DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                UIView.animate(withDuration: 0.3, animations: {
                    self.alpha = 0
                }) { (_) in
                    self.removeFromSuperview()
                }
            }
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
