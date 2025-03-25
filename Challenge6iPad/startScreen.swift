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
            NavigationLink(destination: ClothingDesignListView()) {

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

            ZStack{
                Circle()
                    .fill(.blue)
                    
                    .stroke(Color.white, lineWidth: 6)
                    .frame(width: 400, height: 400)
                    .padding()

                // white outline
                
                VStack(spacing: 50) {
                    Image("House of ")
                        .resizable()
                        .frame(width: 250, height: 250)
                        .padding(.bottom, 235)
                    
                    Text("Casa of Love")
                        .font(.system(size: 50, weight: .bold))
                        .foregroundColor(.white)
                }
            }
                    }
                }
            }
        }
    }


#Preview {
    startScreen()
}
