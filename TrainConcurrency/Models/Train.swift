//
//  Train.swift
//  TrainConcurrency
//
//  Created by Mattia Fochesato on 22/03/22.
//

import Foundation

/* Train List API */
struct TrainSummary: Codable {
    var count: Int
    var trains: [Train]
}

struct Train: Codable {
    var code: String
    var destination: String
    
    public func getTrainInfo() async throws -> TrainInfo? {
        if let trainInfo = await TrainAPIManager.shared.getTrainInfo(code) {
            return trainInfo
        }
    
        print(#function + " TraiInfo nil")
        return nil
    }
}

/* Specific Train Info API */
struct TrainInfo: Codable, Identifiable {
    var id: Int
    var name: String
    var destination: String
    var trainStops: [TrainStop]
}

struct TrainStop: Codable {
    var id: Int
    var name: String
    var time: Date
}
