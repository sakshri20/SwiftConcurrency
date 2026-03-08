//
//  DownloadImages.swift
//  SwiftConcurrency
//
//  Created by Sakshi Shrivastava on 3/2/26.
//

import SwiftUI
import Combine

class DownloadImagesAsyncImageLoader {
    
    let url: URL = URL(string: "https://picsum.photos/200")!
    
    func handleResponse(data: Data?, response: URLResponse?) -> UIImage? {
        guard
            let data = data,
            let response = response as? HTTPURLResponse,
            let image = UIImage(data: data),
            response.statusCode >= 200 && response.statusCode <= 300 else {
            
            return nil
        }
        
        return image
    }
    
    /* Method 1 - Old way - escaping closures
    func downloadWithEscaping(completionHandler: @escaping (_ image: UIImage?, _ error: Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: { [weak self] data, response, error in
            
            let image = self?.handleResponse(data: data, response: response)
            completionHandler(image, nil)
        })
        .resume()
    }
     */
    
    // Method 2 - Combine way
    func downloadImageWithCombine() -> AnyPublisher<UIImage?, Error> {
        URLSession.shared.dataTaskPublisher(for: url)
            .map(handleResponse)
            .mapError({ $0 })
            .eraseToAnyPublisher()
    }
    
    // Method 3 - Async await way
    func downloadImageWithAsync() async throws -> UIImage? {
        
        do {
            let (data, response) = try await URLSession.shared.data(for: URLRequest(url: url))
            return handleResponse(data: data, response: response)
        } catch {
            throw error
        }
        
    }
}

class DownloadImagesViewModel: ObservableObject {
    
    @Published var image: UIImage? = nil
    let loader = DownloadImagesAsyncImageLoader()
    var cancellables = Set<AnyCancellable>()
    
    func fetchImage() async {
        // self.image = UIImage(systemName: "heart.fill")
    
        /*
        loader.downloadWithEscaping(completionHandler: { [weak self] image, error in
            
            /* This can give an error - "Publishing chnages from background thread is not allowed"
            if let image = image {
                self?.image = image
            }
             */
            
            /*
            DispatchQueue.main.async(execute: {
                self?.image = image
            })
             */
        })
         */
        
        // Using combine
        /* loader.downloadImageWithCombine()
            .receive(on: DispatchQueue.main)
            .sink { _ in
                
            } receiveValue: { [weak self] image in
                self?.image = image
            }
            .store(in: &cancellables)
         */
        

        // Using async/await
        do {
            let image = try await loader.downloadImageWithAsync()
            await MainActor.run(body: {
                self.image = image
            })
        } catch {
            // handle error if needed
        }
    }
}

struct DownloadImages: View {
    
    @StateObject var viewModel = DownloadImagesViewModel()
    
    var body: some View {
        ZStack {
            if let image = viewModel.image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 250, height: 250)
            }
        }
        .onAppear() {
            Task {
                await viewModel.fetchImage()
            }
        }
    }
}

#Preview {
    DownloadImages()
}
