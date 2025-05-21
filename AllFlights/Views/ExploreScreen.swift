import SwiftUI
import Alamofire
import Combine


struct MultiCityTrip: Identifiable {
    var id = UUID()
    var fromLocation: String = ""
    var fromIataCode: String = ""
    var toLocation: String = ""
    var toIataCode: String = ""
    var date: Date = Date()
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
    var displayDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE, d MMM"
        return formatter.string(from: date)
    }
}

// MARK: - Search API Response Models
struct SearchResponse: Codable {
    let searchId: String
    let language: String
    let currency: String
    let mode: Int
    let currencyInfo: CurrencyInfo
    
    enum CodingKeys: String, CodingKey {
        case searchId = "search_id"
        case language
        case currency
        case mode
        case currencyInfo = "currency_info"
    }
}

struct CurrencyInfo: Codable {
    let code: String
    let symbol: String
    let thousandsSeparator: String
    let decimalSeparator: String
    let symbolOnLeft: Bool
    let spaceBetweenAmountAndSymbol: Bool
    let decimalDigits: Int
    
    enum CodingKeys: String, CodingKey {
        case code
        case symbol
        case thousandsSeparator = "thousands_separator"
        case decimalSeparator = "decimal_separator"
        case symbolOnLeft = "symbol_on_left"
        case spaceBetweenAmountAndSymbol = "space_between_amount_and_symbol"
        case decimalDigits = "decimal_digits"
    }
}

// MARK: - Poll API Response Models
struct FlightPollResponse: Codable {
    let count: Int
    let next: String?
    let previous: String?
    let cache: Bool
    let passengerCount: Int
    let minDuration: Int
    let maxDuration: Int
    let minPrice: Double
    let maxPrice: Double
    let airlines: [PollAirline]
    let agencies: [Agency]
    let cheapestFlight: FlightSummary
    let bestFlight: FlightSummary
    let fastestFlight: FlightSummary
    let results: [FlightDetailResult]
    
    enum CodingKeys: String, CodingKey {
        case count
        case next
        case previous
        case cache
        case passengerCount = "passenger_count"
        case minDuration = "min_duration"
        case maxDuration = "max_duration"
        case minPrice = "min_price"
        case maxPrice = "max_price"
        case airlines
        case agencies
        case cheapestFlight = "cheapest_flight"
        case bestFlight = "best_flight"
        case fastestFlight = "fastest_flight"
        case results
    }
}

struct PollAirline: Codable {
    let airlineName: String
    let airlineIata: String
    let airlineLogo: String
}

struct Agency: Codable {
    let code: String
    let name: String
    let image: String
}

struct FlightSummary: Codable {
    let price: Double
    let duration: Int
}

struct FlightDetailResult: Codable {
    let id: String
    let totalDuration: Int
    let minPrice: Double
    let maxPrice: Double
    let legs: [FlightLegDetail]
    let providers: [FlightProvider]
    let isBest: Bool
    let isCheapest: Bool
    let isFastest: Bool
    
    enum CodingKeys: String, CodingKey {
        case id
        case totalDuration = "total_duration"
        case minPrice = "min_price"
        case maxPrice = "max_price"
        case legs
        case providers
        case isBest = "is_best"
        case isCheapest = "is_cheapest"
        case isFastest = "is_fastest"
    }
}

struct FlightLegDetail: Codable {
    let arriveTimeAirport: Int
    let departureTimeAirport: Int
    let duration: Int
    let origin: String
    let originCode: String
    let destination: String
    let destinationCode: String
    let stopCount: Int
    let segments: [FlightSegment]
    
    enum CodingKeys: String, CodingKey {
        case arriveTimeAirport
        case departureTimeAirport
        case duration
        case origin
        case originCode
        case destination
        case destinationCode
        case stopCount = "stopCount"
        case segments
    }
}

struct FlightSegment: Codable {
    let id: String
    let arriveTimeAirport: Int
    let departureTimeAirport: Int
    let duration: Int
    let flightNumber: String
    let airlineName: String
    let airlineIata: String
    let airlineLogo: String
    let originCode: String
    let origin: String
    let destinationCode: String
    let destination: String
    let arrivalDayDifference: Int
    let wifi: Bool
    let cabinClass: String?
    let aircraft: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case arriveTimeAirport
        case departureTimeAirport
        case duration
        case flightNumber
        case airlineName
        case airlineIata
        case airlineLogo
        case originCode
        case origin
        case destinationCode
        case destination
        case arrivalDayDifference = "arrival_day_difference"
        case wifi
        case cabinClass
        case aircraft
    }
}

struct FlightProvider: Codable {
    let isSplit: Bool
    let transferType: String
    let price: Double
    let splitProviders: [SplitProvider]
    
    enum CodingKeys: String, CodingKey {
        case isSplit
        case transferType
        case price
        case splitProviders
    }
}

struct SplitProvider: Codable {
    let name: String
    let imageURL: String
    let price: Double
    let deeplink: String
    let rating: Double?
    let ratingCount: Int?
    let fareFamily: String?
    
    enum CodingKeys: String, CodingKey {
        case name
        case imageURL = "imageURL"
        case price
        case deeplink
        case rating
        case ratingCount
        case fareFamily
    }
}


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
    
    // Add custom initializer to handle empty strings
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        iata = try container.decode(String.self, forKey: .iata)
        name = try container.decode(String.self, forKey: .name)
        country = try container.decode(String.self, forKey: .country)
    }
}

struct Airline: Codable {
    let iata: String
    let name: String
    let logo: String
    
    // Add custom initializer to handle empty strings
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        iata = try container.decode(String.self, forKey: .iata)
        name = try container.decode(String.self, forKey: .name)
        logo = try container.decode(String.self, forKey: .logo)
    }
}

struct FlightLeg: Codable {
    let origin: Location
    let destination: Location
    let airline: Airline
    let departure: Int?  // Make this optional to handle null values
    let departure_datetime: String?  // Make this optional too
    let direct: Bool
    
    // Add custom initializer to handle potential nulls
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        origin = try container.decode(Location.self, forKey: .origin)
        destination = try container.decode(Location.self, forKey: .destination)
        airline = try container.decode(Airline.self, forKey: .airline)
        direct = try container.decode(Bool.self, forKey: .direct)
        
