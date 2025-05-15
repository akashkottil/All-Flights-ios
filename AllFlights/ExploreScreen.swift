import SwiftUI
import Alamofire
import Combine

// MARK: - API Models
struct ExploreLocation: Codable {
    let entityId: String
    let name: String
    let iata: String
}

struct ExploreDestination: Codable, Identifiable {
    let price: Int
    let location: ExploreLocation
    let is_direct: Bool
    
    var id: String {
        return location.entityId
    }
}




// MARK: - API Service
class ExploreAPIService {
    static let shared = ExploreAPIService()
    
    private let baseURL = "https://staging.plane.lascade.com/api/explore/"
    private var currentFlightSearchRequest: DataRequest?
    private let session = Session()
    
    func fetchDestinations(country: String = "IN",
                          currency: String = "INR",
                          departure: String = "COK",
                          language: String = "en-GB",
                          arrivalType: String = "country",
                          arrivalId: String? = nil) -> AnyPublisher<[ExploreDestination], Error> {
        
        var parameters: [String: Any] = [
            "country": country,
            "currency": currency,
            "departure": departure,
            "language": language,
            "arrival_type": arrivalType
        ]
        
        if let arrivalId = arrivalId {
            parameters["arrival_id"] = arrivalId
        }
        
        return Future<[ExploreDestination], Error> { promise in
            AF.request(self.baseURL, parameters: parameters)
                .validate()
                .responseDecodable(of: [ExploreDestination].self) { response in
                    switch response.result {
                    case .success(let destinations):
                        promise(.success(destinations))
                    case .failure(let error):
                        promise(.failure(error))
                    }
                }
        }.eraseToAnyPublisher()
    }
    
   
}

// MARK: - View Model
class ExploreViewModel: ObservableObject {
    @Published var destinations: [ExploreDestination] = []
    @Published var isLoading = false
    @Published var errorMessage: String? = nil
    @Published var showingCities = false
    @Published var selectedCountryName: String? = nil
    @Published var fromLocation = "Kochi"  // Default to Kochi
    @Published var toLocation = "Chennai"  // Default to Chennai
    @Published var selectedCity: ExploreDestination? = nil
    
 
   

    @Published var selectedDepartureDate = Date()
    @Published var selectedReturnDate: Date?
   
    @Published var hasSearchedFlights = false
    
    private var cancellables = Set<AnyCancellable>()
    private let service = ExploreAPIService.shared
    
    
    
    func fetchCountries() {
        isLoading = true
        errorMessage = nil
        
        service.fetchDestinations()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.errorMessage = error.localizedDescription
                }
            }, receiveValue: { [weak self] destinations in
                self?.destinations = destinations
            })
            .store(in: &cancellables)
    }
    
    func fetchCitiesFor(countryId: String, countryName: String) {
        isLoading = true
        errorMessage = nil
        selectedCountryName = countryName
        
        service.fetchDestinations(arrivalType: "city", arrivalId: countryId)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.errorMessage = error.localizedDescription
                }
                self?.showingCities = true
            }, receiveValue: { [weak self] destinations in
                self?.destinations = destinations
            })
            .store(in: &cancellables)
    }
    
    func selectCity(city: ExploreDestination) {
        selectedCity = city
        toLocation = city.location.name
        

    }
    
    func goBackToCountries() {
        selectedCountryName = nil
        selectedCity = nil
        toLocation = "Anywhere"
        showingCities = false
        hasSearchedFlights = false
        fetchCountries()
    }
    

}

// MARK: - Main View
struct ExploreScreen: View {
    // MARK: - Properties
    @StateObject private var viewModel = ExploreViewModel()
    @State private var selectedTab = 0
    @State private var selectedFilterTab = 0
    @State private var selectedMonthTab = 0
    
