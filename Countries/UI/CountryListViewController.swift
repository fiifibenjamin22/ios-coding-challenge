//
//  CountryListViewController.swift
//  Countries
//
//  Created by Syft on 03/03/2020.
//  Copyright © 2020 Syft. All rights reserved.
//

import UIKit
import CoreData


class CountryListViewController: UIViewController, UITableViewDataSource {

    @IBOutlet weak var countryTableView: UITableView!
    var countries = [Country]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        countryTableView.rowHeight = UITableView.automaticDimension
        countryTableView.estimatedRowHeight = 150
        countryTableView.dataSource = self
        countryTableView.accessibilityIdentifier = Strings().accessibilityIdentifier
        
        Server.shared.countryList() { (error) in
            guard error == nil else {
                assertionFailure("There was an error: \(error!.localizedDescription)")
                return
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        HUD.show(in: view.window!)
        self.countries.removeAll()
        CountryDataController.sharedinstance.fetchedItems.forEach { county in
            self.countries.append(county)
        }
        
        countries.sort {
            guard let first: String = ($0 as AnyObject).name else { return true }
            guard let second: String = ($1 as AnyObject).name else { return false }
            return first < second
        }
    
        HUD.dismiss(from: self.view.window!)
        self.countryTableView.reloadData()
    }
    
    
    // MARK:- UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return countries.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: Strings().cellIdentifier) as! CountryTableViewCell
        
        let country = countries[indexPath.row]
        cell.item = country
        
        return cell
    }
}

