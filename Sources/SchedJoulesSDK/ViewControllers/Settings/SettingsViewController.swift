//
//  SettingsViewController.swift
//  iOS-SDK
//
//  Created by Balazs Vincze on 2018. 03. 29..
//  Copyright © 2018. SchedJoules. All rights reserved.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import UIKit
import SchedJoulesApiClient
import StoreKit
import MessageUI

final class SettingsViewController: UIViewController {
    
    // - MARK: Objects
    fileprivate struct Section {
        var kind: Kind
        var items: [Item]
        var title: String {
            get {
                switch self.kind {
                case .about:
                    return "About us"
                case .localization:
                    return "Country & Language"
                case .purchases:
                    return "Purchases"
                case .notifications:
                    return "Notifications"
                case .contact:
                    return "Contact us"
                case .account:
                    return "Account"
                }
            }
        }
        
        enum Kind {
            case about
            case localization
            case purchases
            case notifications
            case contact
            case account
        }
    }
    
    fileprivate struct Item {
        var title: String
        var details: String?
        var data: Any?
        var alternativeTitle: String?
        
    }
    
    
    // - MARK: Properties
    
    /// The table view.
    @IBOutlet weak var tableView: UITableView!
    
    /// The ApiClient.
    var apiClient: Api!
    
    // - MARK: Private Properties
    private var reloadNotificationsRow = false
    
    //Reference to IAP Store
    private lazy var storeManager = StoreManager.shared
    
    // Items
    private let aboutItems = [Item(title: "SchedJoules",
                                   data: URL(string: "https://cms.schedjoules.com/static_pages/about_us_\(Locale.preferredLanguages[0].components(separatedBy: "-")[0]).html"))]
    
    private let countryLanguageItems = [Item(title: "Country",
                                             data: SettingsManager.SettingsType.country),
                                        Item(title: "Language",
                                             data: SettingsManager.SettingsType.language)]
    
    private var purchasesItems: [Item] {
        var items = [Item(title: "Restore Purchases")]
        if storeManager.isSubscriptionValid == true {
            items.append(Item(title: "Migrate your subscription"))
        }
        return items
    }
    
    private var purchasesItemsMainApp: [Item] {
        return [Item(title: "Restore Purchases")]
    }
    
    private let notificationsItems = [Item(title: "Register for Notifications",
                                           alternativeTitle: "Unregister for notifications")]
    
    private static let supportEmail: String = Bundle.main.object(forInfoDictionaryKey: "CalendarStoreFeedbackEmailAddress") as? String ?? "support@schedjoules.com"
    private let contactItems = [Item(title: "FAQ",
                                     details: nil,
                                     data: URL(string: "https://cms.schedjoules.com/static_pages/help_\(Locale.preferredLanguages[0].components(separatedBy: "-")[0]).html")),
                                Item(title: "e-mail",
                                     details: supportEmail,
                                     data: supportEmail),
                                Item(title: "Twitter",
                                     details: "@schedjoules",
                                     data: URL(string:"https://twitter.com/SchedJoules")),
                                Item(title: "Website",
                                     details: "http://www.schedjoules.com",
                                     data: URL(string:"http://www.schedjoules.com"))]
    private let accountItems = [Item(title: "Delete your account")]
    
    //Sections
    private var sections: [Section] {
        get {
            var sections = [Section(kind: .about, items: aboutItems),
                            Section(kind: .localization, items: countryLanguageItems),
                            Section(kind: .notifications, items: notificationsItems),
                            Section(kind: .contact, items: contactItems),
                            Section(kind: .account, items: accountItems)]
            
            if let appBundle = Bundle.main.infoDictionary?[kCFBundleIdentifierKey as String] as? String,
               appBundle != "com.schedjoules.calstore" {
                sections.insert(Section(kind: .purchases, items: purchasesItems), at: 2)
            } else {
                sections.insert(Section(kind: .purchases, items: purchasesItemsMainApp), at: 2)
            }
            
            return sections
        }
    }
    
    //Activity indicator
    var activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView(style: .whiteLarge)
        activityIndicator.hidesWhenStopped = true
        activityIndicator.color = .blue
        return activityIndicator
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Set table view delegate and data source
        tableView.delegate = self
        tableView.dataSource = self
        
        // Set navbar title
        navigationItem.title = "Settings"
        view.addSubview(activityIndicator)
        
        storeManager.apiClient = self.apiClient
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(updateNotificationStatus),
                                               name: .SJDidBecomeActive,
                                               object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        showLoader(animate: false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()
        
        activityIndicator.center = self.view.center
        showLoader(animate: false)
    }
    
