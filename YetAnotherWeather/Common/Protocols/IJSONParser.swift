//
//  IJSONParser.swift
//  YetAnotherWeather
//
//  Created by Ivan Grebenyuk on 30.06.2024.
//

import Foundation
import SwiftyJSON

protocol IJSONParser: AnyObject {
    
    associatedtype Model
    
    func parse(_ json: JSON) throws -> Model
}
