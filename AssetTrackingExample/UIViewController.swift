import Foundation
import UIKit

extension UIViewController {
    private static var spinnerView: UIView?

    func showLoadingIndicator() {
        let spinnerView = UIView(frame: CGRect(x: 0, y: 0, width: 70, height: 70))
        spinnerView.backgroundColor = UIColor(white: 0, alpha: 0.5)
        spinnerView.layer.cornerRadius = 10
        let activityIndicator: UIActivityIndicatorView
        if #available(iOS 13.0, *) {
            activityIndicator = UIActivityIndicatorView(style: .large)
        } else {
            activityIndicator = UIActivityIndicatorView(style: .whiteLarge)
        }
        activityIndicator.center = CGPoint(x: spinnerView.bounds.width / 2, y: spinnerView.bounds.height / 2)
        activityIndicator.startAnimating()
            
        spinnerView.addSubview(activityIndicator)
        spinnerView.center = self.view.center
        self.view.addSubview(spinnerView)
                
        UIViewController.spinnerView = spinnerView
    }

    func hideLoadingIndicator() {
        UIViewController.spinnerView?.removeFromSuperview()
        UIViewController.spinnerView = nil
    }
}