        // Handle potentially null values
        departure = try container.decodeIfPresent(Int.self, forKey: .departure) ?? 0
        departure_datetime = try container.decodeIfPresent(String.self, forKey: .departure_datetime)
    }
    
    enum CodingKeys: String, CodingKey {
        case origin
        case destination
        case airline
        case departure
        case departure_datetime
        case direct
    }
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
    
    
    func searchFlights(origin: String, destination: String , returndate: String , departuredate: String,   roundTrip: Bool = true) -> AnyPublisher<SearchResponse, Error> {
        let baseURL = "https://staging.plane.lascade.com/api/search/"
        
        let parameters: [String: String] = [
            "user_id": "-0",
            "currency": currency,
            "language": "en-GB",
            "app_code": "D1WF"
        ]
        // Use fixed dates for now
//        let departureDate = "2025-12-29"
//        let returnDate = "2025-12-30"
        
        // Create legs based on round trip status
               var legs: [[String: String]] = [
                   [
                       "origin": origin,
                       "destination": destination,
                       "date": departuredate
                   ]
               ]
               
               // Only add return leg if it's a round trip
               if roundTrip && !returndate.isEmpty {
                   legs.append([
                       "origin": destination,
                       "destination": origin,
                       "date": returndate
                   ])
               }
        
        let requestData: [String: Any] = [
            "legs": legs,
            "cabin_class": "economy",
            "adults": 2,
            "children_ages": [0]
        ]
        
        // Create URL with query parameters
        var urlComponents = URLComponents(string: baseURL)!
        urlComponents.queryItems = parameters.map { URLQueryItem(name: $0.key, value: $0.value) }
        
        var request = URLRequest(url: urlComponents.url!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("IN", forHTTPHeaderField: "country")
        request.httpBody = try? JSONSerialization.data(withJSONObject: requestData)
        
        return Future<SearchResponse, Error> { promise in
            AF.request(request)
                .validate()
                .responseDecodable(of: SearchResponse.self) { response in
                    switch response.result {
                    case .success(let searchResponse):
                        promise(.success(searchResponse))
                    case .failure(let error):
                        print("Search API error: \(error.localizedDescription)")
                        if let data = response.data, let responseString = String(data: data, encoding: .utf8) {
                            print("Response body: \(responseString)")
                        }
                        promise(.failure(error))
                    }
                }
        }.eraseToAnyPublisher()
    }

    func pollFlightResults(searchId: String) -> AnyPublisher<FlightPollResponse, Error> {
        let baseURL = "https://staging.plane.lascade.com/api/poll/"
        
        let parameters: [String: String] = [
            "search_id": searchId
        ]
        
        var urlComponents = URLComponents(string: baseURL)!
        urlComponents.queryItems = parameters.map { URLQueryItem(name: $0.key, value: $0.value) }
        
        let requestData: [String: Any] = [:]
        
        var request = URLRequest(url: urlComponents.url!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: requestData)
        
        print("Starting progressive polling with search ID: \(searchId)")
        
        // Create a subject that will emit values as they come in
        let progressiveResults = PassthroughSubject<FlightPollResponse, Error>()
        
        // Start polling
        pollProgressively(request: request, subject: progressiveResults)
        
        // Return the subject as a publisher
        return progressiveResults.eraseToAnyPublisher()
    }

    // Helper method to handle progressive polling
    private func pollProgressively(request: URLRequest, subject: PassthroughSubject<FlightPollResponse, Error>, attempt: Int = 0, seenResultIds: Set<String> = []) {
        
        
       
        
        AF.request(request)
            .validate()
            .responseData { [weak self] response in
                guard let self = self else { return }
                
                switch response.result {
                case .success(let data):
                    do {
                        let pollResponse = try JSONDecoder().decode(FlightPollResponse.self, from: data)
                        
                        // If count is 0, no flights available
                        if pollResponse.cache == true {
                            print("Poll completed: No flights available")
                            subject.send(pollResponse)
                            subject.send(completion: .finished)
                            return
                        }
                        
                        // Check if we have new results
                        let currentResultIds = Set(pollResponse.results.map { $0.id })
                        let newResultIds = currentResultIds.subtracting(seenResultIds)
                        
                        if !pollResponse.results.isEmpty {
                            // We have results to show, send them
                            print("Poll successful, found \(pollResponse.results.count) results, \(newResultIds.count) new")
                            subject.send(pollResponse)
                            
                            // If we've seen all results or have enough, we can finish
                            if newResultIds.isEmpty  {
                                print("All results received, polling complete")
                                subject.send(completion: .finished)
                                return
                            }
                        }
                        
                        // Continue polling for more results
                     
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                            self.pollProgressively(
                                request: request,
                                subject: subject,
                                attempt: attempt + 1,
                                seenResultIds: currentResultIds
                            )
                        }
                    } catch {
                        print("Poll decoding error: \(error)")
                        
                        // Retry on decoding error if we got a 200 response
                        if response.response?.statusCode == 200 {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                                self.pollProgressively(
                                    request: request,
                                    subject: subject,
                                    attempt: attempt + 1,
                                    seenResultIds: seenResultIds
                                )
                            }
                        } else {
                            subject.send(completion: .failure(error))
                        }
                    }
                case .failure(let error):
                    print("Poll API error: \(error)")
                    
                    // Retry on server errors
                    if let statusCode = response.response?.statusCode, statusCode >= 500 {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                            self.pollProgressively(
                                request: request,
                                subject: subject,
                                attempt: attempt + 1,
                                seenResultIds: seenResultIds
                            )
                        }
                    } else {
                        subject.send(completion: .failure(error))
                    }
                }
            }
    }
    
    
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
    ) -> AnyPublisher<FlightSearchResponse, Error> {
        
        print("origin222 \(origin)")
        print("dest222 \(destination)")
        print("dep222 \(departure)")
        print("roundTr222 \(roundTrip)")
        print("ocurrency222 \(currency)")
        print("ocontry222 \(country)")
        
        // Create request parameters according to requirements
        let parameters: [String: Any] = [
            "origin": origin,
            "destination": destination,
            "departure": departure,
            "round_trip": roundTrip,
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
    @Published var fromLocation = "Mumbai"  // Default to Kochi
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
    
    @Published var selectedFlightDetail: FlightDetailResult?
    @Published var isLoadingFlightDetails = false
    @Published var showingDetailedFlightCard = false
    
    @Published var detailedFlightResults: [FlightDetailResult] = []
    @Published var isLoadingDetailedFlights = false
    @Published var detailedFlightError: String? = nil
    @Published var showingDetailedFlightList = false
    @Published var selectedDepartureDatee: String = ""
    @Published var selectedReturnDatee: String = ""
    @Published var selectedOriginCode: String = ""
    @Published var selectedDestinationCode: String = ""
    
    @Published var dates: [Date] = []
    
    @Published var isRoundTrip: Bool = true
    
    // Add this to the ExploreViewModel class
    @Published var multiCityTrips: [MultiCityTrip] = []

    

    // Initialize with default trips in viewModel's init() method
    func initializeMultiCityTrips() {
        // Default to 2 trips as you mentioned
        let calendar = Calendar.current
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: Date()) ?? Date()
        let dayAfterTomorrow = calendar.date(byAdding: .day, value: 2, to: Date()) ?? Date()
        
        multiCityTrips = [
            MultiCityTrip(fromLocation: fromLocation, fromIataCode: fromIataCode,
                         toLocation: toLocation, toIataCode: toIataCode, date: tomorrow),
            MultiCityTrip(fromLocation: toLocation, fromIataCode: toIataCode,
                         toLocation: "", toIataCode: "", date: dayAfterTomorrow)
        ]
    }
    
     var cancellables = Set<AnyCancellable>()
    private let service = ExploreAPIService.shared
    
    init() {
        setupAvailableMonths()
        
        // Add observer for dates changes
            $dates
                .sink { [weak self] selectedDates in
                    guard let self = self else { return }
                    if !selectedDates.isEmpty {
                        self.updateSelectedDates()
                    }
                }
                .store(in: &cancellables)
    }
    
    func handleTripTypeChange() {
        // If we have an active search, re-run it with the updated trip type
        if !fromIataCode.isEmpty && !toIataCode.isEmpty {
            // Clear current results first
            detailedFlightResults = []
            flightResults = []
            
            // If we were on the detailed flight list, re-run that search
            if showingDetailedFlightList {
                searchFlightsForDates(
                    origin: selectedOriginCode,
                    destination: selectedDestinationCode,
                    returnDate: isRoundTrip ? selectedReturnDatee : "",
                    departureDate: selectedDepartureDatee
                )
            }
            // If we had a selected city in the main view
            else if let city = selectedCity {
                fetchFlightDetails(destination: city.location.iata)
            }
        }
    }
    
    // Method to format selected dates for display in UI
    func formatDateForDisplay(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM"
        return formatter.string(from: date)
    }
    
    func updateSelectedDates() {
        if dates.count >= 2 {
            let sortedDates = dates.sorted()
            
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            
            selectedDepartureDatee = formatter.string(from: sortedDates[0])
            selectedReturnDatee = formatter.string(from: sortedDates[1])
        } else if dates.count == 1 {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            
            selectedDepartureDatee = formatter.string(from: dates[0])
            
            // For one-way trip - set same date or next day depending on your requirements
            if let nextDay = Calendar.current.date(byAdding: .day, value: 1, to: dates[0]) {
                selectedReturnDatee = formatter.string(from: nextDay)
            } else {
                selectedReturnDatee = selectedDepartureDatee
            }
        }
    }
    
    func updateDatesAndRunSearch() {
        // Only proceed if we have both origin and destination selected
        if !fromIataCode.isEmpty && !toIataCode.isEmpty && !dates.isEmpty {
            // Format dates properly for the API
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            
            let departureDate: String
            let returnDate: String
            
            if dates.count >= 2 && isRoundTrip {
                let sortedDates = dates.sorted()
                departureDate = formatter.string(from: sortedDates[0])
                returnDate = formatter.string(from: sortedDates[1])
            } else if dates.count == 1 || !isRoundTrip {
                departureDate = formatter.string(from: dates[0])
                // For one-way trip, set return date to empty string
                returnDate = isRoundTrip ? formatter.string(from: Calendar.current.date(byAdding: .day, value: 1, to: dates[0])!) : ""
            } else {
                // Default dates if somehow dates array is empty
                departureDate = "2025-12-29"
                returnDate = isRoundTrip ? "2025-12-30" : ""
            }
            
            // Update the stored dates
            selectedDepartureDatee = departureDate
            selectedReturnDatee = returnDate
            
            // Initiate search with these dates
            searchFlightsForDates(
                origin: fromIataCode,
                destination: toIataCode,
                returnDate: returnDate,
                departureDate: departureDate
            )
        }
    }
    
    // Add a method to initialize dates from API date strings
    func initializeDatesFromStrings() {
        if !selectedDepartureDatee.isEmpty && dates.isEmpty {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            
            if let departureDate = formatter.date(from: selectedDepartureDatee) {
                var newDates = [departureDate]
                
                if !selectedReturnDatee.isEmpty, let returnDate = formatter.date(from: selectedReturnDatee) {
                    newDates.append(returnDate)
                }
                
                // Update dates array to keep calendar in sync
                dates = newDates
            }
        }
    }
    
    func searchMultiCityFlights() {
        isLoadingDetailedFlights = true
        detailedFlightError = nil
        detailedFlightResults = []
        showingDetailedFlightList = true
        
        // Store the first and last cities for display
        selectedOriginCode = multiCityTrips.first?.fromIataCode ?? ""
        selectedDestinationCode = multiCityTrips.last?.toIataCode ?? ""
        
        // Create request payload using the existing searchFlights method
        // but with multiple legs from the multiCityTrips array
        var legs: [[String: String]] = []
        
        for trip in multiCityTrips {
            legs.append([
                "origin": trip.fromIataCode,
                "destination": trip.toIataCode,
                "date": trip.formattedDate
            ])
        }
        
        print("Searching with \(legs.count) legs")
        
        // Use the same search API but with multiple legs
        let baseURL = "https://staging.plane.lascade.com/api/search/"
        
        let parameters: [String: String] = [
            "user_id": "-0",
            "currency": service.currency,
            "language": "en-GB",
            "app_code": "D1WF"
        ]
        
        let requestData: [String: Any] = [
            "legs": legs,
            "cabin_class": "economy",
            "adults": 2,
            "children_ages": [0]
        ]
        
        var urlComponents = URLComponents(string: baseURL)!
        urlComponents.queryItems = parameters.map { URLQueryItem(name: $0.key, value: $0.value) }
        
        var request = URLRequest(url: urlComponents.url!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("IN", forHTTPHeaderField: "country")
        request.httpBody = try? JSONSerialization.data(withJSONObject: requestData)
        
        // Reuse the same API flow - get search ID then poll for results
        AF.request(request)
            .validate()
            .responseDecodable(of: SearchResponse.self) { [weak self] response in
                guard let self = self else { return }
                
                switch response.result {
                case .success(let searchResponse):
                    print("Search successful, got searchId: \(searchResponse.searchId)")
                    
                    self.service.pollFlightResults(searchId: searchResponse.searchId)
                        .receive(on: DispatchQueue.main)
                        .sink(
                            receiveCompletion: { [weak self] completion in
                                self?.isLoadingDetailedFlights = false
                                if case .failure(let error) = completion {
                                    print("Flight search failed: \(error.localizedDescription)")
                                    self?.detailedFlightError = error.localizedDescription
                                }
                            },
                            receiveValue: { [weak self] pollResponse in
                                guard let self = self else { return }
                                
                                // Same processing as in searchFlightsForDates
                                if !pollResponse.results.isEmpty {
                                    let existingIds = Set(self.detailedFlightResults.map { $0.id })
                                    let newResults = pollResponse.results.filter { !existingIds.contains($0.id) }
                                    
                                    if !newResults.isEmpty {
                                        self.detailedFlightResults.append(contentsOf: newResults)
                                    }
                                    
                                    if !self.detailedFlightResults.isEmpty {
                                        self.isLoadingDetailedFlights = false
                                    }
                                }
                                
                                if pollResponse.cache == true && self.detailedFlightResults.isEmpty {
                                    self.isLoadingDetailedFlights = false
                                }
                            }
                        )
                        .store(in: &self.cancellables)
                    
                case .failure(let error):
                    print("Search API error: \(error.localizedDescription)")
                    self.isLoadingDetailedFlights = false
                    self.detailedFlightError = error.localizedDescription
                }
            }
    }
    
    // Add this function to handle search and poll
    func searchFlightsForDates(origin: String, destination: String , returnDate: String , departureDate: String) {
        isLoadingDetailedFlights = true
        detailedFlightError = nil
        detailedFlightResults = []
        showingDetailedFlightList = true
        
        // Store selected flight details
        selectedOriginCode = origin
        selectedDestinationCode = destination
        selectedDepartureDatee = departureDate
        selectedReturnDatee = returnDate
        
        print("Searching flights: \(origin) to \(destination)")
        
        // First, get the search ID
        service.searchFlights(
                    origin: origin,
                    destination: destination,
                    returndate: isRoundTrip ? selectedReturnDatee : "", // Only pass return date if round trip
                    departuredate: selectedDepartureDatee,
                    roundTrip: isRoundTrip
                )
            .receive(on: DispatchQueue.main)
            .flatMap { searchResponse -> AnyPublisher<FlightPollResponse, Error> in
                print("Search successful, got searchId: \(searchResponse.searchId)")
                return self.service.pollFlightResults(searchId: searchResponse.searchId)
            }
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    // This will only be called when polling is fully completed or fails
                    self?.isLoadingDetailedFlights = false
                    if case .failure(let error) = completion {
                        print("Flight search failed: \(error.localizedDescription)")
                        self?.detailedFlightError = error.localizedDescription
                    }
                },
                receiveValue: { [weak self] pollResponse in
                    guard let self = self else { return }
                    
                    // Received new results - update UI immediately
                    if !pollResponse.results.isEmpty {
  
                        
                        // Option 2: Append unique new results (preferred for progressive loading)
                        let existingIds = Set(self.detailedFlightResults.map { $0.id })
                        let newResults = pollResponse.results.filter { !existingIds.contains($0.id) }
                        
                        if !newResults.isEmpty {
                            self.detailedFlightResults.append(contentsOf: newResults)
                         
                        }
                        
                        
                        // Since we're showing results now, we can consider the loading as complete
                        if !self.detailedFlightResults.isEmpty {
                            self.isLoadingDetailedFlights = false
                        }
                    }
                    
                    // If there are no results in the response and our array is still empty
                    if pollResponse.cache == true && self.detailedFlightResults.isEmpty {
                        self.isLoadingDetailedFlights = false
                    }
                }
            )
            .store(in: &cancellables)
    }

    // Add helper function to format date for API
    func formatDateForAPI(from date: String) -> String? {
           let inputFormatter = DateFormatter()
           inputFormatter.dateFormat = "EEE, d MMM yyyy"
           
           if let parsedDate = inputFormatter.date(from: date) {
               let outputFormatter = DateFormatter()
               outputFormatter.dateFormat = "yyyy-MM-dd"
               return outputFormatter.string(from: parsedDate)
           }
           
           // If we can't parse the date, return nil
           // The caller will use a default value
           return nil
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
        
        print("Fetching flight details for trip type: \(isRoundTrip ? "Round Trip" : "One Way")")
        print("Rountrip1111: \(isRoundTrip)")
        print("depdate1111: \(departureDate)")
        print("dest1111: \(destination)")
        
        service.fetchFlightDetails(
            origin: "DEL",
            destination: destination,
            departure: departureDate,
            roundTrip: isRoundTrip // Make sure this is being passed correctly
        )
        .receive(on: DispatchQueue.main)
        .sink(receiveCompletion: { [weak self] completion in
            self?.isLoadingFlights = false
            if case .failure(let error) = completion {
                self?.errorMessage = error.localizedDescription
                self?.flightResults = [] // Ensure results are cleared on error
                print("Flight details fetch failed: \(error.localizedDescription)")
            }
        }, receiveValue: { [weak self] response in
            self?.flightSearchResponse = response
            self?.flightResults = response.results
            print("Fetched \(response.results.count) flight results")
            
            // If we got an empty array but no error, set a custom error message
            if response.results.isEmpty {
                self?.errorMessage = "No flights available"
            } else {
                self?.errorMessage = nil
            }
        })
        .store(in: &cancellables)
    }
    
    // Update the month selector method to preserve dates
    func selectMonth(at index: Int) {
        if index >= 0 && index < availableMonths.count {
            selectedMonthIndex = index
            
            // If we have origin, destination and dates set, perform a search with the new month
            if !fromIataCode.isEmpty && !toIataCode.isEmpty {
                // Get the first day of the selected month
                let selectedMonth = availableMonths[index]
                
                // Create a new date for the same day in the new month
                let calendar = Calendar.current
                
                // If we have existing dates, try to preserve the day value in the new month
                if !dates.isEmpty {
                    var newDates: [Date] = []
                    
                    for date in dates {
                        let components = calendar.dateComponents([.day], from: date)
                        let day = components.day ?? 1
                        
                        // Create a date with same day but in new month
                        var newDateComponents = calendar.dateComponents([.year, .month], from: selectedMonth)
                        newDateComponents.day = min(day, 28) // Ensure valid day even in February
                        
                        if let newDate = calendar.date(from: newDateComponents) {
                            newDates.append(newDate)
                        }
                    }
                    
                    // Update dates and trigger search
                    if !newDates.isEmpty {
                        dates = newDates
                        updateDatesAndRunSearch()
                        return
                    }
                }
                
                // Fallback - use the selected month with default day values
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd"
                
                // Get first and last days of month for search
                let firstDay = selectedMonth
                let lastDay = calendar.date(byAdding: .day, value: 6, to: firstDay) ?? firstDay // Default to 1 week trip
                
                // Update the search dates based on the new month selection
                selectedDepartureDatee = formatter.string(from: firstDay)
                selectedReturnDatee = formatter.string(from: lastDay)
                
                // Trigger search with the new month dates
                searchFlightsForDates(
                    origin: fromIataCode,
                    destination: toIataCode,
                    returnDate: selectedReturnDatee,
                    departureDate: selectedDepartureDatee
                )
                
                // Also update the dates array to keep UI in sync
                dates = [firstDay, lastDay]
            }
            
            // If a city was selected but we don't have both origin/destination codes yet,
            // still fetch flight details to show available flights in this month
            else if let city = selectedCity {
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
        if timestamp <= 0 {
            return "No date"
        }
        
        let date = Date(timeIntervalSince1970: TimeInterval(timestamp))
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE, d MMM yyyy"
        return formatter.string(from: date)
    }
    
    // Helper function to calculate trip duration
    func calculateTripDuration(_ result: FlightResult) -> String {
        if let inbound = result.inbound, let inboundDeparture = inbound.departure, inboundDeparture > 0 {
            let outboundDate = Date(timeIntervalSince1970: TimeInterval(result.outbound.departure ?? 0))
            let inboundDate = Date(timeIntervalSince1970: TimeInterval(inboundDeparture))
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
    @State private var isRoundTrip: Bool = true
    
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
                                
                                // Centered trip type tabs with more balanced width
                    TripTypeTabView(selectedTab: $selectedTab, isRoundTrip: $isRoundTrip, viewModel: viewModel)
                                    .frame(width: UIScreen.main.bounds.width * 0.55) // Reduced from 0.6 to 0.55
                                
                                Spacer()
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
                .padding(.top,5)
                
                // Search card with dynamic values
                SearchCard(viewModel: viewModel, isRoundTrip: $isRoundTrip, selectedTab: selectedTab)
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
                   
                    else if viewModel.showingDetailedFlightList {
                                    ModifiedDetailedFlightListView(viewModel: viewModel)
                                        .transition(.move(edge: .trailing))
                                        .zIndex(1) // Make sure it's above the main content
                                        .edgesIgnoringSafeArea(.all)
                                        .background(Color(.systemBackground))
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
                                        departureDate: viewModel.formatDate(result.outbound.departure ?? 0),
                                        returnDate: result.inbound != nil && result.inbound?.departure != nil ?
                                                           viewModel.formatDate(result.inbound!.departure!) : "No return",
                                        origin: result.outbound.origin.iata,
                                        destination: result.outbound.destination.iata,
                                        price: "₹\(result.price)",
                                        isOutDirect: result.outbound.direct,
                                        isInDirect: result.inbound?.direct ?? false,
                                        tripDuration: viewModel.calculateTripDuration(result),
                                        viewModel: viewModel
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
    @State private var showingCalendar = false
    
    @Binding var isRoundTrip: Bool
    
    var selectedTab: Int
    
    var body: some View {
        if selectedTab == 2 {
            // Multi-city search card
            MultiCitySearchCard(viewModel: viewModel)
        } else {
            VStack(spacing: 5) {
                Divider()
                // From row
                HStack {
                    Button(action: {
                        initialFocus = .origin
                        showingSearchSheet = true
                    }) {
                        Image(systemName: "airplane.departure")
                            .foregroundColor(.blue)
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
                    
                    Button(action: {
                        initialFocus = .destination
                        showingSearchSheet = true
                    }) {
                        Image(systemName: "airplane.arrival")
                            .foregroundColor(.blue)
                        Text(viewModel.toLocation)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.black)
                    }
                }
                .padding(4)
                
                Divider()
                
                // Date and passengers row
                HStack {
                    Button(action: {
                        showingCalendar = true
                    }){
                        Image(systemName: "calendar")
                            .foregroundColor(.blue)
                        
                        // Display selected dates if available, otherwise show "Anytime"
                        if viewModel.dates.isEmpty {
                            Text("Anytime")
                                .foregroundColor(.primary)
                                .font(.system(size: 14, weight: .medium))
                        } else if viewModel.dates.count == 1 {
                            Text(formatDate(viewModel.dates[0]))
                                .font(.system(size: 14, weight: .medium))
                        } else if viewModel.dates.count >= 2 {
                            Text("\(formatDate(viewModel.dates[0])) - \(formatDate(viewModel.dates[1]))")
                                .font(.system(size: 14, weight: .medium))
                        }
                    }
                    
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
            .sheet(isPresented: $showingCalendar, onDismiss: {
                // When calendar is dismissed, check if dates were selected and trigger search
                if !viewModel.dates.isEmpty && !viewModel.fromIataCode.isEmpty && !viewModel.toIataCode.isEmpty {
                    viewModel.updateDatesAndRunSearch()
                }
            }) {
                
                CalendarView(fromiatacode: $viewModel.fromIataCode, toiatacode:$viewModel.toIataCode, parentSelectedDates:$viewModel.dates,
                             
                )
            }
            .onAppear {
                // Ensure viewModel's isRoundTrip is in sync with the binding
                viewModel.isRoundTrip = isRoundTrip
            }
            .onChange(of: isRoundTrip) { newValue in
                // Update viewModel when isRoundTrip changes
                viewModel.isRoundTrip = newValue
                // If we have origin/destination and dates already set, trigger a new search
                if !viewModel.fromIataCode.isEmpty && !viewModel.toIataCode.isEmpty && !viewModel.dates.isEmpty {
                    viewModel.updateDatesAndRunSearch()
                }
            }
        }
    }
    
    // Helper method to format date for display
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM"
        return formatter.string(from: date)
    }
}


// MARK: - Flight Result Card (matching screenshot)
struct FlightResultCard: View {
    let departureDate: String
    let returnDate: String
    let origin: String
    let destination: String
    let price: String
    let isOutDirect: Bool
    let isInDirect: Bool
    let tripDuration: String
    @ObservedObject var viewModel: ExploreViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            // Departure section
            VStack(alignment: .leading, spacing: 8) {
                Text("Departure")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                HStack {
                    Text(departureDate.dropLast(5))
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
                    
                    Text(isOutDirect ? "Direct" : "Connecting")
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 12)
            
            
            // Return section
            if viewModel.isRoundTrip {
                Divider()
                VStack(alignment: .leading, spacing: 8) {
                    Text("Return")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    HStack {
                        Text(returnDate.dropLast(5))
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
                        
                        Text(isInDirect ? "Direct" : "Connecting")
                            .font(.subheadline)
                            .foregroundColor(.green)
                            .fontWeight(.bold)
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 12)
            }
            
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
                    
                    Text(viewModel.isRoundTrip ? tripDuration : "One way trip")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                Button(action: {
                    searchFlights()
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
    private func searchFlights() {
        // Use the formatted dates from the view model if available, otherwise fallback to card dates
        let departureDate: String
        let returnDate: String
        
        // First, convert the card dates to API format
        let formattedCardDepartureDate = viewModel.formatDateForAPI(from: self.departureDate) ?? "2025-11-25"
        let formattedCardReturnDate = viewModel.formatDateForAPI(from: self.returnDate) ?? "2025-11-27"
        
        // Create dates from the card dates to update the calendar selection
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        // Add separate handling for one-way vs. round trip
        if viewModel.isRoundTrip {
            if let departureDateObj = dateFormatter.date(from: formattedCardDepartureDate),
               let returnDateObj = dateFormatter.date(from: formattedCardReturnDate) {
                // Update the dates array in the view model to keep calendar in sync for round trip
                viewModel.dates = [departureDateObj, returnDateObj]
            }
            // Update the API date parameters
            viewModel.selectedDepartureDatee = formattedCardDepartureDate
            viewModel.selectedReturnDatee = formattedCardReturnDate
        } else {
            // One-way trip - just set departure date
            if let departureDateObj = dateFormatter.date(from: formattedCardDepartureDate) {
                viewModel.dates = [departureDateObj]
            }
            viewModel.selectedDepartureDatee = formattedCardDepartureDate
            viewModel.selectedReturnDatee = "" // Empty for one-way
        }
        
        // Then call the search function with these dates
        viewModel.searchFlightsForDates(
            origin: origin,
            destination: destination,
            returnDate: viewModel.isRoundTrip ? formattedCardReturnDate : "",
            departureDate: formattedCardDepartureDate
        )
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

// MARK: - Updated TripTypeTabView
struct TripTypeTabView: View {
    @Binding var selectedTab: Int
    @Binding var isRoundTrip: Bool
    @ObservedObject var viewModel: ExploreViewModel // Add this to access the view model directly
    let tabs = ["Return", "One way", "Multi city"]
    
    // Calculate dimensions once for consistency
    private var totalWidth: CGFloat {
        return UIScreen.main.bounds.width * 0.6 // Total width of tab control
    }
    
    private var tabWidth: CGFloat {
        return totalWidth / 3 // Each tab gets 1/3 of the space
    }
    
    // Offset adjustment to shift the white background slightly right
    private var rightShift: CGFloat {
        return 5 // Positive value shifts to the right
    }
    
    var body: some View {
        ZStack(alignment: .leading) {
            // Background capsule
            Capsule()
                .fill(Color(UIColor.systemGray6))
                .padding(.horizontal, -5)
                .padding(.vertical, -5)
            
            // Sliding white background with adjustment for right shift
            Capsule()
                .fill(Color.white)
                .frame(width: tabWidth - 10) // Slightly narrower than tab width
                .offset(x: (CGFloat(selectedTab) * tabWidth) + rightShift) // Added rightShift
                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: selectedTab)
            
            // Tab buttons row with consistent spacing
            HStack(spacing: 0) {
                ForEach(0..<tabs.count, id: \.self) { index in
                            Button(action: {
                                selectedTab = index
                                
                                // Handle multi-city selection
                                if index == 2 {
                                    // Initialize multi city trips
                                    viewModel.initializeMultiCityTrips()
                                } else {
                                    // Existing round trip/one way logic
                                    let newIsRoundTrip = (index == 0)
                                    
                                    if isRoundTrip != newIsRoundTrip {
                                        isRoundTrip = newIsRoundTrip
                                        viewModel.isRoundTrip = newIsRoundTrip
                                        
                                        // Your existing search re-triggering logic
                                        if !viewModel.fromIataCode.isEmpty && !viewModel.toIataCode.isEmpty && !viewModel.dates.isEmpty {
                                            // Clear current results first
                                            viewModel.detailedFlightResults = []
                                            viewModel.flightResults = []
                                            
                                            // Force immediate search
                                            viewModel.updateDatesAndRunSearch()
                                        } else if viewModel.selectedCity != nil {
                                            // If a city was selected in explore view, re-fetch with new trip type
                                            viewModel.fetchFlightDetails(destination: viewModel.selectedCity!.location.iata)
                                        }
                                    } else {
                                        isRoundTrip = newIsRoundTrip
                                    }
                                }
                    }) {
                        Text(tabs[index])
                            .font(.system(size: 13, weight: selectedTab == index ? .semibold : .regular))
                            .foregroundColor(selectedTab == index ? .blue : .black)
                            .frame(width: tabWidth)
                            .padding(.vertical, 8)
                    }
                }
            }
        }
        .frame(width: totalWidth, height: 36)
        .padding(.horizontal, 4)
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

struct MultiCitySearchCard: View {
    @ObservedObject var viewModel: ExploreViewModel
    @State private var showingSearchSheet = false
    @State private var initialFocus: LocationSearchSheet.SearchBarType = .origin
    @State private var showingCalendar = false
    @State private var editingTripIndex: Int = 0
    
    var body: some View {
        VStack(spacing: 0) {
            // Multi-city trips list
            ForEach(0..<viewModel.multiCityTrips.count, id: \.self) { index in
                VStack(spacing: 5) {
                    Divider()
                    
                    HStack {
                        // From location
                        Button(action: {
                            editingTripIndex = index
                            initialFocus = .origin
                            showingSearchSheet = true
                        }) {
                            Image(systemName: "airplane.departure")
                                .foregroundColor(.blue)
                            Text(viewModel.multiCityTrips[index].fromLocation.isEmpty ?
                                 "From" : viewModel.multiCityTrips[index].fromLocation)
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(viewModel.multiCityTrips[index].fromLocation.isEmpty ? .gray : .black)
                        }
                        
                        Spacer()
                        
                        // To location
                        Button(action: {
                            editingTripIndex = index
                            initialFocus = .destination
                            showingSearchSheet = true
                        }) {
                            Image(systemName: "airplane.arrival")
                                .foregroundColor(.blue)
                            Text(viewModel.multiCityTrips[index].toLocation.isEmpty ?
                                 "To" : viewModel.multiCityTrips[index].toLocation)
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(viewModel.multiCityTrips[index].toLocation.isEmpty ? .gray : .black)
                        }
                        
                        Spacer()
                        
                        // Date selector with formatted date
                        Button(action: {
                            editingTripIndex = index
                            showingCalendar = true
                        }) {
                            Image(systemName: "calendar")
                                .foregroundColor(.blue)
                            
                            Text(formattedDate(viewModel.multiCityTrips[index].date))
                                .font(.system(size: 14, weight: .medium))
                        }
                        
                        // Delete button (only if more than 2 trips)
                        if viewModel.multiCityTrips.count > 2 {
                            Button(action: {
                                removeTrip(at: index)
                            }) {
                                Image(systemName: "trash")
                                    .foregroundColor(.red)
                                    .font(.system(size: 14))
                            }
                            .padding(.leading, 8)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                }
            }
            
            Divider()
            
            // Add flight button (if less than 5 trips)
            if viewModel.multiCityTrips.count < 5 {
                Button(action: addTrip) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(.blue)
                        Text("Add flight")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.blue)
                    }
                    .padding()
                }
            }
            
            // Passenger info and search button
            HStack {
                Image(systemName: "person")
                    .foregroundColor(.blue)
                
                Text("1, Economy")
                    .font(.system(size: 14, weight: .medium))
                
                Spacer()
                
                // Search button
                Button(action: searchMultiCityFlights) {
                    Text("Search")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 16)
                        .background(Color.blue)
                        .cornerRadius(8)
                }
            }
            .padding()
        }
        .sheet(isPresented: $showingSearchSheet) {
            // Use existing LocationSearchSheet but with a custom handler
            MultiCityLocationSheet(
                viewModel: viewModel,
                initialFocus: initialFocus,
                tripIndex: editingTripIndex
            )
            .presentationDetents([.large])
        }
        .sheet(isPresented: $showingCalendar) {
            // Use existing CalendarView but with single date selection mode
            CalendarView(
                fromiatacode: .constant(""),
                toiatacode: .constant(""),
                parentSelectedDates: .constant([]),
                isMultiCity: true,
                multiCityTripIndex: editingTripIndex,
                multiCityViewModel: viewModel
            )
        }
    }
    
    // Helper function to format date in a simple way
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE, d MMM"
        return formatter.string(from: date)
    }
    
    // Safe removal of trips (ensure we keep at least 2)
    private func removeTrip(at index: Int) {
        if viewModel.multiCityTrips.count > 2 {
            withAnimation {
                viewModel.multiCityTrips.remove(at: index)
            }
        }
    }
    
    // Add a new trip based on the last trip
    private func addTrip() {
        if viewModel.multiCityTrips.count < 5, let lastTrip = viewModel.multiCityTrips.last {
            withAnimation {
                // Create new trip with defaults
                let nextDay = Calendar.current.date(byAdding: .day, value: 1, to: lastTrip.date) ?? Date()
                
                let newTrip = MultiCityTrip(
                    fromLocation: lastTrip.toLocation,
                    fromIataCode: lastTrip.toIataCode,
                    toLocation: "",
                    toIataCode: "",
                    date: nextDay
                )
                
                viewModel.multiCityTrips.append(newTrip)
            }
        }
    }
    
    // Validate and initiate search
    private func searchMultiCityFlights() {
        // Validate all trips have origin, destination and date
        let isValid = viewModel.multiCityTrips.allSatisfy { trip in
            return !trip.fromIataCode.isEmpty && !trip.toIataCode.isEmpty
        }
        
        if isValid {
            viewModel.searchMultiCityFlights()
        } else {
            // Add an alert here if needed
            print("Please fill in all origins and destinations")
        }
    }
}

// This is a simple wrapper around existing LocationSearchSheet
struct MultiCityLocationSheet: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: ExploreViewModel
    var initialFocus: LocationSearchSheet.SearchBarType
    var tripIndex: Int
    
    @State private var searchText = ""
    @State private var selectedLocation = ""
    
    var body: some View {
        LocationSearchSheet(
            viewModel: viewModel,
            multiCityMode: true, multiCityTripIndex: tripIndex, initialFocus: initialFocus
        )
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
    @FocusState private var focusedField: SearchBarType?
    
    var multiCityMode: Bool = false
       var multiCityTripIndex: Int = 0

    enum SearchBarType {
        case origin
        case destination
    }

    var initialFocus: SearchBarType
    private let debouncer = Debouncer(delay: 0.3)

    var body: some View {
        VStack(spacing: 0) {
            // Header section
            headerView()
            
            // Search bars
            originSearchBarView()
            destinationSearchBarView()
            
            // Current location button
            currentLocationButtonView()
            
            Divider()
            
            // Results section
            resultsView()
            

            
            Spacer()
        }
        .background(Color.white)
        .onAppear {
            // Set the initial focus
            activeSearchBar = initialFocus
            focusedField = initialFocus
        }
    }
    
    // MARK: - Component Views
    
    private func headerView() -> some View {
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
    }
    
    private func originSearchBarView() -> some View {
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
                .focused($focusedField, equals: .origin)
                .onChange(of: originSearchText) {
                    handleOriginTextChange()
                }
                .onTapGesture {
                    activeSearchBar = .origin
                    focusedField = .origin
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
    }
    
    private func destinationSearchBarView() -> some View {
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
                .focused($focusedField, equals: .destination)
                .onChange(of: destinationSearchText) {
                    handleDestinationTextChange()
                }
                .onTapGesture {
                    activeSearchBar = .destination
                    focusedField = .destination
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
    }
    
    private func currentLocationButtonView() -> some View {
        Group {
            if activeSearchBar == .origin {
                Button(action: {
                    useCurrentLocation()
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
        }
    }
    
    private func resultsView() -> some View {
        Group {
            if isSearching {
                searchingView()
            } else if let error = searchError {
                errorView(error: error)
            } else if shouldShowNoResults() {
                noResultsView()
            } else {
                resultsList()
            }
        }
    }
    
    private func searchingView() -> some View {
        VStack {
            ProgressView()
            Text("Searching...")
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding()
    }
    
    private func errorView(error: String) -> some View {
        Text(error)
            .foregroundColor(.red)
            .padding()
    }
    
    private func noResultsView() -> some View {
        Text("No results found")
            .foregroundColor(.gray)
            .padding()
    }
    
    private func resultsList() -> some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(results) { result in
                    LocationResultRow(result: result)
                        .onTapGesture {
                            handleResultSelection(result: result)
                        }
                }
            }
        }
    }
    
    
    // MARK: - Helper Methods
    
    
    
    private func handleOriginTextChange() {
        activeSearchBar = .origin
        if !originSearchText.isEmpty {
            debouncer.debounce {
                searchLocations(query: originSearchText)
            }
        } else {
            results = []
        }
    }
    
    private func handleDestinationTextChange() {
        activeSearchBar = .destination
        if !destinationSearchText.isEmpty {
            debouncer.debounce {
                searchLocations(query: destinationSearchText)
            }
        } else {
            results = []
        }
    }
    
    private func shouldShowNoResults() -> Bool {
        let emptyResults = results.isEmpty
        let activeOriginWithText = activeSearchBar == .origin && !originSearchText.isEmpty
        let activeDestinationWithText = activeSearchBar == .destination && !destinationSearchText.isEmpty
        
        return emptyResults && (activeOriginWithText || activeDestinationWithText)
    }
    
    private func useCurrentLocation() {
        viewModel.fromLocation = "Current Location"
        viewModel.fromIataCode = "DEL" // Using Delhi as default
        originSearchText = "Current Location"
        
        activeSearchBar = .destination
        focusedField = .destination
    }
    
    private func handleResultSelection(result: AutocompleteResult) {
        if activeSearchBar == .origin {
            selectOrigin(result: result)
        } else {
            selectDestination(result: result)
        }
    }
    
    private func selectOrigin(result: AutocompleteResult) {
            if multiCityMode {
                viewModel.multiCityTrips[multiCityTripIndex].fromLocation = result.cityName
                viewModel.multiCityTrips[multiCityTripIndex].fromIataCode = result.iataCode
            } else {
                viewModel.fromLocation = result.cityName
                viewModel.fromIataCode = result.iataCode
                originSearchText = result.cityName
            }
            
            // Auto-focus the destination field
            activeSearchBar = .destination
            focusedField = .destination
        }
    
    private func selectDestination(result: AutocompleteResult) {
        
        if multiCityMode {
            viewModel.multiCityTrips[multiCityTripIndex].toLocation = result.cityName
            viewModel.multiCityTrips[multiCityTripIndex].toIataCode = result.iataCode
            dismiss()
        }
        else{
            // Selected destination - update the view model
            viewModel.toLocation = result.cityName
            viewModel.toIataCode = result.iataCode
            
            // Only proceed if we have both origin and destination
            if !viewModel.fromIataCode.isEmpty {
                // Dismiss the sheet
                dismiss()
                
                // If user has selected dates in the calendar, use those dates for search
                if !viewModel.dates.isEmpty {
                    // Let the view model handle date formatting and search
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        viewModel.updateDatesAndRunSearch()
                    }
                } else {
                    // If no dates selected, use default dates
                    let departureDate = "2025-12-29"
                    let returnDate = "2025-12-30"
                    viewModel.selectedDepartureDatee = departureDate
                    viewModel.selectedReturnDatee = returnDate
                    
                    // Initiate flight search with default dates
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        viewModel.searchFlightsForDates(
                            origin: viewModel.fromIataCode,
                            destination: result.iataCode,
                            returnDate: returnDate,
                            departureDate: departureDate
                        )
                    }
                }
            }
    }
    }
    
//    private func initiateSearch() {
//        // Dismiss the sheet
//        dismiss()
//        
//        // Initiate flight search with fixed dates
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
//            viewModel.searchFlightsForDates(origin: viewModel.fromIataCode, destination: viewModel.toIataCode, returnDate: "2025-12-12", departureDate: "2025-12-20"
//                
//            )
//        }
//    }

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



//Last Flight view
struct LastFlightCard: View {


// Outbound flight
let departureTime: String
let departureCode: String
let departureDate: String

let arrivalTime: String
let arrivalCode: String
let arrivalDate: String

let duration: String
let isOutboundDirect: Bool

// Return flight
let returnDepartureTime: String
let returnDepartureCode: String
let returnDepartureDate: String

let returnArrivalTime: String
let returnArrivalCode: String
let returnArrivalDate: String

let returnDuration: String
let isReturnDirect: Bool

// Price and airline info
let airline: String
let price: String
let priceDetail: String

var body: some View {
    VStack(spacing: 0) {

        
        // Outbound flight
        HStack(alignment: .top, spacing: 0) {
            // Departure
            VStack(alignment: .leading, spacing: 2) {
                Text(departureTime)
                    .font(.system(size: 18, weight: .bold))
                Text(departureCode)
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
                Text(departureDate)
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
            }
            .frame(width: 70, alignment: .leading)
            
            // Flight path
            VStack(spacing: 2) {
                HStack(spacing: 4) {
                    Circle()
                        .frame(width: 8, height: 8)
                        .foregroundColor(.gray)
                    
                    Rectangle()
                        .frame(height: 1)
                        .foregroundColor(.gray)
                    
                    Circle()
                        .frame(width: 8, height: 8)
                        .foregroundColor(.gray)
                }
                
                Text(duration)
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
                
                Text(isOutboundDirect ? "Direct" : "1 Stop")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(isOutboundDirect ? .green : .primary)
            }
            .frame(maxWidth: .infinity)
            
            // Arrival
            VStack(alignment: .trailing, spacing: 2) {
                Text(arrivalTime)
                    .font(.system(size: 18, weight: .bold))
                Text(arrivalCode)
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
                Text(arrivalDate)
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
            }
            .frame(width: 70, alignment: .trailing)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        
        Divider()
            .padding(.horizontal, 16)
        
        // Return flight
        HStack(alignment: .top, spacing: 0) {
            // Departure
            VStack(alignment: .leading, spacing: 2) {
                Text(returnDepartureTime)
                    .font(.system(size: 18, weight: .bold))
                Text(returnDepartureCode)
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
                Text(returnDepartureDate)
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
            }
            .frame(width: 70, alignment: .leading)
            
            // Flight path
            VStack(spacing: 2) {
                HStack(spacing: 4) {
                    Circle()
                        .frame(width: 8, height: 8)
                        .foregroundColor(.gray)
                    
                    Rectangle()
                        .frame(height: 1)
                        .foregroundColor(.gray)
                    
                    Circle()
                        .frame(width: 8, height: 8)
                        .foregroundColor(.gray)
                }
                
                Text(returnDuration)
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
                
                Text(isReturnDirect ? "Direct" : "1 Stop")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(isReturnDirect ? .green : .primary)
            }
            .frame(maxWidth: .infinity)
            
            // Arrival
            VStack(alignment: .trailing, spacing: 2) {
                Text(returnArrivalTime)
                    .font(.system(size: 18, weight: .bold))
                Text(returnArrivalCode)
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
                Text(returnArrivalDate)
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
            }
            .frame(width: 70, alignment: .trailing)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        
        Divider()
            .padding(.horizontal, 16)
        
        // Airline and price
        HStack {
            Text(airline)
                .font(.system(size: 14))
                .foregroundColor(.gray)
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                Text(price)
                    .font(.system(size: 20, weight: .bold))
                
                Text(priceDetail)
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
    .background(Color.white)
    .cornerRadius(12)
    .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
}
}

struct FlightTag: Identifiable {
let id = UUID()
let title: String
let color: Color

static let best = FlightTag(title: "Best", color: Color.blue)
static let cheapest = FlightTag(title: "Cheapest", color: Color.green)
static let fastest = FlightTag(title: "Fastest", color: Color.purple)
}



struct DetailedFlightCardWrapper: View {
    let result: FlightDetailResult
    @ObservedObject var viewModel: ExploreViewModel
    var onTap: () -> Void
    
    var body: some View {
        if let outboundLeg = result.legs.first, !outboundLeg.segments.isEmpty {
            let outboundSegment = outboundLeg.segments.first!
            let returnLeg = viewModel.isRoundTrip && result.legs.count >= 2 ? result.legs.last : nil
            let returnSegment = returnLeg?.segments.first
            
            // Format time and dates
            let outboundDepartureTime = formatTime(from: outboundSegment.departureTimeAirport)
            let outboundArrivalTime = formatTime(from: outboundSegment.arriveTimeAirport)
            
            Button(action: onTap) {
                VStack {
                    // Flight tags
                    HStack(spacing: 4) {
                        if result.isBest {
                            FlightTagView(tag: FlightTag.best)
                        }
                        if result.isCheapest {
                            FlightTagView(tag: FlightTag.cheapest)
                        }
                        if result.isFastest {
                            FlightTagView(tag: FlightTag.fastest)
                        }
                    }
                    .padding(.trailing, -40)
                    .zIndex(1)
                    
                    if viewModel.isRoundTrip && returnLeg != nil && returnSegment != nil {
                        // Round trip flight card
                        LastFlightCard(
                            departureTime: outboundDepartureTime,
                            departureCode: outboundSegment.originCode,
                            departureDate: formatDate(from: outboundSegment.departureTimeAirport),
                            arrivalTime: outboundArrivalTime,
                            arrivalCode: outboundSegment.destinationCode,
                            arrivalDate: formatDate(from: outboundSegment.arriveTimeAirport),
                            duration: formatDuration(minutes: outboundLeg.duration),
                            isOutboundDirect: outboundLeg.stopCount == 0,
                            
                            returnDepartureTime: formatTime(from: returnSegment!.departureTimeAirport),
                            returnDepartureCode: returnSegment!.originCode,
                            returnDepartureDate: formatDate(from: returnSegment!.departureTimeAirport),
                            returnArrivalTime: formatTime(from: returnSegment!.arriveTimeAirport),
                            returnArrivalCode: returnSegment!.destinationCode,
                            returnArrivalDate: formatDate(from: returnSegment!.arriveTimeAirport),
                            returnDuration: formatDuration(minutes: returnLeg!.duration),
                            isReturnDirect: returnLeg!.stopCount == 0,
                            
                            airline: outboundSegment.airlineName,
                            price: "₹\(Int(result.minPrice))",
                            priceDetail: "per person"
                        )
                    } else {
                        // One way flight card
                        OneWayFlightCard(
                            departureTime: outboundDepartureTime,
                            departureCode: outboundSegment.originCode,
                            departureDate: formatDate(from: outboundSegment.departureTimeAirport),
                            arrivalTime: outboundArrivalTime,
                            arrivalCode: outboundSegment.destinationCode,
                            arrivalDate: formatDate(from: outboundSegment.arriveTimeAirport),
                            duration: formatDuration(minutes: outboundLeg.duration),
                            isOutboundDirect: outboundLeg.stopCount == 0,
                            airline: outboundSegment.airlineName,
                            price: "₹\(Int(result.minPrice))",
                            priceDetail: "per person"
                        )
                    }
                }
            }
            .buttonStyle(PlainButtonStyle())
        } else {
            Text("Incomplete flight details")
                .foregroundColor(.gray)
                .padding()
        }
    }
    
    // Helper functions for formatting
    private func formatTime(from timestamp: Int) -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(timestamp))
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
    
    private func formatDate(from timestamp: Int) -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(timestamp))
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE, d MMM yyyy"
        return formatter.string(from: date)
    }
    
    private func formatDuration(minutes: Int) -> String {
        let hours = minutes / 60
        let mins = minutes % 60
        return "\(hours)h \(mins)m"
    }
}

// Add a new OneWayFlightCard struct
struct OneWayFlightCard: View {
    let departureTime: String
    let departureCode: String
    let departureDate: String
    let arrivalTime: String
    let arrivalCode: String
    let arrivalDate: String
    let duration: String
    let isOutboundDirect: Bool
    let airline: String
    let price: String
    let priceDetail: String
    
    var body: some View {
        VStack(spacing: 0) {
            // Outbound flight
            HStack(alignment: .top, spacing: 0) {
                // Departure
                VStack(alignment: .leading, spacing: 2) {
                    Text(departureTime)
                        .font(.system(size: 18, weight: .bold))
                    Text(departureCode)
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                    Text(departureDate)
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                }
                .frame(width: 70, alignment: .leading)
                
                // Flight path
                VStack(spacing: 2) {
                    HStack(spacing: 4) {
                        Circle()
                            .frame(width: 8, height: 8)
                            .foregroundColor(.gray)
                        
                        Rectangle()
                            .frame(height: 1)
                            .foregroundColor(.gray)
                        
                        Circle()
                            .frame(width: 8, height: 8)
                            .foregroundColor(.gray)
                    }
                    
                    Text(duration)
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                    
                    Text(isOutboundDirect ? "Direct" : "1 Stop")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(isOutboundDirect ? .green : .primary)
                }
                .frame(maxWidth: .infinity)
                
                // Arrival
                VStack(alignment: .trailing, spacing: 2) {
                    Text(arrivalTime)
                        .font(.system(size: 18, weight: .bold))
                    Text(arrivalCode)
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                    Text(arrivalDate)
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                }
                .frame(width: 70, alignment: .trailing)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            
            Divider()
                .padding(.horizontal, 16)
            
            // Airline and price
            HStack {
                Text(airline)
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    Text(price)
                        .font(.system(size: 20, weight: .bold))
                    
                    Text(priceDetail)
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

struct FlightDetailCard: View {
    let destination: String
    let isDirectFlight: Bool
    let flightDuration: String
    let flightClass: String
    
    // For direct flights
    let departureDate: String
    let departureTime: String? // Added time separately
    let departureAirportCode: String
    let departureAirportName: String
    let departureTerminal: String
    
    let airline: String
    let flightNumber: String
    
    let arrivalDate: String
    let arrivalTime: String? // Added time separately
    let arrivalAirportCode: String
    let arrivalAirportName: String
    let arrivalTerminal: String
    let arrivalNextDay: Bool // Flag to show "You will reach the next day"
    
    // For connecting flights
    let connectionSegments: [ConnectionSegment]?
    
    // Initialize for direct flights
    init(
        destination: String,
        isDirectFlight: Bool,
        flightDuration: String,
        flightClass: String,
        departureDate: String,
        departureTime: String? = nil,
        departureAirportCode: String,
        departureAirportName: String,
        departureTerminal: String,
        airline: String,
        flightNumber: String,
        arrivalDate: String,
        arrivalTime: String? = nil,
        arrivalAirportCode: String,
        arrivalAirportName: String,
        arrivalTerminal: String,
        arrivalNextDay: Bool = false
    ) {
        self.destination = destination
        self.isDirectFlight = isDirectFlight
        self.flightDuration = flightDuration
        self.flightClass = flightClass
        self.departureDate = departureDate
        self.departureTime = departureTime
        self.departureAirportCode = departureAirportCode
        self.departureAirportName = departureAirportName
        self.departureTerminal = departureTerminal
        self.airline = airline
        self.flightNumber = flightNumber
        self.arrivalDate = arrivalDate
        self.arrivalTime = arrivalTime
        self.arrivalAirportCode = arrivalAirportCode
        self.arrivalAirportName = arrivalAirportName
        self.arrivalTerminal = arrivalTerminal
        self.arrivalNextDay = arrivalNextDay
        self.connectionSegments = nil
    }
    
    // Initialize for connecting flights
    init(
        destination: String,
        flightDuration: String,
        flightClass: String,
        connectionSegments: [ConnectionSegment]
    ) {
        self.destination = destination
        self.isDirectFlight = false
        self.flightDuration = flightDuration
        self.flightClass = flightClass
        self.departureDate = ""
        self.departureTime = nil
        self.departureAirportCode = ""
        self.departureAirportName = ""
        self.departureTerminal = ""
        self.airline = ""
        self.flightNumber = ""
        self.arrivalDate = ""
        self.arrivalTime = nil
        self.arrivalAirportCode = ""
        self.arrivalAirportName = ""
        self.arrivalTerminal = ""
        self.arrivalNextDay = false
        self.connectionSegments = connectionSegments
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header section
            VStack(alignment: .leading, spacing: 8) {
                Text("Flight to \(destination)")
                    .font(.system(size: 18, weight: .bold))
                
                HStack(spacing: 16) {
                    HStack(spacing: 4) {
                        Text(isDirectFlight ? "Direct" : "\(connectionSegments?.count ?? 1) Stop")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(isDirectFlight ? .green : .primary)
                    }
                    
                    HStack(spacing: 4) {
                        Image(systemName: "clock")
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                        Text(flightDuration)
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                    }
                    
                    HStack(spacing: 4) {
                        Image(systemName: "seat")
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                        Text(flightClass)
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding(.top, 16)
            .padding(.bottom, 8)
            .padding(.horizontal, 16)
            
            if isDirectFlight {
                // Direct flight path visualization
                DirectFlightView(
                    departureDate: departureDate,
                    departureTime: departureTime,
                    departureAirportCode: departureAirportCode,
                    departureAirportName: departureAirportName,
                    departureTerminal: departureTerminal,
                    airline: airline,
                    flightNumber: flightNumber,
                    arrivalDate: arrivalDate,
                    arrivalTime: arrivalTime,
                    arrivalAirportCode: arrivalAirportCode,
                    arrivalAirportName: arrivalAirportName,
                    arrivalTerminal: arrivalTerminal,
                    arrivalNextDay: arrivalNextDay
                )
            } else if let segments = connectionSegments {
                // Connecting flight path visualization
                ConnectingFlightView(segments: segments)
            }
        }
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

struct DirectFlightView: View {
    let departureDate: String
    let departureTime: String?
    let departureAirportCode: String
    let departureAirportName: String
    let departureTerminal: String
    
    let airline: String
    let flightNumber: String
    
    let arrivalDate: String
    let arrivalTime: String?
    let arrivalAirportCode: String
    let arrivalAirportName: String
    let arrivalTerminal: String
    let arrivalNextDay: Bool
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Timeline
            VStack(spacing: 0) {
                Circle()
                    .frame(width: 8, height: 8)
                    .foregroundColor(.blue)
                
                Rectangle()
                    .frame(width: 2)
                    .foregroundColor(.blue)
                    .padding(.top, -1)
                    .padding(.bottom, -1)
                
                Circle()
                    .frame(width: 8, height: 8)
                    .foregroundColor(.blue)
            }
            .padding(.top, 5)
            
            // Flight details
            VStack(alignment: .leading, spacing: 24) {
                // Departure
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(departureDate)
                            .font(.system(size: 14))
                            .foregroundColor(.black)
                            
                        if let time = departureTime {
                            Text(time)
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.black)
                        }
                    }
                    
                    HStack(alignment: .center, spacing: 12) {
                        Text(departureAirportCode)
                            .font(.system(size: 16, weight: .semibold))
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(departureAirportName)
                                .font(.system(size: 14, weight: .medium))
                            Text("Terminal \(departureTerminal)")
                                .font(.system(size: 13))
                                .foregroundColor(.gray)
                        }
                    }
                    
                    // Airline info
                    HStack(spacing: 10) {
                        ZStack {
                            Rectangle()
                                .fill(Color.blue.opacity(0.1))
                                .frame(width: 32, height: 32)
                                .cornerRadius(4)
                            
                            Text(String(airline.prefix(2)))
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.blue)
                        }
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(airline)
                                .font(.system(size: 14))
                            Text(flightNumber)
                                .font(.system(size: 13))
                                .foregroundColor(.gray)
                        }
                        
                        Spacer()
                        
                        HStack {
                            Text("More info")
                                .font(.system(size: 14))
                                .foregroundColor(.blue)
                            
                            Image(systemName: "chevron.down")
                                .font(.system(size: 12))
                                .foregroundColor(.blue)
                        }
                    }
                    .padding(.top, 6)
                }
                
                // Arrival
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(arrivalDate)
                            .font(.system(size: 14))
                            .foregroundColor(.black)
                            
                        if let time = arrivalTime {
                            Text(time)
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.black)
                        }
                        
                        if arrivalNextDay {
                            Text("You will reach the next day")
                                .font(.system(size: 12))
                                .foregroundColor(.red)
                        }
                    }
                    
                    HStack(alignment: .center, spacing: 12) {
                        Text(arrivalAirportCode)
                            .font(.system(size: 16, weight: .semibold))
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(arrivalAirportName)
                                .font(.system(size: 14, weight: .medium))
                            Text("Terminal \(arrivalTerminal)")
                                .font(.system(size: 13))
                                .foregroundColor(.gray)
                        }
                    }
                }
            }
            .padding(.bottom, 16)
        }
        .padding(.leading, 16)
    }
}

// Model for connection segments
struct ConnectionSegment: Identifiable {
    let id = UUID()
    
    // Departure info
    let departureDate: String
    let departureTime: String
    let departureAirportCode: String
    let departureAirportName: String
    let departureTerminal: String
    
    // Arrival info
    let arrivalDate: String
    let arrivalTime: String
    let arrivalAirportCode: String
    let arrivalAirportName: String
    let arrivalTerminal: String
    let arrivalNextDay: Bool
    
    // Flight info
    let airline: String
    let flightNumber: String
    
    // Connection info (if not the last segment)
    let connectionDuration: String? // e.g. "2h 50m connection"
}

struct ConnectingFlightView: View {
    let segments: [ConnectionSegment]
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Timeline with connection points
            VStack(spacing: 0) {
                // First point
                Circle()
                    .frame(width: 8, height: 8)
                    .foregroundColor(.blue)
                
                // For each segment, create a line and dot
                ForEach(0..<segments.count, id: \.self) { index in
                    // Line to next point
                    if index < segments.count {
                        Rectangle()
                            .frame(width: 2)
                            .foregroundColor(.blue)
                    }
                    
                    // Connection point (if not the last segment)
                    if index < segments.count - 1 {
                        Circle()
                            .frame(width: 8, height: 8)
                            .foregroundColor(.blue)
                    }
                }
                
                // Final point
                Circle()
                    .frame(width: 8, height: 8)
                    .foregroundColor(.blue)
            }
            .padding(.top, 5)
            
            // Flight segments
            VStack(alignment: .leading, spacing: 8) {
                ForEach(segments) { segment in
                    // First departure
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text(segment.departureDate)
                                .font(.system(size: 14))
                                .foregroundColor(.black)
                            
                            Text(segment.departureTime)
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.black)
                        }
                        
                        HStack(alignment: .center, spacing: 12) {
                            Text(segment.departureAirportCode)
                                .font(.system(size: 16, weight: .semibold))
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(segment.departureAirportName)
                                    .font(.system(size: 14, weight: .medium))
                                Text("Terminal \(segment.departureTerminal)")
                                    .font(.system(size: 13))
                                    .foregroundColor(.gray)
                            }
                        }
                        
                        // Airline info
                        HStack(spacing: 10) {
                            ZStack {
                                Rectangle()
                                    .fill(Color.blue.opacity(0.1))
                                    .frame(width: 32, height: 32)
                                    .cornerRadius(4)
                                
                                Text(String(segment.airline.prefix(2)))
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(.blue)
                            }
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(segment.airline)
                                    .font(.system(size: 14))
                                Text(segment.flightNumber)
                                    .font(.system(size: 13))
                                    .foregroundColor(.gray)
                            }
                            
                            Spacer()
                            
                            HStack {
                                Text("More info")
                                    .font(.system(size: 14))
                                    .foregroundColor(.blue)
                                
                                Image(systemName: "chevron.down")
                                    .font(.system(size: 12))
                                    .foregroundColor(.blue)
                            }
                        }
                        .padding(.top, 6)
                    }
                    
                    // Flight arrival
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text(segment.arrivalDate)
                                .font(.system(size: 14))
                                .foregroundColor(.black)
                            
                            Text(segment.arrivalTime)
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.black)
                            
                            if segment.arrivalNextDay {
                                Text("You will reach the next day")
                                    .font(.system(size: 12))
                                    .foregroundColor(.red)
                            }
                        }
                        
                        HStack(alignment: .center, spacing: 12) {
                            Text(segment.arrivalAirportCode)
                                .font(.system(size: 16, weight: .semibold))
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(segment.arrivalAirportName)
                                    .font(.system(size: 14, weight: .medium))
                                Text("Terminal \(segment.arrivalTerminal)")
                                    .font(.system(size: 13))
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    
                    // Show connection info if there is a next segment
                    if let connectionDuration = segment.connectionDuration {
                        HStack {
                            Spacer()
                                .frame(width: 40)
                            
                            Text(connectionDuration)
                                .font(.system(size: 12))
                                .foregroundColor(.red)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(
                                    RoundedRectangle(cornerRadius: 4)
                                        .stroke(Color.red, lineWidth: 1)
                                        .background(Color.red.opacity(0.1))
                                )
                        }
                        .padding(.vertical, 8)
                    }
                }
            }
            .padding(.bottom, 16)
        }
        .padding(.leading, 16)
    }
}

struct FilterButton: View {
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Image(systemName: "line.3.horizontal.decrease")
                    .font(.system(size: 14))
                Text("Filter")
                    .font(.system(size: 14, weight: .medium))
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.white)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.gray.opacity(0.5), lineWidth: 1)
            )
        }
        .foregroundColor(.primary)
    }
}