    private func showLoader(animate: Bool) {
        switch animate {
        case true:
            activityIndicator.startAnimating()
            self.view.isUserInteractionEnabled = false
        case false:
            activityIndicator.stopAnimating()
            self.view.isUserInteractionEnabled = true
        }
    }
    
    
    //MARK: Actions
    @objc private func updateNotificationStatus() {
        tableView.reloadRows(at: [IndexPath(row: 0, section: 3)], with: .automatic)
    }
    
}


extension SettingsViewController: UITableViewDataSource {
    //MARK: Sections
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let settingsSection = sections[section]
        return settingsSection.title
    }
    
    
    //MARK: Items
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let settingsSection = sections[section]
        return settingsSection.items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = sections[indexPath.section]
        let item = section.items[indexPath.row]
        
        //Separate the code by section because each one uses a different design
        switch section.kind {
        case .about:
            let cell = tableView.dequeueReusableCell(withIdentifier: "CellSubtitle", for: indexPath)
            cell.textLabel!.text = item.title
            cell.detailTextLabel?.text = item.details
            cell.detailTextLabel?.textColor = .lightGray
            cell.imageView?.image = UIImage(named: "Icon", in: Bundle.resourceBundle, compatibleWith: nil)
            return cell
        case .localization:
            let cell = tableView.dequeueReusableCell(withIdentifier: "CellDetail", for: indexPath)
            cell.textLabel!.text = item.title
            if let localizationType = item.data as? SettingsManager.SettingsType {
                let localizationObject = SettingsManager.get(type: localizationType)
                cell.detailTextLabel?.text = localizationObject.name
            }
            cell.detailTextLabel!.textColor = .lightGray
            return cell
        case .purchases:
            let cell = tableView.dequeueReusableCell(withIdentifier: "CellSubtitle", for: indexPath)
            if indexPath.row == 0 {
                if storeManager.isSubscriptionValid == true,
                   let expirationDate = UserDefaults.standard.subscriptionExpirationDate,
                   indexPath.row == 0 {
                    cell.textLabel?.text = "\(expirationDate.remainingTimeString()) left on your subscription"
                    cell.detailTextLabel?.text = ""
                    cell.detailTextLabel?.textColor = .lightGray
                    cell.accessoryType = .none
                    return cell
                } else {
                    cell.textLabel?.text = item.title
                    cell.detailTextLabel?.text = nil
                    cell.detailTextLabel?.textColor = .lightGray
                    cell.textLabel?.numberOfLines = 0
                }
            } else {
                cell.textLabel?.text = item.title
                cell.detailTextLabel?.text = nil
                cell.detailTextLabel?.textColor = .lightGray
                cell.textLabel?.numberOfLines = 0
            }
            return cell
        case .notifications:
            let cell = tableView.dequeueReusableCell(withIdentifier: "CellSubtitle", for: indexPath)
            if UIApplication.shared.isRegisteredForRemoteNotifications == true {
                cell.textLabel?.text = item.alternativeTitle
                cell.detailTextLabel?.text = nil
                cell.detailTextLabel?.textColor = .sjRed
            } else {
                cell.textLabel?.text = item.title
                cell.detailTextLabel?.text = nil
                cell.detailTextLabel?.textColor = .lightGray
            }
            return cell
        case .contact:
            let cell = tableView.dequeueReusableCell(withIdentifier: "CellSubtitle", for: indexPath)
            cell.textLabel!.text = item.title
            cell.detailTextLabel?.text = item.details
            let image = UIImage(named: item.title, in: Bundle.resourceBundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
            cell.imageView?.image = image
            cell.imageView?.tintColor = navigationController?.navigationBar.tintColor
            cell.detailTextLabel!.textColor = .lightGray
            return cell
        case .account:
            let cell = tableView.dequeueReusableCell(withIdentifier: "CellDetail", for: indexPath)
            cell.textLabel?.text = item.title
            cell.detailTextLabel?.text = nil
            cell.detailTextLabel?.textColor = .lightGray
            return cell
        }
    }
}


