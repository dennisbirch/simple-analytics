//
//  ButtonTableViewCell.swift
//  SimpleAnalyticsDemo-UIKit
//
//  Created by Dennis Birch on 4/14/21.
//

import UIKit

class ButtonTableViewCell: UITableViewCell {
    @IBOutlet private weak var button: UIButton!
    static let cellIdentifier = "ButtonCell"
    
    func configureWithButtonName(_ name: String) {
        button.setTitle(name, for: .normal)
        button.addTarget(self, action: #selector(logAnalytics), for: .touchUpInside)
    }
    
    @objc private func logAnalytics() {
        guard let name = button.title(for: .normal) else {
            print("Button name is nil")
            return
        }
        
        if name.lowercased().contains("repeat") {
            DemoAnalytics.countItem(name)
        } else {
            DemoAnalytics.addAnalyticsItem(name, params: ["Demo detail" : randomString()])
        }
    }
    
    private func randomString() -> String {
        let wordArray = "The quick brown fox jumped over the cow".split(separator: " ")
        let count = wordArray.count
        let index = arc4random_uniform(UInt32(count))
        return String(wordArray[Int(index)])
    }

}
