//
//  SerachResult+JSONParsable.swift
//  YetAnotherWeather
//
//  Created by Ivan Grebenyuk on 26.09.2024.
//

import Foundation
import SwiftyJSON

extension SearchResultModel: JSONParsable {
    
    // MARK: - JSONParsable
    
    static func fromArray(_ array: JSON) -> [SearchResultModel]? {
        let rawResults = array.arrayValue
        
        var results = [SearchResultModel]()
        
        rawResults.forEach { result in
            let id = result["id"].intValue
            let name = result["name"].stringValue
            let region = result["region"].stringValue
            let country = result["country"].stringValue
            
            let model = SearchResultModel(
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
