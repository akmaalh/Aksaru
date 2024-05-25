//
//  ContentView.swift
//  Aksaru
//
//  Created by Akmal Hakim on 20/05/24.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationView {
            HStack(alignment: .bottom, spacing: 26) {
                VStack(alignment: .leading, spacing: 0) { 
                    Text("Aksaru!")
                      .font(
                        Font.custom("Chubbo", size: 128)
                          .weight(.bold)
                      )
                      .foregroundColor(.black)
                    NavigationLink(destination: LetterListView()) {
                        VStack(alignment: .leading, spacing: 0) {
                            Text("Aksara List")
                                .font(Font.custom("Chubbo", size: 64).weight(.bold))
                                .foregroundColor(.black)
                        }
                        .padding(.horizontal, 35)
                        .padding(.vertical, 31)
                        .frame(width: 569, height: 572, alignment: .topLeading)
                        .background(Color(red: 0.75, green: 0.7, blue: 0.89))
                        .cornerRadius(27)
                    }
                    .padding(0)
                }
                .padding(0)
                NavigationLink(destination: QuizView()) {
                    VStack(alignment: .leading, spacing: 0) {
                        Text("Latihan Menulis")
                            .font(Font.custom("Chubbo", size: 64).weight(.bold))
                            .foregroundColor(.black)
                    }
                    .padding(.horizontal, 35)
                    .padding(.vertical, 31)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                    .background(Color(red: 0.93, green: 0.66, blue: 0.49))
                    .cornerRadius(27)
                }
            }
            .padding(.horizontal, 24)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

#Preview {
    ContentView()
}
