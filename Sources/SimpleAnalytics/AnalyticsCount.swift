//
//  AnalyticsCount.swift
//  
//
//  Created by Dennis Birch on 3/22/21.
//

import Foundation

struct AnalyticsCount: Codable, Hashable {
    enum CodingKeys: String, CodingKey {
        case name
        case count
        case timestamp
    }
    
    let name: String
    var count: Int
    let timestamp: Date
    
    init(name: String, count: Int) {
        self.name = name
        self.count = count
        self.timestamp = Date()
    }
    
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        name = try values.decode(String.self, forKey: .name)
        count = try values.decode(Int.self, forKey: .count)
        let dateString = try values.decode(String.self, forKey: .timestamp)
        timestamp = dateString.dateFromISOString() ?? Date()
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(count, forKey: .count)
        try container.encode(timestamp.toISOString(), forKey: .timestamp)
    }

}
