//
//  ViewController.swift
//  SimpleAnalyticsDemo-UIKit
//
//  Created by Dennis Birch on 4/14/21.
//

import UIKit

class ViewController: UIViewController, UITableViewDataSource {
    @IBOutlet private weak var tableView: UITableView!
    private var titles = ["Ring Bell", "Horn Blaring", "Foghorn Warning", "Car Revving", "Dog Barking", "Fire Siren", "Oven Timer", "Car Door Slam", "Heavy Breathing", "Soft Sigh", "Thunderclap", "Ocean Wave Crashing", "Repeat Last", "Repeat Last (Other)"]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.allowsSelection = false
        tableView.rowHeight = 48
        DemoAnalytics.addAnalyticsItem("Display main view")
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ButtonTableViewCell.cellIdentifier, for: indexPath)
        guard let buttonCell = cell as? ButtonTableViewCell else {
            return cell
        }
        
        buttonCell.configureWithButtonName(titles[indexPath.row])
        return buttonCell
    }

}

