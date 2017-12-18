//
//  Utils.swift
//  PurchaseDemo
//
//  Created by Sujan Vaidya on 12/18/17.
//  Copyright © 2017 Sujan Vaidya. All rights reserved.
//

import UIKit

struct ReceiptValidator {
    
    static func receiptValidation() {
        let SUBSCRIPTION_SECRET = "dafbf64857884776b1b1cc7f453cb176"
        let receiptPath = Bundle.main.appStoreReceiptURL?.path
        if FileManager.default.fileExists(atPath: receiptPath!){
            var receiptData:NSData?
            do{
                receiptData = try NSData(contentsOf: Bundle.main.appStoreReceiptURL!, options: NSData.ReadingOptions.alwaysMapped)
            }
            catch{
                print("ERROR: " + error.localizedDescription)
            }
            //let receiptString = receiptData?.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
            let base64encodedReceipt = receiptData?.base64EncodedString(options: NSData.Base64EncodingOptions.endLineWithCarriageReturn)
            
            let requestDictionary = ["receipt-data":base64encodedReceipt!,"password":SUBSCRIPTION_SECRET]
            
            guard JSONSerialization.isValidJSONObject(requestDictionary) else {  print("requestDictionary is not valid JSON");  return}
            do {
                let requestData = try JSONSerialization.data(withJSONObject: requestDictionary)
                let validationURLString = "https://sandbox.itunes.apple.com/verifyReceipt"  // this works but as noted above it's best to use your own trusted server
                guard let validationURL = URL(string: validationURLString) else { print("the validation url could not be created, unlikely error"); return}
                let session = URLSession(configuration: URLSessionConfiguration.default)
                var request = URLRequest(url: validationURL)
                request.httpMethod = "POST"
                request.cachePolicy = URLRequest.CachePolicy.reloadIgnoringCacheData
                let task = session.uploadTask(with: request, from: requestData) { (data, response, error) in
                    if let data = data , error == nil {
                        do {
                            let appReceiptJSON = try JSONSerialization.jsonObject(with: data)
                            let expirationDate = self.expirationDateFromResponse(jsonResponse: appReceiptJSON as! NSDictionary)
                            print(expirationDate)
                        } catch let error as NSError {
                            print("json serialization failed with error: \(error)")
                        }
                    } else {
                        print("the upload task returned an error: \(error)")
                    }
                }
                task.resume()
            } catch let error as NSError {
                print("json serialization failed with error: \(error)")
            }
            
            
        }
    }
    
    static func expirationDateFromResponse(jsonResponse: NSDictionary) -> NSDate? {
        
        if let receiptInfo: NSArray = jsonResponse["latest_receipt_info"] as? NSArray {
            let lastReceipt = receiptInfo.lastObject as! NSDictionary
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss VV"
            let expirationDate: NSDate =
                formatter.date(from: lastReceipt["expires_date"] as! String) as NSDate!
            return expirationDate
        } else {
            return nil
        }
    }

}
