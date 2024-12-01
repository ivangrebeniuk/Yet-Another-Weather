//
//  SearchResultParser.swift
//  YetAnotherWeather
//
//  Created by Ivan Grebenyuk on 26.09.2024.
//

import Foundation
import SwiftyJSON

final class SearchResultParser: IJSONParser {
    
    func parse(_ json: SwiftyJSON.JSON) throws -> [SearchResultModel] {
        let rawResults = json.arrayValue
        
        var results = [SearchResultModel]()
        
        do {
            try rawResults.forEach { result in
                guard
                    let id = result["id"].int,
                    let name = result["name"].string,
                    let region = result["region"].string,
                    let country = result["country"].string
                else {
                    throw NetworkRequestError.modelParsingError(SearchResultModel.self)
                }
                
                let searchResult = SearchResultModel(
                    id: id,
                    name: name,
                    region: region,
                    country: country
                )
                
                results.append(searchResult)
            }
        }
        
        return results
    }
}

