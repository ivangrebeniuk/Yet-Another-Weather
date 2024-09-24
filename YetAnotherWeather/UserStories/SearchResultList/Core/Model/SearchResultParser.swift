//
//  SearchResultParser.swift
//  YetAnotherWeather
//
//  Created by Ivan Grebenyuk on 30.06.2024.
//

import SwiftyJSON

final class SearchResultParser: IJSONParser {
    
    func parse(_ json: SwiftyJSON.JSON) throws -> ([SearchResult]) {
        let rawResults = json.arrayValue
        
        var results = [SearchResult]()
        
        do {
            try rawResults.forEach { result in
                guard
                    let id = result["id"].int,
                    let name = result["name"].string,
                    let region = result["region"].string,
                    let country = result["country"].string
                else {
                    throw NetworkRequestError.modelParsingError
                }
                
                let searchResult = SearchResult(
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
