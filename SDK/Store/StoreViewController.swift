//
//  StoreViewController.swift
//  iOS-SDK
//
//  Created by Alberto Huerdo on 2019. 02. 21..
//  Copyright © 2019 SchedJoules. All rights reserved.
//

import UIKit
import SchedJoulesApiClient
import StoreKit

class StoreViewController: UIViewController {
    
    /// The Api client.
    private let apiClient: Api
    var storeManager = StoreManager.shared
    var subscriptionIAP: SubscriptionIAP?
    var product: SKProduct?
    
    
    var closeButton: UIButton = {
        var button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("x", for: .normal)
        button.addTarget(self, action: #selector(tapCloseButton), for: .touchUpInside)
        return button
    }()
    
    var titleLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "FREE TRIAL"
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        return label
    }()
    
    var subTitleLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "enjoy our 1 month free trial and get full access to all available calendars"
        label.numberOfLines = 0
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()
    
    var imageView: UIImageView = {
        let image = UIImage(named: "purchase-intro-1")
        let imageView = UIImageView(image: image)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    var bottomView: UIView = {
        let view = UIView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .sjGrayLight
        return view
    }()
    
    var purchaseButton: UIButton = {
        var button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Purchase", for: .normal)
        button.addTarget(self, action: #selector(tapPurchaseButton), for: .touchUpInside)
        button.backgroundColor = .sjBlueLight
        button.alpha = 0.0
        return button
    }()
    
    var priceLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Billed at 4534 per year there after"
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.alpha = 0.0
        return label
    }()
    
    var mainActivityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView(frame: .zero)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.activityIndicatorViewStyle = .whiteLarge
        activityIndicator.hidesWhenStopped = true
        activityIndicator.color = .blue
        return activityIndicator
    }()
    