extension SettingsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let section = sections[indexPath.section]
        let item = section.items[indexPath.row]
        
        let cell = tableView.cellForRow(at: indexPath)
        
        //Separate the code by section because each one uses a different design
        switch section.kind {
        case .about, .contact:
            if let url = item.data as? URL {
                open(url: url, for: section)
            } else if let email = item.data as? String {
                presentAlertFor(email: email, source: cell ?? self.view)
            } else {
                sjPrint("invalid url for item: \(item.title)")
                return
            }
        case .localization:
            guard let localizationType = item.data as? SettingsManager.SettingsType else {
                sjPrint("Wrong localization setting")
                return
            }
            
            switch localizationType {
            case .language:
                let settingsDetailVC = SettingsDetailViewController(apiClient: apiClient,
                                                                    settingsQuery: SupportedLanguagesQuery(), settingsType: localizationType)
                navigationController?.pushViewController(settingsDetailVC, animated: true)
            case .country:
                let settingsDetailVC = SettingsDetailViewController(apiClient: apiClient,
                                                                    settingsQuery: SupportedCountriesQuery(), settingsType: localizationType)
                navigationController?.pushViewController(settingsDetailVC, animated: true)
            }
        case .purchases:
            if indexPath.row == 0 {
                //Only run if there is no subscription
                if storeManager.isSubscriptionValid == false {
                    NotificationCenter.default.post(name: .SJLaunchSignUp, object: self)
//                    storeManager.isRestoringPurchases = true
//                    storeManager.presentable = self
//                    storeManager.restorePurchases()
//                    showLoader(animate: true)
                } else {
                    presentSubscriptionActive(restored: false, source: cell ?? self.view)
                }
            } else if #available(iOS 13.0, *) {
                NotificationCenter.default.post(name: .SJLaunchSignUp, object: self)
                return
            }
        case .notifications:
            if UIApplication.shared.isRegisteredForRemoteNotifications == true {
                guard let bundleIdentifier = Bundle.main.bundleIdentifier,
                      let appSettings = URL(string: UIApplication.openSettingsURLString + bundleIdentifier),
                      UIApplication.shared.canOpenURL(appSettings) else {
                          return
                      }
                
                reloadNotificationsRow = true
                UIApplication.shared.open(appSettings)
            } else {
                NotificationCenter.default.post(name: .SJRegisterForAPNS, object: nil)
            }
        case .account:
            if #available(iOS 15.0, *) {
                Task {
                    do {
                        let appStoreSubscriptions = try await StoreManager.shared.getCurrentProducts()
                        if appStoreSubscriptions.count > 0 {
                            await StoreManager.shared.manageSubscriptionsPage(from: view)
                        } else {
                            deleteAccount()
                        }
                    } catch {
                        print("appstore error: ", error)
                    }
                }
            } else {
                deleteAccount()
            }
        }
    }
    
    func deleteAccount() {
        let alertController = UIAlertController(title: "Delete Info",
                                                message: "SchedJoules doesn't store your personal information.\n\nSign In with Apple is used only to transfer your subscriptions into our main app. You can still choose we cancel the identifier saved.",
                                                preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok",
                                     style: .default) { _ in
            print("delete")
            
            let deleteAccountQuery = DeleteAccountQuery(subscriptionId: nil, userIdentifier: "dd")
            self.apiClient.execute(query: deleteAccountQuery) { result in
                print("result: ", result)
                switch result {
                case .success(let algo):
                    print("algo: ", algo)
                case .failure(let error):
                    print("error: ", error)
                }
            }
            
        }
        alertController.addAction(okAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true)
    //https://api.schedjoules.com/remove_account?sid=23121232 will trigger an email
    }
    
    private func presentSubscriptionActive(restored: Bool, source: UIView) {
        DispatchQueue.main.async {
            let message = restored == true ? "Your purchases are restored!" : "Your subscription is active!"
            
            let alertController = UIAlertController(title: "Great",
                                                    message: message,
                                                    preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Ok",
                                         style: .default) { (action) in
                alertController.dismiss(animated: true, completion: nil)
            }
            alertController.addAction(okAction)
            
            //Present on ipad
            alertController.popoverPresentationController?.sourceView = source
            alertController.popoverPresentationController?.sourceRect = source.bounds
            
            self.showLoader(animate: false)
            self.present(alertController, animated: true, completion: nil)
            
            self.tableView.reloadData()
        }
    }
    
    
    //MARK: open urls for contact and about
    
    private func open(url: URL, for section: Section) {
        //We show the website in safari, everything else in SettingsWebViewController
        if url.absoluteString == "http://www.schedjoules.com" {
            UIApplication.shared.open(url, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
        } else {
            let webVC = SettingsWebViewController()
            webVC.url = url
            webVC.navigationItem.title = section.title
            navigationController?.pushViewController(webVC, animated: true)
        }
    }
    
    
    //MARK: Handle emailing support
    private func presentAlertFor(email: String, source: UIView) {
        let subject = "Calendar Store Feedback"
        
        let emailActionSheet = UIAlertController(title: "Choose an email client",
                                                 message: nil,
                                                 preferredStyle: .actionSheet)
        
        //Add actions for each email client we manually set
        //Mail app
        if MFMailComposeViewController.canSendMail() == true {
            let emailAction = UIAlertAction(title: "Mail App", style: .default) { (action) in
                let mail = MFMailComposeViewController()
                mail.mailComposeDelegate = self
                mail.setToRecipients([email])
                mail.setSubject(subject)
                mail.setMessageBody(self.feedbackInitialText(html: true), isHTML: true)
                self.present(mail, animated: true)
            }
            emailActionSheet.addAction(emailAction)
        }
        
        let gmailUrlString = String(format: "googlegmail:///co?to=%@&subject=%@&body=%@", email, subject, self.feedbackInitialText(html: false))
        let gmailEncodedUrl = gmailUrlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        if let gmailUrl = URL(string: gmailEncodedUrl) {
            if UIApplication.shared.canOpenURL(gmailUrl) {
                let gmailAction = UIAlertAction(title: "Gmail", style: .default) { (action) in
                    UIApplication.shared.open(gmailUrl, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]))
                }
                emailActionSheet.addAction(gmailAction)
            }
        }
        
        let outlookUrlString = String(format: "ms-outlook://compose?to=%@&subject=%@&body=%@", email, subject, self.feedbackInitialText(html: true))
        let outlookEncodedUrl = outlookUrlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        if let outlookUrl = URL(string: outlookEncodedUrl) {
            if UIApplication.shared.canOpenURL(outlookUrl) {
                let outlookAction = UIAlertAction(title: "Outlook", style: .default) { (action) in
                    UIApplication.shared.open(outlookUrl, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]))
                }
                emailActionSheet.addAction(outlookAction)
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive) { (action) in
            emailActionSheet.dismiss(animated: true)
        }
        emailActionSheet.addAction(cancelAction)
        
        //Present on ipad
        emailActionSheet.popoverPresentationController?.sourceView = source
        emailActionSheet.popoverPresentationController?.sourceRect = source.bounds
        
        present(emailActionSheet, animated: true, completion: nil)
    }
    
    func feedbackInitialText(html: Bool) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX") as Locale
        dateFormatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss Z" //RFC2822-Format
        
        // not localized, since it's for support-usage only.
        //We need two formats becase Gmail doesn't parse the html tags
        var formatBody = ""
        if html == true {
            formatBody = """
            Describe your feedback:\
            <br><br><br><hr>\
            <font size='-6'><b>Diagnostics</b><br>\
            App: %@ (%@/%@)<br>\
            UUID: %@<br>\
            SubscriptionId: %@<br>\
            FreeCalendar: %@<br>\
            Device: %@<br>\
            Firmware: %@<br>\
            Library: %@<br>\
            Date: %@<br>\
            Locale: %@<br>\
            Location: %@<br>\
            TimeZone: %@</font><hr>
            """
        } else {
            formatBody = """
            Describe your feedback: -
            Diagnostics: -
            App: %@ (%@/%@) -
            UUID: %@ -
            SubscriptionId: %@ -
            FreeCalendar: %@ -
            Device: %@ -
            Firmware: %@ -
            Library: %@ -
            Date: %@ -
            Locale: %@ -
            Location: %@ -
            TimeZone: %@
            """
        }
        
        let body: String = String(format: formatBody,
                                  Config.appName,
                                  Config.bundleIdentifier,
                                  Config.bundleVersion,
                                  Config.uuid,
                                  UserDefaults.standard.subscriptionId ?? "",
                                  FreeSubscriptionRecord().freeCalendar() ?? "",
                                  UIDevice.current.model,
                                  UIDevice.current.systemVersion,
                                  Config.libraryVersion,
                                  dateFormatter.string(from: Date()),
                                  SettingsManager.get(type: .language).code,
                                  SettingsManager.get(type: .country).code,
                                  NSTimeZone.system.identifier
        )
        return body
    }
    
}