    let filterOptions = ["Cheapest flights", "Direct Flights", "Suggested for you"]

    
    // MARK: - Body
    var body: some View {
        VStack(spacing: 0) {
            // Custom navigation bar
            VStack(spacing: 0) {
                HStack {
                    // Back button
                    Button(action: {
                        if viewModel.showingCities || viewModel.hasSearchedFlights {
                            viewModel.goBackToCountries()
                        }
                    }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.primary)
                            .font(.system(size: 18, weight: .semibold))
                    }
                    
                    Spacer()
                    
                    // Title
                    if viewModel.hasSearchedFlights {
                        Text("Explore \(viewModel.toLocation)")
                            .font(.headline)
                            .fontWeight(.bold)
                    }
                    
                    Spacer()
                    
                    // Trip type tabs
                    HStack(spacing: 0) {
                        TabButton(title: "Return", isSelected: selectedTab == 0) {
                            selectedTab = 0
                        }
                        
                        TabButton(title: "One way", isSelected: selectedTab == 1) {
                            selectedTab = 1
                        }
                        
                        TabButton(title: "Multi city", isSelected: selectedTab == 2) {
                            selectedTab = 2
                        }
                    }
                    .background(Capsule().fill(Color(UIColor.systemGray6)))
                    .padding(.trailing)
                }
                .padding(.horizontal)
                .padding(.top, 8)
                
                // Search card with dynamic values
                SearchCard(
                    fromLocation: viewModel.fromLocation,
                    toLocation: viewModel.toLocation
                )
                .padding(.horizontal)
                .padding(.vertical, 8)
            }
            .background(
                ZStack {
                    // Background fill
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.systemBackground))
                    
                    // Animated or static stroke based on loading state
                    if viewModel.isLoading {
                        LoadingBorderView()
                    } else {
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.orange, lineWidth: 1)
                    }
                }
            )
            .padding()
            
           
            
            ScrollView {
                VStack(alignment: .center, spacing: 16) {
                    // Main content
                    if !viewModel.hasSearchedFlights {
                        // Original explore view content
                        // Title with dynamic text based on view state
                        Text(viewModel.showingCities ? "Cities in \(viewModel.selectedCountryName ?? "")" : "Explore everywhere")
                            .font(.system(size: 24, weight: .bold))
                            .padding(.horizontal)
                            .padding(.top, 16)
                        
                        // Filter tabs (only shown in country view)
                        if !viewModel.showingCities {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(0..<filterOptions.count, id: \.self) { index in
                                        FilterTabButton(
                                            title: filterOptions[index],
                                            isSelected: selectedFilterTab == index
                                        ) {
                                            selectedFilterTab = index
                                        }
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                        
                        // Destination cards (destinations/cities)
                        if !viewModel.isLoading && viewModel.errorMessage == nil {
                            VStack(spacing: 12) {
                                ForEach(viewModel.destinations) { destination in
                                    APIDestinationCard(
                                        item: destination,
                                        currencySymbol: "₹",
                                        onTap: {
                                            if !viewModel.showingCities {
                                                viewModel.fetchCitiesFor(
                                                    countryId: destination.location.entityId,
                                                    countryName: destination.location.name
                                                )
                                            } else {
                                                // Update selected city when tapped
                                                viewModel.selectCity(city: destination)
                                            }
                                        }
                                    )
                                    .padding(.horizontal)
                                }
                            }
                            .padding(.bottom, 16)
                        }
                    }
                    
                    // Loading and error displays
                    if viewModel.isLoading {
                        VStack(spacing: 12) {
                            ForEach(0..<5, id: \.self) { _ in
                                SkeletonDestinationCard()
                            }
                        }
                        .padding(.bottom, 16)
                    }
                    
                    if let errorMessage = viewModel.errorMessage {
                        VStack {
                            Text("Error loading data")
                                .font(.headline)
                                .foregroundColor(.red)
                            
                            Text(errorMessage)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                            
                            Button("Try Again") {
                              
                                    viewModel.fetchCountries()
                                
                            }
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                        }
                        .padding()
                    }
                }
            }
            .background(Color(UIColor.systemGray6))
        }
        .ignoresSafeArea(edges: .bottom)
        .onAppear {
            if !viewModel.hasSearchedFlights {
                viewModel.fetchCountries()
            }
        }
    }
    
   
}

