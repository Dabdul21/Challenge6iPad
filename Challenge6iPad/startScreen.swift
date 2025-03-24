//
//  startScreen.swift
//  Challenge6iPad
//
//  Created by Dayan Abdulla on 3/24/25.
//

import SwiftUI

struct startScreen: View {
    var body: some View {
        
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
                Image("Logo")
            
                VStack{
                   
                        
                    }
                }
            }
        }
    }


#Preview {
    startScreen()
}
