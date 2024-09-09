import UIKit
import NBAssetTracking
import CoreLocation
import NBAssetDataCollectLib

class ExtendedTrackingViewController: UIViewController, AssetTrackingDelegate ,CLLocationManagerDelegate {
    
    
    @IBOutlet weak var locationInfo: UILabel!
    @IBOutlet weak var trackingStatus: UILabel!
    @IBOutlet weak var trackingModeSelector: UISegmentedControl!
    @IBOutlet weak var startTracking: UIButton!
    @IBOutlet weak var stopTracking: UIButton!
    @IBOutlet weak var createAsset: UIButton!
    @IBOutlet weak var customConfinInput: UITextField!
    @IBOutlet weak var startNotification: UISwitch!
    @IBOutlet weak var stopNotification: UISwitch!
    
    
    @IBOutlet weak var triptart: UIButton!
    
    @IBOutlet weak var tripEndButton: UIButton!
    @IBOutlet weak var fakeGPS: UISwitch!
        
    let locationManager = CLLocationManager()
    
    var _onlyTracking : String = ""
    
    var assetTracking: AssetTracking = AssetTracking.shared
    var selectedMode: MultiTrackingMode = MultiTrackingMode.ACTIVE

    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        assetTracking.initialize(apiKey: Constants.DEFAULT_API_KEY)

        startTracking.isEnabled = true
        startTracking.setTitle("Start Tracking", for: .normal)
        startTracking.setTitleColor(.white, for: .normal)
        stopTracking.setTitleColor(UIColor.grey_7c7c7c, for: .disabled)
        startTracking.layer.cornerRadius = 10
        startTracking.layer.backgroundColor = UIColor.systemBlue.cgColor
        
        stopTracking.isEnabled = false
        stopTracking.setTitle("Stop Tracking", for: .normal)
        stopTracking.setTitleColor(.white, for: .normal)
        stopTracking.setTitleColor(UIColor.grey_7c7c7c, for: .disabled)
        stopTracking.layer.cornerRadius = 10
        stopTracking.layer.backgroundColor = UIColor.grey_ececec.cgColor
        
        triptart.isEnabled = true
        triptart.setTitle("Start Trip", for: .normal)
        triptart.setTitleColor(.white, for: .normal)
        triptart.setTitleColor(UIColor.grey_7c7c7c, for: .disabled)
        triptart.layer.cornerRadius = 10
        triptart.layer.backgroundColor = UIColor.systemBlue.cgColor
        
        tripEndButton.isEnabled = false
        tripEndButton.setTitle("End Trip", for: .normal)
        tripEndButton.setTitleColor(.white, for: .normal)
        tripEndButton.setTitleColor(UIColor.grey_7c7c7c, for: .disabled)
        tripEndButton.layer.cornerRadius = 10
        tripEndButton.layer.backgroundColor = UIColor.grey_ececec.cgColor
        
        customConfinInput.isHidden = true
        customConfinInput.delegate = self
        customConfinInput.keyboardType = UIKeyboardType.numberPad
        customConfinInput.layer.borderColor = UIColor.grey_adadad.cgColor
        customConfinInput.layer.borderWidth = 1
        customConfinInput.layer.cornerRadius = 6
        
        startNotification.isOn = true
        stopNotification.isOn = true
        
        assetTracking.delegate = self
        
        
        bindExistingAssetId()
        setUpButtons()
        updateTrackingStatus()
        
