import SwiftUI

struct PassengersAndClassSelector: View {
    @Environment(\.dismiss) private var dismiss
    
    // Use Bindings to ExploreViewModel properties
    @Binding var adultsCount: Int
    @Binding var childrenCount: Int
    @Binding var selectedClass: String
    @Binding var childrenAges: [Int?]
    
    // Local state for UI control
    @State private var showInfoDetails = false
    
    // State for age selection
    @State private var isShowingAgeSelector = false
    @State private var currentEditingChildIndex: Int = 0
    
    var body: some View {
        VStack(spacing: 0) {
            // Header with close button
            HStack {
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "xmark")
                        .foregroundColor(.black)
                        .font(.system(size: 20, weight: .medium))
                }
                
                Spacer()
                
                Text("Passengers and Class")
                    .fontWeight(.bold)
                    .font(.title3)
                
                Spacer()
            }
            .padding(.horizontal,18)
            .padding(.vertical)
            .padding(.top,8)
            
            // Main content - no ScrollView
            VStack(alignment: .leading, spacing: 20) {
                // Class selection
                classSelectionView
                
                Divider()
                    .padding(.top, 5)
                
                // Passengers selection
                passengersSelectionView
                
                // Warning info - only show if there are children
                if childrenCount > 0 {
                    infoView
                }
                
                // Children age selectors - only show if there are children
                if childrenCount > 0 {
                    childAgeSelectionView
                }
                
                Spacer() // Fill remaining space
            }
            .padding(.vertical, 10)
            
            // Bottom Apply button
            VStack {
                Divider()
                
                Button(action: {
                    // Apply changes and dismiss
                    dismiss()
                }) {
                    HStack {
                        Text("Apply")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                        
                        Image(systemName: "chevron.right")
                            .foregroundColor(.white)
                            .font(.system(size: 16, weight: .semibold))
                    }
                    .padding(.vertical, 16)
                    .padding(.horizontal,140) // Added horizontal padding for balanced spacing
                    .background(Color("buttonColor"))
                    .cornerRadius(12)
                    .frame(maxWidth: .infinity) // Ensures the button stretches to take available space
                }
                .padding(.horizontal)
                .padding(.top, 12)
                .padding(.bottom, 20) // Extra bottom padding for safe area
            }
            .background(Color(UIColor.systemBackground))
        }
        .background(Color(UIColor.systemBackground))
        .onAppear {
            // Initialize the children ages array when the view appears
            updateChildrenAgesArray(for: childrenCount)
        }
        .sheet(isPresented: $isShowingAgeSelector) {
            ChildAgePickerView(
                selectedAge: childrenAges[currentEditingChildIndex],
                childNumber: currentEditingChildIndex + 1,
                onSelectAge: { age in
                    childrenAges[currentEditingChildIndex] = age
                    isShowingAgeSelector = false
                },
                onCancel: {
                    isShowingAgeSelector = false
                }
            )
            .presentationDetents([.medium])
        }
    }
    
    // MARK: - Subviews
    
    private var classSelectionView: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Class")
                .font(.headline)
                .fontWeight(.bold)
                .padding(.horizontal)
            
            // Match the layout in the screenshot
            VStack(spacing: 8) {
                // First row
                HStack(spacing: 10) {
                    ClassButton(
                        title: "Economy",
                        isSelected: selectedClass == "Economy",
                        action: { selectedClass = "Economy" }
                    )
                    
                    ClassButton(
                        title: "Business",
                        isSelected: selectedClass == "Business",
                        action: { selectedClass = "Business" }
                    )
                    
                    ClassButton(
                        title: "Premium Business",
                        isSelected: selectedClass == "First",
                        action: { selectedClass = "First" }
                    )
                    
                    Spacer()
                }
                
                // Second row (just Premium Economy)
                HStack {
                    ClassButton(
                        title: "Premium Economy",
                        isSelected: selectedClass == "Premium",
                        action: { selectedClass = "Premium" }
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
                .fontWeight(.bold)
                .padding(.horizontal)
            
            // Adults counter
            FigmaCounterRow(
                title: "Adults",
                subtitle: ">12 years",
                count: $adultsCount,
                min: 1,
                max: 9
            )
            .padding(.horizontal)
            
            // Children counter
            FigmaCounterRow(
                title: "Children",
                subtitle: "<12 years",
                count: $childrenCount,
                min: 0,
                max: 10,
                onChange: { newValue in
                    // Ensure childrenAges array has the right count
                    updateChildrenAgesArray(for: newValue)
                }
            )
            .padding(.horizontal)
        }
    }
    
    private var infoView: some View {
        VStack(alignment: .leading, spacing: 0) {
            // First row: Info icon with horizontal line
            HStack(spacing: 12) {
                // Orange circle with "i"
                ZStack {
                    Circle()
                        .fill(Color.orange)
                        .frame(width: 20, height: 20)
                    
                    Text("i")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white)
                }
                
                // Horizontal line next to the icon
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 1)
                    .frame(maxWidth: .infinity)
            }
            .padding(.horizontal)
            .padding(.bottom, 8)
            
            // Main text content
            VStack(alignment: .leading, spacing: 8) {
                Text("Your age at time of travel must be valid for the age category booked. Airlines have restrictions on under 18s travelling alone.")
                    .font(.footnote)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                
                if showInfoDetails {
                    Text("Age limits and policies for travelling with children may vary so please check with the airline before booking")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                        .opacity(showInfoDetails ? 1 : 0)
                        .animation(.easeInOut(duration: 0.3), value: showInfoDetails)
                }
            }
            .padding(.horizontal)
            
            // Expandable chevron button with horizontal lines
            HStack {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 1)
                    .frame(maxWidth: .infinity)
                
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        showInfoDetails.toggle()
                    }
                }) {
                    ZStack {
                        Circle()
                            .fill(Color.gray.opacity(0.1))
                            .frame(width: 36, height: 36)
                        Image(systemName: "chevron.down")
                                                    .foregroundColor(.primary)
                                                    .font(.system(size: 12, weight: .medium))
                                                    .rotationEffect(.degrees(showInfoDetails ? 180 : 0))
                                                    .animation(.easeInOut(duration: 0.3), value: showInfoDetails)
                    }
                }
                
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 1)
                    .frame(maxWidth: .infinity)
            }
            .padding(.horizontal)
            .padding(.top, 12)
        }
    }
    
    private var childAgeSelectionView: some View {
        ScrollView {
            VStack(spacing: 10) {
                ForEach(0..<childrenCount, id: \.self) { index in
                    FigmaChildAgeRow(
                        childNumber: index + 1,
                        selectedAge: index < childrenAges.count ? childrenAges[index] : nil,
                        onSelectTapped: {
                            // Show age selection for this child
                            currentEditingChildIndex = index
                            isShowingAgeSelector = true
                        }
                    )
                    .padding(.horizontal)
                }
            }
            .padding(.top, 8)
        }
    }
    
    // MARK: - Helper Methods
    
    // Update the childrenAges array when the number of children changes
    private func updateChildrenAgesArray(for newCount: Int) {
        if newCount > childrenAges.count {
            // Add nil ages for new children
            childrenAges.append(contentsOf: Array(repeating: nil, count: newCount - childrenAges.count))
        } else if newCount < childrenAges.count {
            // Remove excess ages
            childrenAges = Array(childrenAges.prefix(newCount))
        }
    }
}

