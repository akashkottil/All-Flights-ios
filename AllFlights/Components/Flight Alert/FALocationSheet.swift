import SwiftUI

struct FALocationSheet: View {
    @Environment(\.dismiss) var dismiss
    @State private var originText = ""
    @State private var destinationText = ""
    
    var body: some View {
        VStack(spacing: 0) {
            // Top bar design
            HStack {
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "xmark")
                        .foregroundColor(.black)
                        .padding(10)
                        .background(Circle().fill(Color.gray.opacity(0.1)))
                }
                Spacer()
                Text("From Where??")
                    .bold()
                    .font(.title2)
                Spacer()
                // Empty view for balance
                Color.clear.frame(width: 40, height: 40)
            }
            .padding()
            
            // Origin search field
            HStack {
                TextField("Origin City, Airport or place", text: $originText)
                    .padding()
                
                if !originText.isEmpty {
                    Button(action: {
                        originText = ""
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                    }
                    .padding(.trailing)
                }
            }
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(originText.isEmpty ? Color.gray.opacity(0.8) : Color.orange, lineWidth: 1)
            )
            .padding(.horizontal)
            .padding(.top)
            
            // Destination search field
            HStack {
                TextField("Destination City, Airport or place", text: $destinationText)
                    .padding()
                
                if !destinationText.isEmpty {
                    Button(action: {
                        destinationText = ""
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                    }
                    .padding(.trailing)
                }
            }
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(destinationText.isEmpty ? Color.gray.opacity(0.8) : Color.orange, lineWidth: 1)
            )
            .padding(.horizontal)
            .padding(.top)
            
            // Use current location button design
            Button(action: {
                // Location action
            }) {
                HStack {
                    Image(systemName: "location.fill")
                        .foregroundColor(.blue)
                    Text("Use Current Location")
                        .foregroundColor(.blue)
                        .fontWeight(.medium)
                    Spacer()
                }
                .padding()
                .padding(.vertical,10)
            }
            
            // Divider
            Divider()
                .padding(.horizontal)
            
                        
            // Search results list design
            ScrollView {
                LazyVStack(spacing: 0) {
                    // Sample location results
                    locationResultRow(iataCode: "JFK", cityName: "New York", countryName: "United States", airportName: "John F. Kennedy International Airport")
                    
                    locationResultRow(iataCode: "LAX", cityName: "Los Angeles", countryName: "United States", airportName: "Los Angeles International Airport")
                    
                    locationResultRow(iataCode: "LHR", cityName: "London", countryName: "United Kingdom", airportName: "Heathrow Airport")
                    
                    locationResultRow(iataCode: "CDG", cityName: "Paris", countryName: "France", airportName: "Charles de Gaulle Airport")
                    
                    locationResultRow(iataCode: "NRT", cityName: "Tokyo", countryName: "Japan", airportName: "Narita International Airport")
                }
            }
        }
        .background(Color.white)
    }
    
    @ViewBuilder
    private func locationResultRow(iataCode: String, cityName: String, countryName: String, airportName: String) -> some View {
        Button(action: {
            // Select location action - you can add logic here to handle selection
            print("Selected: \(iataCode) - \(cityName)")
            // Optionally dismiss after selection
            // dismiss()
        }) {
            VStack(spacing: 0) {
                HStack(spacing: 15) {
                    // Airport code badge
                    Text(iataCode)
                        .font(.system(size: 14, weight: .medium))
                        .padding(8)
                        .frame(width: 44, height: 44)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(8)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        // Main location name
                        Text("\(cityName), \(countryName)")
                            .font(.headline)
                            .foregroundColor(.black)
                        
                        // Subtitle with airport name
                        Text(airportName)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                }
                .padding(.vertical, 12)
                .padding(.horizontal)
            }
        }
        .contentShape(Rectangle())
    }
}

#Preview {
    FALocationSheet()
}