    var productActivityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView(frame: .zero)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.activityIndicatorViewStyle = .whiteLarge
        activityIndicator.hidesWhenStopped = true
        activityIndicator.color = .blue
        activityIndicator.startAnimating()
        return activityIndicator
    }()
    
    
    init(apiClient: Api) {
        self.apiClient = apiClient
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupProperties()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.setNeedsStatusBarAppearanceUpdate()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func setupProperties() {
        storeManager.apiClient = self.apiClient
        storeManager.presentable = self
        
        storeManager.requestSubscriptionProducts { (result, error) in
            guard let validSubscriptionIAP = result,
                error == nil else { return }
            
            self.subscriptionIAP = validSubscriptionIAP
            self.storeManager.requestProductWithID(identifers: [validSubscriptionIAP.productId], subscriptionIAP: validSubscriptionIAP)
        }
    }
    
    func setupUI() {
        view.backgroundColor = .sjBlue
        
        view.addSubview(closeButton)
        view.addSubview(titleLabel)
        view.addSubview(subTitleLabel)
        view.addSubview(imageView)
        view.addSubview(bottomView)
        view.addSubview(mainActivityIndicator)
        
        bottomView.addSubview(purchaseButton)
        bottomView.addSubview(priceLabel)
        bottomView.addSubview(productActivityIndicator)
        
        let layoutGuide = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            
            closeButton.heightAnchor.constraint(equalToConstant: 44),
            closeButton.widthAnchor.constraint(equalTo: closeButton.heightAnchor),
            closeButton.topAnchor.constraint(equalTo: layoutGuide.topAnchor, constant: 10),
            closeButton.leadingAnchor.constraint(equalTo: layoutGuide.leadingAnchor, constant: 10),
            
            titleLabel.topAnchor.constraint(equalTo: closeButton.bottomAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: layoutGuide.leadingAnchor, constant: 40),
            titleLabel.trailingAnchor.constraint(equalTo: layoutGuide.trailingAnchor, constant: -40),
            
            subTitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            subTitleLabel.leadingAnchor.constraint(equalTo: layoutGuide.leadingAnchor, constant: 40),
            subTitleLabel.trailingAnchor.constraint(equalTo: layoutGuide.trailingAnchor, constant: -40),
            
            imageView.centerXAnchor.constraint(equalTo: layoutGuide.centerXAnchor),
            imageView.topAnchor.constraint(equalTo: subTitleLabel.bottomAnchor, constant: 40),
            imageView.widthAnchor.constraint(lessThanOrEqualToConstant: UIScreen.main.bounds.width - 40),
            imageView.bottomAnchor.constraint(equalTo: layoutGuide.bottomAnchor),
            
            bottomView.leadingAnchor.constraint(equalTo: layoutGuide.leadingAnchor),
            bottomView.trailingAnchor.constraint(equalTo: layoutGuide.trailingAnchor),
            bottomView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            mainActivityIndicator.centerXAnchor.constraint(equalTo: layoutGuide.centerXAnchor),
            mainActivityIndicator.centerYAnchor.constraint(equalTo: layoutGuide.centerYAnchor),
            
            purchaseButton.heightAnchor.constraint(equalToConstant: 40),
            purchaseButton.topAnchor.constraint(equalTo: bottomView.topAnchor, constant: 20),
            purchaseButton.leadingAnchor.constraint(equalTo: layoutGuide.leadingAnchor, constant: 40),
            purchaseButton.trailingAnchor.constraint(equalTo: layoutGuide.trailingAnchor, constant: -40),
            purchaseButton.bottomAnchor.constraint(equalTo: layoutGuide.bottomAnchor, constant: -60),
            
            priceLabel.heightAnchor.constraint(equalToConstant: 50),
            priceLabel.leadingAnchor.constraint(equalTo: layoutGuide.leadingAnchor),
            priceLabel.trailingAnchor.constraint(equalTo: layoutGuide.trailingAnchor),
            priceLabel.bottomAnchor.constraint(equalTo: layoutGuide.bottomAnchor),
            
            productActivityIndicator.centerXAnchor.constraint(equalTo: bottomView.centerXAnchor),
            productActivityIndicator.centerYAnchor.constraint(equalTo: bottomView.centerYAnchor)
            ])
    }
    
    func dismiss() {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    // MARK: - Actions
    
    @objc func tapCloseButton() {
        self.dismiss()
    }
    
    @objc func tapPurchaseButton() {
        mainActivityIndicator.startAnimating()
        
        guard let validProduct = self.product else {
            fatalError("no product loaded")
        }
        storeManager.buyProduct(product: validProduct)
    }
    
}


extension StoreViewController: InteractableStoreManager {
    
    func show(subscription: SubscriptionIAP?, product: SKProduct) {
        
        self.product = product
        
        
        guard let subscription = self.subscriptionIAP,
        let currencySymbol = product.priceLocale.currencySymbol
        else { return }
        
        productActivityIndicator.stopAnimating()
        
        let priceString = subscription.localizedPriceInfo.replacingOccurrences(of: "%{price}",
                                                                                       with: "\(currencySymbol) \(product.price)")
        priceLabel.text = priceString
        
        purchaseButton.setTitle(subscription.localizedUpgradeButtonText, for: .normal)
        
        UIView.animate(withDuration: 0.2) {
            self.purchaseButton.alpha = 1.0
            self.priceLabel.alpha = 1.0
        }
    }
    
    func showNoProductsAlert() {
        
    }
    
    func purchaseFinished() {
        mainActivityIndicator.stopAnimating()
        
        self.dismiss()
    }
    
    func purchaseFailed(errorDescription: String?) {
        let message = errorDescription ?? "Your request failed"
        
        let alertController = UIAlertController(title: "Error",
                                                message: message,
                                                preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok",
                                     style: .default) { (action) in
                                        alertController.dismiss(animated: true, completion: nil)
        }
        alertController.addAction(okAction)
        
        mainActivityIndicator.stopAnimating()
        present(alertController, animated: true, completion: nil)
    }
    
}

