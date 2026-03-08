//
//  DoCatchTryThrowsExample.swift
//  SwiftConcurrency
//
//  Created by Sakshi Shrivastava on 3/2/26.
//

import SwiftUI
import Combine

class DoCatchTryThrowsDataManager {
    
    let isActive: Bool = true
    
    func getTitle() -> (title: String?, error: Error?) {
        if isActive {
            return ("NEW TEXT!", nil)
        } else {
            return (nil, URLError(.badURL))
        }
    }
    
    func getTitleUpdated() -> Result<String, Error> {
        if isActive {
            return .success("NEW TEXT!")
        } else {
            return .failure(URLError(.appTransportSecurityRequiresSecureConnection))
        }
    }
    
    func getTitleAdvanced() throws -> String {
        
//        if isActive {
//            return "NEW TEXT!"
//        } else {
//            throw URLError(.badServerResponse)
//        }
        
        throw URLError(.badServerResponse)
    }
    
    func getTitleFinal() throws -> String {
        
        if isActive {
            return "FINAL TEXT!"
        } else {
            throw URLError(.badServerResponse)
        }
    }
}

class DoCatchTryThrowsViewModel: ObservableObject {
    
    @Published var text: String = "Starting text"
    let manager = DoCatchTryThrowsDataManager()
    
    func fetchTitle() {
        
        /*
        let result = manager.getTitle()
        
        if let title = result.title {
            self.text = title
        } else if let error = result.error {
            self.text = error.localizedDescription
        }
         */
        
        /*
        let result = manager.getTitleUpdated()
        
        switch result {
        case .success(let newTitle):
            self.text = newTitle
            
        case .failure(let error):
            self.text = error.localizedDescription
        }
         */
        
        do {
            // there can be multiple try statements in a do block
            // If any of the try statement fails, we exit out of do block and move to catch
            let newTitle = try? manager.getTitleAdvanced()
            
            if let newTitle = newTitle {
                self.text = newTitle
            }
            
            let finalTitle = try manager.getTitleFinal()
            self.text = finalTitle
            
        } catch let error {
            self.text = error.localizedDescription
        }
    }
    
}

struct DoCatchTryThrowsExample: View {
    
    @StateObject private var viewModel = DoCatchTryThrowsViewModel()
    
    var body: some View {
        Text(viewModel.text)
            .frame(width: 300, height: 300)
            .background(.blue)
            .onTapGesture(perform: {
                viewModel.fetchTitle()
            })
    }
}

#Preview {
    DoCatchTryThrowsExample()
}
