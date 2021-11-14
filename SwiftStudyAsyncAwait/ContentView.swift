//
//  ContentView.swift
//  SwiftStudyAsyncAwait
//
//  Created by Nico Prananta on 12.11.21.
//

import SwiftUI

func listPhotos() async -> [String] {
  print("getting photos ...")
  await Task.sleep(UInt64(Int.random(in: 2...4) * 1_000_000_000))
  print("got photos!")
  return ["cat1.jpg", "cat2.jpg", "cat3.jpg"]
}

func downloadPhoto(named name: String) async -> UIImage? {
  
  print("downloading photo \(name) ...")
  await Task.sleep(UInt64(Int.random(in: 3...6) * 1_000_000_000))
  print("got photo \(name)!")
  return UIImage(named: name)
  
  /*
   return await withCheckedContinuation { continuation in
   DispatchQueue.global().async {
   continuation.resume(returning: UIImage(named: name))
   }
   }
   */
}

struct Photo: Identifiable {
  let id: UUID
  var image: UIImage?
  let name: String
}

struct ContentView7: View {
  @State var photos: [Photo] = []
  @State var counter = 0
  
  var body: some View {
    ScrollView {
      VStack {
        HStack {
          Button("Tap me") {
            counter += 1
          }
          Text("\(counter) taps")
        }
        ForEach(photos) { photo in
          if let theImage = photo.image {
            Image(uiImage: theImage)
              .resizable()
              .aspectRatio(contentMode: .fit)
              .frame(width: 200, height: 200)
          } else {
            ProgressView("Loading image")
          }
        }
      }
    }
    .padding()
    .task {
      let photoNames = await listPhotos()
      photos = photoNames.map { Photo(id: UUID(), image: nil, name: $0) }
      await withTaskGroup(of: Photo.self) { group in
        for photo in photos {
          group.addTask {
            let image = await downloadPhoto(named: photo.name)
            return Photo(id: photo.id, image: image, name: photo.name)
          }
        }
        
        for await photo in group {
          photos = photos.map { p in
            if p.id == photo.id {
              return photo
            }
            return p
          }
        }
      }
    }
  }
}

struct ContentView6: View {
  @State var photos: [Photo] = []
  
  var body: some View {
    ScrollView {
      VStack {
        ForEach(photos) { photo in
          if let theImage = photo.image {
            Image(uiImage: theImage)
              .resizable()
              .aspectRatio(contentMode: .fit)
              .frame(width: 200, height: 200)
          } else {
            ProgressView("Loading image")
          }
        }
      }
    }
    .task {
      let photoNames = await listPhotos()
      photos = photoNames.map { Photo(id: UUID(), image: nil, name: $0) }
      await withTaskGroup(of: Photo.self) { group in
        for photo in photos {
          group.addTask {
            let image = await downloadPhoto(named: photo.name)
            return Photo(id: photo.id, image: image, name: photo.name)
          }
        }
        
        for await photo in group {
          photos = photos.map { p in
            if p.id == photo.id {
              return photo
            }
            return p
          }
        }
      }
    }
  }
}

struct ContentView5: View {
  @State var images: [UIImage?] = []
  
  var body: some View {
    ScrollView {
      VStack {
        ForEach(images, id: \.self) { image in
          if let theImage = image {
            Image(uiImage: theImage)
              .resizable()
              .aspectRatio(contentMode: .fit)
              .frame(width: 200, height: 200)
          } else {
            ProgressView("Loading image")
          }
        }
      }
    }
    .task {
      let photoNames = await listPhotos()
      images = [UIImage?](repeating: nil, count: photoNames.count)
      images = await withTaskGroup(of: UIImage?.self) { group in
        var photos = [UIImage?]()
        for name in photoNames {
          group.addTask {
            return await downloadPhoto(named: name)
          }
        }
        
        for await photo in group {
          photos.append(photo)
        }
        return photos
      }
    }
  }
}

