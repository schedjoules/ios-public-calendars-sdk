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
    
    //Properties
    enum TosLinks {
        case terms
        case privacy
        
        var text: String {
            get {
                switch self {
                case .terms:
                    return "Terms of Service"
                case .privacy:
                    return "Privacy Policy."
                }
            }
        }
        
        var url: URL? {
            get {
                switch self {
                case .terms:
                    return URL(string: "https://www.schedjoules.com/app-terms-of-service/")
                case .privacy:
                    return URL(string: "https://www.schedjoules.com/privacy-policy/")
                }
            }
        }
        
    }
    
    //UI
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
        let image = UIImage(named: "purchase-intro-1", in: Bundle.resourceBundle, compatibleWith: nil)
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
    
    var tosLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "SchedJoules Premium is a recurring subscription. You will automatically be billed the amount listed above through iTunes at the end of the free trial period which is 30 days. Your subscription will auto-renew unless you cancel or turn off auto-renew at least 24 hours before the end of the current period. You can manage your subscription in iTunes."
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 12)
        label.textAlignment = .justified
        label.adjustsFontSizeToFitWidth = true
        label.alpha = 0.0
        return label
    }()
    
    var tosLinkLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        label.text = "\(TosLinks.terms.text) and \(TosLinks.privacy.text)."
        
        let text = (label.text)!
        let formattedText = NSMutableAttributedString(string: text)
        
        let range1 = (text as NSString).range(of: TosLinks.terms.text)
        let range2 = (text as NSString).range(of: TosLinks.privacy.text)
        
        let formatAttributes: [NSAttributedString.Key : Any] = [.underlineStyle: NSUnderlineStyle.styleSingle.rawValue,
                                                                .foregroundColor: UIColor.sjBlue]
        
        formattedText.addAttributes(formatAttributes, range: range1)
        formattedText.addAttributes(formatAttributes, range: range2)
        
        label.attributedText = formattedText
        
        label.font = UIFont.systemFont(ofSize: 12)
        label.textAlignment = .justified
        label.adjustsFontSizeToFitWidth = true
        label.alpha = 0.0
        label.isUserInteractionEnabled = true
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
        bottomView.addSubview(tosLabel)
        bottomView.addSubview(tosLinkLabel)
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
            
            bottomView.leadingAnchor.constraint(equalTo: layoutGuide.leadingAnchor),
            bottomView.trailingAnchor.constraint(equalTo: layoutGuide.trailingAnchor),
            bottomView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            mainActivityIndicator.centerXAnchor.constraint(equalTo: layoutGuide.centerXAnchor),
            mainActivityIndicator.centerYAnchor.constraint(equalTo: layoutGuide.centerYAnchor),
            
            purchaseButton.heightAnchor.constraint(equalToConstant: 40),
            purchaseButton.topAnchor.constraint(equalTo: bottomView.topAnchor, constant: 20),
            purchaseButton.leadingAnchor.constraint(equalTo: layoutGuide.leadingAnchor, constant: 40),
            purchaseButton.trailingAnchor.constraint(equalTo: layoutGuide.trailingAnchor, constant: -40),
            
            priceLabel.topAnchor.constraint(equalTo: purchaseButton.bottomAnchor, constant: 8),
            priceLabel.heightAnchor.constraint(equalToConstant: 50),
            priceLabel.leadingAnchor.constraint(equalTo: layoutGuide.leadingAnchor),
            priceLabel.trailingAnchor.constraint(equalTo: layoutGuide.trailingAnchor),

            tosLabel.topAnchor.constraint(equalTo: priceLabel.bottomAnchor, constant: 8),
            tosLabel.leadingAnchor.constraint(equalTo: bottomView.leadingAnchor, constant: 16),
            tosLabel.trailingAnchor.constraint(equalTo: bottomView.trailingAnchor, constant: -16),

            tosLinkLabel.topAnchor.constraint(equalTo: tosLabel.bottomAnchor, constant: 8),
            tosLinkLabel.leadingAnchor.constraint(equalTo: bottomView.leadingAnchor, constant: 16),
            tosLinkLabel.trailingAnchor.constraint(equalTo: bottomView.trailingAnchor, constant: -16),
            
            tosLinkLabel.bottomAnchor.constraint(equalTo: layoutGuide.bottomAnchor, constant: -16),
            
            productActivityIndicator.centerXAnchor.constraint(equalTo: bottomView.centerXAnchor),
            productActivityIndicator.centerYAnchor.constraint(equalTo: bottomView.centerYAnchor)
            ])
        
        let tosTap = UITapGestureRecognizer(target: self, action: #selector(tapLabel(gesture:)))
        tosLinkLabel.addGestureRecognizer(tosTap)
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
    
    @objc func tapLabel(gesture: UITapGestureRecognizer) {
        let text = (tosLinkLabel.text)!
        let termsRange = (text as NSString).range(of: TosLinks.terms.text)
        let privacyRange = (text as NSString).range(of: TosLinks.privacy.text)
        var urlToOpen: URL?
        
        if gesture.didTapAttributedTextInLabel(label: tosLinkLabel, inRange: termsRange) {
            urlToOpen = TosLinks.terms.url
        } else if gesture.didTapAttributedTextInLabel(label: tosLinkLabel, inRange: privacyRange) {
            urlToOpen = TosLinks.privacy.url
        }
        
        guard let validUrl = urlToOpen,
            UIApplication.shared.canOpenURL(validUrl) else { return }
        
        UIApplication.shared.open(validUrl)
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
            self.tosLabel.alpha = 1.0
            self.tosLinkLabel.alpha = 1.0
        }
    }
    
    func showNoProductsAlert() {
        
    }
    
    func purchaseFinished() {
        mainActivityIndicator.stopAnimating()
        
        self.dismiss()
    }
    
    func purchaseFailed(errorDescription: String?) {
        mainActivityIndicator.stopAnimating()
        productActivityIndicator.stopAnimating()
        
        let message = errorDescription ?? "Your request failed"
        
        let alertController = UIAlertController(title: "Error",
                                                message: message,
                                                preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Dismiss",
                                     style: .default) { (action) in
                                        self.dismiss()
                                        alertController.dismiss(animated: true, completion: {
                                            self.tapCloseButton()
                                        })
        }
        alertController.addAction(okAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
}
