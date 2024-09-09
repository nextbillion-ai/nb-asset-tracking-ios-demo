import Foundation

import UIKit

extension UIView {
    func showToast(message: String, duration: Double = 3.0) {
        let toastLabel = UILabel()
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        toastLabel.textColor = UIColor.white
        toastLabel.textAlignment = .center
        toastLabel.font = UIFont.systemFont(ofSize: 14)
        toastLabel.text = message
        toastLabel.alpha = 0.0
        toastLabel.layer.cornerRadius = 10
        toastLabel.clipsToBounds = true

        let textSize = toastLabel.intrinsicContentSize
        let labelHeight = min(textSize.height + 20, self.frame.height - 40)
        let labelWidth = min(textSize.width + 40, self.frame.width - 40)
        
        toastLabel.frame = CGRect(x: (self.frame.width - labelWidth) / 2,
                                  y: self.frame.height - 100,
                                  width: labelWidth,
                                  height: labelHeight)
        
        self.addSubview(toastLabel)
        
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseIn, animations: {
            toastLabel.alpha = 1.0
        }, completion: { _ in
            UIView.animate(withDuration: 0.5, delay: duration, options: .curveEaseOut, animations: {
                toastLabel.alpha = 0.0
            }, completion: { _ in
                toastLabel.removeFromSuperview()
            })
        })
    }
}
