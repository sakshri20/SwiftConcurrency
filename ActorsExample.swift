//
//  ActorsExample.swift
//  SwiftConcurrency
//
//  Created by Sakshi Shrivastava on 3/14/26.
//

import SwiftUI
import Combine

// What is the problem that Actors are solving? - data race problem
// How was this problem solved before actors?
// Actors can solve the problem!

class MydataManager {
    static let instance = MydataManager()
    private init() { }
    
    var data: [String] = []
    private let queue = DispatchQueue(label: "com.MyApp.MydataManager.queue")
    
    func getRandomData(completionHandle: @escaping (_ title: String?) -> ()) {
        queue.async {
            self.data.append(UUID().uuidString)
            print(Thread.current)
            completionHandle(self.data.randomElement())
        }
    }
}

actor MyActorDataManager {
    
    static let instance = MyActorDataManager()
    private init() { }
    
    var data: [String] = []
    nonisolated let myRandonText = "Something"
    
    func getRandomData() -> String? {
        self.data.append(UUID().uuidString)
        print(Thread.current)
        return self.data.randomElement()
    }
    
    nonisolated func getSavedData() -> String {
         return "Saved Data"
    }
}

struct HomeView: View {
    
    // let manager = MydataManager.instance
    let manager = MyActorDataManager.instance
    @State private var text: String = ""
    let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            Color.gray.opacity(0.8).ignoresSafeArea()
            
            Text(text)
                .font(.headline)
        }
//        .onReceive(timer, perform: { _ in
//            DispatchQueue.global(qos: .background).async(execute: {
//                manager.getRandomData(completionHandle: {title in
//                    if let data = title {
//                        DispatchQueue.main.async() {
//                            self.text = data
//                        }
//                    }
//                })
//            })
//        })
        .onAppear() {
            // let newString = manager.getSavedData()
            let newString = manager.myRandonText
        }
        .onReceive(timer, perform: { _ in
            Task {
                if let data = await manager.getRandomData() {
                    await MainActor.run {
                        self.text = data
                    }
                }
            }
        })
    }
}

struct BrowseView: View {
    
    // let manager = MydataManager.instance
    let manager = MyActorDataManager.instance
    @State private var text: String = ""
    let timer = Timer.publish(every: 0.01, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            Color.yellow.opacity(0.8).ignoresSafeArea()
            
            Text(text)
                .font(.headline)
        }
//        .onReceive(timer, perform: { _ in
//            DispatchQueue.global(qos: .default).async(execute: {
//                manager.getRandomData(completionHandle: {title in
//                    if let data = title {
//                        DispatchQueue.main.async() {
//                            self.text = data
//                        }
//                    }
//                })
//            })
//        })
        .onReceive(timer, perform: { _ in
            Task {
                if let data = await manager.getRandomData() {
                    await MainActor.run {
                        self.text = data
                    }
                }
            }
        })
    }
}

struct ActorsExample: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem({
                    Label("Home", systemImage: "house.fill")
                })
            BrowseView()
                .tabItem({
                    Label("Browse", systemImage: "magnifyingglass")
                })
        }
    }
}

#Preview {
    ActorsExample()
}