// MARK: - Search Card Component
struct SearchCard: View {
    let fromLocation: String
    let toLocation: String
    
    var body: some View {
        VStack(spacing: 5) {
            Divider()
            // From row
            HStack {
                Image(systemName: "airplane.departure")
                    .foregroundColor(.blue)

                Text(fromLocation)
                    .font(.system(size: 14, weight: .medium))
                
                Spacer()
                
                ZStack {
                    Circle()
                        .stroke(Color.gray.opacity(0.4), lineWidth: 1)
                        .frame(width: 25, height: 25)
                    Image(systemName: "arrow.left.arrow.right")
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                        .font(.system(size: 10))
                }
                
                Spacer()
                
                Image(systemName: "airplane.arrival")
                    .foregroundColor(.blue)
                
                Text(toLocation)
                    .font(.system(size: 14, weight: .medium))
            }
            
            Divider()
            
            // Date and passengers row
            HStack {
                Image(systemName: "calendar")
                    .foregroundColor(.blue)
                
                Text("Sat, 7 Jun -Anytime")
                    .font(.system(size: 14, weight: .medium))
                
                Spacer()
                
                Image(systemName: "person")
                    .foregroundColor(.blue)
                
                Text("1, Economy")
                    .font(.system(size: 14, weight: .medium))
            }
            .padding(.vertical, 10)
        }
    }
}

// MARK: - Flight Result Card (matching screenshot)
struct FlightResultCard: View {
    let departureDate: String
    let returnDate: String
    let origin: String
    let destination: String
    let price: String
    let isDirect: Bool
    let tripDuration: String
    
    var body: some View {
        VStack(spacing: 0) {
            // Departure section
            VStack(alignment: .leading, spacing: 8) {
                Text("Departure")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                HStack {
                    Text(departureDate)
                        .font(.headline)
                    
                    Spacer()
                    
                    HStack(spacing: 4) {
                        Text(origin)
                            .font(.headline)
                        
                        Image(systemName: "arrow.right")
                            .font(.caption)
                        
                        Text(destination)
                            .font(.headline)
                    }
                    
                    Spacer()
                    
                    Text(isDirect ? "Direct" : "Connecting")
                        .font(.subheadline)
                        .foregroundColor(.green)
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 12)
            
            Divider()
            
            // Return section
            VStack(alignment: .leading, spacing: 8) {
                Text("Return")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                HStack {
                    Text(returnDate)
                        .font(.headline)
                    
                    Spacer()
                    
                    HStack(spacing: 4) {
                        Text(destination)
                            .font(.headline)
                        
                        Image(systemName: "arrow.right")
                            .font(.caption)
                        
                        Text(origin)
                            .font(.headline)
                    }
                    
                    Spacer()
                    
                    Text(isDirect ? "Direct" : "Connecting")
                        .font(.subheadline)
                        .foregroundColor(.green)
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 12)
            
            Divider()
            
            // Price section
            HStack {
                VStack(alignment: .leading) {
                    Text("Flights from")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    Text(price)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text(tripDuration)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                Button(action: {
                    // View details action
                }) {
                    Text("View these dates")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.vertical, 10)
                        .padding(.horizontal, 16)
                        .background(Color.blue)
                        .cornerRadius(8)
                }
            }
            .padding()
        }
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        .padding(.horizontal)
    }
}



// MARK: - API Destination Card
struct APIDestinationCard: View {
    let item: ExploreDestination
    let currencySymbol: String
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                // Destination image placeholder
                Image("sampleimage")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 80, height: 80)
                    .clipped()
                    .cornerRadius(8)
                
                // Destination information
                VStack(alignment: .leading, spacing: 4) {
                    Text("Flights from")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                    
                    Text(item.location.name)
                        .font(.system(size: 18, weight: .bold))
                    
                    Text(item.is_direct ? "Direct" : "Connecting")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                // Price
                Text("\(currencySymbol)\(item.price)")
                    .font(.system(size: 20, weight: .bold))
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Tab Button Component
struct TabButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 13, weight: isSelected ? .semibold : .regular))
                .foregroundColor(isSelected ? .blue : .black)
                .padding(.vertical, 3)
                .padding(.horizontal, 7)
                .background(isSelected ? Color.white : Color.clear)
                .clipShape(Capsule())
                .padding(5)
        }
    }
}