extension SettingsViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
}


extension SettingsViewController: InteractableStoreManager {
    
    //We don't need to present products in the settings View Controller
    func show(subscription: SubscriptionIAP?, product: SKProduct) {}
    
    func showNoProductsAlert() {}
    
    func purchaseFinished() {
        showLoader(animate: false)
        presentSubscriptionActive(restored: true, source: self.view)
    }
    
    func purchaseFailed(errorDescription: String?) {
        DispatchQueue.main.async {
            if let message = errorDescription {
                let alertController = UIAlertController(title: "Error",
                                                        message: message,
                                                        preferredStyle: .alert)
                
                let purchaseAction = UIAlertAction(title: "Get a Subscription",
                                                   style: .default) { (action) in
                    let storeVC = StoreViewController(apiClient: self.apiClient)
                    self.storeManager.isRestoringPurchases = false
                    self.present(storeVC, animated: true, completion: nil)
                    return
                }
                alertController.addAction(purchaseAction)
                
                let dismissAction = UIAlertAction(title: "Dismisss",
                                                  style: .cancel) { (action) in
                    alertController.dismiss(animated: true, completion: nil)
                }
                alertController.addAction(dismissAction)
                
                //Present on ipad
                alertController.popoverPresentationController?.sourceView = self.view
                alertController.popoverPresentationController?.sourceRect = CGRect(origin: self.view.center,
                                                                                   size: CGSize(width: 1, height: 1))
                
                self.present(alertController, animated: true, completion: nil)
            }
            
            self.showLoader(animate: false)
        }
        
    }
    
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
    return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}
