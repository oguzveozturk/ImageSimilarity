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
    @State private var indexes = [Array(0...10)]
    
    let columns = [GridItem(.adaptive(minimum: 90, maximum: 110))]
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            Picker("", selection: $selection) {
                Text("Mixed").tag(0)
                Text("Ordered").tag(1)
            }.pickerStyle(.segmented)
            
            LazyVGrid(columns: columns) {
                ForEach(indexes, id:\.self) { section in
                    Section("") {
                        ForEach(section,id:\.self) { i in
                            AsyncImage(url: Bundle.main.url(forResource: "\(i)", withExtension: "jpg")) { image in
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
        .onChange(of: selection) { newValue in
            withAnimation {
                newValue == 0 ? (indexes = viewModel.mixed) : (indexes = viewModel.grouped)
            }
        }
    }
}
