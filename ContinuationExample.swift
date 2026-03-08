//
//  ContinuationExample.swift
//  SwiftConcurrency
//
//  Created by Sakshi Shrivastava on 3/4/26.
//

import SwiftUI
import Combine

class ContinuationExampleNetworkManager {
    
    func fetchImage(urlString: String) async throws -> Data {
        
        do {
            let (data, _) = try await URLSession.shared.data(for: URLRequest(url: URL(string: urlString)!))
            return data
        } catch {
            throw error
        }
    }
    
    func fetchImageWithContinuation(urlString: String) async throws -> Data {
        return try await withCheckedThrowingContinuation { continuation in
            let task = URLSession.shared.dataTask(with: URL(string: urlString)!) { data, _, error in
                
                if let data = data {
                    continuation.resume(returning: data)
                } else if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(throwing: URLError(.badURL))
                }
            }
            task.resume()
        }
    }
    
    func getHeartImageFromDatabase(_ completionHandler: @escaping (_ image: UIImage) -> ()) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 5, execute: {
            completionHandler(UIImage(systemName: "heart.fill")!)
        })
    }
    
    func getHeartImageFromDatabase() async -> UIImage {
        
        return await withCheckedContinuation { continuation in
            getHeartImageFromDatabase { image in
                continuation.resume(returning: image)
            }
        }
    }
}

class ContinuationExampleViewModel: ObservableObject {
    
    @Published var image: UIImage? = nil
    let networkManager = ContinuationExampleNetworkManager()
    
    func getImage() async {
        do {
            let data = try await networkManager.fetchImageWithContinuation(urlString: "https://picsum.photos/200")
            if let image = UIImage(data: data) {
                await MainActor.run(body: {
                    self.image = image
                })
            }
        } catch {
            print(error)
        }
    }
    
    func getHeartImage() async {
        self.image = await networkManager.getHeartImageFromDatabase()
    }
    
}

struct ContinuationExample: View {
    
    @StateObject private var viewModel = ContinuationExampleViewModel()
    
    var body: some View {
        ZStack {
            if let image = viewModel.image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
            }
        }
        .task {
            // await viewModel.getImage()
            await viewModel.getHeartImage()
        }
    }
}

#Preview {
    ContinuationExample()
}
