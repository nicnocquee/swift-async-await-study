//
//  CatsView.swift
//  SwiftStudyAsyncAwait
//
//  Created by Nico Prananta on 12.11.21.
//

import Foundation
import SwiftUI

struct CatImage: Identifiable {
  let cat: Cat
  let id: String
  var image: UIImage?
}

struct CatsView: View {
  @State var cats: [CatImage] = []
  var body: some View {
    ScrollView {
      VStack {
        ForEach(cats) { cat in
          if let image = cat.image {
            Image(uiImage: image)
              .resizable()
              .aspectRatio(contentMode: .fit)
              .frame(width: 200, height: 200)
          } else {
            HStack {
              ProgressView("Loading cat \(cat.id)")
            }
            .padding()
            .border(Color.gray)
          }
        }
      }
    }
    .task {
      /*
       do {
       let justCats = try await getCats()
       cats = justCats.map { CatImage(cat: $0, id: $0.id, image: nil) }
       var catWithImages: [CatImage] = []
       for cat in cats {
       let img = try await downloadCatImage(catImage: cat)
       catWithImages.append(CatImage(cat: cat.cat, id: cat.cat.id, image: img))
       }
       cats = catWithImages
       } catch {
       print(error)
       }
       */
      /*
      do {
        let justCats = try await getCats()
        cats = justCats.map { CatImage(cat: $0, id: $0.id, image: nil) }
        await withThrowingTaskGroup(of: Void.self) { group in
          for catImage in cats {
            group.addTask {
              let image = try await downloadCatImage(catImage: catImage)
              let newCatImage = CatImage(cat: catImage.cat, id: catImage.cat.id, image: image)
              cats = cats.map { cat in
                if cat.id == catImage.id {
                  return newCatImage
                }
                return cat
              }
            }
          }
        }
      } catch {
        print(error)
      }
      */
      
      do {
        let justCats = try await getCats()
        cats = justCats.map { CatImage(cat: $0, id: $0.id, image: nil) }
        try await withThrowingTaskGroup(of: CatImage.self) { group in
          for catImage in cats {
            group.addTask {
              let image = try await downloadCatImage(catImage: catImage)
              let newCatImage = CatImage(cat: catImage.cat, id: catImage.cat.id, image: image)
             return newCatImage
            }
          }
          
          var newCats = [CatImage]()
          for try await catImage in group {
            newCats.append(catImage)
          }
          cats = newCats
        }
      } catch {
        print(error)
      }
    }
  }
}

func downloadCatImage(catImage: CatImage) async throws -> UIImage? {
  print("Fetching \(catImage.cat.url)")
  await Task.sleep(UInt64(Int.random(in: 3...6) * 1_000_000_000))
  let (data, _) = try await URLSession.shared.data(from: URL(string: catImage.cat.url)!)
  print("Done fetching \(catImage.cat.url)")
  return UIImage(data: data)
}

struct CatsView_Previews: PreviewProvider {
  static var previews: some View {

    CatsView()
  }
}
