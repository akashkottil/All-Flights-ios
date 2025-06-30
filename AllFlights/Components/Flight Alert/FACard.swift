import SwiftUI

struct FACard: View {
    var body: some View {
        VStack(spacing: 0) {
            // Top image section
            ZStack(alignment: .topLeading) {
                // Main image
                Image("FADemoImg")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 120)
                    .clipped()
                
                // Green badge overlay
                HStack {
                    VStack {
                        HStack {
                            Image("FAPriceTag")
                                .frame(width: 12, height: 16)
                            Text("$55 drop")
                                .font(.caption2)
                                .fontWeight(.medium)
                                .foregroundColor(.white)
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color("FADarkGreen"))
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                        //                        Spacer()
                    }
                    Spacer()
                }
                .padding(8)
            }
            .clipShape(
                .rect(
                    topLeadingRadius: 12,
                    bottomLeadingRadius: 0,
                    bottomTrailingRadius: 0,
                    topTrailingRadius: 12
                )
            )
            
            //            content section
            VStack(alignment: .leading){
            HStack{
                VStack(spacing: 0) {
                    // Spacing for alignment
                    //                    Spacer()
                    // Departure circle
                    Circle()
                        .stroke(Color.primary, lineWidth: 1)
                        .frame(width: 8, height: 8)
                    // Connecting line
                    Rectangle()
                        .fill(Color.primary)
                        .frame(width: 1, height: 24)
                        .padding(.top, 4)
                        .padding(.bottom, 4)
                    // Arrival circle
                    Circle()
                        .stroke(Color.primary, lineWidth: 1)
                        .frame(width: 8, height: 8)
                    // Space for remaining content
                    //                    Spacer()
                }
                
                VStack(alignment: .leading, spacing: 20){
                    HStack{
                        Text("JFK")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.black)
                        Text("John F. Kennedy International Airport")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    
                    HStack{
                        Text("COK")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.black)
                        Text("Cochin International Airport")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    
                }
                Spacer()
            }.padding()
        }
            
            Divider()
                .padding(.vertical, 16)
            HStack{
                HStack {
                    Text("Fri 13 Jun")
                        .font(.subheadline)
                        .fontWeight(.light)
                        .foregroundColor(.black)
                    
                    Spacer()
                    
                    HStack(alignment: .firstTextBaseline, spacing: 6) {
                        Text("$110")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(Color("FAPriceCut"))
                            .strikethrough()
                            
                        
                        Text("$55")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.black)
                    }
                    
                }
                .padding(.horizontal, 16)
                                           .padding(.bottom, 16)
            }.background(Color.white)
                        .clipShape(
                            .rect(
                                topLeadingRadius: 0,
                                bottomLeadingRadius: 12,
                                bottomTrailingRadius: 12,
                                topTrailingRadius: 0
                            )
                        )
        }
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
    }
}

#Preview {
    FACard()
        .padding()
}
