//
//  ContentView.swift
//  NetworkCallsAsync
//
//  Created by Harry Kwesi De Graft on 16/01/24.
//

import SwiftUI

struct ContentView: View {
    @State private var meals: [Meal] = []
    
    var body: some View {
        NavigationView{
            List{
                    ForEach(meals, id: \.idCategory){ meal in
                        HStack {
                            AsyncImage(url: URL(string: meal.strCategoryThumb)) { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 100, height: 100)
                            } placeholder: {
                                Image(systemName: "photo.artframe")
                                              .resizable()
                                              .frame(width: 50, height: 50)
                                              .background(Color.gray)
                            }
                            
                            Text(meal.strCategory)
                               .bold()
                        }
                        .padding(3)
                   }
            } .navigationTitle("Meals")
                .task {
                    do {
                        meals = try await fetchMeals()

                    } catch NetworkError.invalidURL {
                        print ("invalid url")
                    } catch NetworkError.invalidResponse{
                        print ("invalid response")
                    } catch NetworkError.invalidData {
                        print ("invalid data")
                    } catch {
                        print ("unexpected error")
                    }
                }
        }
       
    }
    func fetchMeals() async throws -> [Meal] {
        let endpoint = "https://www.themealdb.com/api/json/v1/1/categories.php"
        guard let url = URL (string: endpoint) else {
            throw NetworkError.invalidURL
        }
        let (data, response) = try await URLSession.shared.data(from: url)
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            throw NetworkError.invalidResponse
        }
        do {
            let decoder = JSONDecoder()
            let decodedData = try decoder.decode(CategoryResponse.self, from: data)
            return decodedData.categories
        } catch{
            throw NetworkError.invalidData
        }
    }
}

#Preview {
    ContentView()
}


struct Meal : Hashable, Codable, Identifiable {
    let idCategory: String
    let strCategory: String
    let strCategoryThumb : String
    let strCategoryDescription: String
    
    var id: String { idCategory }
}


enum NetworkError: Error {
    case invalidURL
    case invalidData
    case unauthorised
    case timeout
    case serverError
    case invalidResponse
}

struct CategoryResponse: Decodable {
    let categories: [Meal]
}