// MARK: - Filter Tab Button Component
struct FilterTabButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 14, weight: isSelected ? .semibold : .regular))
                .foregroundColor(isSelected ? .blue : .black)
                .padding(.vertical, 8)
                .padding(.horizontal, 16)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.white)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.blue, lineWidth: isSelected ? 1 : 0)
                )
        }
    }
}

// MARK: - Loading Border View
struct LoadingBorderView: View {
    @State private var progressValue: CGFloat = 0.0
    @State private var isAnimating: Bool = false
    
    var body: some View {
        ZStack {
            // Base light stroke (background track)
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.orange.opacity(0.3), lineWidth: 2.5)
            
            // Main progress section (darker) - just this single element now
            RoundedRectangle(cornerRadius: 12)
                .trim(from: 0, to: progressValue)
                .stroke(Color.orange, lineWidth: 2.5)
                .animation(.linear(duration: 0.4), value: progressValue)
        }
        .onAppear {
            // Slowed down main animation
            withAnimation(.linear(duration: 6.0).repeatForever(autoreverses: false)) {
                progressValue = 1.0
            }
            
            // Keeping the subtle pulse for interest (can be removed if desired)
            withAnimation(Animation.easeInOut(duration: 3.0).repeatForever(autoreverses: true)) {
                isAnimating = true
            }
        }
        .scaleEffect(isAnimating ? 1.02 : 1.0)
    }
}

// MARK: - Skeleton Destination Card
struct SkeletonDestinationCard: View {
    @State private var isAnimating = false
    
    var body: some View {
        HStack(spacing: 12) {
            // Placeholder image
            Rectangle()
                .fill(Color(UIColor.systemGray5))
                .frame(width: 80, height: 80)
                .cornerRadius(8)
            
            // Placeholder text
            VStack(alignment: .leading, spacing: 8) {
                // "Flights from" placeholder
                Rectangle()
                    .fill(Color(UIColor.systemGray5))
                    .frame(height: 12)
                    .frame(width: 70)
                    .cornerRadius(4)
                
                // Location name placeholder
                Rectangle()
                    .fill(Color(UIColor.systemGray5))
                    .frame(height: 18)
                    .frame(width: 120)
                    .cornerRadius(4)
                
                // "Direct/Connecting" placeholder
                Rectangle()
                    .fill(Color(UIColor.systemGray5))
                    .frame(height: 12)
                    .frame(width: 60)
                    .cornerRadius(4)
            }
            
            Spacer()
            
            // Price placeholder
            Rectangle()
                .fill(Color(UIColor.systemGray5))
                .frame(height: 24)
                .frame(width: 70)
                .cornerRadius(4)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
        )
        .padding(.horizontal)
        .redacted(reason: .placeholder) // Apply the redacted modifier
        .opacity(isAnimating ? 0.7 : 1.0) // Animate opacity for shimmer effect
        .onAppear {
            withAnimation(Animation.easeInOut(duration: 1.0).repeatForever()) {
                isAnimating.toggle()
            }
        }
    }
}

struct ExploreScreenPreview: PreviewProvider {
    static var previews: some View {
        ExploreScreen()
    }
}