struct ContentView4: View {
  @State var images: [UIImage?] = []
  
  var body: some View {
    ScrollView {
      VStack {
        ForEach(images, id: \.self) { image in
          if let theImage = image {
            Image(uiImage: theImage)
              .resizable()
              .aspectRatio(contentMode: .fit)
              .frame(width: 200, height: 200)
          } else {
            ProgressView("Loading image")
          }
        }
      }
    }
    .task {
      let photoNames = await listPhotos()
      images = [UIImage?](repeating: nil, count: photoNames.count)
      var photos: [UIImage?] = []
      for name in photoNames {
        await photos.append(downloadPhoto(named: name))
      }
      images = photos
    }
  }
}

struct ContentView: View {
  @State var image: UIImage?
  var body: some View {
    VStack {
      if let theImage = image {
        Image(uiImage: theImage)
          .resizable()
          .aspectRatio(contentMode: .fit)
          .frame(width: 200, height: 200)
      } else {
        ProgressView("Loading image")
      }
    }
    .task {
      let photoNames = await listPhotos()
      let sortedNames = photoNames.sorted()
      let name = sortedNames[0]
      image = await downloadPhoto(named: name)
    }
  }
}

struct ContentView2: View {
  @State var image1: UIImage?
  @State var image2: UIImage?
  @State var image3: UIImage?
  
  var body: some View {
    VStack(spacing: 30) {
      if let theImage = image1 {
        Image(uiImage: theImage)
          .resizable()
          .aspectRatio(contentMode: .fit)
          .frame(width: 200, height: 200)
      } else {
        ProgressView("Loading image 1")
      }
      if let theImage = image2 {
        Image(uiImage: theImage)
          .resizable()
          .aspectRatio(contentMode: .fit)
          .frame(width: 200, height: 200)
      } else {
        ProgressView("Loading image 2")
      }
      if let theImage = image3 {
        Image(uiImage: theImage)
          .resizable()
          .aspectRatio(contentMode: .fit)
          .frame(width: 200, height: 200)
      } else {
        ProgressView("Loading image 3")
      }
    }
    .task {
      let photoNames = await listPhotos()
      let sortedNames = photoNames.sorted()
      image1 = await downloadPhoto(named: sortedNames[0])
      image2 = await downloadPhoto(named: sortedNames[1])
      image3 = await downloadPhoto(named: sortedNames[2])
    }
  }
}

struct ContentView3: View {
  @State var image1: UIImage?
  @State var image2: UIImage?
  @State var image3: UIImage?
  
  var body: some View {
    VStack(spacing: 30) {
      if let theImage = image1 {
        Image(uiImage: theImage)
          .resizable()
          .aspectRatio(contentMode: .fit)
          .frame(width: 200, height: 200)
      } else {
        ProgressView("Loading image 1")
      }
      if let theImage = image2 {
        Image(uiImage: theImage)
          .resizable()
          .aspectRatio(contentMode: .fit)
          .frame(width: 200, height: 200)
      } else {
        ProgressView("Loading image 2")
      }
      if let theImage = image3 {
        Image(uiImage: theImage)
          .resizable()
          .aspectRatio(contentMode: .fit)
          .frame(width: 200, height: 200)
      } else {
        ProgressView("Loading image 3")
      }
    }
    .task {
      let photoNames = await listPhotos()
      let sortedNames = photoNames.sorted()
      async let img1 = downloadPhoto(named: sortedNames[0])
      async let img2 =  downloadPhoto(named: sortedNames[1])
      async let img3 =  downloadPhoto(named: sortedNames[2])
      
      let images = await [img1, img2, img3]
      image1 = images[0]
      image2 = images[1]
      image3 = images[2]
    }
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    // ContentView()
    //ContentView2()
    //ContentView3()
    //ContentView4()
    //ContentView5()
    // ContentView6()
    ContentView7()
  }
}
