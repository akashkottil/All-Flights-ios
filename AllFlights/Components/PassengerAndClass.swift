import SwiftUI

struct PassengersAndClassSelector: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: SearchViewModel
    
    // Local state for children ages
    @State private var childrenAges: [Int?] = [nil, nil]
    @State private var showInfoDetails = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Header with close button
            HStack {
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "xmark")
                        .foregroundColor(.black)
                        .padding(10)
                }
                
                Spacer()
                
                Text("Passengers and Class")
                    .font(.headline)
                
                Spacer()
                
                // Empty view for balance
                Color.clear.frame(width: 40, height: 40)
            }
            .padding(.horizontal)
            .padding(.top)
            
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Class selection
                    classSelectionView
                    
                    Divider()
                    
                    // Passengers selection
                    passengersSelectionView
                    
                    // Warning info
                    infoView
                    
                    // Child age selectors
                    if viewModel.childrenCount > 0 {
                        childAgeSelectionView
                    }
                    
                    Spacer(minLength: 100)
                }
                .padding(.vertical)
            }
        }
        .background(Color(UIColor.systemBackground))
        .onAppear {
            // Initialize children ages array based on current count
            if childrenAges.count != viewModel.childrenCount {
                childrenAges = Array(repeating: nil, count: max(viewModel.childrenCount, 2))
            }
        }
    }
    
    // MARK: - Subviews
    
    private var classSelectionView: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Class")
                .font(.headline)
                .fontWeight(.semibold)
                .padding(.horizontal)
            
            VStack(spacing: 10) {
                // First row of class buttons
                HStack(spacing: 8) {
                    ClassButton(
                        title: "Economy",
                        isSelected: viewModel.travelClass.rawValue == "Economy",
                        action: { viewModel.travelClass = .economy }
                    )
                    
                    ClassButton(
                        title: "Business",
                        isSelected: viewModel.travelClass.rawValue == "Business",
                        action: { viewModel.travelClass = .business }
                    )
                    
                    ClassButton(
                        title: "Premium Business",
                        isSelected: viewModel.travelClass.rawValue == "Premium Business",
                        action: {
                            // Using firstClass as a placeholder
                            viewModel.travelClass = .firstClass
                        }
                    )
                }
                
                // Second row with just Premium Economy
                HStack {
                    ClassButton(
                        title: "Premium Economy",
                        isSelected: viewModel.travelClass.rawValue == "Premium Economy",
                        action: {
                            // Need to add this to TravelClass enum
                            viewModel.travelClass = .economy // Placeholder
                        }
                    )
                    Spacer()
                }
            }
            .padding(.horizontal)
        }
    }
    
    private var passengersSelectionView: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Passengers")
                .font(.headline)
                .fontWeight(.semibold)
                .padding(.horizontal)
            
            // Adults counter
            CounterRow(
                title: "Adults",
                subtitle: ">12 years",
                count: $viewModel.adultsCount,
                min: 1,
                max: 9
            )
            .padding(.horizontal)
            
            // Children counter
            CounterRow(
                title: "Children",
                subtitle: "<12 years",
                count: $viewModel.childrenCount,
                min: 0,
                max: 8
            )
            .padding(.horizontal)
        }
    }
    
    private var infoView: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .top, spacing: 12) {
                // Orange circle with "i"
                ZStack {
                    Circle()
                        .fill(Color.orange)
                        .frame(width: 20, height: 20)
                    
                    Text("i")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Your age at time of travel must be valid for the age category booked. Airlines have restrictions on under 18s travelling alone.")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                    
                    if showInfoDetails {
                        Text("Age limits and policies for travelling with children may vary so please check with the airline before booking")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
            }
            .padding(.horizontal)
            
            // Expandable info button with rotation animation
            HStack {
                VStack{
                    Divider()
                }
                Button(action: {
                    withAnimation {
                        showInfoDetails.toggle()
                    }
                }) {
                    Image("upAndDown")

                        .foregroundColor(.gray)
                        .rotationEffect(showInfoDetails ? .degrees(360) : .degrees(180))
                        .animation(.easeInOut, value: showInfoDetails)
                        .frame(width: 36, height: 36)
                }
                VStack{
                    Divider()
                }
            }
            .padding(.top, 8)
        }
    }
    
    private var childAgeSelectionView: some View {
        VStack(spacing: 12) {
            ForEach(0..<viewModel.childrenCount, id: \.self) { index in
                ChildAgeRow(
                    childNumber: index + 1,
                    onSelectTapped: {
                        // Show age selection for this child
                        print("Select age for child \(index + 1)")
                    }
                )
                .padding(.horizontal)
            }
        }
        .padding(.top, 8)
    }
}

// MARK: - Helper Components

struct ClassButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 13))
                .padding(.horizontal, 10)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(isSelected ? Color.blue : Color.gray.opacity(0.5), lineWidth: 1)
                        .background(isSelected ? Color.blue.opacity(0.05) : Color.clear)
                )
                .foregroundColor(isSelected ? Color.blue : Color.black)
        }
    }
}

struct CounterRow: View {
    let title: String
    let subtitle: String
    @Binding var count: Int
    let min: Int
    let max: Int
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.body)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            HStack(spacing: 16) {
                Button(action: {
                    if count > min {
                        count -= 1
                    }
                }) {
                    Image(systemName: "minus")
                        .foregroundColor(count <= min ? Color.gray : Color.blue)
                        .frame(width: 32, height: 32)
                        .background(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(count <= min ? Color.gray.opacity(0.5) : Color.blue, lineWidth: 1)
                        )
                }
                .disabled(count <= min)
                
                Text("\(count)")
                    .frame(minWidth: 16)
                    .multilineTextAlignment(.center)
                
                Button(action: {
                    if count < max {
                        count += 1
                    }
                }) {
                    Image(systemName: "plus")
                        .foregroundColor(.blue)
                        .frame(width: 32, height: 32)
                        .background(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(Color.blue, lineWidth: 1)
                        )
                }
                .disabled(count >= max)
            }
        }
    }
}

struct ChildAgeRow: View {
    let childNumber: Int
    let onSelectTapped: () -> Void
    
    var body: some View {
        HStack {
            Text("Child \(childNumber)")
                .font(.system(size: 16, weight: .medium))
            
            Spacer()
            
            Button(action: onSelectTapped) {
                HStack(spacing: 4) {
                    Text("Select age")
                        .font(.system(size: 15))
                        .foregroundColor(.blue)
                    
                    Image(systemName: "chevron.right")
                        .foregroundColor(.blue)
                        .font(.caption)
                }
            }
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 16)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        )
    }
}

// MARK: - Preview
struct PassengersAndClassSelector_Previews: PreviewProvider {
    static var previews: some View {
        PassengersAndClassSelector(viewModel: SearchViewModel())
            .previewLayout(.sizeThatFits)
    }
}
