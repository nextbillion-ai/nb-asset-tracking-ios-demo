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
        if #available(iOS 15.0, *) {
            AssetTracking.shared.setAllowFakeGps(allow: true)
        } else {
            // Fallback on earlier versions
        }
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
        let assetProfile: AssetProfile = AssetProfile.init(name: "testName", customId: UUID().uuidString.lowercased(), description: "testDescription", attributes: attributes)
        
        AssetTracking.shared.createAsset(assetProfile: assetProfile) { assetId in
            let toastView = ToastView(message: "Create asset successfully with id: " + assetId)
            toastView.show()
            
            self.mAssetId = assetId
            self.assetId.text = "asset id is: " + assetId
        } errorHandler: { error in
            let errorMessage = error.message
            let toastView = ToastView(message: "Create asset failed: " + errorMessage)
            toastView.show()
        }
    }
    
    @objc func bindAssetAndStartTracking() {
        AssetTracking.shared.bindAsset(assetId: mAssetId) { responseCode in
            let toastView = ToastView(message: "Bind asset successfully with id: " + self.mAssetId)
            toastView.show()
            AssetTracking.shared.startTracking()
            self.trackingStatus.text = "Asset Tracking is running"
        } errorHandler: { error in
            let errorMessage = error.message
            let toastView = ToastView(message: "Bind asset failed: " + errorMessage)
            toastView.show()
        }
    }
}
