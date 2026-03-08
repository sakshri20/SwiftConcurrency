//
//  TasksExample.swift
//  SwiftConcurrency
//
//  Created by Sakshi Shrivastava on 3/3/26.
//

import SwiftUI
import Combine

class TasksExampleViewModel: ObservableObject {
    
    @Published var image1: UIImage? = nil
    @Published var image2: UIImage? = nil
    
    func fetchImage1() async {
        try? await Task.sleep(nanoseconds: 5_000_000_000)
        
        /*
        if this were a long taks with a lot of computation, than even though the task gets cancelled
        when the view disappears the computation that stated will continue and it will reduce performance
         
         So you need to add a check for task cancelation
         
         for x in array {
         
            try Task.checkCancellation() { break }
            
            // do work
         
         }
         */
        
        do {
            guard let url = URL(string: "https://picsum.photos/200") else { return }
            let (data, _) = try await URLSession.shared.data(from: url)
            self.image1 = UIImage(data: data)
            print("Image Download Complete!")
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func fetchImage2() async {
        
        do {
            guard let url = URL(string: "https://picsum.photos/200") else { return }
            let (data, _) = try await URLSession.shared.data(from: url)
            self.image2 = UIImage(data: data)
        } catch {
            print(error.localizedDescription)
        }
    }
}

struct TasksExampleHome: View {
    var body: some View {
        NavigationStack {
            ZStack {
                Color.yellow.ignoresSafeArea()
                
                NavigationLink("Click Me!!", destination: TasksExample())
            }
        }
    }
}

struct TasksExample: View {
    
    @StateObject private var viewModel = TasksExampleViewModel()
    @State private var fetchImageTask: Task<(), Never>? = nil
    
    var body: some View {
        
        VStack{
            if let image1 = viewModel.image1 {
                Image(uiImage: image1)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
            }
            
            if let image2 = viewModel.image2 {
                Image(uiImage: image2)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
            }
        }
        .task {
            await viewModel.fetchImage1()
        }
//        .onDisappear() {
//            fetchImageTask?.cancel()
//        }
//        .onAppear {
//            fetchImageTask = Task {
//                print(Thread.current)
//                print(Task.currentPriority)
//                await viewModel.fetchImage1()
//            }
//            
//            Task {
//                print(Thread.current)
//                print(Task.currentPriority)
//                await viewModel.fetchImage2()
//            }
//            
//            Task(priority: .high, operation: {
//                // try? await Task.sleep(nanoseconds: 2_000_000_000)
//                await Task.yield()
//                print("high: \(Thread.current) : \(Task.currentPriority)")
//            })
//            Task(priority: .background, operation: {
//                print("background: \(Thread.current) : \(Task.currentPriority)")
//            })
//            Task(priority: .low, operation: {
//                print("low: \(Thread.current) : \(Task.currentPriority)")
//            })
//            Task(priority: .medium, operation: {
//                print("medium: \(Thread.current) : \(Task.currentPriority)")
//            })
//            Task(priority: .userInitiated, operation: {
//                print("userInitiated: \(Thread.current) : \(Task.currentPriority)")
//            })
//            Task(priority: .utility, operation: {
//                print("utility: \(Thread.current) : \(Task.currentPriority)")
//            })
            
//            Task(priority: .low, operation: {
//                print("low: \(Thread.current) : \(Task.currentPriority)")
//                
//                Task.detached {
//                    print("low: \(Thread.current) : \(Task.currentPriority)")
//                }
//            })
//        }
    }
}

#Preview {
    TasksExample()
}
