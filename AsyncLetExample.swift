//
//  AsyncLetExample.swift
//  SwiftConcurrency
//
//  Created by Sakshi Shrivastava on 3/3/26.
//

import SwiftUI

struct AsyncLetExample: View {
    
    @State private var images: [UIImage] = []
    let columns = [GridItem(.flexible()), GridItem(.flexible())]
    let url = URL(string: "https://picsum.photos/200")!
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: columns, content: {
                    ForEach(images, id: \.self, content: { image in
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 150)
                    })
                })
            }
            .navigationTitle(Text("Async Let 🥳"))
            .onAppear() {
                Task {
                    do {
                        
                        /*
                         Async let is great for running multiple async functions at once and
                         awaiting the results for all of them.
                         You can also call multiple async functions at once the returns differnt types.
                        */
                        async let fetchImage1 = fetchImage()
                        async let fetchImage2 = fetchImage()
                        async let fetchImage3 = fetchImage()
                        async let fetchImage4 = fetchImage()
                        
                        let (image1, image2, image3, image4) = try await (fetchImage1, fetchImage2, fetchImage3, fetchImage4)
                        self.images.append(contentsOf: [image1, image2, image3, image4])
                        
//                        let image1 = try await fetchImage()
//                        self.images.append(image1)
//                        
//                        let image2 = try await fetchImage()
//                        self.images.append(image2)
//                        
//                        let image3 = try await fetchImage()
//                        self.images.append(image3)
//                        
//                        let image4 = try await fetchImage()
//                        self.images.append(image4)
//                        
//                        let image5 = try await fetchImage()
//                        self.images.append(image5)
                    }
                }
            }
        }
    }
    
    func fetchImage() async throws -> UIImage {
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

#Preview {
    AsyncLetExample()
}
