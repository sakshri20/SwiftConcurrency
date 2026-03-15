//
//  GlobalActorsExample.swift
//  SwiftConcurrency
//
//  Created by Sakshi Shrivastava on 3/14/26.
//

import SwiftUI
import Combine

@globalActor struct MyFirstGlobalActors {
    
    static var shared = MyNewDataManager()
}

actor MyNewDataManager {
    
    func getDataFromDatabase() -> [String] {
        return ["One", "Two" , "Three", "Four", "Five"]
    }
    
}

class GlobalActorsViewMode: ObservableObject {
    
    @Published var dataArray: [String] = []
    let manager = MyFirstGlobalActors.shared
    
    @MyFirstGlobalActors func getData() {
        
        // Heavy and complex method - don't want to run this on main actor
        
        // If you have a method that is not part of an actor but you want to run it in isolation - that's when you use global actors
        Task {
            let data = await manager.getDataFromDatabase()
            
            await MainActor.run {
                self.dataArray = data
            }
        }
    }
}

struct GlobalActorsExample: View {
    
@StateObject private var viewModel = GlobalActorsViewMode()
    
    var body: some View {
        ScrollView {
            VStack {
                ForEach(viewModel.dataArray, id: \.self, content: {
                    Text($0)
                        .font(.headline)
                })
            }
        }
        .task {
            await viewModel.getData()
        }
    }
}

#Preview {
    GlobalActorsExample()
}