        if #available(iOS 15.0, *) {
            fakeGPS.isOn = assetTracking.isAllowFakeGps()
        } else {
            fakeGPS.isOn = true
        }
        locationManager.delegate = self
        
        initTrackingMode()
    
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    func initTrackingMode() {
        var config = assetTracking.getLocationConfig()
        var selectedIndex = 0
        switch config.trackingMode {
        case .ACTIVE:
            selectedMode = MultiTrackingMode.ACTIVE
            selectedIndex = 0
        case .none:
            selectedMode = MultiTrackingMode.DISTANCE_INTERVAL
            selectedIndex = 3
        case .some(.BALANCED):
            selectedMode = MultiTrackingMode.BALANCED
            selectedIndex = 1
        case .some(.PASSIVE):
            selectedMode = MultiTrackingMode.PASSIVE
            selectedIndex = 2
        case .some(_):
            selectedMode = MultiTrackingMode.DISTANCE_INTERVAL
            selectedIndex = 3
        }
        trackingModeSelector.selectedSegmentIndex = selectedIndex
    }
    
    func checkLocationAuthorization(onlyTracking: Bool) {
        switch CLLocationManager.authorizationStatus() {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted, .denied:
            showLocationServicesDeniedAlert()
        case .authorizedWhenInUse, .authorizedAlways:
            if onlyTracking {
                checkNotificationConfig()
                if (checkLocationConfig()) {
                    assetTracking.startTracking()
                }
            }else {
                checkNotificationConfig()
                if (!checkLocationConfig()) {
                    return
                }
                showInputDialog(title: "Enter Trip Details",
                                message: "Please provide trip details below.") { userInput in
                    guard userInput[0] != nil && userInput[1] != nil && userInput[2] != nil else {
                        return
                    }
                    let tripName = userInput[0]
                    let tripId = userInput[1]
                    let tripDescription = userInput[2]
                    
                    let trip = TripProfile(customId: tripId, name: tripName ?? "",description: tripDescription)
                    self.showLoadingIndicator()
                    self.assetTracking.startTrip(tripProfile: trip) { tripId in
                        self.hideLoadingIndicator()
                    } errorHandler: { error in
                        self.view.showToast(message: error.message, duration: 2)
                        self.hideLoadingIndicator()
                    }
                }
            }
           break
            
        @unknown default:
            fatalError("unknown status")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if _onlyTracking == "YES" {
            checkLocationAuthorization(onlyTracking: true)
        }else if (_onlyTracking == "NO") {
            checkLocationAuthorization(onlyTracking: false)
        }
    }
    
    func showLocationServicesDeniedAlert() {
        let alert = UIAlertController(title: "Location service is not enabled",
                                          message: "Please enable Location services in your Settings to use this feature.",
                                          preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
        
    func showLocationServicesDisabledAlert() {
        let alert = UIAlertController(title: "Location services are disabled",
                                          message: "Please enable location services",
                                          preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func bindExistingAssetId(){
        let assetId = UserDefaults.standard.string(forKey: Constants.LAST_BIND_ASSET_ID_KEY) ?? ""
        
        if(!assetId.isEmpty) {
            assetTracking.bindAsset(assetId: assetId) { responseCode in
                let toastView = ToastView(message: "Bind asset successfully with id: " + assetId)
                toastView.show()
            } errorHandler: { error in
                let errorMessage = error.message
                let toastView = ToastView(message: "Bind asset failed: " + errorMessage)
                toastView.show()
            }
        }
    }
    
    private func setUpButtons(){
        createAsset.setTitleColor(.white, for: .normal)
        createAsset.layer.cornerRadius = 10
        createAsset.layer.backgroundColor = UIColor.systemBlue.cgColor
        
        trackingModeSelector.apportionsSegmentWidthsByContent = true
        
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

    
    @IBAction func onFackGpsButtonChanged(_ sender: Any) {
        if #available(iOS 15.0, *) {
            assetTracking.setAllowFakeGps(allow: fakeGPS.isOn)
        } else {
            fakeGPS.isOn = true
        }
    }
    
    @IBAction func startTracking(_ sender: Any) {
        view.endEditing(true)
        let assetId = assetTracking.getAssetId()
        
        if (assetId.isEmpty){
            let toastView = ToastView(message: "Please bind asset first before start tracking!")
            toastView.show()
            return
        }
        _onlyTracking = "YES"
        checkLocationAuthorization(onlyTracking: true)
        
    }
    
    func checkLocationConfig() -> Bool {
        let locationConfig: LocationConfig
        switch selectedMode {
        case .ACTIVE, .BALANCED, .PASSIVE:
            locationConfig = LocationConfig(trackingMode: TrackingMode(rawValue: selectedMode.rawValue)!)
        case .DISTANCE_INTERVAL:
            if let distance = Double(customConfinInput.text ?? "") {
                locationConfig = LocationConfig(distanceFilter: distance)
            } else {
                let toastView = ToastView(message: "Please input valid distance interval")
                toastView.show()
                return false
            }
        }
        
        assetTracking.setLocationConfig(config: locationConfig)
        return true
    }
    
    func checkNotificationConfig() {
        let notificationConfig = NotificationConfig()
        print("===showAssetEnableNotification: \(startNotification.isOn)")
        notificationConfig.showAssetEnableNotification = startNotification.isOn
        notificationConfig.showAssetDisableNotification = stopNotification.isOn
        assetTracking.setNotificationConfig(config: notificationConfig)
    }
    
    @IBAction func stopTracking(_ sender: Any) {
        locationInfo.text = ""
        checkNotificationConfig()
        assetTracking.stopTracking()
        _onlyTracking = ""

    }
    
    
    @IBAction func onTrackingModeChanged(_ sender: Any) {
        switch trackingModeSelector.selectedSegmentIndex {
        case 0:
            selectedMode = .ACTIVE
        case 1:
            selectedMode = .BALANCED
        case 2:
            selectedMode = .PASSIVE
        case 3:
            customConfinInput.placeholder = "Distance in meters"
            selectedMode = .DISTANCE_INTERVAL
        default:
            break
        }
        customConfinInput.isHidden = selectedMode != .DISTANCE_INTERVAL
        
    }
    
    
    @IBAction func startTrip(_ sender: Any) {
        _onlyTracking = "NO"
        checkLocationAuthorization(onlyTracking: false)
        
    }
    
    @IBAction func stopTrip(_ sender: Any) {
        self.showLoadingIndicator()
        assetTracking.endTrip(){ tripId in
            self.hideLoadingIndicator()
        } errorHandler: { error in
            self.view.showToast(message: error.message, duration: 2)
            self.hideLoadingIndicator()
        }
        _onlyTracking = ""
    }
    
    func onTrackingStart(assetId: String) {
        updateTrackingStatus()
        
        assetTracking.getAssetDetail { asset in
            print("AssetInfo--------1 : \(asset.toDictionary())")
        } errorHandler: { error in
            print(error)
        }
        let profile = UpdateAssetProfile(name: "Test_qiu_asset_tracking")
        assetTracking.updateAsset(assetProfile: profile) { assetId in
            self.assetTracking.getAssetDetail { asset in
                print("AssetInfo-------- 2: \(asset.toDictionary())")
            } errorHandler: { error in
                print(error)
            }
        } errorHandler: { error in
            
        }



    }
    
    func onTrackingStop(assetId: String, trackingDisableType: TrackingDisableType) {
        updateTrackingStatus()
    }
    
    func formatTimestamp(_ timestamp: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .medium
        dateFormatter.timeZone = .current
        
        return dateFormatter.string(from: timestamp)
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
            Time: \(formatTimestamp(location.timestamp))
            """
    }
    
    func onTripStatusChanged(tripId: String, status: TripStatus) {
        updateTrackingStatus()
    
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
        trackingStatus.text = " Tracking Status: \(assetTracking.isRunning() ? "ON" : "OFF") \n Trip Status: \(assetTracking.isTripInProgress() ? "ON" : "OFF")"
    

        if !assetTracking.isRunning() {
            locationInfo.text = ""
            trackingModeSelector.isEnabled = true
            startTracking.layer.backgroundColor = UIColor.systemBlue.cgColor
            stopTracking.layer.backgroundColor = UIColor.grey_ececec.cgColor
            stopTracking.isEnabled = false
            startTracking.isEnabled = true
            customConfinInput.isEnabled = true
        } else {
            trackingModeSelector.isEnabled = false
            startTracking.layer.backgroundColor = UIColor.grey_ececec.cgColor
            stopTracking.layer.backgroundColor = UIColor.systemBlue.cgColor
            stopTracking.isEnabled = true
            startTracking.isEnabled = false
            customConfinInput.isEnabled = false
        }
        
        if assetTracking.isTripInProgress() {
            tripEndButton.layer.backgroundColor = UIColor.systemBlue.cgColor
            triptart.layer.backgroundColor = UIColor.grey_ececec.cgColor
            tripEndButton.isEnabled = true
            triptart.isEnabled = false
        }else {
            tripEndButton.layer.backgroundColor = UIColor.grey_ececec.cgColor
            triptart.layer.backgroundColor = UIColor.systemBlue.cgColor
            tripEndButton.isEnabled = false
            triptart.isEnabled = true

        }
    }
    
}

extension ExtendedTrackingViewController : UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
}


extension ExtendedTrackingViewController{
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
}

