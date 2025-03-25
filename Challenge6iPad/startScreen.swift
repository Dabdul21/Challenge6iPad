//
//  startScreen.swift
//  Challenge6iPad
//
//  Created by Dayan Abdulla on 3/24/25.
//

import SwiftUI

struct startScreen: View {
    var body: some View {
        NavigationStack{
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0/255, green: 0/255, blue: 0/255),           // almost black

                    
                    Color(red: 0/255, green: 40/255, blue: 94/255),         // deep navy blue
                    Color(red: 85/255, green: 142/255, blue: 235/255),      // sky blue
                    Color(red: 160/255, green: 180/255, blue: 255/255)      // light purplish blue
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .edgesIgnoringSafeArea(.all)

            
            VStack(spacing: 10){
                Image("Logo")
                    .resizable()
                    .frame(width: 250, height: 250) //img size
                    .padding(.bottom, 20)
                
                Text("Casa Love")
                    .font(.system(size: 48, weight: .medium))
                    .padding(.bottom, 100)
                    .foregroundColor(.white)

                
                NavigationLink(destination: Dashboard()) {
                    HStack{
                        Text("Browse Clothing")
                            .font(.system(size: 48, weight: .bold))
                        Spacer()
                        Image(systemName: "arrow.right")
                            .font(.system(size: 48))

                    }
                        .foregroundColor(.white)
                        .padding(.horizontal, 150)
                        .padding(.vertical, 45)
                        .background(Color(red: 31/255, green: 46/255, blue: 58/255))
                        .cornerRadius(25)

                        . overlay(
                            RoundedRectangle(cornerRadius: 25)
                                .stroke(Color.white, lineWidth: 6) // white outline background
                        )
                    
                        }
                    .padding(.horizontal, 100) // keeps the btn from touching the edge of screen
                    .padding(.bottom, 35)       //space in between btn's
                
                
                NavigationLink(destination: addDesign()) {
                    HStack{
                        Text("Add New Design")
                            .font(.system(size: 48, weight: .bold))

                        Spacer()
                        Image(systemName: "plus")
                            .font(.system(size: 48))

                    }
                        .foregroundColor(.white)
                        .padding(.horizontal, 150)
                        .padding(.vertical, 45)
                        .background(Color(red: 39/255, green: 80/255, blue: 114/255))
                        .cornerRadius(25)

                        . overlay(
                            RoundedRectangle(cornerRadius: 25)
                                .stroke(Color.white, lineWidth: 6) // white outline
                        )
                    }
                    .padding(.horizontal, 100) // keeps the btn from touching the screen

                    }
                }
            }
        }
    }


#Preview {
    startScreen()
}
