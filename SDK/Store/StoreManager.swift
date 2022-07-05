//
//  StoreManager.swift
//  iOS-SDK
//
//  Created by Alberto Huerdo on 2019. 02. 21..
//  Copyright © 2019 SchedJoules. All rights reserved.
//

import Foundation
import SchedJoulesApiClient
import StoreKit

@objc public enum SJPurchaseModel: Int {
    case freeTrial
    case freeCalendar
    
    var trackingValue: String {
        get {
            switch self {
            case .freeTrial:
                return "free_trial"
            case .freeCalendar:
                return "free_calendar"
            }
        }
    }
}

public protocol InteractableStoreManager: AnyObject {
    func show(subscription: SubscriptionIAP?, product: SKProduct)
    func purchaseFinished()
    func purchaseFailed(errorDescription: String?)
}


public class StoreManager: NSObject {
    
    weak var presentable: InteractableStoreManager?
    
    /// The Api client.
    var apiClient: Api! {
        didSet {
            getStatusForSubscription()
        }
    }
    
    var productsRequest = SKProductsRequest()
    var iapProducts = [SKProduct]()
    var subscriptionIAP: SubscriptionIAP?
    var iapProduct: SKProduct?
    var isRestoringPurchases = false
    var restorePurchaseCompleted = false
    
    public var isSubscriptionValid: Bool {
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
    public static let shared = StoreManager()
    
    func Begin(){
        sjPrint("StoreManager initialized")
    }
    
    
    override init() {
        super.init()
        
        // Add pyament observer to payment queu
        SKPaymentQueue.default().add(self)
    }
    
    private func getStatusForSubscription() {
        guard let subscriptionId = UserDefaults.standard.subscriptionId else {
            return
        }
        let subscriptionStatusQuery = SubscriptionStatusQuery(subscriptionId: subscriptionId)
        apiClient.execute(query: subscriptionStatusQuery) { result in
            switch result {
            case let .success(resultInfo):
                UserDefaults.standard.subscriptionId = resultInfo.subscriptionId
                UserDefaults.standard.subscriptionExpirationDate = Date(timeIntervalSince1970: resultInfo.expirationDate)
            case let .failure(error):
                sjPrint(error)
                sjPrint(error.localizedDescription)
                break
            }
        }
    }
    
    func requestSubscriptionProducts(_ completion:@escaping (_ subscription: SubscriptionIAP?, _ error: ApiError?) -> Void) {
        let iapQuery = SubscriptionIAPQuery()
        apiClient.execute(query: iapQuery, completion: { result in
            switch result {
            case let .success(resultInfo):
                sjPrint("product for id: \(resultInfo.productId)")
                completion(resultInfo, nil)
                break
            case let .failure(error):
                completion(nil, error)
                break
            }
        })
    }
    
    func requestProductWithID(identifers:Set<String>, subscriptionIAP: SubscriptionIAP) {
        self.subscriptionIAP = subscriptionIAP
        
        if SKPaymentQueue.canMakePayments() {
            let request = SKProductsRequest(productIdentifiers: identifers)
            request.delegate = self
            request.start()
        } else {
            presentable?.purchaseFailed(errorDescription: "Store Not Available")
            sjPrint("ERROR: Store Not Available")
        }
    }
    
    func buyProduct(product: SKProduct) {
        self.iapProduct = product
        let payment = SKPayment(product: product)
        SKPaymentQueue.default().add(payment)
    }
    
    func restorePurchases() {
        //1.
        //If needed get the list of products from the backend
        if self.iapProduct != nil {
            SKPaymentQueue.default().restoreCompletedTransactions()
        } else {
            requestSubscriptionProducts { (result, error) in
                guard let validSubscriptionIAP = result,
                      error == nil else { return }
                
                //2.
                //get the product
                self.requestProductWithID(identifers: [validSubscriptionIAP.productId], subscriptionIAP: validSubscriptionIAP)
            }
        }
    }
    
    //Receipt
    func validateThroughApi(transaction: SKPaymentTransaction) {
        guard let validProduct = self.iapProduct else {
            SKPaymentQueue.default().finishTransaction(transaction)
            return
        }
        
        let receiptURL = Bundle.main.appStoreReceiptURL
        guard let receiptData = NSData(contentsOf: receiptURL!) else {
            SKPaymentQueue.default().finishTransaction(transaction)
            return
        }
        
        let receipt = receiptData.base64EncodedString(options: [])
        let subscriptionQuery = SubscriptionQuery(transaction: transaction,
                                                  product: validProduct,
                                                  receipt: receipt)
        apiClient.execute(query: subscriptionQuery, completion: { result in
            switch result {
            case let .success(resultInfo):
                UserDefaults.standard.subscriptionId = resultInfo.subscriptionId
                UserDefaults.standard.subscriptionExpirationDate = Date(timeIntervalSince1970: resultInfo.expirationDate)
            case let .failure(error):
                sjPrint(error)
                sjPrint(error.localizedDescription)
                break
            }
        })
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
        @unknown default:
            return Date()
        }
        
        var dayComponent = DateComponents()
        dayComponent.second = duration
        let expirationDate = Calendar.current.date(byAdding: dayComponent, to: Date())
        
        return expirationDate
    }
    
}


// MARK: SKProductsRequestDelegate

//The delegate receives the product information that the request was interested in.
extension StoreManager: SKProductsRequestDelegate{
    
    public func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        let products = response.products as [SKProduct]
        
        guard let firstProduct = products.first else {
            presentable?.purchaseFailed(errorDescription: "No product found")
            return
        }
        
