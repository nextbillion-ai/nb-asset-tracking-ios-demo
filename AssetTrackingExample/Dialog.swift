//
//  Dialog.swift
//  AssetTrackingExample
//
//  Created by qiu on 2024/6/11.
//

import Foundation
import UIKit

func showInputDialog(title: String, message: String, completion: @escaping ([String?]) -> Void) {
    guard let topController = UIApplication.shared.keyWindow?.rootViewController else {
        return
    }
    
    let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
    
    alertController.addTextField { (textField) in
        textField.placeholder = "Input trip name"
    }
    
    alertController.addTextField { (textField) in
        textField.placeholder = "Input trip id"
    }
    
    alertController.addTextField { (textField) in
        textField.placeholder = "Input trip description"
    }
    
    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in
        completion([nil, nil, nil])
    }
    alertController.addAction(cancelAction)
    
    let confirmAction = UIAlertAction(title: "OK", style: .default) { _ in
        let userInput = alertController.textFields?.map { $0.text }
        completion(userInput ?? [nil, nil, nil])
    }
    alertController.addAction(confirmAction)
    
    topController.present(alertController, animated: true, completion: nil)
}

func showUpdateDialog(title: String, message: String, completion: @escaping ([String?]) -> Void) {
    guard let topController = UIApplication.shared.keyWindow?.rootViewController else {
        return
    }
    
    let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
    
    alertController.addTextField { (textField) in
        textField.placeholder = "Input trip name"
    }
    
    alertController.addTextField { (textField) in
        textField.placeholder = "Input trip description"
    }
    
    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in
        completion([nil, nil, nil])
    }
    alertController.addAction(cancelAction)
    
    let confirmAction = UIAlertAction(title: "OK", style: .default) { _ in
        let userInput = alertController.textFields?.map { $0.text }
        completion(userInput ?? [nil, nil])
    }
    alertController.addAction(confirmAction)
    
    topController.present(alertController, animated: true, completion: nil)
}