struct FlightFilterTabView: View {
    let selectedFilter: FilterOption
    let onSelectFilter: (FilterOption) -> Void
    
    enum FilterOption: String, CaseIterable {

        case all = "All"
        case best = "Best"
        case cheapest = "Cheapest"
        case fastest = "Fastest"
        case direct = "Direct"
    }
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(FilterOption.allCases, id: \.self) { filter in
                    Button(action: {
                        onSelectFilter(filter)
                    }) {
                        Text(filter.rawValue)
                            .font(.system(size: 14, weight: selectedFilter == filter ? .semibold : .regular))
                            .foregroundColor(selectedFilter == filter ? .blue : .black)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.white)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(selectedFilter == filter ? Color.blue : Color.black.opacity(0.3), lineWidth: selectedFilter == filter ? 1 : 0.5)
                            )
                    }
                }
            }
            .padding(.horizontal)
        }
    }
}


struct ModifiedDetailedFlightListView: View {
    @ObservedObject var viewModel: ExploreViewModel
    @State private var selectedFlightId: String? = nil
    @State private var selectedFilter: FlightFilterTabView.FilterOption = .all
    
    @State private var filteredResults: [FlightDetailResult] = []
    
    @State private var resultCount: Int = 0
    
    @State private var showingFilterSheet = false
    
