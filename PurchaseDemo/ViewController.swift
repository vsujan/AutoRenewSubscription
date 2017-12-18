//
//  ViewController.swift
//  PurchaseDemo
//
//  Created by Sujan Vaidya on 12/18/17.
//  Copyright © 2017 Sujan Vaidya. All rights reserved.
//

import UIKit
import StoreKit

class ViewController: UIViewController {
    var activityIndicator = UIActivityIndicatorView()
    
    var products: [SKProduct] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func loadSubsctiptions(_ sender: UIButton) {
        loadProducts()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // 1
    func loadProducts() {
        let productIdentifiers = Set<String>(ProductType.all.map({$0.rawValue}))
        let request = SKProductsRequest(productIdentifiers: productIdentifiers)
        request.delegate = self
        request.start()
        
        activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        activityIndicator.frame = CGRect(x: self.view.frame.width/2 - 25, y: self.view.frame.height/2 - 25, width: 50, height: 50)
        activityIndicator.startAnimating()
        self.view.addSubview(activityIndicator)
    }
    
}

//MARK: - SKProducatsRequestDelegate
extension ViewController: SKProductsRequestDelegate {
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        guard response.products.count > 0 else {return}
        self.products = response.products
        activityIndicator.stopAnimating()
        activityIndicator.removeFromSuperview()
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let subscriptionTVC = storyboard.instantiateViewController(withIdentifier: "SubscriptionTVC") as! SubscriptionTVC
        subscriptionTVC.products = self.products
        self.navigationController?.pushViewController(subscriptionTVC, animated: true)
    }
}
