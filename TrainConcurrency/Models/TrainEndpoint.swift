//
//  TrainEndpoint.swift
//  TrainConcurrency
//
//  Created by Mattia Fochesato on 22/03/22.
//

import Foundation

/// The `TrainEndpoint` struct helps us to construct the `URL`
struct TrainEndpoint {
    let path: String
    let queryItems: [URLQueryItem]

    /// Base `URL` used to construct the endpoint
    var url: URL? {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "api-train-demo-medium.herokuapp.com"
        components.path = path
        components.queryItems = queryItems
        return components.url
    }

    /// Endpoint to get an essential list of `Train` departing from a specific station
    static func trainList(station: String, offset: Int = 0) -> TrainEndpoint {
        return TrainEndpoint(
            path: "/api/train/",
            queryItems: [
                URLQueryItem(name: "limit", value: String(TrainAPIManager.ITEMS_PER_PAGE)),
                URLQueryItem(name: "offset", value: String(offset)),
                URLQueryItem(name: "station", value: station)
            ]
        )
    }
    
    /// Endpoint to get detailed info about a `Train` given its code
    static func trainInfo(_ name: String) -> TrainEndpoint {
        return TrainEndpoint(
            path: "/api/train/" + name,
            queryItems: []
        )
    }
}