// MARK: - Child Age Picker View
struct ChildAgePickerView: View {
    let selectedAge: Int?
    let childNumber: Int
    let onSelectAge: (Int) -> Void
    let onCancel: () -> Void
    
    // Available ages for children
    let availableAges: [Int] = Array(1...12)
    
    // Grid layout - 3 columns
    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Button(action: onCancel) {
                    Image(systemName: "xmark")
                        .foregroundColor(.black)
                        .padding(10)
                }
                
                Spacer()
                
                Text("Select Age for Child \(childNumber)")
                    .font(.headline)
                
                Spacer()
                
                // Empty space for balance
                Color.clear
                    .frame(width: 40, height: 40)
            }
            .padding(.horizontal)
            .padding(.top)
            
            Text("Select an age between 1 and 12 years")
                .font(.subheadline)
                .foregroundColor(.gray)
                .padding(.top, 8)
            
            // Age grid
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(availableAges, id: \.self) { age in
                    AgeSelectionButton(
                        age: age,
                        isSelected: selectedAge == age,
                        onTap: {
                            onSelectAge(age)
                        }
                    )
                }
            }
            .padding(.horizontal)
            .padding(.top, 24)
            
            Spacer()
        }
        .background(Color(UIColor.systemBackground))
    }
}

// Age selection button component
struct AgeSelectionButton: View {
    let age: Int
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            ZStack {
                Circle()
                    .stroke(isSelected ? Color.blue : Color.gray.opacity(0.3), lineWidth: 1.5)
                    .background(
                        Circle()
                            .fill(isSelected ? Color.blue.opacity(0.1) : Color.white)
                    )
                    .frame(height: 60)
                
                Text("\(age)")
                    .font(.system(size: 20, weight: isSelected ? .semibold : .regular))
                    .foregroundColor(isSelected ? .blue : .black)
            }
        }
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
                .fontWeight(.medium)
                .font(.system(size: 13))
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .frame(height: 36)
                .background(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(isSelected ? Color.blue : Color.gray.opacity(0.5), lineWidth: 1)
                        .background(Color.white) // Optional: ensures a white base behind the text
                        .cornerRadius(6)
                        .shadow(color: isSelected ? Color.black.opacity(0.1) : .clear, radius: 4, x: 0, y: 2)
                )
                .foregroundColor(isSelected ? Color.blue : Color.black)
        }
    }
}


struct FigmaCounterRow: View {
    let title: String
    let subtitle: String
    @Binding var count: Int
    let min: Int
    let max: Int
    var onChange: ((Int) -> Void)? = nil
    
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
                        onChange?(count)
                    }
                }) {
                    Image(systemName: "minus")
                        .foregroundColor(count <= min ? Color.blue.opacity(0.2) : Color.blue)
                        .frame(width: 36, height: 36)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(count <= min ? Color.blue.opacity(0.3) : Color.blue, lineWidth: 2)
                        )
                }
                .disabled(count <= min)
                
                Text("\(count)")
                    .frame(minWidth: 16)
                    .font(.system(size: 16, weight: .medium))
                
                Button(action: {
                    if count < max {
                        count += 1
                        onChange?(count)
                    }
                }) {
                    Image(systemName: "plus")
                        .foregroundColor(.blue)
                        .frame(width: 36, height: 36)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.blue, lineWidth: 2)
                        )
                }
                .disabled(count >= max)
            }
        }
    }
}

struct FigmaChildAgeRow: View {
    let childNumber: Int
    let selectedAge: Int?
    let onSelectTapped: () -> Void
    
    var body: some View {
        HStack {
            Text("Child \(childNumber)")
                .font(.system(size: 16, weight: .medium))
            
            Spacer()
            
            Button(action: onSelectTapped) {
                HStack(spacing: 6) {
                    if let age = selectedAge {
                        Text("\(age)")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.blue)
                    } else {
                        Text("Select age")
                            .fontWeight(.bold)
                            .font(.system(size: 16))
                            .foregroundColor(.blue)
                    }
                    
                    Image(systemName: "chevron.right")
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                        
                }
            }
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        )
    }
}
