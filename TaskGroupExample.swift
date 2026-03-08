//
//  TaskGroupExample.swift
//  SwiftConcurrency
//
//  Created by Sakshi Shrivastava on 3/3/26.
//

import SwiftUI
import Combine

class TaskGroupExampleDataManager {
    
    private let url = "https://picsum.photos/200"
    
    func fetchImagesWithAsyncLet() async throws -> [UIImage] {
        
        async let fetchImage1 = fetchImage(urlString: url)
        async let fetchImage2 = fetchImage(urlString: url)
        async let fetchImage3 = fetchImage(urlString: url)
        async let fetchImage4 = fetchImage(urlString: url)
        
        let (image1, image2, image3, image4) = try await (fetchImage1, fetchImage2, fetchImage3, fetchImage4)
        return [image1, image2, image3, image4]
        
    }
    
    func fetchImagesWithTaskGroups() async throws -> [UIImage] {
        
        let imageStringArray = [
            "https://picsum.photos/200",
            "https://picsum.photos/200",
            "https://picsum.photos/200",
            "https://picsum.photos/200",
            "https://picsum.photos/200",
            "https://picsum.photos/200",
            "https://picsum.photos/200",
            "https://picsum.photos/200",
            "https://picsum.photos/200"
        ]
        
        return try await withThrowingTaskGroup(of: UIImage.self, body: { group in
            
            var images = [UIImage]()
            
            /*
             Here is any of the tasks fails we will get an alert, which I have handled through an
             error message.
             Optionally you can make the try? and all the return trypes as UIImage?
             */
            for url in imageStringArray {
                group.addTask(operation: {
                    try await self.fetchImage(urlString: url)
                })
            }
            
            for try await image in group {
                images.append(image)
            }
            
            return images
        })
    }
    
    private func fetchImage(urlString: String) async throws -> UIImage {
        
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            if let image = UIImage(data: data) {
                return image
            } else {
                throw URLError(.badURL)
            }
        } catch {
            throw error
        }
    }
}

class TaskGroupExampleViewModel: ObservableObject {
    
    @Published var images: [UIImage] = []
    let manager = TaskGroupExampleDataManager()
    @Published var errorMessage: String = ""
    
    func loadImages() async {
        if let result = try? await manager.fetchImagesWithTaskGroups() {
            images.append(contentsOf: result)
        } else {
            errorMessage = "Failed to fetch images."
        }
    }
}

struct TaskGroupExample: View {
    
    @StateObject private var viewModel = TaskGroupExampleViewModel()
    @State private var isShowingError = false
    let columns = [GridItem(.flexible()), GridItem(.flexible())]
    
    
    var body: some View {
        NavigationStack {
            ScrollView {
                if viewModel.errorMessage.isEmpty {
                    LazyVGrid(columns: columns, content: {
                        ForEach(viewModel.images, id: \.self, content: { image in
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFit()
                                .frame(height: 150)
                        })
                    })
                } else {
                    VStack { }
                        .alert(
                            "Error",
                            isPresented: $isShowingError,
                            actions: { },
                            message: {
                                Text(viewModel.errorMessage)
                            }
                        )
                }
            }
            .navigationTitle(Text("Task Groups 🥳"))
            .task {
                await viewModel.loadImages()
            }
            .onChange(of: viewModel.errorMessage) { _, newValue in
                isShowingError = !newValue.isEmpty
            }
        }
    }
}

#Preview {
    TaskGroupExample()
}
