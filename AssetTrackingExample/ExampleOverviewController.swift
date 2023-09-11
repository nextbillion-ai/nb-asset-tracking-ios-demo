//
// Copyright © 2023 NextBillion.ai. All rights reserved.
// Use of this source code is governed by license that can be found in the LICENSE file.
//


import Foundation
import UIKit

class ExampleOverviewController: UITableViewController {
    
    let examples: [String: [ViewModel]] = [
        "Asset Tracking Examples":[
            ViewModel(name: "Simple Tracking", viewController: SimpleTrackingViewController.self, storyboardIdentifier: "SimpleTrackingViewController"),
            ViewModel(name: "Asset Related Operations", viewController: AssetOperationViewController.self, storyboardIdentifier: "AssetOperationViewController"),
            ViewModel(name: "Get Asset Tracking Callback", viewController: GetAssetCallbackViewController.self, storyboardIdentifier: "GetAssetCallbackViewController"),
            ViewModel(name: "Update Configurations", viewController: UpdateConfigurationViewController.self, storyboardIdentifier: "UpdateConfigurationViewController"),
            ViewModel(name: "Extended Tracking Example", viewController: ExtendedTrackingViewController.self, storyboardIdentifier: "ExtendedTrackingViewController"),
        ]
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return examples.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionKey = Array(examples.keys)[section]
        return examples[sectionKey]?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let sectionKey = Array(examples.keys)[section]
        return sectionKey
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = "tableViewCell"
        var cell: UITableViewCell? = tableView.dequeueReusableCell(withIdentifier: identifier)
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: identifier)
        }
        
        let sectionKey = Array(examples.keys)[indexPath.section]
        if let viewModels = examples[sectionKey], indexPath.row < viewModels.count {
            cell?.textLabel?.text = viewModels[indexPath.row].name
        }
        
        cell?.textLabel?.numberOfLines = 0
        
        return cell!
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let sectionKey = Array(examples.keys)[indexPath.section]
        if let viewModels = examples[sectionKey], indexPath.row < viewModels.count {
            let viewModel = viewModels[indexPath.row]
            
            // Load the destination view controller from the storyboard
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let destinationViewController = storyboard.instantiateViewController(withIdentifier: viewModel.storyboardIdentifier)
            
            // Push to the destination view controller
            self.navigationController?.pushViewController(destinationViewController, animated: true)
            
        }
    }
}
