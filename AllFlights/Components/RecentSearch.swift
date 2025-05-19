import SwiftUI

struct RecentSearch: View {
    // Track if view has appeared
    @State private var hasAppeared = false
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
                ForEach(0..<5, id: \.self) { index in
                    GeometryReader { geometry in
                        VStack(alignment: .leading) {
                            Text("COK - LON")
                                .font(.system(size: 16))
                                .fontWeight(.bold)
                            HStack {
                                Text("Economy")
                                HStack{}
                                    .frame(width: 6, height: 6)
                                    .background(Color.gray.opacity(0.6))
                                    .cornerRadius(100)
                                Text("3 People")
                            }
                            .foregroundColor(Color.gray.opacity(0.8))
                            .fontWeight(.medium)
                            .font(.system(size: 14))
                        }
                        .padding()
                        .background(Color.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.gray.opacity(0.5), lineWidth: 2)
                        )
                        .cornerRadius(10)
                        // Calculate the center distance for parallax effect
                        .scaleEffect(scaleValue(geometry))
//                        .shadow(radius: shadowRadius(geometry))
                        // Initial animation
                        .opacity(hasAppeared ? 1 : 0)
                        .offset(y: hasAppeared ? 0 : 20)
                        .animation(
                            .spring(response: 0.6, dampingFraction: 0.8)
                            .delay(Double(index) * 0.1),
                            value: hasAppeared
                        )
                    }
                    .frame(width: 180, height: 100)
                }
            }
            .padding()
            .padding(.vertical, 10) // Add space for scaling effect
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                hasAppeared = true
            }
        }
    }
    
    // Calculate scale based on position
    private func scaleValue(_ geometry: GeometryProxy) -> CGFloat {
        let midX = geometry.frame(in: .global).midX
        let viewWidth = UIScreen.main.bounds.width
        let distanceFromCenter = abs(midX - viewWidth / 2)
        let screenProportion = distanceFromCenter / (viewWidth / 2)
        
        // Scale between 1 (centered) and 0.9 (edges)
        return 1.0 - (0.1 * min(screenProportion, 1.0))
    }
    
    // Calculate shadow based on position
    private func shadowRadius(_ geometry: GeometryProxy) -> CGFloat {
        let midX = geometry.frame(in: .global).midX
        let viewWidth = UIScreen.main.bounds.width
        let distanceFromCenter = abs(midX - viewWidth / 2)
        let screenProportion = distanceFromCenter / (viewWidth / 2)
        
        // Shadow between 4 (centered) and 1 (edges)
        return 4 - (3 * min(screenProportion, 1.0))
    }
}
