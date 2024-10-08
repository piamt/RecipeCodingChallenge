//
//  RecipeListViewModel.swift
//  RecipesCodingChallenge
//
//  Created by Pia on 1/10/24.
//

import Foundation

class RecipeListViewModel: ObservableObject {
    
    var getRecipeUseCase: GetRecipesUseCase
    
    @Published var recipes: [Recipe] = []
    @Published var searchButtonAvailable: Bool = true
    @Published var showAlertInternetConnectivity: Bool = false
    @Published var showAlertUnknownError: Bool = false
    var lastSearch = ""
    
    init(useCase: GetRecipesUseCase) {
        self.getRecipeUseCase = useCase
    }
    
    public func getRecipes(search: String) {
        guard lastSearch != search else { return }
        lastSearch = search
        Task {
            do {
                ViewDispatcher.shared.execute {
                    self.searchButtonAvailable = false
                }
                let rec = try await getRecipeUseCase.execute(search)
                ViewDispatcher.shared.execute {
                    self.recipes = rec
                }
            } catch {
                ViewDispatcher.shared.execute {
                    self.searchButtonAvailable = true
                }
                guard let useCaseError = error as? GetRecipesUseCaseError else {
                    ViewDispatcher.shared.execute {
                        self.showAlertUnknownError = true
                    }
                    return
                }
                switch useCaseError {
                case .networkError:
                    ViewDispatcher.shared.execute {
                        self.showAlertInternetConnectivity = true
                    }
                case .decodingError, . undefinedError:
                    ViewDispatcher.shared.execute {
                        self.showAlertUnknownError = true
                    }
                }
            }
        }
    }
    
    func searchTextChanged() {
        ViewDispatcher.shared.execute {
            self.searchButtonAvailable = true
        }
    }
}