        if isRestoringPurchases == false {
            presentable?.show(subscription: nil, product: firstProduct)
        } else {
            self.iapProduct = firstProduct
            SKPaymentQueue.default().restoreCompletedTransactions()
        }
    }
    
    public func request(_ request: SKRequest, didFailWithError error: Error) {
        presentable?.purchaseFailed(errorDescription: error.localizedDescription)
    }
}


// MARK: SKTransactions
extension StoreManager: SKPaymentTransactionObserver {
    
    public func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        if isRestoringPurchases == true {
            let allRestoreTransactions = transactions.filter({ $0.transactionState == .restored })
            let restoreTransactions = allRestoreTransactions.filter({ $0.payment.productIdentifier.hasPrefix("com.schedjoules") })
            let sortedTransactions = restoreTransactions.sorted(by: {
                let firstTimeInterval = $0.transactionDate?.timeIntervalSince1970 ?? 0
                let secondTimeInterval = $1.transactionDate?.timeIntervalSince1970 ?? 0
                
                return firstTimeInterval > secondTimeInterval
            })
            
            if let newestTransaction = sortedTransactions.first {
                restoreTransaction(transaction: newestTransaction)
            }
        } else {
            for transaction in transactions {
                switch (transaction.transactionState) {
                case .purchased:
                    completeTransaction(transaction: transaction)
                    break
                case .failed:
                    failedTransaction(transaction: transaction)
                    break
                case .restored:
                    //We already handled this scenario
                    completeTransaction(transaction: transaction)
                    break
                case .deferred:
                    //No need to handle
                    break
                case .purchasing:
                    //No need to handle
                    break
                @unknown default:
                    break
                }
            }
        }
    }
    
    public func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        if restorePurchaseCompleted == false {
            presentable?.purchaseFailed(errorDescription: "No transaction was restored")
        }
    }
    
    public func paymentQueue(_ queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: Error) {
        sjPrint("failed restoration")
        if error.localizedDescription == "Cannot connect to iTunes Store" {
            presentable?.purchaseFailed(errorDescription: nil)
        } else {
            presentable?.purchaseFailed(errorDescription: error.localizedDescription)
        }
    }
    
    
    //Helpers
    private func completeTransaction(transaction: SKPaymentTransaction) {
        sjPrint("completeTransaction...")
        
        validateThroughApi(transaction: transaction)
        
        guard let productPurchased = iapProduct else { return }
        
        let expirationDate = self.expirationDate(for: productPurchased)
        UserDefaults.standard.subscriptionExpirationDate = expirationDate
        
        deliverPurchaseForIdentifier(identifier: transaction.payment.productIdentifier)
        
        SKPaymentQueue.default().finishTransaction(transaction)
    }
    
    private func restoreTransaction(transaction: SKPaymentTransaction) {
        sjPrint("restoreTransaction...")
        
        validateThroughApi(transaction: transaction)
        
        guard let productIdentifier = transaction.original?.payment.productIdentifier else { return }
        
        sjPrint("restoreTransaction... \(productIdentifier)")
        
        deliverPurchaseForIdentifier(identifier: productIdentifier)
        restorePurchaseCompleted = true
        SKPaymentQueue.default().finishTransaction(transaction)
    }
    
    private func failedTransaction(transaction: SKPaymentTransaction) {
        var errorDescription: String?
        
        if let error = transaction.error as NSError? {
            sjPrint(error.localizedDescription)
            if error.domain == SKErrorDomain {
                // handle all possible errors
                switch (error.code) {
                case SKError.unknown.rawValue:
                    errorDescription = error.localizedDescription
                case SKError.clientInvalid.rawValue:
                    errorDescription = "Client is not allowed to issue the request"
                case SKError.paymentCancelled.rawValue:
                    errorDescription = "User cancelled the request"
                case SKError.paymentInvalid.rawValue:
                    errorDescription = "Purchase identifier was invalid"
                case SKError.paymentNotAllowed.rawValue:
                    errorDescription = "This device is not allowed to make the payment"
                default:
                    errorDescription = "Unknown error"
                    break;
                }
            }
        }
        
        presentable?.purchaseFailed(errorDescription: errorDescription)
        SKPaymentQueue.default().finishTransaction(transaction)
    }
    
    private func deliverPurchaseForIdentifier(identifier: String?) {
        presentable?.purchaseFinished()
    }
    
}


//In-App Purchases App Store
extension StoreManager{
    
    public func paymentQueue(_ queue: SKPaymentQueue, shouldAddStorePayment payment: SKPayment, for product: SKProduct) -> Bool {
        return true
    }
    
}


// MARK: StoreKit 2
@available(iOS 15.0, *)
extension StoreManager {
    
    func getCurrentProducts() async throws -> [Transaction.Transactions.Element] {
        print(":::: ", Transaction.currentEntitlements)
        for await result in Transaction.currentEntitlements {
            print("currentEntitlements: ", result)
        }
        let currentEntitlements = await Transaction.currentEntitlements.collect()
        return currentEntitlements
    }
    
    func manageSubscriptionsPage(from view: UIView) async {
        // Fetch the current scene, then attempt to show the sheet. If there was an issue, print the error.
        if let scene = await view.window?.windowScene {
            do {
                try  await AppStore.showManageSubscriptions(in: scene)
            } catch {
                print("Error:(error)")
            }
        }
    }
    
}


@available(iOS 13.0, *)
extension AsyncSequence {
    func collect() async rethrows -> [Element] {
        try await reduce(into: [Element]()) { $0.append($1) }
    }
}
