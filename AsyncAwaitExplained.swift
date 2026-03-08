//
//  AsyncAwaitExplained.swift
//  SwiftConcurrency
//
//  Created by Sakshi Shrivastava on 3/2/26.
//

import SwiftUI
import Combine

class AsyncAwaitViewModel : ObservableObject {
    
    @Published var dataArray: [String] = []
    
    func addTitle1() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
            self.dataArray.append("Title 1: \(Thread.current)")
        })
    }
    
    func addTitle2() {
        DispatchQueue.global().asyncAfter(deadline: .now() + 2, execute: {
            self.dataArray.append("Title 2: \(Thread.current)")
        })
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3, execute: {
            self.dataArray.append("Title 3: \(Thread.current)")
        })
    }
    
    @MainActor
    func addAuthor() async {
        let author1IsMain = await MainActor.run { Thread.isMainThread }
        let author1 = "Author 1 \(author1IsMain)"
        self.dataArray.append(author1)
        
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        
        let author2IsMain = await MainActor.run { Thread.isMainThread }
        let author2 = "Author 2 \(author2IsMain)"
        self.dataArray.append(author2)
    }
    
    @MainActor
    func doSomething() async {
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        
        let something1IsMain = await MainActor.run { Thread.isMainThread }
        let something1 = "something 1 \(something1IsMain)"
        self.dataArray.append(something1)
        
        let something2IsMain = await MainActor.run { Thread.isMainThread }
        let something2 = "something 2 \(something2IsMain)"
        self.dataArray.append(something2)
    }
}

struct AsyncAwaitExplained: View {
    
    @StateObject private var viewModel = AsyncAwaitViewModel()
    
    var body: some View {
        List {
            ForEach(viewModel.dataArray, id: \.self, content: { data in
                Text(data)
            })
        }
        .onAppear(perform: {
            Task {
                await viewModel.addAuthor()
                await viewModel.doSomething()
                
                let finalText = "Final Text"
                viewModel.dataArray.append(finalText)
            }
//            viewModel.addTitle1()
//            viewModel.addTitle2()
        })
    }
}

#Preview {
    AsyncAwaitExplained()
}
