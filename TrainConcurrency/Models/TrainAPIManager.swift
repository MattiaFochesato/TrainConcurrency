//
//  TrainAPIManager.swift
//  TrainConcurrency
//
//  Created by Mattia Fochesato on 22/03/22.
//

import Foundation
import SwiftUI

/// This class manages all the API calls wrapping them into async functions.
class TrainAPIManager {
    /// Static constant to tell the API how many items to fetch on every paged request.
    static let ITEMS_PER_PAGE = 20
    
    /// Singleton
    static let shared = TrainAPIManager()
    private init() { }
    
    /// Shared jsonDecoder used to decode the JSON response
    private let jsonDecoder = JSONDecoder()
    
    /**
     Asks the API the list of trains departing from the specified station.
     
     - parameters:
        - station: The name of the station to check
        - offset: How many items to skip
     - returns: The `TrainSummary` object which contains all the data
     */
    func loadTrainList(station: String, from offset: Int = 0) async -> TrainSummary? {
        /// Construct the `URL` using the TrainEndpoint struct and check if it is valid.
        guard let url = TrainEndpoint.trainList(station: station, offset: offset).url else {
            print(#function + " Invalid URL")
            return nil
        }
        
        do {
            /// Make the GET request to the API and fetch the JSON string value
            let (data, _) = try await URLSession.shared.data(from: url)
            /// Try to decode the JSON string to a `TrainSummary` object using the `JSONDecoder`
            return try jsonDecoder.decode(TrainSummary.self, from: data)
        } catch {
            /// If something goes wrong, the function is going to return a nil object
            print(#function + " - Failed to load TrainSummary: \(error)")
            return nil
        }
    }
    
    /**
     Asks  the API the detailed data about a specific train given its code
     
     - parameter code: The code of the `Train`
     - returns: The `TrainSummary` object which contains all the data
     */
    func getTrainInfo(_ code: String) async -> TrainInfo? {
        /// Construct the `URL` using the TrainEndpoint struct and check if it is valid.
        guard let url = TrainEndpoint.trainInfo(code).url else {
            print(#function + " Invalid URL")
            return nil
        }
        
        do {
            /// Make the GET request to the API and fetch the JSON string value
            let (data, _) = try await URLSession.shared.data(from: url)
            /// Try to decode the JSON string to a `TrainInfo` object using the `JSONDecoder`
            return try jsonDecoder.decode(TrainInfo.self, from: data)
        } catch {
            /// If something goes wrong, the function is going to return a nil object
            print(#function + " - Failed to load TrainInfo")
            return nil
        }
    }
    
}
