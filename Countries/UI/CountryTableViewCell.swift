//
//  CountryTableViewCell.swift
//  Countries
//
//  Created by Syft on 05/03/2020.
//  Copyright © 2020 Syft. All rights reserved.
//

import UIKit

class CountryTableViewCell: UITableViewCell {

    @IBOutlet weak var country: UILabel!
    @IBOutlet weak var capital: UILabel!
    @IBOutlet weak var capitalLabel: UILabel!
    @IBOutlet weak var capitalStackView: UIStackView!
    @IBOutlet weak var population: UILabel!
    @IBOutlet weak var populationLabel: UILabel!
    @IBOutlet weak var regionLabel: UILabel!
    @IBOutlet weak var areaLabel: UILabel!
    
    var item: Country? {
        didSet {
            self.country.text! = item?.name ?? ""
            self.capital.text = item?.capital ?? ""
            self.regionLabel.text! = item?.region ?? ""
            self.areaLabel.text! = "\(item?.area ?? 0)"
            
            let largeNumber = item?.population ?? 0
            let numberFormatter = NumberFormatter()
            numberFormatter.numberStyle = .decimal
            let formattedNumber = numberFormatter.string(from: NSNumber(value:largeNumber))
            self.population.text = "\(formattedNumber ?? "")"

            self.accessibilityIdentifier = "\(item?.name ?? "")-Cell"
            self.country.accessibilityIdentifier = "Country"
            self.capital.accessibilityIdentifier = "\(item?.name! ?? "")-Capital"
            self.population.accessibilityIdentifier = "\(item?.name! ?? "")-Population"
            self.populationLabel.accessibilityIdentifier = "\(item?.name ?? "")-Population-Label"

        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
