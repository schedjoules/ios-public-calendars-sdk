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
                case .contact:
                    return "Contact us"
                }
            }
        }
        
        enum Kind {
            case about
            case localization
            case purchases
            case contact
        }
    }
    
    fileprivate struct Item {
        var title: String
        var details: String?
        var data: Any?
        
        init(title: String, details: String? = nil, data: Any? = nil) {
            self.title = title
            self.details = details
            self.data = data
        }
    }
    
    
    // - MARK: Properties
    
    /// The table view.
    @IBOutlet weak var tableView: UITableView!
    
    /// The ApiClient.
    var apiClient: Api!
    
    // - MARK: Private Properties
    
    // Items
    private let aboutItems = [Item(title: "SchedJoules",
                                   data: URL(string: "https://cms.schedjoules.com/static_pages/about_us_\(Locale.preferredLanguages[0].components(separatedBy: "-")[0]).html"))]
    
    private let countryLanguageItems = [Item(title: "Country",
                                             data: SettingsManager.SettingsType.country),
                                        Item(title: "Language",
                                             data: SettingsManager.SettingsType.language)]
    
    private let purchasesItems = [Item(title: "Restore Purchases")]
    
    /// Contact menu items.
    private let contactItems = [Item(title: "FAQ",
                                     details: nil,
                                     data: URL(string: "https://cms.schedjoules.com/static_pages/help_\(Locale.preferredLanguages[0].components(separatedBy: "-")[0]).html")),
                                Item(title: "Twitter",
                                     details: "@schedjoules",
                                     data: URL(string:"https://twitter.com/SchedJoules")),
                                Item(title: "Facebook",
                                     details: "SchedJoules",
                                     data: URL(string:"https://www.facebook.com/SchedJoules/")),
                                Item(title: "Website",
                                     details: "http://www.schedjoules.com",
                                     data: URL(string:"http://www.schedjoules.com"))]
    
    //Sections
    private var sections: [Section] {
        get {
            return [Section(kind: .about, items: aboutItems),
                    Section(kind: .localization, items: countryLanguageItems),
                    Section(kind: .purchases, items: purchasesItems),
                    Section(kind: .contact, items: contactItems)]
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Set table view delegate and data source
        tableView.delegate = self
        tableView.dataSource = self
        
        // Set navbar title
        navigationItem.title = "Settings"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()
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
            cell.detailTextLabel!.text = item.details
            cell.detailTextLabel!.textColor = .lightGray
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
            cell.textLabel!.text = item.title
            cell.detailTextLabel!.text = ""
            cell.detailTextLabel!.textColor = .lightGray
            return cell
        case .contact:
            let cell = tableView.dequeueReusableCell(withIdentifier: "CellSubtitle", for: indexPath)
            cell.textLabel!.text = item.title
            cell.detailTextLabel!.text = item.details
            cell.imageView?.image = UIImage(named: item.title, in: Bundle.resourceBundle, compatibleWith: nil)
            cell.imageView?.tintColor = navigationController?.navigationBar.tintColor
            cell.detailTextLabel!.textColor = .lightGray
            return cell
        }
    }
}


extension SettingsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let section = sections[indexPath.section]
        let item = section.items[indexPath.row]
        
        //Separate the code by section because each one uses a different design
        switch section.kind {
        case .about, .contact:
            guard let url = item.data as? URL else {
                sjPrint("invalid url for item: \(item.title)")
                return
            }
            
            //We show the website in safari, everything else in SettingsWebViewController
            if url.absoluteString == "http://www.schedjoules.com" {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                let webVC = SettingsWebViewController()
                webVC.url = url
                webVC.navigationItem.title = section.title
                print(url)
                navigationController?.pushViewController(webVC, animated: true)
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
            let storeManager = StoreManager.shared
            storeManager.restorePurchases()
        }
    }
}
