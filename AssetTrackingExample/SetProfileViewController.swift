//
//  SetProfileViewController.swift
//  AssetTrackingExample
//
//  Created by Jia on 4/7/23.
//

import UIKit
import NBAssetTracking

class SetProfileViewController: UIViewController, UIGestureRecognizerDelegate {
    @IBOutlet weak var editCustomId: UITextField!
    @IBOutlet weak var editAssetName: UITextField!
    @IBOutlet weak var editAssetDescription: UITextField!
    @IBOutlet weak var editAssetAttributes: UITextField!
    @IBOutlet weak var lastAssetId: UITextField!
    @IBOutlet weak var createAsset: UIButton!
    
    @IBOutlet weak var editAssetId: UITextField!
    @IBOutlet weak var bindAsset: UIButton!
    
    var customId: String = ""
    var assetName: String = ""
    var assetDescription: String = ""
    var assetAttributes: String = ""
    var assetId: String = ""
    
    let userDefaults: UserDefaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        self.hideKeyboardWhenTappedAround()
        initData()
        setUpInitialView()
        addGestureEvents()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    private func initData() {
        customId = userDefaults.string(forKey: Constants.CUSTOM_ID_KEY) ?? UUID().uuidString.lowercased()
        assetName = userDefaults.string(forKey: Constants.ASSET_NAME_KEY) ?? "my car"
        assetDescription = userDefaults.string(forKey: Constants.ASSET_DESCRIPTION_KEY) ?? "a luxury BMW"
        assetAttributes = userDefaults.string(forKey: Constants.ASSET_ATTRIBUTES_KEY) ?? "a test attribute"
        
        assetId = userDefaults.string(forKey: Constants.ASSET_ID_KEY) ?? ""
    }
    
    private func setUpInitialView(){
        editCustomId.delegate = self
        editAssetName.delegate = self
        editAssetDescription.delegate = self
        editAssetAttributes.delegate = self
        editAssetId.delegate = self
        
        editCustomId.text = customId
        editAssetName.text = assetName
        editAssetDescription.text = assetDescription
        editAssetAttributes.text = assetAttributes
        editAssetId.text = assetId
        lastAssetId.text = userDefaults.string(forKey: Constants.LAST_BIND_ASSET_ID_KEY) ?? ""
        
        createAsset.setTitleColor(.white, for: .normal)
        createAsset.layer.cornerRadius = 10
        createAsset.layer.backgroundColor = UIColor.systemBlue.cgColor
        
        bindAsset.setTitleColor(.systemBlue, for: .normal)
        bindAsset.layer.cornerRadius = 10
        bindAsset.layer.borderWidth = 1.0
        bindAsset.layer.borderColor = UIColor.systemBlue.cgColor
    }
    
    private func addGestureEvents() {
        createAsset.addTarget(self, action: #selector(onCreateAssetTapped), for: .touchUpInside)
        bindAsset.addTarget(self, action: #selector(onBindAssetTapped), for: .touchUpInside)
    }
    
    private func saveAssetProfile(assetId: String){
        userDefaults.set(customId, forKey: Constants.CUSTOM_ID_KEY)
        userDefaults.set(assetName, forKey: Constants.ASSET_NAME_KEY)
        userDefaults.set(assetDescription, forKey: Constants.ASSET_DESCRIPTION_KEY)
        userDefaults.set(assetAttributes, forKey: Constants.ASSET_ATTRIBUTES_KEY)
        userDefaults.set(assetId, forKey: Constants.ASSET_ID_KEY)
    }
    
    @objc private func onCreateAssetTapped() {
        if (assetName.isEmpty) {
            let toastView = ToastView(message: "Please enter asset name")
            toastView.show()
            return
        }
        
        if(AssetTracking.shared.isRunning()){
            let toastView = ToastView(message: "Asset tracking is ON, please turn off tracking before creating new asset!")
            toastView.show()
            return
        }
        
        let assetProfile: AssetProfile = AssetProfile.init(customId: customId, assetDescription: assetDescription, name: assetName, attributes: ["test": assetAttributes])
        
        AssetTracking.shared.createAsset(assetProfile: assetProfile) { assetCreationResponse in
            let assetId = assetCreationResponse.data.id
            self.editAssetId.text = assetId
            self.saveAssetProfile(assetId: assetId)
        } errorHandler: { error in
            let errorMessage = error.localizedDescription
            let toastView = ToastView(message: "Create asset failed: " + errorMessage)
            toastView.show()
        }
    }
    
    private func showForceBindDialog(assetId: String, warningMessage: String) {
        // Create an alert controller
        let alertController = UIAlertController(title: "", message: warningMessage + ", do you want to clear local data and force bind to new asset id?", preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "Proceed", style: .default) { (_) in
            self.dismiss(animated: true, completion: nil)
            AssetTracking.shared.forceBindAsset(assetId: assetId) { responseCode in
                let toastView = ToastView(message: "Force bind new asset successfully with assetId: " + assetId)
                toastView.show()
                
                self.userDefaults.set(true, forKey: Constants.IS_NOT_FIRST_INSTALLATION_KEY)
                self.userDefaults.set(assetId, forKey: Constants.LAST_BIND_ASSET_ID_KEY)
                
                self.navigationController?.popViewController(animated: true)
            } errorHandler: { error in
                let errorMessage = error.localizedDescription
                let toastView = ToastView(message: "Bind asset failed: " + errorMessage)
                toastView.show()
            }
        }
        alertController.addAction(okAction)
        
        // Add "Cancel" button
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in
            self.dismiss(animated: true, completion: nil)
        }
        alertController.addAction(cancelAction)
        
        // Show the alert
        present(alertController, animated: true, completion: nil)
    }
    
    @objc private func onBindAssetTapped() {
        guard let assetId = editAssetId.text else {
            let toastView = ToastView(message: "Please enter asset id")
            toastView.show()
            return
        }
        
        AssetTracking.shared.bindAsset(assetId: assetId) { responseCode in
            let toastView = ToastView(message: "Bind asset successfully with id: " + assetId)
            toastView.show()
            
            self.userDefaults.set(true, forKey: Constants.IS_NOT_FIRST_INSTALLATION_KEY)
            self.userDefaults.set(assetId, forKey: Constants.LAST_BIND_ASSET_ID_KEY)
            
            self.navigationController?.popViewController(animated: true)
            
        } errorHandler: { error in
            let errorMessage = error.localizedDescription
            
            if (errorMessage.contains(AssetTrackingApiExceptionType.UN_UPLOADED_LOCATION_DATA.rawValue)) {
                self.showForceBindDialog(assetId: assetId, warningMessage: errorMessage)
            } else {
                let toastView = ToastView(message: "Bind asset failed: " + errorMessage)
                toastView.show()
            }
        }
        
    }
    
}

extension SetProfileViewController{
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
}

extension SetProfileViewController: UITextFieldDelegate {
    public func textFieldDidChangeSelection(_ textField: UITextField) {
        let text = textField.text?.trimmingCharacters(in: CharacterSet.whitespaces) ?? ""
        if textField == self.editCustomId {
            customId = text
        } else if textField == self.editAssetName {
            assetName = text
        } else if textField == self.editAssetDescription {
            assetDescription = text
        } else if textField == self.editAssetAttributes {
            assetAttributes = text
        } else if textField == self.editAssetId {
            assetId = text
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
