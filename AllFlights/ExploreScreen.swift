import SwiftUI
import Alamofire
import Combine

// MARK: - API Models
struct ExploreLocation: Decodable {
    let entityId: String
    let name: String
    let iata: String
}

struct ExploreDestination: Decodable, Identifiable {
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
    
    func fetchDestinations(country: String = "IN",
                          currency: String = "INR",
                          departure: String = "LAX",
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
    
    func goBackToCountries() {
        selectedCountryName = nil
        showingCities = false
        fetchCountries()
    }
}

// MARK: - Main View
struct ExploreScreen: View {
    // MARK: - Properties
    @StateObject private var viewModel = ExploreViewModel()
    @State private var selectedTab = 0
    @State private var selectedFilterTab = 0
    
    let filterOptions = ["Cheapest flights", "Direct Flights", "Suggested for you"]
    
    // MARK: - Body
    var body: some View {
        VStack(spacing: 0) {
            // Custom navigation bar
            VStack(spacing: 0) {
                HStack {
                    // Back button
                    Button(action: {
                        if viewModel.showingCities {
                            viewModel.goBackToCountries()
                        }
                    }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.primary)
                            .font(.system(size: 18, weight: .semibold))
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
                    
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.top, 8)
                
                // Search card
                SearchCard()
                    .padding(.horizontal)
                    .padding(.vertical, 8)
            }
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.orange, lineWidth: 1)
                    .background(RoundedRectangle(cornerRadius: 12).fill(Color(.systemBackground)))
            )
            .padding()
            
            // Main content
            ScrollView {
                VStack(alignment: .center, spacing: 16) {
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
                    
                    // Loading state
                    if viewModel.isLoading {
                        ProgressView()
                            .padding()
                    }
                    
                    // Error state
                    if let errorMessage = viewModel.errorMessage {
                        VStack {
                            Text("Error loading destinations")
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
                    
                    // Destination cards
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
                                        }
                                    }
                                )
                                .padding(.horizontal)
                            }
                        }
                        .padding(.bottom, 16)
                    }
                }
            }
            .background(Color(UIColor.systemGray6))
        }
        .ignoresSafeArea(edges: .bottom)
        .onAppear {
            viewModel.fetchCountries()
        }
    }
}

// MARK: - Search Card Component
struct SearchCard: View {
    var body: some View {
        VStack(spacing: 5) {
            Divider()
            // From row
            HStack {
                Image(systemName: "airplane.departure")
                    .foregroundColor(.blue)
                
                VStack(alignment: .leading, spacing: 0) {
                    Text("From")
                        .font(.system(size: 14, weight: .medium))
                }
                
                Spacer()
                
                ZStack {
                    Circle()
                        .stroke(Color.gray.opacity(0.4), lineWidth: 1)
                        .frame(width: 25, height: 40)
                    Image(systemName: "arrow.left.arrow.right")
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                        .font(.system(size: 10))
                }
                .padding(.leading,30)
                
                Spacer()
                
                Image(systemName: "airplane.arrival")
                    .foregroundColor(.blue)
                
                VStack(alignment: .leading, spacing: 0) {
                    Text("Anywhere")
                        .font(.system(size: 14, weight: .medium))
                }
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

// MARK: - API Destination Card
struct APIDestinationCard: View {
    let item: ExploreDestination
    let currencySymbol: String
    let onTap: () -> Void
    
    
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                // Destination image (using placeholder from assets)
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

// MARK: - Other model kept for reference
struct DestinationItem: Identifiable {
    let id = UUID()
    let country: String
    let price: String
    let image: String
}

// MARK: - Preview
struct ExploreScreenView_Previews: PreviewProvider {
    static var previews: some View {
        ExploreScreen()
    }
}
