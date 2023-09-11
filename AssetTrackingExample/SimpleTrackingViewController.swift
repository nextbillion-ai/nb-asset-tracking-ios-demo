//
// Copyright © 2023 NextBillion.ai. All rights reserved.
// Use of this source code is governed by license that can be found in the LICENSE file.
//


import Foundation
import UIKit
import NBAssetTracking

class SimpleTrackingViewController: UIViewController {
    @IBOutlet weak var startTracking: UIButton!
    @IBOutlet weak var assetId: UILabel!
    @IBOutlet weak var trackingStatus: UILabel!
    
    private var mAssetId: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let dataTrackingConfig = DataTrackingConfig(baseUrl: Constants.DEFAULT_BASE_URL, dataStorageSize: 5000, dataUploadingBatchSize: 30, dataUploadingBatchWindow: 20, shouldClearLocalDataWhenCollision: true)
        AssetTracking.shared.setDataTrackingConfig(config: dataTrackingConfig)
        AssetTracking.shared.initialize(apiKey: Constants.DEFAULT_API_KEY)
        
        initView()
        
        createAsset()
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
    
    func initView() {
        startTracking.addTarget(self, action: #selector(bindAssetAndStartTracking), for: .touchUpInside)
        assetId.text = ""
        trackingStatus.text = ""
    }
    
    func createAsset(){
        let attributes = ["attribute 1": "test 1", "attribute 2": "test 2"]
        let assetProfile: AssetProfile = AssetProfile.init(customId: UUID().uuidString.lowercased(), assetDescription: "testDescription", name: "testName", attributes: attributes)
        
        NBAssetTrackingApiFetcher.shared.createAsset(assetProfile: assetProfile) { assetCreationResponse in
            let assetId = assetCreationResponse.data.id
            
            let toastView = ToastView(message: "Create asset successfully with id: " + assetId)
            toastView.show()
            
            self.mAssetId = assetId
            self.assetId.text = "asset id is: " + assetId
        } errorHandler: { error in
            let errorMessage = error.localizedDescription
            let toastView = ToastView(message: "Create asset failed: " + errorMessage)
            toastView.show()
        }
    }
    
    @objc func bindAssetAndStartTracking() {
        NBAssetTrackingApiFetcher.shared.bindAsset(assetId: mAssetId) { responseCode in
            let toastView = ToastView(message: "Bind asset successfully with id: " + self.mAssetId)
            toastView.show()
            AssetTracking.shared.startTracking()
            self.trackingStatus.text = "Asset Tracking is running"
        } errorHandler: { error in
            let errorMessage = error.localizedDescription
            let toastView = ToastView(message: "Bind asset failed: " + errorMessage)
            toastView.show()
        }
    }
}
