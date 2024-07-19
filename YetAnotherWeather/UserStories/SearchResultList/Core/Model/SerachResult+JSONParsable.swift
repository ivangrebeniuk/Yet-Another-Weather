//
//  SerachResult+JSONParsable.swift
//  YetAnotherWeather
//
//  Created by Ivan Grebenyuk on 12.06.2024.
//

import Foundation
import SwiftyJSON

extension SearchResult: JSONParsable {
    
    // MARK: - JSONParsable
    
    static func fromArray(_ array: JSON) -> [SearchResult]? {
        let rawResults = array.arrayValue
        
        var results = [SearchResult]()
        
        rawResults.forEach { result in
            let id = result["id"].intValue
            let name = result["name"].stringValue
            let region = result["region"].stringValue
            let country = result["country"].stringValue
            
            let model = SearchResult(
                id: id,
                name: name,
                region: region,
                country: country
            )
            
            results.append(model)
        }
        
        return results
    }
}
