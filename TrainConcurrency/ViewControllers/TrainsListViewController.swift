//
//  TrainsListViewController.swift
//  TrainConcurrency
//
//  Created by Mattia Fochesato on 22/03/22.
//

import Foundation

/// Custom exception
enum FetchTrainDataError: Error {
    case trainInfoNil
}

class TrainListViewController: ObservableObject {
    
    //@Published var trainList: AsyncResult<[Train]> = .empty
    
    /// The list of trains what the UI is going to use
    @Published var trainList: [TrainInfo] = []
    @Published private(set) var listIsComplete = false
    
    /**
     This asynchronous function retrieves the list of trains from the remote API.
     
     It fetches the data about the single trains using the `withTrowingTaskGroup` to wait for the completion of all tasks without interrupting the UI.
     
     - parameter reload: Set `true` if you want to clear the previous data.
     - warning: This is an async function
     */
    @MainActor
    func loadTrainList(reload: Bool = false) async {
        /// Ask the TrainAPIManager to load the base list of departing trains.
        let trainSummary = await TrainAPIManager.shared.loadTrainList(station: "Naples", from: (reload ? 0 : trainList.count))
        
        /// If trainSummary is nil we exit the function. Here we should handle the error and show it to the user!
        guard let trainSummary = trainSummary else {
            return
        }
        
        do {
            /// Assign to `trainList` the result of `withThrowingTaskGroup` which will be assigned after the completion of all the tasks that we are going to schedule inside
            trainList = try await withThrowingTaskGroup(of: TrainInfo.self) { group -> [TrainInfo] in
                /// If the user refreshes the view, we should wipe all the previous data
                var trainToAdd = (reload ? [] : trainList)
                
                /// For each train code that we have, we are going to create a new task to fetch more detailed info
                for newTrain in trainSummary.trains {
                    /// Here we are adding an *async task * to the `TaskGroup`
                    group.addTask {
                        /// Since we have a *ThrowingTaskGroup*, we can also throw an exception if something happens
                        /// So here, we check if the result is not nil and then return it as a result
                        if let result = try await newTrain.getTrainInfo() {
                            return result
                        }
                        /// If the result is `nil`, we can throw a custom exception. It will be handled without any problem, and the execution of other tasks will continue.
                        throw FetchTrainDataError.trainInfoNil
                    }
                }
                
                /// This `for` cycle will be executed once the task has been completed. It will cycle all the `TrainInfo` that we got as a result.
                for try await train in group {
                    /// Add the `TrainInfo` from the API to the list
                    trainToAdd.append(train)
                }
                
                /// This is the value that will be returned from `withThrowingTaskGroup`
                return trainToAdd
            }
        } catch {
            print("Error loading train data: \(error)")
        }
        
        /// Since we make paginated requests, we have to check if we have reached the end of the list.
        if trainList.count == trainSummary.count {
            listIsComplete = true
        }
    }
}

