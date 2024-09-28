//
//  SearchResultModel.swift
//  YetAnotherWeather
//
//  Created by Ivan Grebenyuk on 26.09.2024.
//

import Foundation

struct SearchResultModel: Codable {
    let id: Int
    let name: String
    let region: String
    let country: String
}