    private var formattedDates: String {
        if viewModel.dates.count >= 2 {
            let sortedDates = viewModel.dates.sorted()
            return "\(viewModel.formatDateForDisplay(date: sortedDates[0])) - \(viewModel.formatDateForDisplay(date: sortedDates[1]))"
        } else if viewModel.dates.count == 1 {
            return viewModel.formatDateForDisplay(date: viewModel.dates[0])
        } else if !viewModel.selectedDepartureDatee.isEmpty && !viewModel.selectedReturnDatee.isEmpty {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            
            if let departureDate = formatter.date(from: viewModel.selectedDepartureDatee),
               let returnDate = formatter.date(from: viewModel.selectedReturnDatee) {
                return "\(viewModel.formatDateForDisplay(date: departureDate)) - \(viewModel.formatDateForDisplay(date: returnDate))"
            }
        }
        return "Selected dates"
    }
    
    // Add a computed property to check if we're in multi-city mode
    private var isMultiCity: Bool {
        return viewModel.multiCityTrips.count >= 2
    }
    
    // Helper to get display text for multi-city routes
    private func multiCityRouteText() -> String {
        if viewModel.multiCityTrips.count <= 1 {
            return "\(viewModel.selectedOriginCode) → \(viewModel.selectedDestinationCode)"
        }
        
        // For multiple cities, show first origin to last destination
        let firstOrigin = viewModel.multiCityTrips.first?.fromIataCode ?? viewModel.selectedOriginCode
        let lastDestination = viewModel.multiCityTrips.last?.toIataCode ?? viewModel.selectedDestinationCode
        
        return "\(firstOrigin) → ... → \(lastDestination)"
    }
    
