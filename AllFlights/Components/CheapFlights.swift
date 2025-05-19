import SwiftUI

struct CheapFlights: View {
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
                ForEach(0..<5, id: \.self) { _ in
                    VStack(alignment: .leading, spacing: 8) {
                        Image("cityImage")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 120)
                            .cornerRadius(10)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("New York")
                                .font(.system(size: 13))
                                .foregroundColor(.black)
                                .fontWeight(.medium)
                            
                            Text("Sat, 7 Jun")
                                .font(.system(size: 12))
                                .foregroundColor(.gray)
                                .fontWeight(.medium)
                            Text("₹ 2,546")
                                .font(.title2)
                                .fontWeight(.bold)
                        }
                        .padding(.horizontal, 12)
                        .padding(.bottom, 12)
                    }
                    .background(Color.white)
                    .cornerRadius(20)
                    .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                    .scrollTransition { content, phase in
                        content
                            .scaleEffect(phase.isIdentity ? 1.0 : 0.95)
                            .opacity(phase.isIdentity ? 1.0 : 0.8)
                    }
                    .containerRelativeFrame(.horizontal)
                }
                .frame(width: 150)
            }
            .padding(.horizontal)
            .scrollTargetLayout()
        }
        .scrollTargetBehavior(.viewAligned)
        .animation(.easeInOut(duration: 0.3), value: UUID())
    }
}

#Preview {
    CheapFlights()
}
