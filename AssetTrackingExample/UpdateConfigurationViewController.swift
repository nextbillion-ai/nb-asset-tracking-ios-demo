//
// Copyright © 2023 NextBillion.ai. All rights reserved.
// Use of this source code is governed by license that can be found in the LICENSE file.
//


import Foundation
import UIKit
import NBAssetTracking

class UpdateConfigurationViewController: UIViewController {
    @IBOutlet weak var updateLocationConfigBtn: UIButton!
    @IBOutlet weak var updateNotificationConfigBtn: UIButton!
    @IBOutlet weak var updateDataTrackingConfigBtn: UIButton!
    @IBOutlet weak var configurationInfo: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let assetTracking = AssetTracking.shared
        
        let locationConfig = LocationConfig(trackingMode: .ACTIVE)
        locationConfig.distanceFilter = 5
        assetTracking.setLocationConfig(config: locationConfig)
        
        let notificationConfig = NotificationConfig()
        notificationConfig.showLowBatteryNotification = true
        assetTracking.setNotificationConfig(config: notificationConfig)
        
        let dataTrackingConfig = DataTrackingConfig()
        dataTrackingConfig.shouldClearLocalDataWhenCollision = false
        assetTracking.setDataTrackingConfig(config: dataTrackingConfig)
        
        assetTracking.initialize(apiKey: Constants.DEFAULT_API_KEY)
        
        createAsset()
        initView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    func initView(){
        updateLocationConfigBtn.addTarget(self, action: #selector(updateLocationConfig), for: .touchUpInside)
        updateNotificationConfigBtn.addTarget(self, action: #selector(updateNotificationConfig), for: .touchUpInside)
        updateDataTrackingConfigBtn.addTarget(self, action: #selector(updateDataTrackingConfig), for: .touchUpInside)
        configurationInfo.text = ""
    }
    
    @objc  func updateLocationConfig(){
        let locationConfig = AssetTracking.shared.getLocationConfig()
        locationConfig.distanceFilter = 10
        
        AssetTracking.shared.updateLocationConfig(config: locationConfig)
        
        let newLocationConfig = AssetTracking.shared.getLocationConfig()
        
        configurationInfo.text = "The updated location config value is: " + String(newLocationConfig.distanceFilter)
    }
    
    @objc func updateNotificationConfig() {
        let notificationConfig = AssetTracking.shared.getNotificationConfig()
        notificationConfig.showLowBatteryNotification = true
        
        AssetTracking.shared.updateNotificationConfig(config: notificationConfig)
        
        let newNotificationConfig = AssetTracking.shared.getNotificationConfig()
        
        configurationInfo.text = "The updated notificationConfig config value is: " + String(newNotificationConfig.showLowBatteryNotification)
    }
    
    @objc func updateDataTrackingConfig() {
        let dataTrackingConfig = AssetTracking.shared.getDataTrackingConfig()
        dataTrackingConfig.shouldClearLocalDataWhenCollision = true
        
        AssetTracking.shared.updateDataTrackingConfig(config: dataTrackingConfig)
        
        let newDataTrackingConfig = AssetTracking.shared.getDataTrackingConfig()
        
        configurationInfo.text = "The updated dataTrackingConfig config value is: " + String(newDataTrackingConfig.shouldClearLocalDataWhenCollision)
    }
    
    
    func createAsset(){
        let attributes = ["attribute 1": "test 1", "attribute 2": "test 2"]
        let assetProfile: AssetProfile = AssetProfile.init(customId: UUID().uuidString.lowercased(), assetDescription: "testDescription", name: "testName", attributes: attributes)
        
        NBAssetTrackingApiFetcher.shared.createAsset(assetProfile: assetProfile) { assetCreationResponse in
            let assetId = assetCreationResponse.data.id
            
            let toastView = ToastView(message: "Create asset successfully with id: " + assetId)
            toastView.show()
            
            self.bindAssetAndStartTracking(assetId: assetId)
        } errorHandler: { error in
            let errorMessage = error.localizedDescription
            let toastView = ToastView(message: "Create asset failed: " + errorMessage)
            toastView.show()
        }
    }
    
    func bindAssetAndStartTracking(assetId: String) {
        NBAssetTrackingApiFetcher.shared.bindAsset(assetId: assetId) { responseCode in
            let toastView = ToastView(message: "Bind asset successfully with id: " + assetId)
            toastView.show()
            AssetTracking.shared.startTracking()
        } errorHandler: { error in
            let errorMessage = error.localizedDescription
            let toastView = ToastView(message: "Bind asset failed: " + errorMessage)
            toastView.show()
        }
    }
    
}
