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
    
    //MARK: The Api client.
    private let apiClient: Api
    var storeManager = StoreManager.shared
    var subscriptionIAP: SubscriptionIAP?
    var product: SKProduct?
    var benefits = ["Unlimited access to thousands of interesting calendars & events",
                    "(School) holidays, sports, TV-shows, weather and more",
                    "(Live) sports updates in your calendar",
                    "No ads"]
    
    //MARK: Properties
    enum TosLinks {
        case terms
        case privacy
        
        var text: String {
            get {
                switch self {
                case .terms:
                    return "Terms of Service"
                case .privacy:
                    return "Privacy Policy"
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
    
    
    //MARK: UI
    private let backgroundImageView : UIImageView = {
        let imageView = UIImageView(frame: .zero)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        let image = UIImage(named: "stadium_short", in: Bundle.resourceBundle, compatibleWith: nil)
        imageView.image = image
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private let backgroundEffectView: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: .dark)
        let view = UIVisualEffectView(effect: blurEffect)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let logoImageView: UIImageView = {
        let imageView = UIImageView(frame: .zero)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "Icon", in: Bundle.resourceBundle, compatibleWith: nil)
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let closeButton: UIButton = {
        var button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        if #available(iOS 13.0, *) {
            let closeImage = UIImage(systemName: "xmark")
            button.setImage(closeImage, for: .normal)
            button.tintColor = .white
        } else {
            button.setTitle("x", for: .normal)
            button.setTitleColor(.white, for: .normal)
        }
        return button
    }()
    
    private let scrollView: UIScrollView = {
        let scrollview = UIScrollView(frame: .zero)
        scrollview.translatesAutoresizingMaskIntoConstraints = false
        return scrollview
    }()
    
    private let stackView: UIStackView = {
        let stackView = UIStackView(frame: .zero)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 8
        return stackView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Go Premium"
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 22, weight: .semibold)
        return label
    }()
    
    private let subTitleLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.textColor = .white
        label.font = .systemFont(ofSize: UIFont.systemFontSize + 2.0)
        label.text = "Loading..."
        return label
    }()
    
    private let descriptionStackView: UIStackView = {
        let stackView = UIStackView(frame: .zero)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.spacing = 8
        return stackView
    }()
    
    private let purchaseButton: UIButton = {
        var button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Continue", for: .normal)
        button.backgroundColor = .sjBlueBright
        button.alpha = 1.0
        return button
    }()
    
    private let dismissButton: UIButton = {
        var button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("No thanks", for: .normal)
        button.backgroundColor = .clear
        button.alpha = 1.0
        button.titleLabel?.font = .systemFont(ofSize: 12)
        button.setTitleColor(.white, for: .normal)
        return button
    }()
    
    private let tosLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "SchedJoules Premium is a recurring subscription. You will automatically be billed the amount listed above through iTunes at the end of the free trial period which is 30 days. Your subscription will auto-renew unless you cancel or turn off auto-renew at least 24 hours before the end of the current period. You can manage your subscription in iTunes."
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 12)
        label.textAlignment = .justified
        label.alpha = 1.0
        label.textColor = .white
        return label
    }()
    
    private let tosLinkLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        label.text = "\(TosLinks.terms.text) and \(TosLinks.privacy.text)."
        label.textColor = .white
        
        let text = (label.text)!
        let formattedText = NSMutableAttributedString(string: text)
        
        let range1 = (text as NSString).range(of: TosLinks.terms.text)
        let range2 = (text as NSString).range(of: TosLinks.privacy.text)
        
        let formatAttributes: [NSAttributedString.Key : Any] = [.underlineStyle: NSUnderlineStyle.single.rawValue,
                                                                .foregroundColor: UIColor.sjBlueBright]
        
        formattedText.addAttributes(formatAttributes, range: range1)
        formattedText.addAttributes(formatAttributes, range: range2)
        
        label.attributedText = formattedText
        
        label.font = UIFont.systemFont(ofSize: 12)
        label.textAlignment = .justified
        label.adjustsFontSizeToFitWidth = true
        label.alpha = 1.0
        label.isUserInteractionEnabled = true
        return label
    }()
    
    private let mainActivityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView(frame: .zero)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.style = .whiteLarge
        activityIndicator.hidesWhenStopped = true
        return activityIndicator
    }()
    
    
    //MARK: Initialization
    init(apiClient: Api) {
        self.apiClient = apiClient
        super.init(nibName: nil, bundle: nil)
        
        modalPresentationStyle = .fullScreen
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    //MARK: View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        showIndicator(true)
        
        setupProperties()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if view.bounds.height > 568.0 {
            stackView.distribution = .fillEqually
        }
        
        self.setNeedsStatusBarAppearanceUpdate()
        NotificationCenter.default.post(name: .SJShowPurchaseScreen, object: nil)
    }
    
    
    //MARK: Setup
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    private func setupProperties() {
        storeManager.apiClient = self.apiClient
        storeManager.presentable = self
        
        storeManager.requestSubscriptionProducts { (result, error) in
            guard let validSubscriptionIAP = result,
                error == nil else { return }
            
            self.subscriptionIAP = validSubscriptionIAP
            self.storeManager.requestProductWithID(identifers: [validSubscriptionIAP.productId], subscriptionIAP: validSubscriptionIAP)
        }
        
        closeButton.addTarget(self, action: #selector(tapCloseButton), for: .touchUpInside)
        purchaseButton.addTarget(self, action: #selector(tapPurchaseButton), for: .touchUpInside)
        dismissButton.addTarget(self, action: #selector(tapDismissButton), for: .touchUpInside)
        
        let tosTap = UITapGestureRecognizer(target: self, action: #selector(tapLabel(gesture:)))
        tosLinkLabel.addGestureRecognizer(tosTap)
        
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        
        view.addSubview(backgroundImageView)
        view.addSubview(backgroundEffectView)
        
        view.addSubview(scrollView)
        scrollView.addSubview(stackView)
        view.addSubview(closeButton)
        view.addSubview(mainActivityIndicator)
        
        stackView.addArrangedSubview(logoImageView)
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(subTitleLabel)
        
        benefits.forEach { benefit in
            let benefitStackView = UIStackView(frame: .zero)
            benefitStackView.translatesAutoresizingMaskIntoConstraints = false
            benefitStackView.axis = .horizontal
            benefitStackView.spacing = 8
            benefitStackView.alignment = .top
            
            if #available(iOS 13.0, *) {
                let imageView = UIImageView(frame: .zero)
                imageView.translatesAutoresizingMaskIntoConstraints = false
                imageView.contentMode = .scaleAspectFit
                imageView.image = UIImage(systemName: "checkmark")
                imageView.tintColor = .white
                benefitStackView.addArrangedSubview(imageView)
                
                NSLayoutConstraint.activate([
                    imageView.heightAnchor.constraint(equalToConstant: 16),
                    imageView.widthAnchor.constraint(equalToConstant: 16)
                ])
            } else {
                let label = UILabel(frame: .zero)
                label.translatesAutoresizingMaskIntoConstraints = false
                label.text = "- "
                label.numberOfLines = 1
                label.textAlignment = .left
                label.adjustsFontSizeToFitWidth = true
                label.textColor = .white
                label.font = .systemFont(ofSize: UIFont.systemFontSize + 1.0)
                benefitStackView.addArrangedSubview(label)
            }
            
            let label = UILabel(frame: .zero)
            label.translatesAutoresizingMaskIntoConstraints = false
            label.numberOfLines = 0
            label.textAlignment = .left
            label.textColor = .white
            label.text = benefit
            label.font = .systemFont(ofSize: UIFont.systemFontSize + 1.0)
            benefitStackView.addArrangedSubview(label)
            
            stackView.addArrangedSubview(benefitStackView)
            stackView.setCustomSpacing(16, after: benefitStackView)
        }
        
        stackView.addArrangedSubview(purchaseButton)
        stackView.addArrangedSubview(dismissButton)
        stackView.addArrangedSubview(tosLabel)
        stackView.addArrangedSubview(tosLinkLabel)
        
        stackView.setCustomSpacing(24, after: logoImageView)
        stackView.setCustomSpacing(24, after: subTitleLabel)
        stackView.setCustomSpacing(16, after: dismissButton)
        
        NSLayoutConstraint.activate([
            backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            backgroundEffectView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundEffectView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundEffectView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundEffectView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            closeButton.heightAnchor.constraint(equalToConstant: 44),
            closeButton.widthAnchor.constraint(equalToConstant: 44),
            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            closeButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -10),
            
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 44),
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            stackView.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -48),
            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 24),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -24),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -24),
            
            purchaseButton.heightAnchor.constraint(equalToConstant: 44),
            
            mainActivityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            mainActivityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func dismiss() {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    private func showIndicator(_ animate: Bool) {
        DispatchQueue.main.async {
            if animate == true {
                self.mainActivityIndicator.startAnimating()
            } else {
                self.mainActivityIndicator.stopAnimating()
            }
        }
    }
    
    
    // MARK: - Actions
    
    @objc private func tapCloseButton() {
        self.dismiss()
    }
    
    @objc private func tapPurchaseButton() {
        NotificationCenter.default.post(name: .SJClickPurchaseScreenButton, object: nil)
        
        showIndicator(true)
        
        guard let validProduct = self.product else {
            fatalError("no product loaded")
        }
        
        storeManager.buyProduct(product: validProduct)
    }
    
    @objc private func tapDismissButton() {
        self.dismiss()
    }
    
    @objc private func tapLabel(gesture: UITapGestureRecognizer) {
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
    
    internal func show(subscription: SubscriptionIAP?, product: SKProduct) {
        showIndicator(false)
        
        self.product = product
        
        guard let subscription = self.subscriptionIAP,
            let currencySymbol = product.priceLocale.currencySymbol else {
            return
        }
        
        DispatchQueue.main.async {
            let priceString = subscription.localizedPriceInfo.replacingOccurrences(of: "%{price}",
                                                                                   with: "\(currencySymbol) \(product.price)")
            
            self.subTitleLabel.text = priceString
            
            self.purchaseButton.setTitle(subscription.localizedUpgradeButtonText, for: .normal)
            
            UIView.animate(withDuration: 0.2) {
                self.purchaseButton.alpha = 1.0
                self.subTitleLabel.alpha = 1.0
                self.tosLabel.alpha = 1.0
                self.tosLinkLabel.alpha = 1.0
            }
        }
    }
    
    private func showNoProductsAlert() {
        
    }
    
    internal func purchaseFinished() {
        NotificationCenter.default.post(name: .SJPurchaseSubsctiption, object: nil)
        
        showIndicator(false)
        
        self.dismiss()
    }
    
    internal func purchaseFailed(errorDescription: String?) {
        NotificationCenter.default.post(name: .SJPurchaseSubscriptionFailed, object: errorDescription)
        
        showIndicator(false)
        
        DispatchQueue.main.async {
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
            
            alertController.popoverPresentationController?.sourceView = self.view
            alertController.popoverPresentationController?.sourceRect = CGRect(origin: self.view.center,
                                                                               size: CGSize(width: 1, height: 1))
            
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
}
