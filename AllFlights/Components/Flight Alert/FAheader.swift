import SwiftUI

struct FAheader: View {
    // ADDED: State for passenger selection
    @State private var showPassengerSelector = false
    @State private var adultsCount: Int = 1
    @State private var childrenCount: Int = 0
    @State private var selectedClass: String = "Economy"
    @State private var childrenAges: [Int?] = []
    
    // ADDED: Computed property for passenger display text
    private var passengerDisplayText: String {
        let totalPassengers = adultsCount + childrenCount
        return "\(totalPassengers)"
    }
    
    var body: some View {
        VStack{
            HStack{
                Image("FALogoWhite")
                Spacer()
                
                // UPDATED: Make passenger section tappable
                Button(action: {
                    showPassengerSelector = true
                }) {
                    HStack{
                        Image("FAPassenger")
                        Text(passengerDisplayText) // UPDATED: Use dynamic count
                    }
                    .padding(.vertical,8)
                    .padding(.horizontal,10)
                    .background(.white)
                    .cornerRadius(10)
                }
                .buttonStyle(PlainButtonStyle()) // ADDED: Remove default button styling
            }
            .padding(.horizontal,10)
        }
        // ADDED: Bottom sheet presentation
        .sheet(isPresented: $showPassengerSelector) {
            PassengersAndClassSelector(
                adultsCount: $adultsCount,
                childrenCount: $childrenCount,
                selectedClass: $selectedClass,
                childrenAges: $childrenAges
            )
            .presentationDetents([.fraction(0.9), .large]) // ADDED: Custom sheet sizes
            .presentationDragIndicator(.visible) // ADDED: Drag indicator
        }
    }
}

#Preview {
    FAheader()
}
