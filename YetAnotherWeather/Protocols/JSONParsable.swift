//
//  JSONParsable.swift
//  YetAnotherWeather
//
//  Created by Ivan Grebenyuk on 12.06.2024.
//

import Foundation
import SwiftyJSON

protocol JSONParsable {
    
    static func from(_ json: JSON) -> Self?
}
