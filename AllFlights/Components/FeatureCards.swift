//
//  FeatureCards.swift
//  all-flights
//
//  Created by Akash Kottill on 14/05/25.
//

import SwiftUI

struct FeatureCards: View {
    var body: some View {
        HStack{
            HStack (){
                VStack (alignment: .leading){
                    
                    Image("trackFlight")
                    Text("Track")
                        .font(.system(size: 16))
                        .fontWeight(.bold)
                        .foregroundColor(Color("AppPrimaryColor"))
                    Text("yout Flights")
                        .font(.system(size: 16))
                        .fontWeight(.medium)
                        .foregroundColor(Color("AppPrimaryColor"))
                }
                .padding(.leading,30)
                Spacer()
                
            }
            .frame(width: 180, height: 118)
            .background(Color.blue.opacity(0.06))
            .cornerRadius(30)
            .overlay(
                RoundedRectangle(cornerRadius: 30)
                    .stroke(Color("AppPrimaryColor"), lineWidth: 1)
            )
            Spacer()
            HStack (){
                VStack (alignment: .leading){
                    
                    Image("exploreFlight")
                    Text("Track")
                        .font(.system(size: 16))
                        .fontWeight(.bold)
                        .foregroundColor(Color("AppPrimaryColor"))
                    Text("yout Flights")
                        .font(.system(size: 16))
                        .fontWeight(.medium)
                        .foregroundColor(Color("AppPrimaryColor"))
                }
                .padding(.leading,30)
                Spacer()
                
            }
            .frame(width: 180, height: 118)
            .background(Color.blue.opacity(0.06))
            .cornerRadius(30)
            .overlay(
                RoundedRectangle(cornerRadius: 30)
                    .stroke(Color("AppPrimaryColor"), lineWidth: 1)
            )
        }
        .padding()
        
        
        
    }
}


#Preview {
    FeatureCards()
}
