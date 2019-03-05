//
//  StoreManager.swift
//  iOS-SDK
//
//  Created by Alberto Huerdo on 2/21/19.
//  Copyright © 2019 SchedJoules. All rights reserved.
//

import Foundation
import SchedJoulesApiClient
import StoreKit
import Alamofire

protocol InteractableStoreManager: class {
    func show(subscription: SubscriptionIAP?, product: SKProduct)
    func showNoProductsAlert()
    func finishPurchase()
    func purchaseFailed(errorDescription: String?)
}


class StoreManager: NSObject {
    
    weak var presentable: InteractableStoreManager?
    
    let apiKey = SJSecureStorage(type: .api).apiKey
    var productsRequest = SKProductsRequest()
    var iapProducts = [SKProduct]()
    var subscriptionIAP: SubscriptionIAP?
    var iapProduct: SKProduct?
    
    var isSubscriptionValid: Bool {
        get {
            guard let expirationDate = UserDefaults.standard.subscriptionExpirationDate else {
                return false
            }
            //If the expiration date is bigger than the current date then we can assume the user's subscription is still valid
            return expirationDate > Date()
        }
    }
    
    /**
     Initialize StoreManager and load subscriptions SKProducts from Store
     */
    static let shared = StoreManager()
    
    func Begin(){
        print("StoreManager initialized")
    }
    
    
    override init() {
        super.init()
        
        // Add pyament observer to payment qu
        SKPaymentQueue.default().add(self)
    }
    
    func requestProductWithID(identifers:Set<String>, subscriptionIAP: SubscriptionIAP) {
        self.subscriptionIAP = subscriptionIAP
        
        if SKPaymentQueue.canMakePayments() {
            let request = SKProductsRequest(productIdentifiers:
                identifers)
            request.delegate = self
            request.start()
            
            
        } else {
            print("ERROR: Store Not Available")
        }
        
        
    }
    
    func buyProduct(product: SKProduct) {
        self.iapProduct = product
        let payment = SKPayment(product: product)
        SKPaymentQueue.default().add(payment)
    }
    
    
    func restorePurchases(){
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
    /*
     Instance variables
     
     */
    //Receipt
    func validateInServer(transaction: SKPaymentTransaction) {
        let receiptURL = Bundle.main.appStoreReceiptURL
        
        guard let receipt = NSData(contentsOf: receiptURL!) else {
            return
        }
        
        
        print( self.subscriptionIAP)
        guard let validSubscriptionIAP = self.subscriptionIAP else {
            return
        }
        
        print(self.iapProduct?.subscriptionPeriod)
        print(self.iapProduct?.subscriptionPeriod?.unit)
        print(self.iapProduct?.subscriptionPeriod?.unit.rawValue)
        print(self.iapProduct?.subscriptionPeriod?.unit.hashValue)
        print(self.iapProduct?.subscriptionPeriod?.numberOfUnits)
        
        
        
        let receiptData = receipt.base64EncodedString(options: [])
        let transactionId = transaction.transactionIdentifier ?? ""
        let purchaseDateValid = transaction.transactionDate ?? Date()
        let purchaseDate = Int(purchaseDateValid.timeIntervalSince1970)
        let productId = validSubscriptionIAP.productId
        let pricingLocale = iapProduct?.priceLocale.currencyCode ?? "" //=> {"type" => "string", "minLength" => 1, "maxLength" => 3},
        let pricing = iapProduct?.price.description(withLocale: nil) ?? "" // => {"type" => "string", "minLength" => 1, "maxLength" => 200},
        let formattedPrice = subscriptionIAP?.localizedPriceInfo ?? ""
        let transactionDictionary = [
            "transactions": [
                "transactionId" : transactionId,
                "purchaseDate" : purchaseDate,
                "productId" : productId,
                "quantity" : 1,
                "pricingLocale" : pricingLocale,
                "pricing" : pricing,
                "formattedPrice" : formattedPrice
            ]
        ]
        let requestContents: [String: Any] = [
            "receipt-data": receiptData,
            "transactions": transactionDictionary
        ]
        
        DispatchQueue.global(qos: .background).async {
            let stringURL = "https://api.schedjoules.com/subscription"
            guard let url = URL(string: stringURL) else {
                sjPrint("url isn't valid")
                return
            }
            
            var urlRequest = URLRequest(url: url)
            urlRequest.httpMethod = "POST"
            urlRequest.setHeaders(for: .analytics, apiKey: self.apiKey)
            
            do {
                urlRequest.httpBody = try JSONSerialization.data(withJSONObject: requestContents, options: .prettyPrinted)
            } catch let error {
                sjPrint(error.localizedDescription)
            }
            
            
            let session = URLSession.shared
            
            let task = session.dataTask(with: urlRequest) {
                (data, response, error) in
                // check for any errors
                
                if let error = error {
                    sjPrint("error:", error)
                    return
                }
                
                guard let result = response as? HTTPURLResponse else {
                    sjPrint("no response")
                    return
                }
                
                print(result)
                
                guard let data = data else { return }
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [AnyHashable : Any]
                    
                    guard let receipts = json["latest_receipt_info"] as? [[AnyHashable : Any]] else { print("nothing here")
                        return
                    }
                    
                    if let status = json["status"] as? Int,
                        status == 0 {
                        SKPaymentQueue.default().finishTransaction(transaction)
                        self.presentable?.finishPurchase()
                    } else {
                        fatalError("bad status")
                    }
                    
                    for dict in receipts {
                        print(dict)
                    }
                } catch let error as NSError {
                    print(error)
                }
            }
            
            task.resume()
        }
    }
    
