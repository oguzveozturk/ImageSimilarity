//
//  ContentView.swift
//  ImageSimilarity
//
//  Created by Oğuz Öztürk on 6.10.2022.
//

import SwiftUI

struct ContentView: View {
    
    @StateObject private var viewModel = ContentViewModel()

    @State private var selection = 0
    @State private var showGallery = false
    @State private var ordered = false
    
    let columns = [GridItem(.adaptive(minimum: 110),spacing: 10)]
    
    var body: some View {
        NavigationView {
            ScrollView(showsIndicators: false) {
                Picker("", selection: $selection) {
                    Text("Mixed").tag(0)
                    Text("Grouped").tag(1)
                }.pickerStyle(.segmented)

                LazyVGrid(columns: columns) {
                    ForEach(ordered ? viewModel.groupedUrls : viewModel.stockUrls, id:\.self) { section in
                        Section("") {
                            ForEach(section,id:\.self) { url in
                                AsyncImage(url: url,scale:0.4) { image in
                                    image
                                        .resizable()
                                        .scaledToFill()
                                } placeholder: {
                                    Color(.systemGray6)
                                }
                                .frame(width:110,height:80)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                            }
                        }
                    }
                }
            }
            .padding()
            .navigationTitle("Similar Images")
            .toolbar {
                ToolbarItem(placement:.navigationBarTrailing) {
                    AddContainer {
                        selection = 0
                        showGallery.toggle()
                    }
                }
            }
        }
        .navigationViewStyle(.stack)
        .sheet(isPresented: $showGallery, content: {
            PhotoPicker(filter:.images)
        })
        .onChange(of: selection) { newValue in
            withAnimation {
                ordered = newValue != 0
            }
        }
    }
}

struct AddContainer:View {
    @State private var text = "Add"
    var tapped:()->Void
    
    var body: some View {
        Button(text) {
            if text == "Add" {
                tapped()
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .indexes)) { notif in
            if let indexText = notif.userInfo?["data"] as? String {
                DispatchQueue.main.async {
                    text = indexText
                }
            }
        }
    }
}