    // Helper to get formatted multi-city dates
    private func multiCityDatesText() -> String {
        if viewModel.multiCityTrips.isEmpty {
            return formattedDates
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM"
        
        let firstDate = formatter.string(from: viewModel.multiCityTrips.first?.date ?? Date())
        let lastDate = formatter.string(from: viewModel.multiCityTrips.last?.date ?? Date())
        
        return "\(firstDate) - \(lastDate)"
    }
    
    var body: some View {
        VStack {
            // Header
            HStack {
                Button(action: {
                    selectedFlightId = nil
                    viewModel.showingDetailedFlightList = false
                }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.primary)
                        .font(.system(size: 18, weight: .semibold))
                }
                
                Spacer()
                
                // Use the appropriate route display based on mode
                Text(isMultiCity ? multiCityRouteText() : "\(viewModel.selectedOriginCode) → \(viewModel.selectedDestinationCode)")
                    .font(.headline)
                
                Spacer()
                
                // Use appropriate date display based on mode
                Text(isMultiCity ? multiCityDatesText() : formattedDates)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            .padding()
            
            // Only show filter tabs when we have results and no flight is selected
                        if !viewModel.detailedFlightResults.isEmpty && selectedFlightId == nil {
                            // Filter tabs
                            HStack {
                                // New Filter button
                                FilterButton {
                                    showingFilterSheet = true
                                }
                                .padding(.leading,10)
                                
                                FlightFilterTabView(
                                    selectedFilter: selectedFilter,
                                    onSelectFilter: { filter in
                                        selectedFilter = filter
                                        applyFilters()
                                    }
                                )
                                
                                
                                
                            }
                            .padding(.trailing, 16)
                            
                            // Show flight count
                            HStack {
                                Text("\(filteredResults.count) flights")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                Spacer()
                            }
                            .padding(.horizontal)
                            .padding(.bottom, 8)
                        }
            
            // Content
            if viewModel.detailedFlightResults.isEmpty {
                if viewModel.isLoadingDetailedFlights {
                    Spacer()
                    ForEach(0..<4){_ in
                        DetailedFlightCardSkeleton()
                            .padding(.bottom,5)
                    }
                
                    Spacer()
                } else if let error = viewModel.detailedFlightError {
                    Spacer()
                    Text("Error: \(error)")
                        .foregroundColor(.red)
                        .padding()
                    Spacer()
                } else {
                    Spacer()
                    Text("No flights found for these dates")
                        .foregroundColor(.gray)
                        .padding()
                    Spacer()
                }
            } else {
                VStack {
                    // If we have a selected flight, show the FlightDetailCard for it
                    if let selectedId = selectedFlightId,
                       let selectedFlight = viewModel.detailedFlightResults.first(where: { $0.id == selectedId }) {
                        
                        ScrollView {
                            VStack(spacing: 0) {
                                // Back button at the top
                                HStack {
                                    Button(action: {
                                        selectedFlightId = nil // Deselect flight to return to list view
                                    }) {
                                        HStack(spacing: 4) {
                                            Image(systemName: "chevron.left")
                                                .font(.system(size: 14))
                                            Text("Back to flights")
                                                .font(.system(size: 14, weight: .medium))
                                        }
                                        .foregroundColor(.blue)
                                    }
                                    .padding(.top, 12)
                                    .padding(.bottom, 8)
                                    Spacer()
                                }
                                .padding(.horizontal)
                                
                                // Flight tags
                                HStack(spacing: 8) {
                                    if selectedFlight.isBest {
                                        FlightTagView(tag: FlightTag.best)
                                    }
                                    if selectedFlight.isCheapest {
                                        FlightTagView(tag: FlightTag.cheapest)
                                    }
                                    if selectedFlight.isFastest {
                                        FlightTagView(tag: FlightTag.fastest)
                                    }
                                    Spacer()
                                }
                                .padding(.horizontal)
                                .padding(.bottom, 8)
                                
                                // Display flight details - handle legs differently based on mode
                                if isMultiCity {
                                    // For multi-city, display all legs in sequence
                                    ForEach(0..<selectedFlight.legs.count, id: \.self) { legIndex in
                                        let leg = selectedFlight.legs[legIndex]
                                        
                                        // Display leg header with city codes
                                        HStack {
                                            Text("Flight \(legIndex + 1): \(leg.originCode) → \(leg.destinationCode)")
                                                .font(.headline)
                                                .padding(.bottom, 4)
                                            Spacer()
                                        }
                                        .padding(.horizontal)
                                        .padding(.top, legIndex > 0 ? 16 : 0)
                                        
                                        // Display the leg details
                                        if leg.stopCount == 0 && !leg.segments.isEmpty {
                                            // Direct flight
                                            let segment = leg.segments.first!
                                            displayDirectFlight(leg: leg, segment: segment)
                                        } else if leg.stopCount > 0 && leg.segments.count > 1 {
                                            // Connecting flight
                                            displayConnectingFlight(leg: leg)
                                        }
                                        
                                        // Add a divider between legs (except after the last one)
                                        if legIndex < selectedFlight.legs.count - 1 {
                                            Divider()
                                                .padding(.horizontal)
                                                .padding(.vertical, 8)
                                        }
                                    }
                                } else {
                                    // For regular flights (one-way/roundtrip), use existing logic
                                    if let outboundLeg = selectedFlight.legs.first {
                                        // Outbound leg
                                        if outboundLeg.stopCount == 0 && !outboundLeg.segments.isEmpty {
                                            let segment = outboundLeg.segments.first!
                                            displayDirectFlight(leg: outboundLeg, segment: segment)
                                        } else if outboundLeg.stopCount > 0 && outboundLeg.segments.count > 1 {
                                            displayConnectingFlight(leg: outboundLeg)
                                        }
                                        
                                        // Only display return leg if it's different from outbound
                                        if selectedFlight.legs.count > 1,
                                           let returnLeg = selectedFlight.legs.last,
                                           returnLeg.origin != outboundLeg.origin || returnLeg.destination != outboundLeg.destination {
                                            
                                            if returnLeg.stopCount == 0 && !returnLeg.segments.isEmpty {
                                                let segment = returnLeg.segments.first!
                                                displayDirectFlight(leg: returnLeg, segment: segment)
                                            } else if returnLeg.stopCount > 0 && returnLeg.segments.count > 1 {
                                                displayConnectingFlight(leg: returnLeg)
                                            }
                                        }
                                    }
                                }
                                
                                // Price section
                                PriceSection(price: "₹\(Int(selectedFlight.minPrice))", passengers: "2")
                                    .padding()
                            }
                        }
                    }
                    // Otherwise show the list of flights
                    else {
                        ScrollView {
                            VStack(spacing: 16) {
                                ForEach(filteredResults, id: \.id) { result in
                                    // Use a custom wrapper for multi-city or the existing one for regular flights
                                    if isMultiCity {
                                        MultiCityFlightCardWrapper(
                                            result: result,
                                            viewModel: viewModel,
                                            onTap: {
                                                selectedFlightId = result.id
                                            }
                                        )
                                        .padding(.horizontal)
                                    } else {
                                        DetailedFlightCardWrapper(
                                            result: result,
                                            viewModel: viewModel,
                                            onTap: {
                                                selectedFlightId = result.id
                                            }
                                        )
                                        .padding(.horizontal)
                                    }
                                }
                            }
                            .padding(.vertical)
                        }
                        // Show loading indicator at the bottom if still loading more
                        if viewModel.isLoadingDetailedFlights {
                            HStack {
                                Spacer()
                                ProgressView()
                                Text("Loading more flights...")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                    .padding(.leading, 8)
                                Spacer()
                            }
                            .padding()
                            .background(Color(.systemBackground))
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $showingFilterSheet) {
                    Text("Filter Sheet")
                }
        .onAppear {
                    // Initialize dates array from the API date strings
                    viewModel.initializeDatesFromStrings()
                    
                    // Apply initial filters
                    applyFilters()
         
                }
        .onReceive(viewModel.$detailedFlightResults.map { $0.count }) { count in
                    // Only reapply filters if the count has changed
                    if count != resultCount {
                        resultCount = count
                        applyFilters()
                    }
                }
        .background(Color(.systemBackground))
    }
    
    private func applyFilters() {
            switch selectedFilter {
            case .all:
                filteredResults = viewModel.detailedFlightResults
                
                
            case .best:
                filteredResults = viewModel.detailedFlightResults.filter { $0.isBest }
                // If no best flights, fallback to all
                if filteredResults.isEmpty {
                    filteredResults = viewModel.detailedFlightResults
                }
                
            case .cheapest:
                filteredResults = viewModel.detailedFlightResults.filter { $0.isCheapest }
                // If no cheapest flights specifically marked, sort by price
                if filteredResults.isEmpty {
                    filteredResults = viewModel.detailedFlightResults.sorted { $0.minPrice < $1.minPrice }
                }
                
            case .fastest:
                filteredResults = viewModel.detailedFlightResults.filter { $0.isFastest }
                // If no fastest flights specifically marked, sort by duration
                if filteredResults.isEmpty {
                    filteredResults = viewModel.detailedFlightResults.sorted { $0.totalDuration < $1.totalDuration }
                }
                
            case .direct:
                // Filter to only include flights where all legs are direct
                filteredResults = viewModel.detailedFlightResults.filter { flight in
                    flight.legs.allSatisfy { $0.stopCount == 0 }
                }
                // If no direct flights, show empty state with message
                if filteredResults.isEmpty && selectedFilter == .direct {
                    // Add an empty state message
                    // For now, just use all flights
                    filteredResults = []
                }
            }
        }
    
    @ViewBuilder
    private func displayDirectFlight(leg: FlightLegDetail, segment: FlightSegment) -> some View {
        FlightDetailCard(
            destination: leg.destination,
            isDirectFlight: true,
            flightDuration: formatDuration(minutes: leg.duration),
            flightClass: segment.cabinClass ?? "Economy",
            departureDate: formatDate(from: segment.departureTimeAirport),
            departureTime: formatTime(from: segment.departureTimeAirport),
            departureAirportCode: segment.originCode,
            departureAirportName: segment.origin,
            departureTerminal: "1", // Using a default value
            airline: segment.airlineName,
            flightNumber: segment.flightNumber,
            arrivalDate: formatDate(from: segment.arriveTimeAirport),
            arrivalTime: formatTime(from: segment.arriveTimeAirport),
            arrivalAirportCode: segment.destinationCode,
            arrivalAirportName: segment.destination,
            arrivalTerminal: "2", // Using a default value
            arrivalNextDay: segment.arrivalDayDifference > 0
        )
        .padding(.horizontal)
        .padding(.bottom, 16)
    }
    
    @ViewBuilder
    private func displayConnectingFlight(leg: FlightLegDetail) -> some View {
        // Create segments for connecting flight
        let connectionSegments = createConnectionSegments(from: leg)
        
        FlightDetailCard(
            destination: leg.destination,
            flightDuration: formatDuration(minutes: leg.duration),
            flightClass: leg.segments.first?.cabinClass ?? "Economy",
            connectionSegments: connectionSegments
        )
        .padding(.horizontal)
        .padding(.bottom, 16)
    }
    
    private func createConnectionSegments(from leg: FlightLegDetail) -> [ConnectionSegment] {
        var segments: [ConnectionSegment] = []
        
        // Process each segment
        for (index, segment) in leg.segments.enumerated() {
            // Calculate connection duration if this isn't the last segment
            var connectionDuration: String? = nil
            if index < leg.segments.count - 1 {
                let nextSegment = leg.segments[index + 1]
                let connectionMinutes = (nextSegment.departureTimeAirport - segment.arriveTimeAirport) / 60
                let hours = connectionMinutes / 60
                let mins = connectionMinutes % 60
                connectionDuration = "\(hours)h \(mins)m connection Airport"
            }
            
            segments.append(
                ConnectionSegment(
                    departureDate: formatDate(from: segment.departureTimeAirport),
                    departureTime: formatTime(from: segment.departureTimeAirport),
                    departureAirportCode: segment.originCode,
                    departureAirportName: segment.origin,
                    departureTerminal: "1", // Default
                    arrivalDate: formatDate(from: segment.arriveTimeAirport),
                    arrivalTime: formatTime(from: segment.arriveTimeAirport),
                    arrivalAirportCode: segment.destinationCode,
                    arrivalAirportName: segment.destination,
                    arrivalTerminal: "2", // Default
                    arrivalNextDay: segment.arrivalDayDifference > 0,
                    airline: segment.airlineName,
                    flightNumber: segment.flightNumber,
                    connectionDuration: connectionDuration
                )
            )
        }
        
        return segments
    }
    
    // Helper functions for formatting
    private func formatDate(from timestamp: Int) -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(timestamp))
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE, d MMM"
        return formatter.string(from: date)
    }
    
    private func formatTime(from timestamp: Int) -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(timestamp))
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
    
    private func formatDuration(minutes: Int) -> String {
        let hours = minutes / 60
        let mins = minutes % 60
        return "\(hours)h \(mins)m"
    }
}

struct MultiCityFlightCardWrapper: View {
    let result: FlightDetailResult
    @ObservedObject var viewModel: ExploreViewModel
    var onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack {
                // Flight tags at the top
                HStack(spacing: 4) {
                    if result.isBest {
                        FlightTagView(tag: FlightTag.best)
                    }
                    if result.isCheapest {
                        FlightTagView(tag: FlightTag.cheapest)
                    }
                    if result.isFastest {
                        FlightTagView(tag: FlightTag.fastest)
                    }
                    Spacer()
                }
                .padding(.bottom, 4)
                
                // Multi-city flight card
                VStack(spacing: 0) {
                    // Display each leg
                    ForEach(0..<result.legs.count, id: \.self) { index in
                        let leg = result.legs[index]
                        
                        if index > 0 {
                            Divider()
                                .padding(.horizontal, 16)
                        }
                        
                        // Flight leg
                        if let segment = leg.segments.first {
                            MultiCityLegView(
                                legIndex: index + 1,
                                departureTime: formatTime(from: segment.departureTimeAirport),
                                departureCode: segment.originCode,
                                departureDate: formatDate(from: segment.departureTimeAirport),
                                arrivalTime: formatTime(from: segment.arriveTimeAirport),
                                arrivalCode: segment.destinationCode,
                                arrivalDate: formatDate(from: segment.arriveTimeAirport),
                                duration: formatDuration(minutes: leg.duration),
                                isDirectFlight: leg.stopCount == 0,
                                stopCount: leg.stopCount,
                                airlineName: segment.airlineName
                            )
                            .padding(.vertical, 12)
                        }
                    }
                    
                    Divider()
                        .padding(.horizontal, 16)
                    
                    // Price and total duration
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Total Duration: \(formatDuration(minutes: result.totalDuration))")
                                .font(.system(size: 14))
                                .foregroundColor(.gray)
                            
                            Text("₹\(Int(result.minPrice))")
                                .font(.system(size: 20, weight: .bold))
                            
                            Text("per person")
                                .font(.system(size: 12))
                                .foregroundColor(.gray)
                        }
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .foregroundColor(.gray)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                }
                .background(Color.white)
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // Helper view for a single leg in the multi-city journey
    struct MultiCityLegView: View {
        let legIndex: Int
        let departureTime: String
        let departureCode: String
        let departureDate: String
        let arrivalTime: String
        let arrivalCode: String
        let arrivalDate: String
        let duration: String
        let isDirectFlight: Bool
        let stopCount: Int
        let airlineName: String
        
        var body: some View {
            VStack(spacing: 8) {
                // Leg number
                HStack {
                    Text("Flight \(legIndex)")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.blue)
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 4)
                
                // Flight details
                HStack(alignment: .top, spacing: 0) {
                    // Departure
                    VStack(alignment: .leading, spacing: 2) {
                        Text(departureTime)
                            .font(.system(size: 18, weight: .bold))
                        Text(departureCode)
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                        Text(departureDate)
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                    }
                    .frame(width: 70, alignment: .leading)
                    
                    // Flight path
                    VStack(spacing: 2) {
                        HStack(spacing: 4) {
                            Circle()
                                .frame(width: 8, height: 8)
                                .foregroundColor(.gray)
                            
                            Rectangle()
                                .frame(height: 1)
                                .foregroundColor(.gray)
                            
                            Circle()
                                .frame(width: 8, height: 8)
                                .foregroundColor(.gray)
                        }
                        
                        Text(duration)
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                        
                        if isDirectFlight {
                            Text("Direct")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.green)
                        } else {
                            Text("\(stopCount) \(stopCount == 1 ? "Stop" : "Stops")")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.primary)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    
                    // Arrival
                    VStack(alignment: .trailing, spacing: 2) {
                        Text(arrivalTime)
                            .font(.system(size: 18, weight: .bold))
                        Text(arrivalCode)
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                        Text(arrivalDate)
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                    }
                    .frame(width: 70, alignment: .trailing)
                }
                .padding(.horizontal, 16)
                
                // Airline info
                HStack {
                    Text(airlineName)
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.top, 4)
            }
        }
    }
    
    // Helper functions for formatting
    private func formatTime(from timestamp: Int) -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(timestamp))
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
    
