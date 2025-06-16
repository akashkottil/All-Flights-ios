import SwiftUI

struct trackLocationSheet: View {
    

    var body: some View {
        VStack(spacing: 0) {
            
            // Top Bar
            HStack {
                Button(action: {}) {
                    Image(systemName: "xmark")
                        .foregroundColor(.black)
                        .padding(10)
                        .background(Circle().fill(Color.gray.opacity(0.1)))
                }
                Spacer()
                Text("Search Flight")
                    .bold()
                    .font(.title2)
                Spacer()
                Color.clear.frame(width: 40, height: 40)
            }
            .padding()
            
            // Search Field
            HStack {
                TextField("Search Flights or Airports", text: .constant(""))
                    .padding()
                
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.gray)
                    .padding(.trailing)
            }
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.orange, lineWidth: 1)
            )
            .padding(.horizontal)
            .padding(.top)
            
//             search field to search Flight number
//            only show this if the user searched flight in the first input.
            HStack {
                TextField("Flight Number", text: .constant(""))
                    .padding()
                
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.gray)
                    .padding(.trailing)
            }
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.orange, lineWidth: 1)
            )
            .padding(.horizontal)
            .padding(.top)

            //             search field to search arraival airport location
            //            only show this if the user searched airport in the first input.
                        HStack {
                            TextField("Flight Number", text: .constant(""))
                                .padding()
                            
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.gray)
                                .padding(.trailing)
                        }
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.orange, lineWidth: 1)
                        )
                        .padding(.horizontal)
                        .padding(.top)
            
            Spacer()
            
//            date section show only when all the inputs are filled.
            
            VStack (alignment: .center){
                HStack{
                    Text("select date")
                        .font(.system(size: 18))
                        .fontWeight(.bold)
                    Spacer()
                }
                VStack{
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Yesterday")
                            Text("14 May, Tuesday")
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                        )
                        
                        
                        VStack(alignment: .leading) {
                            Text("Yesterday")
                            Text("14 May, Tuesday")
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                        )
                        
                        
                    }
                    
                    
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Yesterday")
                            Text("14 May, Tuesday")
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                        )
                        
                        
                        VStack(alignment: .leading) {
                            Text("Yesterday")
                            Text("14 May, Tuesday")
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                        )
                        
                        
                    }
                    

                }
            }.padding()
            
            ScrollView{
                
//                Airlines list
                
                VStack (alignment: .leading){
                    HStack{
                        Text("Airlines")
                            .font(.system(size: 18))
                            .fontWeight(.bold)
                        Spacer()
                    }
                    HStack{
                        Image("AirlineLogo")
                            .frame(width: 50, height: 50)
                        Text("Airline Name")
                            .font(.system(size: 14))
                            .fontWeight(.semibold)
                    }
                    
                }
                .padding()
                
//                airport list
                
                VStack(alignment: .leading){
                    HStack{
                        Text("Popular airports")
                            .font(.system(size: 18))
                            .fontWeight(.bold)
                        Spacer()
                    }
                    HStack{
                        Text("COK")
                                                        .font(.system(size: 14, weight: .medium))
                                                        .padding(8)
                                                        .frame(width: 50, height: 50)
                                                        .background(Color.blue.opacity(0.1))
                                                        .cornerRadius(8)
                        Text("Airport Name")
                            .font(.system(size: 14))
                            .fontWeight(.semibold)
                    }
                }
                .padding()
            }
            
        }
        .background(Color.white)
    }
}

#Preview {
    trackLocationSheet()
}
