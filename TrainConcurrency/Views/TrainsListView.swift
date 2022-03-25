//
//  ContentView.swift
//  TrainConcurrency
//
//  Created by Mattia Fochesato on 22/03/22.
//

import SwiftUI

/** Main Train List View */
struct TrainsListView: View {
    /// TrainList View controller that manager the data
    @ObservedObject var viewController = TrainListViewController()
    
    var body: some View {
        ScrollView {
            LazyVStack {
                /// Display every train present in the list
                ForEach(viewController.trainList) { train in
                    TrainListItem(train: train)
                    Divider()
                }
                /// Show the loading indicator at the bottom of the list only if the are more items to load
                if !viewController.listIsComplete {
                    ProgressView()
                    /// Execute the code only when the progress view appears on the screen
                        .onAppear {
                            /// Load the next chunck of trains with an asyncronous task
                            Task.init {
                                await viewController.loadTrainList()
                            }
                        }
                }
            }
        }
        /// Pull to reload: reload the list of departing trains
        .refreshable {
            await viewController.loadTrainList(reload: true)
        }
        .navigationTitle("Departing Trains")
    }
}

/** Train Info Row  */
struct TrainListItem: View {
    /// Train data to show
    var train: TrainInfo
    
    @State private var expanded = false
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                /// Leading view with train info
                VStack(alignment: .leading) {
                    Text("Train To")
                        .font(.footnote)
                    Text(train.destination)
                        .font(.title2)
                    Text(train.name)
                        .font(.body)
                        .foregroundColor(.gray)
                }
                Spacer()
                /// Trailing view with next stop
                VStack(alignment: .trailing) {
                    Text("Next Stop")
                        .font(.footnote)
                    let nextStop = train.trainStops.first!
                    Text(nextStop.name)
                    Text(getString(nextStop.time))
                        .bold()
                }
                Image(systemName: (expanded ? "chevron.up" : "chevron.down"))
            }
            /// Section to show only if the view is expanded
            if expanded {
                Divider()
                Text("Stops")
                /// Show all the stops of the train
                ForEach(train.trainStops, id: \.id) { stop in
                    HStack {
                        Circle()
                            .frame(width: 20, height: 20)
                        VStack(alignment: .leading) {
                            Text(stop.name)
                            Text(getString(stop.time))
                                .font(.footnote)
                        }
                    }
                }
            }
        }
        .padding([.leading, .trailing])
        .frame(maxWidth: .infinity, alignment: .leading)
        .contentShape(Rectangle())
        .onTapGesture {
            /// Expand the view on click
            expanded.toggle()
        }
        .onHover { inside in
            /// Change the cursor on hover
            if inside {
                NSCursor.pointingHand.push()
            } else {
                NSCursor.pop()
            }
        }
    }
    
    /** Format the date to HH:mm  */
    func getString(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = NSLocale.current
        dateFormatter.dateFormat = "HH:mm"
        return dateFormatter.string(from: date)
    }
}

#if DEBUG
/** Xcode Preview */
struct TrainsListView_Previews: PreviewProvider {
    static var previews: some View {
        TrainsListView()
    }
}
#endif
