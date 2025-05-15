    import SwiftUI
    import Alamofire
    import Combine



    // MARK: - Autocomplete Models
    struct AutocompleteCoordinates: Codable {
        let latitude: String
        let longitude: String
    }

    struct AutocompleteResult: Codable, Identifiable {
        let iataCode: String
        let airportName: String
        let type: String
        let displayName: String
        let cityName: String
        let countryName: String
        let countryCode: String
        let imageUrl: String
        let coordinates: AutocompleteCoordinates
        
        var id: String { iataCode }
    }

    struct AutocompleteResponse: Codable {
        let data: [AutocompleteResult]
        let language: String
    }
    // MARK: - Flight API Response Models
    struct Location: Codable {
        let iata: String
        let name: String
        let country: String
    }

    struct Airline: Codable {
        let iata: String
        let name: String
        let logo: String
    }

    struct FlightLeg: Codable {
        let origin: Location
        let destination: Location
        let airline: Airline
        let departure: Int
        let departure_datetime: String
        let direct: Bool
    }

    struct PriceStats: Codable {
        let mean: Double
        let std_dev: Double
        let lower_threshold: Double
        let upper_threshold: Double
    }

    struct FlightResult: Codable, Identifiable {
        let date: Int
        let price: Int
        let currency: String
        let outbound: FlightLeg
        let inbound: FlightLeg?
        let price_category: String
        
        var id: String {
            return UUID().uuidString
        }
    }

    struct FlightSearchResponse: Codable {
        let price_stats: PriceStats
        let results: [FlightResult]
    }

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
        
        let currency:String = "INR"
        let country:String = "IN"
        
        private let baseURL = "https://staging.plane.lascade.com/api/explore/"
        private let flightsURL = "https://staging.plane.lascade.com/api/explore/?currency=INR&country=IN"
        private var currentFlightSearchRequest: DataRequest?
        private let session = Session()
        
        func fetchAutocomplete(query: String, country: String = "IN", language: String = "en-GB") -> AnyPublisher<[AutocompleteResult], Error> {
            let baseURL = "https://staging.plane.lascade.com/api/autocomplete"
            
            let parameters: [String: String] = [
                "search": query,
                "country": country,
                "language": language
            ]
            
            return Future<[AutocompleteResult], Error> { promise in
                AF.request(baseURL, parameters: parameters)
                    .validate()
                    .responseDecodable(of: AutocompleteResponse.self) { response in
                        switch response.result {
                        case .success(let autocompleteResponse):
                            promise(.success(autocompleteResponse.data))
                        case .failure(let error):
                            promise(.failure(error))
                        }
                    }
            }.eraseToAnyPublisher()
        }
        
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
        
        func fetchFlightDetails(
            origin: String = "MOB", // Using Mumbai as default
            destination: String,
            departure: String,
            roundTrip: Bool = true,
            currency: String = "INR",
            country: String = "IN"
        ) -> AnyPublisher<FlightSearchResponse, Error> {
            
            // Create request parameters according to requirements
            let parameters: [String: Any] = [
                "origin": origin,
                "destination": destination,
                "departure": departure,
                "round_trip": roundTrip,
                "currency": currency,
                "country": country
            ]
            
            return Future<FlightSearchResponse, Error> { promise in
                AF.request(self.flightsURL,
                          method: .post,
                          parameters: parameters,
                          encoding: JSONEncoding.default)
                    .validate()
                    .responseDecodable(of: FlightSearchResponse.self) { response in
                        switch response.result {
                        case .success(let searchResponse):
                            promise(.success(searchResponse))
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
        @Published var fromLocation = "From"  // Default to Kochi
        @Published var toLocation = "Anywhere"  // Default to Chennai
        @Published var selectedCity: ExploreDestination? = nil
        
        @Published var availableMonths: [Date] = []
        @Published var selectedMonthIndex: Int = 0
        
        // Updated flight results properties
        @Published var flightSearchResponse: FlightSearchResponse?
        @Published var flightResults: [FlightResult] = []
        @Published var isLoadingFlights = false

        @Published var selectedDepartureDate = Date()
        @Published var selectedReturnDate: Date?
       
        @Published var hasSearchedFlights = false
        
        @Published var fromIataCode: String = ""
        @Published var toIataCode: String = ""
        
         var cancellables = Set<AnyCancellable>()
        private let service = ExploreAPIService.shared
        
        init() {
            setupAvailableMonths()
        }
        
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
            
            // Fetch flight details when a city is selected
            fetchFlightDetails(destination: city.location.iata)
        }
        
        func setupAvailableMonths() {
            // Generate next 6 months starting from current month
            let calendar = Calendar.current
            let currentDate = Date()
            
            var months: [Date] = []
            for i in 0..<12 {
                if let date = calendar.date(byAdding: .month, value: i, to: currentDate) {
                    // Get the first day of each month
                    let components = calendar.dateComponents([.year, .month], from: date)
                    if let firstDayOfMonth = calendar.date(from: components) {
                        months.append(firstDayOfMonth)
                    }
                }
            }
            
            availableMonths = months
            selectedMonthIndex = 0 // Default to current month
        }
        
        func fetchFlightDetails(destination: String) {
            isLoadingFlights = true
            errorMessage = nil
            hasSearchedFlights = true
            flightResults = [] // Clear previous results when starting a new search
            
            // Format date based on selected month
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd-MM-yyyy"
            
            let dateToUse: Date
            
            if selectedMonthIndex == 0 {
                // If current month, use current date
                dateToUse = Date()
            } else {
                // Otherwise use the first day of the selected month
                dateToUse = availableMonths[selectedMonthIndex]
            }
            
            let departureDate = dateFormatter.string(from: dateToUse)
            
            service.fetchFlightDetails(
                origin: "DEL",
                destination: destination,
                departure: departureDate
            )
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                self?.isLoadingFlights = false
                if case .failure(let error) = completion {
                    self?.errorMessage = error.localizedDescription
                    self?.flightResults = [] // Ensure results are cleared on error
                }
            }, receiveValue: { [weak self] response in
                self?.flightSearchResponse = response
                self?.flightResults = response.results
                // If we got an empty array but no error, set a custom error message
                       if response.results.isEmpty {
                           self?.errorMessage = "No flights available"
                       } else {
                           self?.errorMessage = nil
                       }
            })
            .store(in: &cancellables)
        }
        
        func selectMonth(at index: Int) {
            if index >= 0 && index < availableMonths.count {
                selectedMonthIndex = index
                
                // Re-fetch flight details with the new month if a city is selected
                if let city = selectedCity {
                    fetchFlightDetails(destination: city.location.iata)
                }
            }
        }
        
        func goBackToCountries() {
            selectedCountryName = nil
            selectedCity = nil
            toLocation = "Anywhere"
            showingCities = false
            hasSearchedFlights = false
            flightResults = []
            flightSearchResponse = nil
            fetchCountries()
        }
        
        // Helper function to format timestamp to readable date
        func formatDate(_ timestamp: Int) -> String {
            let date = Date(timeIntervalSince1970: TimeInterval(timestamp))
            let formatter = DateFormatter()
            formatter.dateFormat = "EEE, d MMM"
            return formatter.string(from: date)
        }
        
        // Helper function to calculate trip duration
        func calculateTripDuration(_ result: FlightResult) -> String {
            if let inbound = result.inbound {
                let outboundDate = Date(timeIntervalSince1970: TimeInterval(result.outbound.departure))
                let inboundDate = Date(timeIntervalSince1970: TimeInterval(inbound.departure))
                let days = Calendar.current.dateComponents([.day], from: outboundDate, to: inboundDate).day ?? 0
                return "\(days) days trip"
            } else {
                return "One way trip"
            }
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
                    
                    // Search card with dynamic values
                    SearchCard(viewModel: viewModel)
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                }
                .background(
                    ZStack {
                        // Background fill
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(.systemBackground))
                        
                        // Animated or static stroke based on loading state
                        if viewModel.isLoading || viewModel.isLoadingFlights {
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
                            Text(viewModel.showingCities ? "Explore \(viewModel.selectedCountryName ?? "")" : "Explore everywhere")
                                .font(.system(size: 24, weight: .bold))
                                .padding(.horizontal)
                                .padding(.top, 16)
                            
                           
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
                        else {
                            // Flight search results view
                            VStack(alignment: .center, spacing: 16) {
                                 Text("Explore \(viewModel.toLocation)")
                                    .font(.system(size: 24, weight: .bold))
                                    .padding(.horizontal)
                                    .padding(.top, 16)
                                MonthSelectorView(
                                    months: viewModel.availableMonths,
                                    selectedIndex: viewModel.selectedMonthIndex,
                                    onSelect: { index in
                                        viewModel.selectMonth(at: index)
                                    }
                                )
                                .padding(.top, 8)
                                
                                if viewModel.isLoadingFlights {
                                    // Show loading skeleton for flights
                                    ForEach(0..<3, id: \.self) { _ in
                                        SkeletonFlightResultCard()
                                            .padding(.bottom, 8)
                                    }
                                } else if viewModel.errorMessage != nil || viewModel.flightResults.isEmpty{

                                   
                                        Text("No flights found")
                                            .font(.subheadline)
                                            .foregroundColor(.gray)


                                } else {
                                    // Display flight results
                                    ForEach(viewModel.flightResults) { result in
                                        // Create a FlightResultCard for each result
                                        FlightResultCard(
                                            departureDate: viewModel.formatDate(result.outbound.departure),
                                            returnDate: result.inbound != nil ? viewModel.formatDate(result.inbound!.departure) : "No return",
                                            origin: result.outbound.origin.iata,
                                            destination: result.outbound.destination.iata,
                                            price: "₹\(result.price)",
                                            isDirect: result.outbound.direct && (result.inbound?.direct ?? true),
                                            tripDuration: viewModel.calculateTripDuration(result)
                                        )
                                        .padding(.bottom, 8)
                                    }
                                }
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
                    }
                    .background(
                        Color("scroll")
                    )
                    
                }
                .background(Color(.systemBackground))
            }
            .ignoresSafeArea(edges: .bottom)
            .onAppear {
                if !viewModel.hasSearchedFlights {
                    viewModel.fetchCountries()
                }
                viewModel.setupAvailableMonths()
            }
        }
    }

    // MARK: - Search Card Component
    struct SearchCard: View {
        @ObservedObject var viewModel: ExploreViewModel
        @State private var showingSearchSheet = false
        @State private var initialFocus: LocationSearchSheet.SearchBarType = .origin
        
        var body: some View {
            VStack(spacing: 5) {
                Divider()
                // From row
                HStack {
                    Image(systemName: "airplane.departure")
                        .foregroundColor(.blue)

                    Button(action: {
                        initialFocus = .origin
                        showingSearchSheet = true
                    }) {
                        Text(viewModel.fromLocation)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.black)
                    }
                    
                    Spacer()
                    
                    ZStack {
                        Circle()
                            .stroke(Color.gray.opacity(0.4), lineWidth: 1)
                            .frame(width: 20, height: 20)
                        Image(systemName: "arrow.left.arrow.right")
                            .fontWeight(.bold)
                            .foregroundColor(.blue)
                            .font(.system(size: 8))
                    }
                    
                    Spacer()
                    
                    Image(systemName: "airplane.arrival")
                        .foregroundColor(.blue)
                    
                    Button(action: {
                        initialFocus = .destination
                        showingSearchSheet = true
                    }) {
                        Text(viewModel.toLocation)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.black)
                    }
                }
                .padding(4)
                
                Divider()

                // Date and passengers row
                HStack {
                    Image(systemName: "calendar")
                        .foregroundColor(.blue)
                    
                    Text("Anytime")
                        .font(.system(size: 14, weight: .medium))
                    
                    Spacer()
                    
                    Image(systemName: "person")
                        .foregroundColor(.blue)
                    
                    Text("1, Economy")
                        .font(.system(size: 14, weight: .medium))
                }
                .padding(.vertical, 4)
            }
            .sheet(isPresented: $showingSearchSheet) {
                LocationSearchSheet(viewModel: viewModel, initialFocus: initialFocus)
                    .presentationDetents([.large])
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
                            .fontWeight(.bold)
                            .foregroundColor(.green)
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 12)
                
                
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
                            .fontWeight(.bold)
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
                            .font(.subheadline)
                            .foregroundColor(.white)
                            .padding(.vertical, 10)
                            .padding(.horizontal, 16)
                            .background(Color("primarycolor"))
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

    // MARK: - Skeleton Flight Result Card
    struct SkeletonFlightResultCard: View {
        @State private var isAnimating = false
        
        var body: some View {
            VStack(spacing: 0) {
                // Departure section
                VStack(alignment: .leading, spacing: 8) {
                    Rectangle()
                        .fill(Color(UIColor.systemGray5))
                        .frame(height: 16)
                        .frame(width: 80)
                        .cornerRadius(4)
                    
                    HStack {
                        Rectangle()
                            .fill(Color(UIColor.systemGray5))
                            .frame(height: 18)
                            .frame(width: 100)
                            .cornerRadius(4)
                        
                        Spacer()
                        
                        Rectangle()
                            .fill(Color(UIColor.systemGray5))
                            .frame(height: 18)
                            .frame(width: 120)
                            .cornerRadius(4)
                        
                        Spacer()
                        
                        Rectangle()
                            .fill(Color(UIColor.systemGray5))
                            .frame(height: 16)
                            .frame(width: 60)
                            .cornerRadius(4)
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 12)
                
                Divider()
                
                // Return section
                VStack(alignment: .leading, spacing: 8) {
                    Rectangle()
                        .fill(Color(UIColor.systemGray5))
                        .frame(height: 16)
                        .frame(width: 60)
                        .cornerRadius(4)
                    
                    HStack {
                        Rectangle()
                            .fill(Color(UIColor.systemGray5))
                            .frame(height: 18)
                            .frame(width: 100)
                            .cornerRadius(4)
                        
                        Spacer()
                        
                        Rectangle()
                            .fill(Color(UIColor.systemGray5))
                            .frame(height: 18)
                            .frame(width: 120)
                            .cornerRadius(4)
                        
                        Spacer()
                        
                        Rectangle()
                            .fill(Color(UIColor.systemGray5))
                            .frame(height: 16)
                            .frame(width: 60)
                            .cornerRadius(4)
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 12)
                
                Divider()
                
                // Price section
                HStack {
                    VStack(alignment: .leading, spacing: 8) {
                        Rectangle()
                            .fill(Color(UIColor.systemGray5))
                            .frame(height: 16)
                            .frame(width: 80)
                            .cornerRadius(4)
                        
                        Rectangle()
                            .fill(Color(UIColor.systemGray5))
                            .frame(height: 24)
                            .frame(width: 100)
                            .cornerRadius(4)
                        
                        Rectangle()
                            .fill(Color(UIColor.systemGray5))
                            .frame(height: 16)
                            .frame(width: 120)
                            .cornerRadius(4)
                    }
                    
                    Spacer()
                    
                    Rectangle()
                        .fill(Color(UIColor.systemGray5))
                        .frame(height: 40)
                        .frame(width: 140)
                        .cornerRadius(8)
                }
                .padding()
            }
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
            .padding(.horizontal)
            .opacity(isAnimating ? 0.7 : 1.0)
            .onAppear {
                withAnimation(Animation.easeInOut(duration: 1.0).repeatForever()) {
                    isAnimating.toggle()
                }
            }
        }
    }

    // Add this new component:

    struct MonthSelectorView: View {
        let months: [Date]
        let selectedIndex: Int
        let onSelect: (Int) -> Void
        
        var body: some View {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(0..<months.count, id: \.self) { index in
                        MonthButton(
                            month: months[index],
                            isSelected: selectedIndex == index,
                            action: {
                                onSelect(index)
                            }
                        )
                    }
                }
                .padding(.horizontal)
            }
        }
    }

    struct MonthButton: View {
        let month: Date
        let isSelected: Bool
        let action: () -> Void
        
        var body: some View {
            Button(action: action) {
                VStack(spacing: 4) {
                    Text(monthName(from: month))
                        .font(.system(size: 14, weight: isSelected ? .semibold : .regular))
                        .foregroundColor(isSelected ? .blue : .black)
                    
                    Text(year(from: month))
                        .font(.system(size: 12))
                        .foregroundColor(isSelected ? .blue : .gray)
                }
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
        
        private func monthName(from date: Date) -> String {
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM"
            return formatter.string(from: date)
        }
        
        private func year(from date: Date) -> String {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy"
            return formatter.string(from: date)
        }
    }



struct LocationSearchSheet: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: ExploreViewModel
    @State private var originSearchText = ""
    @State private var destinationSearchText = ""
    @State private var results: [AutocompleteResult] = []
    @State private var isSearching = false
    @State private var searchError: String? = nil
    @State private var activeSearchBar: SearchBarType = .origin
    // Add FocusState to manage keyboard focus
    @FocusState private var focusedField: SearchBarType?
    
    enum SearchBarType {
        case origin
        case destination
    }
    
    var initialFocus: SearchBarType
    
    private let debouncer = Debouncer(delay: 0.3)
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 18))
                        .foregroundColor(.black)
                }
                
                Spacer()
                
                Text(activeSearchBar == .origin ? "From Where?" : "Where to?")
                    .font(.headline)
                
                Spacer()
                
                // Empty space to balance the X button
                Image(systemName: "xmark")
                    .font(.system(size: 18))
                    .foregroundColor(.clear)
            }
            .padding()
            
            // Origin search bar
            HStack {
                TextField("", text: $originSearchText)
                    .placeholder(when: originSearchText.isEmpty) {
                        Text("Origin City, Airport or place")
                            .foregroundColor(.gray)
                    }
                    .padding(12)
                    .background(Color(.systemBackground))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(activeSearchBar == .origin ? Color.orange : Color.gray, lineWidth: 2)
                    )
                    .cornerRadius(8)
                    .focused($focusedField, equals: .origin) // Add focused modifier
                    .onChange(of: originSearchText) { newValue in
                        activeSearchBar = .origin
                        if !newValue.isEmpty {
                            debouncer.debounce {
                                searchLocations(query: newValue)
                            }
                        } else {
                            results = []
                        }
                    }
                    .onTapGesture {
                        activeSearchBar = .origin
                        focusedField = .origin // Update focus state
                    }
                
                if !originSearchText.isEmpty {
                    Button(action: {
                        originSearchText = ""
                        if activeSearchBar == .origin {
                            results = []
                        }
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding()
            
            // Destination search bar
            HStack {
                TextField("", text: $destinationSearchText)
                    .placeholder(when: destinationSearchText.isEmpty) {
                        Text("Destination City, Airport or place")
                            .foregroundColor(.gray)
                    }
                    .padding(12)
                    .background(Color(.systemBackground))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(activeSearchBar == .destination ? Color.orange : Color.gray, lineWidth: 2)
                    )
                    .cornerRadius(8)
                    .focused($focusedField, equals: .destination) // Add focused modifier
                    .onChange(of: destinationSearchText) { newValue in
                        activeSearchBar = .destination
                        if !newValue.isEmpty {
                            debouncer.debounce {
                                searchLocations(query: newValue)
                            }
                        } else {
                            results = []
                        }
                    }
                    .onTapGesture {
                        activeSearchBar = .destination
                        focusedField = .destination // Update focus state
                    }
                
                if !destinationSearchText.isEmpty {
                    Button(action: {
                        destinationSearchText = ""
                        if activeSearchBar == .destination {
                            results = []
                        }
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding(.horizontal)
            
            // Use current location button (only available for origin)
            if activeSearchBar == .origin {
                Button(action: {
                    viewModel.fromLocation = "Current Location"
                    viewModel.fromIataCode = ""
                    originSearchText = "Current Location" // Update the search text field
                    
                    // Move focus to destination field
                    activeSearchBar = .destination
                    focusedField = .destination
                    
                    // If destination is set, close the sheet
                    if !viewModel.toLocation.isEmpty && viewModel.toLocation != "Anywhere" {
                        dismiss()
                    }
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
                }
            }
            
            Divider()
            
            // Results list
            if isSearching {
                VStack {
                    ProgressView()
                    Text("Searching...")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                .padding()
            } else if let error = searchError {
                Text(error)
                    .foregroundColor(.red)
                    .padding()
            } else if results.isEmpty && ((activeSearchBar == .origin && !originSearchText.isEmpty) ||
                                          (activeSearchBar == .destination && !destinationSearchText.isEmpty)) {
                Text("No results found")
                    .foregroundColor(.gray)
                    .padding()
            } else {
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(results) { result in
                            LocationResultRow(result: result)
                                .onTapGesture {
                                    if activeSearchBar == .origin {
                                        viewModel.fromLocation = result.cityName
                                        viewModel.fromIataCode = result.iataCode
                                        originSearchText = result.cityName // Update the search text field
                                        
                                        // Auto-focus the destination field
                                        activeSearchBar = .destination
                                        focusedField = .destination
                                    } else {
                                        viewModel.toLocation = result.cityName
                                        viewModel.toIataCode = result.iataCode
                                        destinationSearchText = result.cityName // Update the search text field
                                        
                                        // If origin is already set, dismiss the sheet
                                        if !viewModel.fromLocation.isEmpty && viewModel.fromLocation != "From" {
                                            dismiss()
                                        }
                                    }
                                }
                        }
                    }
                }
            }
            
            Spacer()
        }
        .background(Color.white)
        .onAppear {
            // Set the initial focus from props
            activeSearchBar = initialFocus
            focusedField = initialFocus
        }
    }
    
    private func searchLocations(query: String) {
        guard !query.isEmpty else {
            results = []
            return
        }
        
        isSearching = true
        searchError = nil
        
        ExploreAPIService.shared.fetchAutocomplete(query: query)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                isSearching = false
                if case .failure(let error) = completion {
                    searchError = error.localizedDescription
                }
            }, receiveValue: { results in
                self.results = results
            })
            .store(in: &viewModel.cancellables)
    }
}

    // Helper view for placeholder text in TextField
    extension View {
        func placeholder<Content: View>(
            when shouldShow: Bool,
            alignment: Alignment = .leading,
            @ViewBuilder placeholder: () -> Content) -> some View {
            
            ZStack(alignment: alignment) {
                placeholder().opacity(shouldShow ? 1 : 0)
                self
            }
        }
    }

    // Row view for displaying search results
    struct LocationResultRow: View {
        let result: AutocompleteResult
        
        var body: some View {
            HStack(spacing: 16) {
                Text(result.iataCode)
                    .font(.system(size: 16, weight: .medium))
                    .frame(width: 40, height: 40)
                    .background(Color(UIColor.systemGray6))
                    .cornerRadius(4)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(result.cityName), \(result.countryName)")
                        .font(.system(size: 16, weight: .medium))
                    
                    Text(result.type == "airport" ? result.airportName : "All Airports")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                }
                
                Spacer()
            }
            .padding()
            .contentShape(Rectangle())
        }
    }

    // Simple debouncer to avoid excessive API calls
    class Debouncer {
        private let delay: TimeInterval
        private var workItem: DispatchWorkItem?
        
        init(delay: TimeInterval) {
            self.delay = delay
        }
        
        func debounce(action: @escaping () -> Void) {
            workItem?.cancel()
            
            let workItem = DispatchWorkItem(block: action)
            self.workItem = workItem
            
            DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: workItem)
        }
    }

    struct ExploreScreenPreview: PreviewProvider {
        static var previews: some View {
            ExploreScreen()
        }
    }
