//
// Copyright © 2023 NextBillion.ai. All rights reserved.
// Use of this source code is governed by license that can be found in the LICENSE file.
//


import Foundation
import UIKit
import NBAssetTracking
import CoreLocation

class GetAssetCallbackViewController: UIViewController, AssetTrackingCallback {
    @IBOutlet weak var startTrackingBtn: UIButton!
    @IBOutlet weak var stopTrackingBtn: UIButton!
    @IBOutlet weak var trackingStatus: UILabel!
    @IBOutlet weak var locationInfo: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Add this to confirm the protocol and receive callbacks
        AssetTracking.shared.delegate = self
        
        let dataTrackingConfig = DataTrackingConfig(baseUrl: Constants.DEFAULT_BASE_URL, dataStorageSize: 5000, dataUploadingBatchSize: 30, dataUploadingBatchWindow: 20, shouldClearLocalDataWhenCollision: true)
        AssetTracking.shared.setDataTrackingConfig(config: dataTrackingConfig)
        AssetTracking.shared.initialize(apiKey: Constants.DEFAULT_API_KEY)
        
        createAndBindAsset()
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
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        AssetTracking.shared.stopTracking()
    }
    
    func initView(){
        startTrackingBtn.addTarget(self, action: #selector(startTracking), for: .touchUpInside)
        stopTrackingBtn.addTarget(self, action: #selector(stopTracking), for: .touchUpInside)
        trackingStatus.text = ""
        locationInfo.text = ""
    }
    
    func createAndBindAsset(){
        let attributes = ["attribute 1": "test 1", "attribute 2": "test 2"]
        let assetProfile: AssetProfile = AssetProfile.init(customId: UUID().uuidString.lowercased(), assetDescription: "testDescription", name: "testName", attributes: attributes)
        
        AssetTracking.shared.createAsset(assetProfile: assetProfile) { assetCreationResponse in
            let assetId = assetCreationResponse.data.id
            
            let toastView = ToastView(message: "Create asset successfully with id: " + assetId)
            toastView.show()
            
            self.bindAsset(assetId: assetId)
        } errorHandler: { error in
            let errorMessage = error.message
            let toastView = ToastView(message: "Create asset failed: " + errorMessage)
            toastView.show()
        }
    }
    
    func bindAsset(assetId: String) {
        AssetTracking.shared.bindAsset(assetId: assetId) { responseCode in
            let toastView = ToastView(message: "Bind asset successfully with id: " + assetId)
            toastView.show()
        } errorHandler: { error in
            let errorMessage = error.message
            let toastView = ToastView(message: "Bind asset failed: " + errorMessage)
            toastView.show()
        }
    }
    
    @objc func startTracking() {
        AssetTracking.shared.startTracking()
    }
    
    @objc func stopTracking() {
        AssetTracking.shared.stopTracking()
    }
    
    func onTrackingStart(assetId: String) {
        updateTrackingStatus()
    }
    
    func onTrackingStop(assetId: String, trackingDisableType: NBAssetTracking.TrackingDisableType) {
        updateTrackingStatus()
    }
    
    func onLocationSuccess(location: CLLocation) {
        locationInfo.text = """
                        --------- Location Info ---------
            Latitude: \(location.coordinate.latitude)
            Longitude: \(location.coordinate.longitude)
            Altitude: \(location.altitude)
            Accuracy: \(location.horizontalAccuracy)
            Speed: \(location.speed)
            Bearing: \(location.course)
            Time: \(location.timestamp)
            """
    }
    
    func onLocationFailure(error: Error) {
        locationInfo.text = "Failed to get location data: " + error.localizedDescription
    }
    
    func onLocationServiceOff() {
        showLocationAlert()
    }
    
    func showLocationAlert() {
        let alert = UIAlertController(title: "Location Services Disabled", message: "To enable location services, please go to Settings > Privacy > Location Services.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        
        present(alert, animated: true, completion: nil)
    }
    
    func updateTrackingStatus() {
        let assetTrackingRunning = AssetTracking.shared.isRunning()
        trackingStatus.text = "Tracking Status: \(assetTrackingRunning ? "ON" : "OFF")"
        if !assetTrackingRunning {
            locationInfo.text = ""
        }
    }
}