    private func formatDate(from timestamp: Int) -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(timestamp))
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE, d MMM"
        return formatter.string(from: date)
    }
    
    private func formatDuration(minutes: Int) -> String {
        let hours = minutes / 60
        let mins = minutes % 60
        return "\(hours)h \(mins)m"
    }
}

struct FlightTagView: View {
    let tag: FlightTag
    
    var body: some View {
        Text(tag.title)
            .font(.system(size: 12, weight: .medium))
            .foregroundColor(.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(tag.color)
            .cornerRadius(4)
          
    }
}

struct PriceSection: View {
    let price: String
    let passengers: String
    
    var body: some View {
        VStack(spacing: 16) {
            Divider()
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Total Price")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    Text(price)
                        .font(.title2)
                        .fontWeight(.bold)
                    Text("\(passengers) passengers")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                Button(action: {
                    // Book flight action
                }) {
                    Text("Book Flight")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.vertical, 12)
                        .padding(.horizontal, 24)
                        .background(Color.blue)
                        .cornerRadius(8)
                }
            }
        }
    }
}


struct DetailedFlightCardSkeleton: View {
    @State private var isAnimating = false
    
    var body: some View {
        HStack {
            // Flight tags shimmer
//            VStack(spacing: 4) {
//                Rectangle()
//                    .fill(Color(UIColor.systemGray5))
//                    .frame(width: 60, height: 24)
//                    .cornerRadius(4)
//                
//                Rectangle()
//                    .fill(Color(UIColor.systemGray5))
//                    .frame(width: 60, height: 24)
//                    .cornerRadius(4)
//            }
//            .frame(width: 80, alignment: .leading)
//            .padding(.trailing, -40)
//            .zIndex(1)
//            
            // Flight card shimmer
            VStack(spacing: 0) {
                // Outbound flight
                HStack(alignment: .top, spacing: 0) {
                    // Departure
                    VStack(alignment: .leading, spacing: 2) {
                        Rectangle()
                            .fill(Color(UIColor.systemGray5))
                            .frame(height: 18)
                            .frame(width: 50)
                            .cornerRadius(4)
                        
                        Rectangle()
                            .fill(Color(UIColor.systemGray5))
                            .frame(height: 14)
                            .frame(width: 30)
                            .cornerRadius(4)
                        
                        Rectangle()
                            .fill(Color(UIColor.systemGray5))
                            .frame(height: 14)
                            .frame(width: 60)
                            .cornerRadius(4)
                    }
                    .frame(width: 70, alignment: .leading)
                    
                    // Flight path
                    VStack(spacing: 2) {
                        HStack(spacing: 4) {
                            Circle()
                                .fill(Color(UIColor.systemGray5))
                                .frame(width: 8, height: 8)
                            
                            Rectangle()
                                .fill(Color(UIColor.systemGray5))
                                .frame(height: 1)
                            
                            Circle()
                                .fill(Color(UIColor.systemGray5))
                                .frame(width: 8, height: 8)
                        }
                        
                        Rectangle()
                            .fill(Color(UIColor.systemGray5))
                            .frame(height: 12)
                            .frame(width: 50)
                            .cornerRadius(4)
                        
                        Rectangle()
                            .fill(Color(UIColor.systemGray5))
                            .frame(height: 12)
                            .frame(width: 40)
                            .cornerRadius(4)
                    }
                    .frame(maxWidth: .infinity)
                    
                    // Arrival
                    VStack(alignment: .trailing, spacing: 2) {
                        Rectangle()
                            .fill(Color(UIColor.systemGray5))
                            .frame(height: 18)
                            .frame(width: 50)
                            .cornerRadius(4)
                        
                        Rectangle()
                            .fill(Color(UIColor.systemGray5))
                            .frame(height: 14)
                            .frame(width: 30)
                            .cornerRadius(4)
                        
                        Rectangle()
                            .fill(Color(UIColor.systemGray5))
                            .frame(height: 14)
                            .frame(width: 60)
                            .cornerRadius(4)
                    }
                    .frame(width: 70, alignment: .trailing)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                
                Divider()
                    .padding(.horizontal, 16)
                
                // Return flight
                HStack(alignment: .top, spacing: 0) {
                    // Departure
                    VStack(alignment: .leading, spacing: 2) {
                        Rectangle()
                            .fill(Color(UIColor.systemGray5))
                            .frame(height: 18)
                            .frame(width: 50)
                            .cornerRadius(4)
                        
                        Rectangle()
                            .fill(Color(UIColor.systemGray5))
                            .frame(height: 14)
                            .frame(width: 30)
                            .cornerRadius(4)
                        
                        Rectangle()
                            .fill(Color(UIColor.systemGray5))
                            .frame(height: 14)
                            .frame(width: 60)
                            .cornerRadius(4)
                    }
                    .frame(width: 70, alignment: .leading)
                    
                    // Flight path
                    VStack(spacing: 2) {
                        HStack(spacing: 4) {
                            Circle()
                                .fill(Color(UIColor.systemGray5))
                                .frame(width: 8, height: 8)
                            
                            Rectangle()
                                .fill(Color(UIColor.systemGray5))
                                .frame(height: 1)
                            
                            Circle()
                                .fill(Color(UIColor.systemGray5))
                                .frame(width: 8, height: 8)
                        }
                        
                        Rectangle()
                            .fill(Color(UIColor.systemGray5))
                            .frame(height: 12)
                            .frame(width: 50)
                            .cornerRadius(4)
                        
                        Rectangle()
                            .fill(Color(UIColor.systemGray5))
                            .frame(height: 12)
                            .frame(width: 40)
                            .cornerRadius(4)
                    }
                    .frame(maxWidth: .infinity)
                    
                    // Arrival
                    VStack(alignment: .trailing, spacing: 2) {
                        Rectangle()
                            .fill(Color(UIColor.systemGray5))
                            .frame(height: 18)
                            .frame(width: 50)
                            .cornerRadius(4)
                        
                        Rectangle()
                            .fill(Color(UIColor.systemGray5))
                            .frame(height: 14)
                            .frame(width: 30)
                            .cornerRadius(4)
                        
                        Rectangle()
                            .fill(Color(UIColor.systemGray5))
                            .frame(height: 14)
                            .frame(width: 60)
                            .cornerRadius(4)
                    }
                    .frame(width: 70, alignment: .trailing)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                
                Divider()
                    .padding(.horizontal, 16)
                
                // Airline and price
                HStack {
                    Rectangle()
                        .fill(Color(UIColor.systemGray5))
                        .frame(height: 14)
                        .frame(width: 100)
                        .cornerRadius(4)
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 2) {
                        Rectangle()
                            .fill(Color(UIColor.systemGray5))
                            .frame(height: 20)
                            .frame(width: 80)
                            .cornerRadius(4)
                        
                        Rectangle()
                            .fill(Color(UIColor.systemGray5))
                            .frame(height: 12)
                            .frame(width: 60)
                            .cornerRadius(4)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        }
        .opacity(isAnimating ? 0.7 : 1.0)
        .onAppear {
            withAnimation(Animation.easeInOut(duration: 1.0).repeatForever()) {
                isAnimating.toggle()
            }
        }
    }
}
