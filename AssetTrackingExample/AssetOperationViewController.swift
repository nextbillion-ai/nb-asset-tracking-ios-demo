//
// Copyright © 2023 NextBillion.ai. All rights reserved.
// Use of this source code is governed by license that can be found in the LICENSE file.
//


import Foundation
import UIKit
import NBAssetTracking

class AssetOperationViewController: UIViewController {
    @IBOutlet weak var createNewAssetBtn: UIButton!
    @IBOutlet weak var bindAssetBtn: UIButton!
    @IBOutlet weak var updateAssetBtn: UIButton!
    @IBOutlet weak var getAssetInfoBtn: UIButton!
    @IBOutlet weak var assetInfo: UILabel!
    
    private var assetId = ""
    private var assetName = "testName"
    private var assetDescription = "testDescription"
    private var assetAttributes = ["attribute 1": "test 1", "attribute 2": "test 2"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let dataTrackingConfig = DataTrackingConfig(baseUrl: Constants.DEFAULT_BASE_URL, dataStorageSize: 5000, dataUploadingBatchSize: 30, dataUploadingBatchWindow: 20, shouldClearLocalDataWhenCollision: true)
        AssetTracking.shared.setDataTrackingConfig(config: dataTrackingConfig)
        AssetTracking.shared.initialize(apiKey: Constants.DEFAULT_API_KEY)
        
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
        createNewAssetBtn.addTarget(self, action: #selector(createAsset), for: .touchUpInside)
        bindAssetBtn.addTarget(self, action: #selector(bindAsset), for: .touchUpInside)
        updateAssetBtn.addTarget(self, action: #selector(updateAsset), for: .touchUpInside)
        getAssetInfoBtn.addTarget(self, action: #selector(getAssetInfo), for: .touchUpInside)
        assetInfo.text = ""
    }
    
    @objc func createAsset(){
        let assetProfile: AssetProfile = AssetProfile.init(customId: UUID().uuidString.lowercased(), assetDescription: assetDescription, name: assetName, attributes: assetAttributes)
        
        AssetTracking.shared.createAsset(assetProfile: assetProfile) { assetCreationResponse in
            let assetId = assetCreationResponse.data.id
            self.assetId = assetId
            
            let toastView = ToastView(message: "Create asset successfully with id: " + self.assetId)
            toastView.show()
            
            do {
                let encoder = JSONEncoder()
                let jsonData = try encoder.encode(assetProfile)
                if let jsonString = String(data: jsonData, encoding: .utf8) {
                    self.assetInfo.text = jsonString
                }
            } catch {
                print("Error encoding JSON: \(error)")
            }
            
        } errorHandler: { error in
            let errorMessage = error.message
            let toastView = ToastView(message: "Create asset failed: " + errorMessage)
            toastView.show()
        }
    }
    
    @objc func bindAsset(){
        AssetTracking.shared.bindAsset(assetId: self.assetId) { responseCode in
            let toastView = ToastView(message: "Bind asset successfully with id: " + self.assetId)
            toastView.show()
        } errorHandler: { error in
            let errorMessage = error.message
            let toastView = ToastView(message: "Bind asset failed: " + errorMessage)
            toastView.show()
        }
    }
    
    @objc func updateAsset() {
        assetName = "newName"
        assetDescription = "newDescription"
        
        let assetProfile: AssetProfile = AssetProfile.init(customId: assetId, assetDescription: assetDescription, name: assetName, attributes: assetAttributes)
        
        AssetTracking.shared.updateAsset(assetProfile: assetProfile) {responseCode in
            let toastView = ToastView(message: "update asset profile successfully with id: " + self.assetId)
            toastView.show()
            
            do {
                let encoder = JSONEncoder()
                let jsonData = try encoder.encode(assetProfile)
                if let jsonString = String(data: jsonData, encoding: .utf8) {
                    self.assetInfo.text = jsonString
                }
            } catch {
                print("Error encoding JSON: \(error)")
            }
            
        } errorHandler: {
            error in
            let errorMessage = error.localizedDescription
            let toastView = ToastView(message: "Update asset profile failed: " + errorMessage)
            toastView.show()
        }
    }
    
    @objc func getAssetInfo(){
        AssetTracking.shared.getAssetDetail(){getAssetResponse in
            let data: GetAssetResponseData = getAssetResponse.data
            do {
                let encoder = JSONEncoder()
                let jsonData = try encoder.encode(data)
                if let jsonString = String(data: jsonData, encoding: .utf8) {
                    self.assetInfo.text = jsonString
                }
            } catch {
                print("Error encoding JSON: \(error)")
            }
        } errorHandler: { error in
            let errorMessage = error.message
            let toastView = ToastView(message: "Get asset profile failed: " + errorMessage)
            toastView.show()
        }
    }
    
    
}
