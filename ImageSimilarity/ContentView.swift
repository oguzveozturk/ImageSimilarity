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
    
    let columns = [GridItem(.adaptive(minimum: 90, maximum: 110))]
    
    var body: some View {
        NavigationView {
            ScrollView(showsIndicators: false) {
                Picker("", selection: $selection) {
                    Text("Mixed").tag(0)
                    Text("Ordered").tag(1)
                }.pickerStyle(.segmented)

                LazyVGrid(columns: columns) {
                    ForEach(ordered ? viewModel.groupedUrls : viewModel.stockUrls, id:\.self) { section in
                        Section("") {
                            ForEach(section,id:\.self) { url in
                                AsyncImage(url: url) { image in
                                    image.resizable()
                                } placeholder: {
                                    Color(.systemGray6)
                                }
                                .frame(height: 80)
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
                    Button("Add") {
                        selection = 0
                        showGallery.toggle()
                    }
                }
            }
        }
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
