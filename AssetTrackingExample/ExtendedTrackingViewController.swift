//
// Copyright © 2023 NextBillion.ai. All rights reserved.
// Use of this source code is governed by license that can be found in the LICENSE file.
//


import UIKit
import NBAssetTracking
import CoreLocation
import NBAssetDataCollectLib

class ExtendedTrackingViewController: UIViewController, AssetTrackingCallback {
    
    
    @IBOutlet weak var locationInfo: UILabel!
    @IBOutlet weak var trackingStatus: UILabel!
    @IBOutlet weak var trackingModeSelector: UISegmentedControl!
    @IBOutlet weak var startTracking: UIButton!
    @IBOutlet weak var stopTracking: UIButton!
    @IBOutlet weak var createAsset: UIButton!
    var assetTracking: AssetTracking = AssetTracking.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Add this to confirm the protocol and receive callbacks
        assetTracking.delegate = self
        
        let dataTrackingConfig = DataTrackingConfig(baseUrl: Constants.DEFAULT_BASE_URL, dataStorageSize: 5000, dataUploadingBatchSize: 30, dataUploadingBatchWindow: 20, shouldClearLocalDataWhenCollision: true)
        AssetTracking.shared.setDataTrackingConfig(config: dataTrackingConfig)
        AssetTracking.shared.initialize(apiKey: Constants.DEFAULT_API_KEY)
        
        startTracking.setTitle("Start Tracking", for: .normal)
        startTracking.setTitleColor(.white, for: .normal)
        startTracking.layer.cornerRadius = 10
        startTracking.layer.backgroundColor = UIColor.systemBlue.cgColor
        
        stopTracking.setTitle("Stop Tracking", for: .normal)
        stopTracking.setTitleColor(.white, for: .normal)
        stopTracking.layer.cornerRadius = 10
        stopTracking.layer.backgroundColor = UIColor.systemBlue.cgColor
        
        bindExistingAssetId()
        setUpButtons()
        updateTrackingStatus()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    private func bindExistingAssetId(){
        let assetId = UserDefaults.standard.string(forKey: Constants.LAST_BIND_ASSET_ID_KEY) ?? ""
        
        if(!assetId.isEmpty) {
            AssetTracking.shared.bindAsset(assetId: assetId) { responseCode in
                let toastView = ToastView(message: "Bind asset successfully with id: " + assetId)
                toastView.show()
            } errorHandler: { error in
                let errorMessage = error.localizedDescription
                let toastView = ToastView(message: "Bind asset failed: " + errorMessage)
                toastView.show()
            }
        }
    }
    
    private func setUpButtons(){
        createAsset.setTitleColor(.white, for: .normal)
        createAsset.layer.cornerRadius = 10
        createAsset.layer.backgroundColor = UIColor.systemBlue.cgColor
        
        createAsset.addTarget(self, action: #selector(onCreateAssetTapped), for: .touchUpInside)
    }
    
    @objc private func onCreateAssetTapped() {
        if assetTracking.isRunning() {
            let toastView = ToastView(message: "please stop tracking before editing asset profile")
            toastView.show()
            return
        }
        
        let setProfileViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SetProfileViewController") as! SetProfileViewController
        self.navigationController?.pushViewController(setProfileViewController, animated: true)
    }
    
    
    @IBAction func startTracking(_ sender: Any) {
        let assetId = assetTracking.getAssetId()
        
        if (assetId.isEmpty){
            let toastView = ToastView(message: "Please bind asset first before start tracking!")
            toastView.show()
            return
        }
        
        assetTracking.startTracking()
    }
    
    @IBAction func stopTracking(_ sender: Any) {
        locationInfo.text = ""
        assetTracking.stopTracking()
    }
    
    
    @IBAction func onTrackingModeChanged(_ sender: Any) {
        var trackingMode: TrackingMode = TrackingMode.ACTIVE
        switch trackingModeSelector.selectedSegmentIndex {
        case 0:
            trackingMode = .ACTIVE
        case 1:
            trackingMode = .BALANCED
        case 2:
            trackingMode = .PASSIVE
        default:
            break
        }
        
        let locationConfig = LocationConfig(trackingMode: trackingMode)
        assetTracking.updateLocationConfig(config: locationConfig)
    }
    
    func onTrackingStart(assetId: String) {
        updateTrackingStatus()
    }
    
    func onTrackingStop(assetId: String, trackingDisableType: TrackingDisableType) {
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
    
    func showLocationAlert() {
        let alert = UIAlertController(title: "Location Services Disabled", message: "To enable location services, please go to Settings > Privacy > Location Services.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        
        present(alert, animated: true, completion: nil)
    }
    
    func onLocationFailure(error: Error) {
    }
    
    func onLocationServiceOff() {
        showLocationAlert()
    }
    
    
    func updateTrackingStatus() {
        trackingStatus.text = "Tracking Status: \(assetTracking.isRunning() ? "ON" : "OFF")"
        if !assetTracking.isRunning() {
            locationInfo.text = ""
        }
    }
    
}


