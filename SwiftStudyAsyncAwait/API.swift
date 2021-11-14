//
//  API.swift
//  SwiftStudyAsyncAwait
//
//  Created by Nico Prananta on 12.11.21.
//

import Foundation
import UIKit

struct Cat: Codable, Identifiable {
  let id: String
  let url: String
}

func getCats() async throws -> [Cat] {
  var request = URLRequest(url: URL(string: "https://api.thecatapi.com/v1/images/search?limit=3&size=full")!)
  request.httpMethod = "GET"
  request.setValue("", forHTTPHeaderField: "-api-key")
  
  let (response, _) = try await URLSession.shared.data(for: request)
  let data = try JSONDecoder().decode([Cat].self, from: response)
  return data
}
