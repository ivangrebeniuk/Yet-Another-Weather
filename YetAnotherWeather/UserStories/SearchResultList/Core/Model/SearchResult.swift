//
//  SearchResult.swift
//  YetAnotherWeather
//
//  Created by Ivan Grebenyuk on 12.06.2024.
//

import Foundation

struct SearchResult: Codable {
    let id: Int
    let name: String
    let region: String
    let country: String
}
