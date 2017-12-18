//
//  SubscriptionTVC.swift
//  PurchaseDemo
//
//  Created by Sujan Vaidya on 12/18/17.
//  Copyright © 2017 Sujan Vaidya. All rights reserved.
//

import UIKit
import StoreKit

enum ProductType: String {
    case product1 = "com.sujanvaidya.PurchaseDemo.spd1"
    case product2 = "com.sujanvaidya.PurchaseDemo.spd2"
    case product3 = "com.sujanvaidya.PurchaseDemo.spd3"
    
    static var all: [ProductType] {
        return [.product1, .product2, .product3]
    }
}

enum InAppErrors: Swift.Error {
    case noSubscriptionPurchased
    case noProductsAvailable
    
    var localizedDescription: String {
        switch self {
        case .noSubscriptionPurchased:
            return "No subscription purchased"
        case .noProductsAvailable:
            return "No products available"
        }
    }
}

protocol InAppManagerDelegate: class {
    func inAppLoadingStarted()
    func inAppLoadingSucceded(productType: ProductType)
    func inAppLoadingFailed(error: Swift.Error?)
    func subscriptionStatusUpdated(value: Bool)
}

class SubscriptionTVC: UITableViewController {
    
    weak var delegate: InAppManagerDelegate?
    
    var products: [SKProduct]!
    
    var isTrialPurchased: Bool?
    var expirationDate: Date?
    var purchasedProduct: ProductType?
    var isRefreshingReceipt = false
    var error: NSError?
    
    var isSubscriptionAvailable: Bool = true
    {
        didSet(value) {
            self.delegate?.subscriptionStatusUpdated(value: value)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return products.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ProductCell", for: indexPath) as? ProductCell else { return UITableViewCell() }
        cell.name.text = products[indexPath.row].localizedTitle
        cell.price.text = String(describing: products[indexPath.row].price)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let productType = ProductType(rawValue: self.products[indexPath.row].productIdentifier)
        purchaseProduct(productType: productType!)
    }
    
    func purchaseProduct(productType: ProductType) {
        guard let product = self.products.filter({$0.productIdentifier == productType.rawValue}).first else {
            self.delegate?.inAppLoadingFailed(error: InAppErrors.noProductsAvailable)
            return
        }
        let payment = SKMutablePayment(product: product)
        SKPaymentQueue.default().add(payment)
        startMonitoring()
    }
    
    func startMonitoring() {
        SKPaymentQueue.default().add(self)
    }
    
}

extension SubscriptionTVC: SKPaymentTransactionObserver {
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        //        for transaction in transactions {
        //            guard let productType = ProductType(rawValue: transaction.payment.productIdentifier) else {fatalError()}
        //            switch transaction.transactionState {
        //            case .purchasing:
        //                self.delegate?.inAppLoadingStarted()
        //            case .purchased:
        //                SKPaymentQueue.default().finishTransaction(transaction)
        //                self.isSubscriptionAvailable = true
        //                self.delegate?.inAppLoadingSucceded(productType: productType)
        //            case .failed:
        //                if let transactionError = transaction.error as NSError?,
        //                    transactionError.code != SKError.paymentCancelled.rawValue {
        //                    self.delegate?.inAppLoadingFailed(error: transaction.error)
        //                } else {
        //                    self.delegate?.inAppLoadingFailed(error: InAppErrors.noSubscriptionPurchased)
        //                }
        //                SKPaymentQueue.default().finishTransaction(transaction)
        //            case .restored:
        //                SKPaymentQueue.default().finishTransaction(transaction)
        //                self.isSubscriptionAvailable = true
        //                self.delegate?.inAppLoadingSucceded(productType: productType)
        //            case .deferred:
        //                self.delegate?.inAppLoadingSucceded(productType: productType)
        //            }
        //        }
        
        for transaction: AnyObject in transactions {
            
            if let trans:SKPaymentTransaction = transaction as? SKPaymentTransaction {
                
                switch trans.transactionState {
                case .purchased:
                    SKPaymentQueue.default().finishTransaction(trans)
                    if let receiptURL = Bundle.main.appStoreReceiptURL, FileManager.default.fileExists(atPath: receiptURL.path) {
                        ReceiptValidator.receiptValidation()
                        print("Expiration date of latest subscription is: ", expirationDate)
                    } else {
                        if !isRefreshingReceipt {
                            let request = SKReceiptRefreshRequest(receiptProperties: nil)
                            request.delegate = self
                            request.start()
                        }
                    }
                    break
                    
                case .failed:
                    SKPaymentQueue.default().finishTransaction(trans)
                    SKPaymentQueue.default().remove(self)
                    break
                    
                default:
                    break
                    
                }
            }
        }
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: Swift.Error) {
        self.delegate?.inAppLoadingFailed(error: error)
    }
    
}

extension SubscriptionTVC: SKRequestDelegate {
    
    func requestDidFinish(_ request: SKRequest) {
        if let appStoreReceiptURL = Bundle.main.appStoreReceiptURL,
            FileManager.default.fileExists(atPath: appStoreReceiptURL.path) {
            ReceiptValidator.receiptValidation()
        }
    }
}