    private func expirationDate(for product: SKProduct) -> Date? {
        guard let period = product.subscriptionPeriod else {
            return nil
        }
        
        var debug = false
        #if DEBUG
        debug = true
        #endif
        
        var duration = 0
        let numberOfUnits = period.numberOfUnits
        
        switch period.unit {
        case .day:
            duration = debug == false ? (1 * 24 * 60 * 60 * numberOfUnits) : 3 * 60
        case .week:
            duration = debug == false ? (7 * 24 * 60 * 60 * numberOfUnits) : 3 * 60
        case .month:
            duration = debug == false ? (30 * 24 * 60 * 60 * numberOfUnits) : 5 * numberOfUnits
        case .year:
            duration = debug == false ? (365 * 24 * 60 * 60 * numberOfUnits) : 60 * 60
        }
        
        var dayComponent = DateComponents()
        dayComponent.second = duration
        let expirationDate = Calendar.current.date(byAdding: dayComponent, to: Date())
        
        return expirationDate
    }
    
}


// MARK:
// MARK: SKProductsRequestDelegate

//The delegate receives the product information that the request was interested in.
extension StoreManager:SKProductsRequestDelegate{
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        let products = response.products as [SKProduct]
        
        guard let firstProduct = products.first else { return }
        
        presentable?.show(subscription: nil, product: firstProduct)
    }
    
    
    func request(_ request: SKRequest, didFailWithError error: Error) {
        print("Something went wrong: \(error.localizedDescription)")
    }
}


// MARK:
// MARK: SKTransactions
extension StoreManager: SKPaymentTransactionObserver {
    
    public func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch (transaction.transactionState) {
            case .purchased:
                completeTransaction(transaction: transaction)
                break
            case .failed:
                failedTransaction(transaction: transaction)
                break
            case .restored:
                restoreTransaction(transaction: transaction)
                break
            case .deferred:
                // TODO show user that is waiting for approval
                
                break
            case .purchasing:
                break
            }
        }
    }
    
    private func completeTransaction(transaction: SKPaymentTransaction) {
        
        print("completeTransaction...")
        
        SKPaymentQueue.default().finishTransaction(transaction)
        validateInServer(transaction: transaction)
        
        guard let productPurchased = iapProduct else { return }
        
        let expirationDate = self.expirationDate(for: productPurchased)
        UserDefaults.standard.subscriptionExpirationDate = expirationDate
        
        deliverPurchaseForIdentifier(identifier: transaction.payment.productIdentifier)
    }
    
    private func restoreTransaction(transaction: SKPaymentTransaction) {
        
        
        guard let productIdentifier = transaction.original?.payment.productIdentifier else { return }
        
        print("restoreTransaction... \(productIdentifier)")
        
        
        deliverPurchaseForIdentifier(identifier: productIdentifier)
        SKPaymentQueue.default().finishTransaction(transaction)
    }
    
    private func failedTransaction(transaction: SKPaymentTransaction) {
        
        var errorDescription: String?
        
        if let error = transaction.error as NSError? {
            if error.domain == SKErrorDomain {
                // handle all possible errors
                switch (error.code) {
                case SKError.unknown.rawValue:
                    errorDescription = "Unknown error"
                case SKError.clientInvalid.rawValue:
                    errorDescription = "Client is not allowed to issue the request"
                case SKError.paymentCancelled.rawValue:
                    errorDescription = "User cancelled the request"
                case SKError.paymentInvalid.rawValue:
                    errorDescription = "Purchase identifier was invalid"
                case SKError.paymentNotAllowed.rawValue:
                    errorDescription = "This device is not allowed to make the payment"
                default:
                    break;
                }
            }
        }
        
        presentable?.purchaseFailed(errorDescription: errorDescription)
        SKPaymentQueue.default().finishTransaction(transaction)
    }
    
    private func deliverPurchaseForIdentifier(identifier: String?) {
        presentable?.finishPurchase()
    }
    
}



//In-App Purchases App Store
extension StoreManager{
    
    func paymentQueue(_ queue: SKPaymentQueue, shouldAddStorePayment payment: SKPayment, for product: SKProduct) -> Bool {
        return true
        
        //To hold
        //return false
        
        //And then to continue
        //SKPaymentQueue.default().add(savedPayment)
    }
    
}
