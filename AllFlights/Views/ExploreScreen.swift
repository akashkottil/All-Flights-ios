import SwiftUI
import Alamofire
import Combine
import SafariServices


// MARK: - Updated Models for the new API Response Structure
struct ExploreApiResponse: Codable {
    let origin: String
    let currency: CurrencyDetail
    let data: [ExploreDestinationData]
}

struct CurrencyDetail: Codable {
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

struct ExploreDestinationData: Codable {
    let price: Int
    let location: ExploreLocationData
    let is_direct: Bool
}

struct ExploreLocationData: Codable {
    let entityId: String
    let name: String
    let iata: String
}

// Filter request model that matches the API requirements
struct FlightFilterRequest: Codable {
    var durationMax: Int?
    var stopCountMax: Int?
    var arrivalDepartureRanges: [ArrivalDepartureRange]?
    var iataCodesExclude: [String]?
    var iataCodesInclude: [String]?
    var sortBy: String?
    var sortOrder: String?
    var agencyExclude: [String]?
    var agencyInclude: [String]?
    var priceMin: Int?
    var priceMax: Int?
    
    enum CodingKeys: String, CodingKey {
        case durationMax = "duration_max"
        case stopCountMax = "stop_count_max"
        case arrivalDepartureRanges = "arrival_departure_ranges"
        case iataCodesExclude = "iata_codes_exclude"
        case iataCodesInclude = "iata_codes_include"
        case sortBy = "sort_by"
        case sortOrder = "sort_order"
        case agencyExclude = "agency_exclude"
        case agencyInclude = "agency_include"
        case priceMin = "price_min"
        case priceMax = "price_max"
    }
}

struct ArrivalDepartureRange: Codable {
    var arrival: TimeRange?
    var departure: TimeRange?
}

struct TimeRange: Codable {
    var min: Int?
    var max: Int?
}

struct MultiCityTrip: Identifiable, Codable {
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
    
    var compactDisplayDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "E,d MMM" // Produces "Sat,7 Jun" format
        return formatter.string(from: date)
    }
    
    // Optional: Custom initializer to maintain existing functionality
    init(fromLocation: String = "", fromIataCode: String = "",
         toLocation: String = "", toIataCode: String = "", date: Date = Date()) {
        self.id = UUID()
        self.fromLocation = fromLocation
        self.fromIataCode = fromIataCode
        self.toLocation = toLocation
        self.toIataCode = toIataCode
        self.date = date
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
    
    private(set) var lastFetchedCurrencyInfo: CurrencyDetail?
    
    // At the top of ExploreAPIService
    weak var viewModelReference: ExploreViewModel?
    
    let currency:String = "INR"
    let country:String = "IN"
    
    private let baseURL = "https://staging.plane.lascade.com/api/explore/"
    private let flightsURL = "https://staging.plane.lascade.com/api/explore/?currency=INR&country=IN"
    private var currentFlightSearchRequest: DataRequest?
    private let session = Session()
    
    func pollFlightResultsPaginated(searchId: String, page: Int = 1, limit: Int = 20, filterRequest: FlightFilterRequest? = nil) -> AnyPublisher<FlightPollResponse, Error> {
        let baseURL = "https://staging.plane.lascade.com/api/poll/"
        
        // Build query parameters
        var parameters: [String: String] = [
            "search_id": searchId,
            "page": String(page),
            "limit": String(limit)
        ]
        
        var urlComponents = URLComponents(string: baseURL)!
        urlComponents.queryItems = parameters.map { URLQueryItem(name: $0.key, value: $0.value) }
        
        // Create request
        var request = URLRequest(url: urlComponents.url!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("IN", forHTTPHeaderField: "country")
        
        // Build request body from filter request (only include non-null fields)
        var requestDict: [String: Any] = [:]
        if let filterRequest = filterRequest {
            // Your existing filterRequest parsing logic...
        }
        
        // Add body to request
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestDict)
        } catch {
            print("Error encoding pagination request: \(error)")
            return Fail(error: error).eraseToAnyPublisher()
        }
        
        print("Fetching page \(page) with limit \(limit) for search ID: \(searchId)")
        
        // Return a publisher that will emit results
        return Future<FlightPollResponse, Error> { promise in
            AF.request(request)
                .validate()
                .responseData { [weak self] response in
                    switch response.result {
                    case .success(let data):
                        do {
                            let pollResponse = try JSONDecoder().decode(FlightPollResponse.self, from: data)
                            
                            // Store response in viewModel
                            self?.viewModelReference?.lastPollResponse = pollResponse
                            
                            // Update the total count
                            self?.viewModelReference?.totalFlightCount = pollResponse.count
                            
                            // Update cache status
                            self?.viewModelReference?.isDataCached = pollResponse.cache
                            
                            print("Successfully fetched page \(page): \(pollResponse.results.count) results, total: \(pollResponse.count), cached: \(pollResponse.cache)")
                            
                            promise(.success(pollResponse))
                        } catch {
                            print("Pagination decoding error: \(error)")
                            promise(.failure(error))
                        }
                    case .failure(let error):
                        print("Pagination API error: \(error)")
                        promise(.failure(error))
                    }
                }
        }.eraseToAnyPublisher()
    }

// Helper function to check if filter request has any meaningful filters
private func isFilterRequestNonEmpty(_ filterRequest: FlightFilterRequest) -> Bool {
    return (filterRequest.durationMax != nil && filterRequest.durationMax! > 0) ||
           filterRequest.stopCountMax != nil ||
           (filterRequest.arrivalDepartureRanges != nil && !filterRequest.arrivalDepartureRanges!.isEmpty) ||
           (filterRequest.iataCodesExclude != nil && !filterRequest.iataCodesExclude!.isEmpty) ||
           (filterRequest.iataCodesInclude != nil && !filterRequest.iataCodesInclude!.isEmpty) ||
           (filterRequest.sortBy != nil && !filterRequest.sortBy!.isEmpty) ||
           (filterRequest.agencyExclude != nil && !filterRequest.agencyExclude!.isEmpty) ||
           (filterRequest.agencyInclude != nil && !filterRequest.agencyInclude!.isEmpty) ||
           (filterRequest.priceMin != nil && filterRequest.priceMin! > 0) ||
           (filterRequest.priceMax != nil && filterRequest.priceMax! > 0)
}
    
    func pollFlightResultsWithFilters(searchId: String, filterRequest: FlightFilterRequest) -> AnyPublisher<FlightPollResponse, Error> {
        let baseURL = "https://staging.plane.lascade.com/api/poll/"
        
        let parameters: [String: String] = [
            "search_id": searchId
        ]
        
        var urlComponents = URLComponents(string: baseURL)!
        urlComponents.queryItems = parameters.map { URLQueryItem(name: $0.key, value: $0.value) }
        
        // Create a minimal request body that only includes the fields that have values
        var requestDict: [String: Any] = [:]
        
        // Get isRoundTrip value from the viewModel reference
        let isRoundTrip = viewModelReference?.isRoundTrip ?? true
        
        // Only add fields that are actually set and have valid values
        if let durationMax = filterRequest.durationMax, durationMax > 0 {
            requestDict["duration_max"] = durationMax
        }
        
        if let stopCountMax = filterRequest.stopCountMax {
            requestDict["stop_count_max"] = stopCountMax
        }
        
        if let ranges = filterRequest.arrivalDepartureRanges, !ranges.isEmpty {
            var rangesArray: [[String: Any]] = []
            
            // Get the first range to use as a template
            if let firstRange = ranges.first {
                // Add the first range
                var rangeDict: [String: Any] = [:]
                
                if let arrival = firstRange.arrival {
                    var arrivalDict: [String: Any] = [:]
                    if let min = arrival.min {
                        arrivalDict["min"] = min
                    }
                    if let max = arrival.max {
                        arrivalDict["max"] = max
                    }
                    if !arrivalDict.isEmpty {
                        rangeDict["arrival"] = arrivalDict
                    }
                }
                
                if let departure = firstRange.departure {
                    var departureDict: [String: Any] = [:]
                    if let min = departure.min {
                        departureDict["min"] = min
                    }
                    if let max = departure.max {
                        departureDict["max"] = max
                    }
                    if !departureDict.isEmpty {
                        rangeDict["departure"] = departureDict
                    }
                }
                
                // Add the first range
                if !rangeDict.isEmpty {
                    rangesArray.append(rangeDict)
                    
                    // If it's a round trip, add the same range again for the return leg
                    if isRoundTrip {
                        rangesArray.append(rangeDict)
                    }
                }
            }
            
            // Only add arrays if they contain elements
            if !rangesArray.isEmpty {
                requestDict["arrival_departure_ranges"] = rangesArray
            }
        }
        
        // Only add non-empty arrays
        if let exclude = filterRequest.iataCodesExclude, !exclude.isEmpty {
            requestDict["iata_codes_exclude"] = exclude
        }
        
        if let include = filterRequest.iataCodesInclude, !include.isEmpty {
            requestDict["iata_codes_include"] = include
        }
        
        // Only add sorting if it's specified AND it's a valid value
        if let sortBy = filterRequest.sortBy {
            // IMPORTANT: Only use valid sort values - do NOT use "best"
            if sortBy == "price" || sortBy == "duration" {
                requestDict["sort_by"] = sortBy
                
                // Add sort_order if needed
                if let sortOrder = filterRequest.sortOrder {
                    requestDict["sort_order"] = sortOrder
                } else {
                    // Default sort order is ascending
                    requestDict["sort_order"] = "asc"
                }
            }
        }
        
        // Only add non-empty arrays
        if let agencyExclude = filterRequest.agencyExclude, !agencyExclude.isEmpty {
            requestDict["agency_exclude"] = agencyExclude
        }
        
        if let agencyInclude = filterRequest.agencyInclude, !agencyInclude.isEmpty {
            requestDict["agency_include"] = agencyInclude
        }
        
        // Only add price constraints if they're meaningful
        if let priceMin = filterRequest.priceMin, priceMin > 0 {
            requestDict["price_min"] = priceMin
        }
        
        if let priceMax = filterRequest.priceMax, priceMax > 0 {
            requestDict["price_max"] = priceMax
        }
        
        var request = URLRequest(url: urlComponents.url!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("IN", forHTTPHeaderField: "country")  // Add country header
        
        // Debug log the complete request dictionary
        print("Filter request dictionary: \(requestDict)")
        
        do {
            // Convert the dictionary to JSON data
            request.httpBody = try JSONSerialization.data(withJSONObject: requestDict)
            if let requestBody = String(data: request.httpBody ?? Data(), encoding: .utf8) {
                print("Filter request JSON: \(requestBody)")
            }
        } catch {
            print("Error encoding filter request: \(error)")
            // Instead of sending empty JSON, propagate the error
            let progressiveResults = PassthroughSubject<FlightPollResponse, Error>()
            progressiveResults.send(completion: .failure(error))
            return progressiveResults.eraseToAnyPublisher()
        }
        
        print("Starting filtered polling with search ID: \(searchId)")
        
        // Create a subject that will emit values as they come in
        let progressiveResults = PassthroughSubject<FlightPollResponse, Error>()
        
        // Start polling with enhanced logging
        pollProgressivelyWithLogs(request: request, subject: progressiveResults)
        
        // Return the subject as a publisher
        return progressiveResults.eraseToAnyPublisher()
    }

    // Add this helper function to include response logging
    private func pollProgressivelyWithLogs(request: URLRequest, subject: PassthroughSubject<FlightPollResponse, Error>, attempt: Int = 0, seenResultIds: Set<String> = []) {
        AF.request(request)
            .validate()
            .responseData { [weak self] response in
                guard let self = self else { return }
                
                // Log response status and headers
                print("Poll response status: \(response.response?.statusCode ?? 0)")
                if let headers = response.response?.allHeaderFields {
                    print("Poll response headers: \(headers)")
                }
                
                switch response.result {
                case .success(let data):
                    do {
                        // Log a sample of the response data
                        if let responsePreview = String(data: data.prefix(200), encoding: .utf8) {
                            print("Poll response preview: \(responsePreview)")
                        }
                        
                        let pollResponse = try JSONDecoder().decode(FlightPollResponse.self, from: data)
                        
                        // Store the response in the view model
                        self.viewModelReference?.lastPollResponse = pollResponse
                        
                        // Rest of your existing poll handling code...
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
                            if newResultIds.isEmpty {
                                print("All results received, polling complete")
                                subject.send(completion: .finished)
                                return
                            }
                        }
                        
                        // Continue polling for more results
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                            self.pollProgressivelyWithLogs(
                                request: request,
                                subject: subject,
                                attempt: attempt + 1,
                                seenResultIds: currentResultIds
                            )
                        }
                    } catch {
                        print("Poll decoding error: \(error)")
                        // Log the JSON that couldn't be decoded
                        if let responseStr = String(data: data, encoding: .utf8) {
                            print("Failed to decode response: \(responseStr)")
                        }
                        
                        subject.send(completion: .failure(error))
                    }
                case .failure(let error):
                    print("Poll API error: \(error)")
                    // Log the response body if available
                    if let data = response.data, let responseStr = String(data: data, encoding: .utf8) {
                        print("Error response body: \(responseStr)")
                    }
                    
                    subject.send(completion: .failure(error))
                }
            }
    }
    
    
    func searchFlights(origin: String, destination: String, returndate: String, departuredate: String,
                      roundTrip: Bool = true, adults: Int = 1, childrenAges: [Int?] = [], cabinClass: String = "economy") -> AnyPublisher<SearchResponse, Error> {
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
        
        // Filter out nil values from childrenAges and convert to Int array
           let validChildrenAges = childrenAges.compactMap { $0 }
        
        let requestData: [String: Any] = [
            "legs": legs,
            "cabin_class": cabinClass.lowercased(),
            "adults": adults,
            "children_ages": validChildrenAges
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
        
        // Start polling - use a modified version that saves responses
        pollProgressivelyAndSaveLatest(request: request, subject: progressiveResults)
        
        // Return the subject as a publisher
        return progressiveResults.eraseToAnyPublisher()
    }
    
    // Add this new helper method
    private func pollProgressivelyAndSaveLatest(request: URLRequest, subject: PassthroughSubject<FlightPollResponse, Error>, attempt: Int = 0, seenResultIds: Set<String> = []) {
        AF.request(request)
            .validate()
            .responseData { [weak self] response in
                guard let self = self else { return }
                
                switch response.result {
                case .success(let data):
                    do {
                        let pollResponse = try JSONDecoder().decode(FlightPollResponse.self, from: data)
                        
                        // Store the response in the view model
                        self.viewModelReference?.lastPollResponse = pollResponse
                        
                        // Rest of your existing poll handling code...
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
                            self.pollProgressivelyAndSaveLatest(
                                request: request,
                                subject: subject,
                                attempt: attempt + 1,
                                seenResultIds: currentResultIds
                            )
                        }
                    } catch {
                        // Error handling code...
                    }
                case .failure(_): break
                    // Error handling code...
                }
            }
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
                              departure: String = "DEL",
                              language: String = "en-GB",
                              arrivalType: String = "country",
                              arrivalId: String? = nil) -> AnyPublisher<[ExploreDestination], Error> {
            
            // Create URL components for the updated API endpoint
            var urlComponents = URLComponents(string: self.baseURL)!
            
            // Add query parameters
            var queryItems = [
                URLQueryItem(name: "country", value: country),
                URLQueryItem(name: "currency", value: currency),
                URLQueryItem(name: "departure", value: departure),
                URLQueryItem(name: "language", value: language),
                URLQueryItem(name: "arrival_type", value: arrivalType)
            ]
            
            // Add optional arrivalId if provided
            if let arrivalId = arrivalId {
                queryItems.append(URLQueryItem(name: "arrival_id", value: arrivalId))
            }
            
            urlComponents.queryItems = queryItems
            
            // Create the URL request
            let request = URLRequest(url: urlComponents.url!)
            
            return Future<[ExploreDestination], Error> { promise in
                AF.request(request)
                    .validate()
                    .responseDecodable(of: ExploreApiResponse.self) { response in
                        switch response.result {
                        case .success(let apiResponse):
                            // Convert the new API response to the existing ExploreDestination model
                            let destinations = apiResponse.data.map { item -> ExploreDestination in
                                return ExploreDestination(
                                    price: item.price,
                                    location: ExploreLocation(
                                        entityId: item.location.entityId,
                                        name: item.location.name,
                                        iata: item.location.iata
                                    ),
                                    is_direct: item.is_direct
                                )
                            }
                            promise(.success(destinations))
                            
                        case .failure(let error):
                            print("API error: \(error.localizedDescription)")
                            if let data = response.data, let responseString = String(data: data, encoding: .utf8) {
                                print("Response body: \(responseString)")
                            }
                            promise(.failure(error))
                        }
                    }
            }.eraseToAnyPublisher()
        }
    
    // Add a helper method to get the currency symbol from API response
       func getCurrencySymbol(from apiResponse: ExploreApiResponse) -> String {
           return apiResponse.currency.symbol
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
    private static var cachedDestinations: [ExploreDestination]? = nil
    @Published var destinations: [ExploreDestination] = []
    @Published var isLoading = false
    @Published var errorMessage: String? = nil
    @Published var showingCities = false
    @Published var selectedCountryName: String? = nil
    @Published var fromLocation = "Delhi"  // Default to Kochi
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
    
    @Published var fromIataCode: String = "DEL"
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

    
    @Published var adultsCount = 1
    @Published var childrenCount = 0
    @Published var childrenAges: [Int?] = []
    @Published var selectedCabinClass = "Economy"
    @Published var showingPassengersSheet = false
    
    @Published var currencyInfo: CurrencyDetail?
    
    @Published var isAnytimeMode: Bool = false
    
    @Published var selectedFlightId: String? = nil
    
    @Published var directFlightsOnlyFromHome = false
    
    // Pagination properties
    @Published var currentPage = 1
    @Published var totalFlightCount = 0
    @Published var isLoadingMoreFlights = false
    @Published var hasMoreFlights = true
    @Published var currentSearchId: String? = nil
    
    @Published var isFirstLoad: Bool = true
    
    @Published var isDataCached = false
    @Published var actualLoadedCount = 0
    
    
    // Add this method inside the ExploreViewModel class

    func resetToInitialState(preserveCountries: Bool = true) {
        print("🔄 Resetting ExploreViewModel to initial state")
            
            // Reset all search-related states
            isDirectSearch = false
            showingDetailedFlightList = false
            hasSearchedFlights = false
            flightResults = []
            detailedFlightResults = []
            flightSearchResponse = nil
            selectedFlightId = nil
            isAnytimeMode = false
            directFlightsOnlyFromHome = false
            
            // Reset navigation states
            showingCities = false
            selectedCountryName = nil
            selectedCity = nil
            
            // Reset location states to default
            toLocation = "Anywhere"
            toIataCode = ""
            fromLocation = "Mumbai"
            fromIataCode = "DEL"
            
            // Clear search context
            selectedOriginCode = ""
            selectedDestinationCode = ""
            selectedDepartureDatee = ""
            selectedReturnDatee = ""
            dates = []
            
            // Reset error states
            errorMessage = nil
            detailedFlightError = nil
            isLoadingDetailedFlights = false
            isLoadingFlights = false
            
            // Reset pagination
            currentPage = 1
            totalFlightCount = 0
            actualLoadedCount = 0
            hasMoreFlights = true
            isLoadingMoreFlights = false
            isFirstLoad = true
            isDataCached = false
            
            // Clear multi-city data
            multiCityTrips = []
            
            // FIXED: Set loading state to true if destinations will be cleared
            // This ensures skeleton shows during the reset-to-fetch process
        if !preserveCountries {
                    destinations = []
                }
            if destinations.isEmpty {
                isLoading = true
                print("🔄 Setting loading state during reset (destinations empty)")
            }
            
            print("✅ ExploreViewModel reset completed")
    }
    
    func debugDuplicateFlightIDs() {
            let allIds = detailedFlightResults.map { $0.id }
            let uniqueIds = Set(allIds)
            
            if allIds.count != uniqueIds.count {
                print("🚨 DUPLICATE IDs DETECTED!")
                print("Total flights: \(allIds.count)")
                print("Unique IDs: \(uniqueIds.count)")
                
                // Find and print duplicates
                var idCounts: [String: Int] = [:]
                for id in allIds {
                    idCounts[id, default: 0] += 1
                }
                
                let duplicates = idCounts.filter { $0.value > 1 }
                print("Duplicate IDs: \(duplicates)")
            } else {
                print("✅ No duplicate IDs found. Total unique flights: \(uniqueIds.count)")
            }
        }
    
    func searchMultiCityFlightsWithPagination() {
    isLoadingDetailedFlights = true
    detailedFlightError = nil
    detailedFlightResults = []
    showingDetailedFlightList = true
        // Reset pagination
        currentPage = 1
        totalFlightCount = 0
        hasMoreFlights = true
        isLoadingMoreFlights = false
        
        // Store the first and last cities for display
        selectedOriginCode = multiCityTrips.first?.fromIataCode ?? ""
        selectedDestinationCode = multiCityTrips.last?.toIataCode ?? ""
        
        // Create request payload using the existing searchFlights method
        var legs: [[String: String]] = []
        
        for trip in multiCityTrips {
            legs.append([
                "origin": trip.fromIataCode,
                "destination": trip.toIataCode,
                "date": trip.formattedDate
            ])
        }
        
        print("Searching multi-city with pagination: \(legs.count) legs")
        
        let validChildrenAges = childrenAges.compactMap { $0 }
        
        let baseURL = "https://staging.plane.lascade.com/api/search/"
        
        let parameters: [String: String] = [
            "user_id": "-0",
            "currency": service.currency,
            "language": "en-GB",
            "app_code": "D1WF"
        ]
        
        let requestData: [String: Any] = [
            "legs": legs,
            "cabin_class": selectedCabinClass.lowercased(),
            "adults": adultsCount,
            "children_ages": validChildrenAges
        ]
        
        var urlComponents = URLComponents(string: baseURL)!
        urlComponents.queryItems = parameters.map { URLQueryItem(name: $0.key, value: $0.value) }
        
        var request = URLRequest(url: urlComponents.url!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("IN", forHTTPHeaderField: "country")
        request.httpBody = try? JSONSerialization.data(withJSONObject: requestData)
        
        AF.request(request)
            .validate()
            .responseDecodable(of: SearchResponse.self) { [weak self] response in
                guard let self = self else { return }
                
                switch response.result {
                case .success(let searchResponse):
                    print("Multi-city search successful, got searchId: \(searchResponse.searchId)")
                    self.currentSearchId = searchResponse.searchId
                    
                    self.service.pollFlightResultsPaginated(
                        searchId: searchResponse.searchId,
                        page: 1,
                        limit: 20
                    )
                    .receive(on: DispatchQueue.main)
                    .sink(
                        receiveCompletion: { completion in
                            self.isLoadingDetailedFlights = false
                            if case .failure(let error) = completion {
                                print("Multi-city flight search failed: \(error.localizedDescription)")
                                self.detailedFlightError = error.localizedDescription
                            }
                        },
                        receiveValue: { pollResponse in
                            self.totalFlightCount = pollResponse.count
                            self.detailedFlightResults = pollResponse.results
                            self.hasMoreFlights = pollResponse.next != nil
                            self.isLoadingDetailedFlights = false
                            
                            print("Multi-city first page loaded: \(pollResponse.results.count) flights, total: \(pollResponse.count)")
                        }
                    )
                    .store(in: &self.cancellables)
                    
                case .failure(let error):
                    print("Multi-city search API error: \(error.localizedDescription)")
                    self.isLoadingDetailedFlights = false
                    self.detailedFlightError = error.localizedDescription
                }
            }
    }

    func searchFlightsForDatesWithPagination(origin: String, destination: String, returnDate: String, departureDate: String, isDirectSearch: Bool = false) {
        print("🔍 Starting search: \(origin) -> \(destination)")
        
        // Immediately set loading state
        self.isDirectSearch = isDirectSearch
        isLoadingDetailedFlights = true
        detailedFlightError = nil
        detailedFlightResults = []
        showingDetailedFlightList = true
        
        // Reset pagination and cache tracking
        currentPage = 1
        totalFlightCount = 0
        actualLoadedCount = 0
        isDataCached = false
        hasMoreFlights = true
        isLoadingMoreFlights = false
        isFirstLoad = true
        
        // Store search parameters
        selectedOriginCode = origin
        selectedDestinationCode = destination
        selectedDepartureDatee = departureDate
        selectedReturnDatee = returnDate
        
        // Start the search process
        service.searchFlights(
            origin: origin,
            destination: destination,
            returndate: isRoundTrip ? selectedReturnDatee : "",
            departuredate: selectedDepartureDatee,
            roundTrip: isRoundTrip,
            adults: adultsCount,
            childrenAges: childrenAges,
            cabinClass: selectedCabinClass
        )
        .receive(on: DispatchQueue.main)
        .flatMap { [weak self] searchResponse -> AnyPublisher<FlightPollResponse, Error> in
            guard let self = self else {
                return Fail(error: NSError(domain: "ViewModelError", code: 0, userInfo: [NSLocalizedDescriptionKey: "View model deallocated"]))
                    .eraseToAnyPublisher()
            }
            
            print("🔍 Search successful, got searchId: \(searchResponse.searchId)")
            self.currentSearchId = searchResponse.searchId
            
            // First poll with smaller limit (8) for faster initial display
            return self.service.pollFlightResultsPaginated(
                searchId: searchResponse.searchId,
                page: 1,
                limit: 8,
                filterRequest: self._currentFilterRequest
            )
        }
        .receive(on: DispatchQueue.main)
        .sink(
            receiveCompletion: { [weak self] completion in
                guard let self = self else { return }
                
                if case .failure(let error) = completion {
                    print("❌ Flight search failed: \(error.localizedDescription)")
                    self.detailedFlightError = error.localizedDescription
                }
                
                // Turn off loading state when done
                self.isLoadingDetailedFlights = false
            },
            receiveValue: { [weak self] pollResponse in
                guard let self = self else { return }
                
                // Update state with response data
                self.totalFlightCount = pollResponse.count
                self.isDataCached = pollResponse.cache
                self.actualLoadedCount = pollResponse.results.count
                self.hasMoreFlights = self.shouldContinueLoadingMore()
                self.detailedFlightResults = pollResponse.results
                self.detailedFlightError = nil
                
                print("✅ Initial search completed: \(pollResponse.results.count) flights, total: \(pollResponse.count), cached: \(pollResponse.cache)")
                
                // If not cached (still being processed on backend), try fetching more data after a delay
                if !pollResponse.cache {
                    self.scheduleRetryAfterDelay()
                }
            }
        )
        .store(in: &cancellables)
    }
    
    private func scheduleRetryAfterDelay() {
        // Similar to Flutter's retry logic, schedule a delayed retry if not cached
        print("🔄 Backend still processing data, scheduling retry...")
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
            guard let self = self, let searchId = self.currentSearchId, !self.isDataCached else {
                return
            }
            
            print("🔄 Executing retry poll for more results")
            self.service.pollFlightResultsPaginated(
                searchId: searchId,
                page: self.currentPage,
                limit: 20,
                filterRequest: self._currentFilterRequest
            )
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { [weak self] pollResponse in
                    guard let self = self else { return }
                    
                    // Update cache status and results
                    self.isDataCached = pollResponse.cache
                    self.totalFlightCount = pollResponse.count
                    
                    // Add new results, avoiding duplicates
                    let existingIds = Set(self.detailedFlightResults.map { $0.id })
                    let newResults = pollResponse.results.filter { !existingIds.contains($0.id) }
                    if !newResults.isEmpty {
                        self.detailedFlightResults.append(contentsOf: newResults)
                        self.actualLoadedCount = self.detailedFlightResults.count
                    }
                    
                    print("✅ Retry fetched \(newResults.count) new results, total now: \(self.detailedFlightResults.count)")
                    
                    // If still not cached, schedule another retry
                    if !pollResponse.cache {
                        self.scheduleRetryAfterDelay()
                    }
                }
            )
            .store(in: &self.cancellables)
        }
    }

    // 2. Also update the applyFiltersWithPagination method in ExploreViewModel
    func applyFiltersWithPagination(filterRequest: FlightFilterRequest) {
        // Store the filter request
        self._currentFilterRequest = filterRequest
        
        // Reset pagination and reload from first page
        guard let searchId = currentSearchId else { return }
        
        isLoadingDetailedFlights = true
        detailedFlightResults = []
        currentPage = 1
        hasMoreFlights = true
        isLoadingMoreFlights = false
        isFirstLoad = true // Reset first load flag for filters too
        
        service.pollFlightResultsPaginated(
            searchId: searchId,
            page: 1,
            limit: 8, // Use 8 results for initial load after filtering
            filterRequest: filterRequest
        )
        .receive(on: DispatchQueue.main)
        .sink(
            receiveCompletion: { [weak self] completion in
                self?.isLoadingDetailedFlights = false
                if case .failure(let error) = completion {
                    print("Filter application failed: \(error.localizedDescription)")
                    self?.detailedFlightError = error.localizedDescription
                }
            },
            receiveValue: { [weak self] pollResponse in
                guard let self = self else { return }
                
                // IMPORTANT: Set total count from the API response immediately
                self.totalFlightCount = pollResponse.count
                
                self.detailedFlightResults = pollResponse.results
                self.hasMoreFlights = pollResponse.next != nil
                self.isLoadingDetailedFlights = false
                
                print("Filters applied: \(pollResponse.results.count) flights loaded, total available: \(pollResponse.count)")
            }
        )
        .store(in: &cancellables)
    }


    // Add this to ExploreViewModel
    func loadMoreFlights() {
        guard let searchId = currentSearchId,
              !isLoadingMoreFlights,
              !isLoadingDetailedFlights,
              hasMoreFlights else {
            print("🚫 Cannot load more flights")
            return
        }
        
        // Check if we should continue loading
        if !shouldContinueLoadingMore() {
            print("🛑 All available flights loaded: \(actualLoadedCount)/\(totalFlightCount)")
            hasMoreFlights = false
            return
        }
        
        print("📥 Loading more flights: page \(currentPage + 1)")
        isLoadingMoreFlights = true
        let nextPage = currentPage + 1
        
        service.pollFlightResultsPaginated(
            searchId: searchId,
            page: nextPage,
            limit: 20,
            filterRequest: _currentFilterRequest
        )
        .receive(on: DispatchQueue.main)
        .sink(
            receiveCompletion: { [weak self] completion in
                guard let self = self else { return }
                self.isLoadingMoreFlights = false
                
                if case .failure(let error) = completion {
                    print("❌ Load more flights failed: \(error.localizedDescription)")
                }
            },
            receiveValue: { [weak self] pollResponse in
                guard let self = self else { return }
                
                // Update cache status from response
                self.isDataCached = pollResponse.cache
                self.totalFlightCount = pollResponse.count
                self.currentPage = nextPage
                
                // Filter out duplicates before appending
                let existingIds = Set(self.detailedFlightResults.map { $0.id })
                let newResults = pollResponse.results.filter { !existingIds.contains($0.id) }
                
                print("📥 Received \(pollResponse.results.count) flights, \(newResults.count) are unique")
                
                // Append only unique results
                self.detailedFlightResults.append(contentsOf: newResults)
                self.actualLoadedCount = self.detailedFlightResults.count
                
                // Determine if we should continue loading more
                self.hasMoreFlights = self.shouldContinueLoadingMore()
                self.isLoadingMoreFlights = false
                
                // If not cached and there are potentially more results, try again after delay
                if !pollResponse.cache && pollResponse.count > self.actualLoadedCount {
                    self.scheduleRetryAfterDelay()
                }
            }
        )
        .store(in: &cancellables)
    }
    
    private func shouldContinueLoadingMore() -> Bool {
        // If data is not cached (still loading in backend), we should keep trying
        if !isDataCached {
            print("🔄 Backend still loading data (cache: false)")
            return true
        }
        
        // If data is cached, check if we have all available flights
        if actualLoadedCount < totalFlightCount {
            print("📊 Need more flights: \(actualLoadedCount)/\(totalFlightCount)")
            return true
        }
        
        // We have all available flights
        print("✅ All flights loaded: \(actualLoadedCount)/\(totalFlightCount)")
        return false
    }
        

    // Modified method with special page 2 handling
    private func fetchPageWithRetry(searchId: String, page: Int, limit: Int, retryCount: Int, isPage2: Bool = false) {
        print("Fetching page \(page) (attempt \(retryCount + 1))")
        
        // Set a safety timeout to reset loading state if the request takes too long
        let safetyTimer = Timer.scheduledTimer(withTimeInterval: 15.0, repeats: false) { [weak self] _ in
            guard let self = self, self.isLoadingMoreFlights else { return }
            print("⚠️ Safety timeout triggered for page \(page) - resetting loading state")
            self.isLoadingMoreFlights = false
        }
        
        service.pollFlightResultsPaginated(
            searchId: searchId,
            page: page,
            limit: limit,
            filterRequest: _currentFilterRequest
        )
        .receive(on: DispatchQueue.main)
        .sink(
            receiveCompletion: { [weak self] completion in
                guard let self = self else { return }
                
                // Cancel the safety timer since we got a response
                safetyTimer.invalidate()
                
                if case .failure(let error) = completion {
                    print("Pagination error (attempt \(retryCount + 1)): \(error.localizedDescription)")
                    
                    // Check if it's a 404 error (common for pagination)
                    let is404Error = error.localizedDescription.contains("404")
                    
                    // Special handling for page 2 - always retry page 2 failures with a different approach
                    if isPage2 && retryCount == 0 {
                        // For first failure of page 2, try a different approach immediately
                        print("Page 2 first attempt failed - trying again immediately with different parameters")
                        
                        // Wait a short time (0.5 seconds) then retry with a smaller page size
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            // Try with a smaller page size for the retry
                            self.fetchPageWithRetry(
                                searchId: searchId,
                                page: page,
                                limit: 15, // Use smaller page size for retry
                                retryCount: retryCount + 1,
                                isPage2: true
                            )
                        }
                    }
                    // Standard retry logic for other errors and pages
                    else if is404Error && retryCount < 3 {
                        // Exponential backoff: wait longer between retries
                        let delay = Double(1 << retryCount) // 1, 2, 4 seconds
                        print("Retrying in \(delay) seconds...")
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                            self.fetchPageWithRetry(
                                searchId: searchId,
                                page: page,
                                limit: limit,
                                retryCount: retryCount + 1,
                                isPage2: isPage2
                            )
                        }
                    } else {
                        // Max retries reached or non-404 error
                        self.isLoadingMoreFlights = false
                        
                        // For 404 errors, just silently fail and update the UI
                        if is404Error {
                            print("Pagination failed after \(retryCount + 1) attempts - no more results available")
                            self.hasMoreFlights = false
                        } else {
                            // For other errors, show a message
                            print("Pagination failed: \(error.localizedDescription)")
                            
                            // IMPORTANT: Even on failure, we might still have more flights
                            // Only set hasMoreFlights to false if we're sure there are no more
                            if page > 1 && self.detailedFlightResults.count >= self.totalFlightCount {
                                self.hasMoreFlights = false
                            }
                        }
                    }
                }
            },
            receiveValue: { [weak self] pollResponse in
                guard let self = self else { return }
                
                // Cancel the safety timer since we got a response
                safetyTimer.invalidate()
                
                self.totalFlightCount = pollResponse.count
                
                // Only update current page on success
                self.currentPage = page
                
                // Append new results
                self.detailedFlightResults.append(contentsOf: pollResponse.results)
                
                // Update pagination state more reliably
                // Check both next flag and total count
                let loadedCount = self.detailedFlightResults.count
                let hasMoreBasedOnCount = loadedCount < pollResponse.count
                let hasMoreBasedOnNext = pollResponse.next != nil
                
                // Use both signals to determine if there are more flights
                self.hasMoreFlights = hasMoreBasedOnNext || hasMoreBasedOnCount
                
                // Always ensure we reset the loading flag
                self.isLoadingMoreFlights = false
                self.isFirstLoad = false
                
                print("Page \(page) loaded successfully: \(pollResponse.results.count) new flights, total loaded: \(self.detailedFlightResults.count), hasMore: \(self.hasMoreFlights)")
            }
        )
        .store(in: &cancellables)
    }

   
    
    func resetToAnywhereDestination() {
            print("resetToAnywhereDestination called")
            
            // If we came from a direct search, clear everything
            if isDirectSearch {
                clearSearchFormAndReturnToExplore()
                return
            }
            
            // Otherwise use existing logic
            // Reset destination
            self.toLocation = "Anywhere"
            self.toIataCode = ""
            
            // Clear any search states
            self.hasSearchedFlights = false
            self.showingDetailedFlightList = false
            self.isDirectSearch = false
            self.isAnytimeMode = false
            
            // Clear results
            self.flightResults = []
            self.detailedFlightResults = []
            self.flightSearchResponse = nil
            
            // Clear selected city and return to countries
            self.selectedCity = nil
            self.selectedCountryName = nil
            self.showingCities = false
            
            // Clear error states
            self.errorMessage = nil
            self.detailedFlightError = nil
            
            // Clear dates to show "Anytime"
            self.dates = []
            self.selectedDepartureDatee = ""
            self.selectedReturnDatee = ""
            
            // Fetch countries to show the main explore screen
            self.fetchCountries()
        }
    
    func handleBackNavigationWithAnywhere() {
            if toLocation == "Anywhere" {
                // If destination is "Anywhere", check if we need to clear form
                if isDirectSearch {
                    clearSearchFormAndReturnToExplore()
                } else {
                    goBackToCountries()
                }
            } else {
                // Use existing back navigation logic
                if selectedFlightId != nil {
                    selectedFlightId = nil
                } else if showingDetailedFlightList {
                    goBackToFlightResults()
                } else if hasSearchedFlights {
                    goBackToCities()
                } else if showingCities {
                    goBackToCountries()
                }
            }
        }
    
    func handleDetailedFlightBackNavigation() {
            print("handleDetailedFlightBackNavigation called")
            print("Current selectedFlightId: \(selectedFlightId ?? "nil")")
            print("Current showingDetailedFlightList: \(showingDetailedFlightList)")
            
            if selectedFlightId != nil {
                // If a flight is selected, deselect it first
                print("Deselecting flight, going back to flight list")
                selectedFlightId = nil
            } else {
                // Otherwise go back to flight results or previous level
                print("Going back to previous level")
                goBackToFlightResults()
            }
        }
    
    func handleAnytimeResults(_ results: [FlightResult]) {
        // Set anytime mode flag
           self.isAnytimeMode = true
        // Reset all detailed view flags to ensure they don't activate
        self.detailedFlightResults = []
        self.showingDetailedFlightList = false
        self.isLoadingDetailedFlights = false
        self.detailedFlightError = nil
        self.isDirectSearch = false
        
        // Set up the flight results display
        self.flightResults = results
        self.hasSearchedFlights = true
        self.isLoadingFlights = false
        
        // If we got results, update the to/from location display
        if let firstResult = results.first {
            self.fromLocation = firstResult.outbound.origin.name
            self.toLocation = firstResult.outbound.destination.name
            
            self.fromIataCode = firstResult.outbound.origin.iata
            self.toIataCode = firstResult.outbound.destination.iata
            
            // Save search details for later use
            self.selectedOriginCode = firstResult.outbound.origin.iata
            self.selectedDestinationCode = firstResult.outbound.destination.iata
            
            if let outboundDeparture = firstResult.outbound.departure {
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd"
                let departureDate = Date(timeIntervalSince1970: TimeInterval(outboundDeparture))
                self.selectedDepartureDatee = formatter.string(from: departureDate)
                
                if let inboundDeparture = firstResult.inbound?.departure {
                    let returnDate = Date(timeIntervalSince1970: TimeInterval(inboundDeparture))
                    self.selectedReturnDatee = formatter.string(from: returnDate)
                }
            }
        }
        
        // Clear these to ensure we're in the right state
        self.selectedCity = nil
        self.showingCities = false
        
        // Set dates array to empty to show "Anytime" in the date field
        self.dates = []
        
        // Update error message based on results
        if results.isEmpty {
            self.errorMessage = "No flights found for this route"
        } else {
            self.errorMessage = nil
        }
        
        // Force an update to ensure changes are processed
        self.objectWillChange.send()
    }
    
    // Helper method to format price with the correct currency symbol
        func formatPrice(_ price: Int) -> String {
            if let currencyInfo = currencyInfo {
                let symbol = currencyInfo.symbol
                let hasSpace = currencyInfo.spaceBetweenAmountAndSymbol
                let spacer = hasSpace ? " " : ""
                
                if currencyInfo.symbolOnLeft {
                    return "\(symbol)\(spacer)\(price)"
                } else {
                    return "\(price)\(spacer)\(symbol)"
                }
            } else {
                // Fallback to default format
                return "₹\(price)"
            }
        }
    
    // Add this method to update currency info when receiving API response
        func updateCurrencyInfo(_ info: CurrencyDetail) {
            self.currencyInfo = info
        }
    
    struct FilterSheetState {
        var sortOption: FlightFilterTabView.FilterOption = .all
        var directFlightsSelected: Bool = true
        var oneStopSelected: Bool = false
        var multiStopSelected: Bool = false
        var priceRange: [Double] = [0.0, 2000.0]
        var departureTimes: [Double] = [0.0, 24.0]
        var arrivalTimes: [Double] = [0.0, 24.0]
        var durationRange: [Double] = [1.75, 8.5]
        var selectedAirlines: Set<String> = []
        
        // Add any other filter state variables you need to preserve
    }
    @Published var filterSheetState = FilterSheetState()
    
    @Published var isDirectSearch: Bool = false
    
    func goBackToMainFromDirectSearch() {
            print("goBackToMainFromDirectSearch called")
            clearSearchFormAndReturnToExplore()
        }
    
    // For storing filter state
    private var _currentFilterRequest: FlightFilterRequest?
    private var _lastPollResponse: FlightPollResponse?

    // Public accessors
    var currentFilterRequest: FlightFilterRequest? {
        get {
            return _currentFilterRequest
        }
        set {
            _currentFilterRequest = newValue
        }
    }

    var lastPollResponse: FlightPollResponse? {
        get {
            return _lastPollResponse
        }
        set {
            _lastPollResponse = newValue
        }
    }
    
    func applyQuickFilter(_ filter: FlightFilterTabView.FilterOption) {
        var filterRequest: FlightFilterRequest? = nil
        
        switch filter {
        case .all:
            // No specific filters needed
            currentFilterRequest = nil
        case .best:
            // For "best", don't set any sort parameter - let API return default best results
            filterRequest = FlightFilterRequest()
            // Don't set sortBy for best - this was causing the 400 error
            currentFilterRequest = filterRequest
        case .cheapest:
            filterRequest = FlightFilterRequest()
            filterRequest!.sortBy = "price"
            filterRequest!.sortOrder = "asc"
            currentFilterRequest = filterRequest
        case .fastest:
            filterRequest = FlightFilterRequest()
            filterRequest!.sortBy = "duration"
            filterRequest!.sortOrder = "asc"
            currentFilterRequest = filterRequest
        case .direct:
            filterRequest = FlightFilterRequest()
            filterRequest!.stopCountMax = 0
            currentFilterRequest = filterRequest
        }
        
        // Always trigger a new search if we have origin/destination data
        if !self.selectedOriginCode.isEmpty && !self.selectedDestinationCode.isEmpty {
            // Clear existing results
            self.detailedFlightResults = []
            
            // Restart search with the current filter (or no filter for .all)
            searchFlightsForDates(
                origin: self.selectedOriginCode,
                destination: self.selectedDestinationCode,
                returnDate: self.isRoundTrip ? self.selectedReturnDatee : "",
                departureDate: self.selectedDepartureDatee
            )
        }
        
        objectWillChange.send()
    }
    
    func applyPollFilters(filterRequest: FlightFilterRequest) {
            guard let searchId = currentSearchId else {
                print("⚠️ No search ID available for filter application")
                return
            }
            
            print("🔍 Applying filters via API - searchId: \(searchId)")
            
            // Store the filter request
            self._currentFilterRequest = filterRequest
            
            // Reset pagination and cache tracking for filtered results
            isLoadingDetailedFlights = true
            detailedFlightError = nil
            currentPage = 1
            actualLoadedCount = 0
            isDataCached = false
            hasMoreFlights = true
            isLoadingMoreFlights = false
            isFirstLoad = true
            
            service.pollFlightResultsPaginated(
                searchId: searchId,
                page: 1,
                limit: 8,
                filterRequest: filterRequest
            )
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    guard let self = self else { return }
                    
                    self.isLoadingDetailedFlights = false
                    
                    if case .failure(let error) = completion {
                        print("❌ Filter application failed: \(error.localizedDescription)")
                        self.detailedFlightError = error.localizedDescription
                    }
                },
                receiveValue: { [weak self] response in
                    guard let self = self else { return }
                    
                    print("✅ Filters applied: \(response.results.count) flights, total: \(response.count), cached: \(response.cache)")
                    
                    // FIXED: Update all tracking variables from API response
                    self.totalFlightCount = response.count
                    self.isDataCached = response.cache
                    self.actualLoadedCount = response.results.count
                    self.hasMoreFlights = self.shouldContinueLoadingMore()
                    self.isLoadingDetailedFlights = false
                    self.detailedFlightError = nil
                    
                    // Update results
                    self.detailedFlightResults = response.results
                    
                    print("📊 Filter complete: \(self.actualLoadedCount)/\(self.totalFlightCount), cached: \(self.isDataCached), hasMore: \(self.hasMoreFlights)")
                }
            )
            .store(in: &cancellables)
        }
    
    
    func updateChildrenAgesArray(for newCount: Int) {
        if newCount > childrenAges.count {
            // Add nil ages for new children
            childrenAges.append(contentsOf: Array(repeating: nil, count: newCount - childrenAges.count))
        } else if newCount < childrenAges.count {
            // Remove excess ages
            childrenAges = Array(childrenAges.prefix(newCount))
        }
    }

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
        
        // Initialize passenger data
        adultsCount = 1
        childrenCount = 0
        childrenAges = [0]
        selectedCabinClass = "Economy"
        
        // FIXED: Set initial loading state to true if no destinations are loaded
        // This ensures skeleton appears immediately when view is first shown
        if destinations.isEmpty {
            isLoading = true
            print("🔄 ExploreViewModel: Setting initial loading state to true")
        }
        
        // Add observer for dates changes
        $dates
            .sink { [weak self] selectedDates in
                guard let self = self else { return }
                if !selectedDates.isEmpty {
                    self.updateSelectedDates()
                }
            }
            .store(in: &cancellables)
        
        ExploreAPIService.shared.viewModelReference = self
    }
    
    func handleTripTypeChange() {
        print("🔄 Trip type changed to: \(isRoundTrip ? "Round Trip" : "One Way")")
        
        // Handle date changes when switching trip types
        if isRoundTrip { // Switching TO round trip
            // Make sure we have both departure and return dates for round trip
            if dates.count == 1 {
                // We only have a departure date, add a return date (departure + 7 days)
                if let returnDate = Calendar.current.date(byAdding: .day, value: 7, to: dates[0]) {
                    dates.append(returnDate)
                    
                    // Update the formatted date strings
                    let formatter = DateFormatter()
                    formatter.dateFormat = "yyyy-MM-dd"
                    selectedReturnDatee = formatter.string(from: returnDate)
                    
                    print("Added return date for round trip: \(selectedReturnDatee)")
                }
            } else if dates.isEmpty && !selectedDepartureDatee.isEmpty {
                // We have a string date but no Date objects - reconstruct from strings
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd"
                
                if let departureDate = formatter.date(from: selectedDepartureDatee) {
                    dates = [departureDate]
                    
                    // Add a return date (departure + 7 days)
                    if let returnDate = Calendar.current.date(byAdding: .day, value: 7, to: departureDate) {
                        dates.append(returnDate)
                        selectedReturnDatee = formatter.string(from: returnDate)
                        print("Created return date for round trip: \(selectedReturnDatee)")
                    }
                }
            }
        } else { // Switching TO one-way
            // Keep only the first date for one-way if we have multiple dates
            if dates.count > 1 {
                dates = Array(dates.prefix(1))
            }
            // Clear the return date string
            selectedReturnDatee = ""
            print("Cleared return date for one-way trip")
        }
        
        // FIXED: Enhanced logic to handle all search scenarios
        if !fromIataCode.isEmpty && !toIataCode.isEmpty {
            // Clear current results first
            detailedFlightResults = []
            flightResults = []
            
            // Scenario 1: We're on the detailed flight list (most common case)
            if showingDetailedFlightList && !selectedOriginCode.isEmpty && !selectedDestinationCode.isEmpty && !selectedDepartureDatee.isEmpty {
                print("🔄 Re-searching detailed flights with new trip type")
                
                // For round trip, ensure we have a return date
                let returnDate = isRoundTrip ? selectedReturnDatee : ""
                
                searchFlightsForDates(
                    origin: selectedOriginCode,
                    destination: selectedDestinationCode,
                    returnDate: returnDate,
                    departureDate: selectedDepartureDatee,
                    isDirectSearch: isDirectSearch
                )
            }
            // Scenario 2: We have dates selected and are ready to search
            else if !dates.isEmpty {
                print("🔄 Re-searching with dates array")
                updateDatesAndRunSearch()
            }
            // Scenario 3: We have a selected city in the explore flow
            else if let city = selectedCity {
                print("🔄 Re-fetching flight details for selected city")
                fetchFlightDetails(destination: city.location.iata)
            }
            // Scenario 4: We have search parameters but need to reconstruct dates
            else if !selectedDepartureDatee.isEmpty {
                print("🔄 Reconstructing search from stored parameters")
                
                // Reconstruct dates array from stored strings
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd"
                
                var newDates: [Date] = []
                if let departureDate = formatter.date(from: selectedDepartureDatee) {
                    newDates.append(departureDate)
                    
                    if isRoundTrip && !selectedReturnDatee.isEmpty,
                       let returnDate = formatter.date(from: selectedReturnDatee) {
                        newDates.append(returnDate)
                    }
                }
                
                dates = newDates
                
                // Now trigger the search
                if !selectedOriginCode.isEmpty && !selectedDestinationCode.isEmpty {
                    searchFlightsForDates(
                        origin: selectedOriginCode,
                        destination: selectedDestinationCode,
                        returnDate: isRoundTrip ? selectedReturnDatee : "",
                        departureDate: selectedDepartureDatee,
                        isDirectSearch: isDirectSearch
                    )
                } else {
                    updateDatesAndRunSearch()
                }
            }
            else {
                print("⚠️ No valid search context found for trip type change")
            }
        } else {
            print("⚠️ Missing origin/destination codes for trip type change")
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
            } else if dates.count == 1 {
                departureDate = formatter.string(from: dates[0])
                
                // For round trip with only one date, create a return date
                if isRoundTrip {
                    if let nextWeek = Calendar.current.date(byAdding: .day, value: 7, to: dates[0]) {
                        returnDate = formatter.string(from: nextWeek)
                        // Also add the return date to the dates array
                        if !dates.contains(nextWeek) {
                            dates.append(nextWeek)
                        }
                    } else {
                        returnDate = ""
                    }
                } else {
                    returnDate = ""
                }
            } else {
                // Default fallback dates if somehow we have no dates
                let today = Date()
                if let nextWeek = Calendar.current.date(byAdding: .day, value: 7, to: today) {
                    departureDate = formatter.string(from: today)
                    returnDate = isRoundTrip ? formatter.string(from: nextWeek) : ""
                    
                    // Also update the dates array
                    dates = isRoundTrip ? [today, nextWeek] : [today]
                } else {
                    departureDate = "2025-12-29"
                    returnDate = isRoundTrip ? "2025-12-30" : ""
                }
            }
            
            // Update the stored dates
            selectedDepartureDatee = departureDate
            selectedReturnDatee = returnDate
            
            // Initiate search with these dates - mark as direct search
            searchFlightsForDates(
                origin: fromIataCode,
                destination: toIataCode,
                returnDate: returnDate,
                departureDate: departureDate,
                isDirectSearch: true
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
        searchMultiCityFlightsWithPagination()
    }
    
    // Add this function to handle search and poll
    func searchFlightsForDates(origin: String, destination: String, returnDate: String, departureDate: String, isDirectSearch: Bool = false) {
        searchFlightsForDatesWithPagination(
            origin: origin,
            destination: destination,
            returnDate: returnDate,
            departureDate: departureDate,
            isDirectSearch: isDirectSearch
        )
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
    
    // MARK: - Enhanced fetchCountries method (replace the existing fetchCountries)
    func fetchCountries() {
            // First check if we already have cached data
            if let cachedData = ExploreViewModel.cachedDestinations, !cachedData.isEmpty {
                print("✅ Using cached country list data")
                self.destinations = cachedData
                self.isLoading = false
                
                // Update currency info if available
                if let currencyInfo = self.service.lastFetchedCurrencyInfo {
                    self.updateCurrencyInfo(currencyInfo)
                }
                
                return
            }
            
            // No cached data, proceed with normal fetch
            isLoading = true
            errorMessage = nil
            
            print("🔄 fetchCountries: Loading state set to true immediately")
            
            service.fetchDestinations()
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    if case .failure(let error) = completion {
                        self?.errorMessage = error.localizedDescription
                        print("❌ fetchCountries failed: \(error.localizedDescription)")
                    }
                }, receiveValue: { [weak self] destinations in
                    self?.destinations = destinations
                    
                    // Cache the data for future use
                    ExploreViewModel.cachedDestinations = destinations
                    
                    self?.debugDuplicateFlightIDs()
                    
                    if let currencyInfo = self?.service.lastFetchedCurrencyInfo {
                        self?.updateCurrencyInfo(currencyInfo)
                    }
                    
                    print("✅ fetchCountries completed: \(destinations.count) destinations loaded")
                })
                .store(in: &cancellables)
        }
        
        // Add this method to clear the cache if needed
        func clearCountriesCache() {
            ExploreViewModel.cachedDestinations = nil
        }
    
    
    func fetchCitiesFor(countryId: String, countryName: String) {
        isLoading = true
        errorMessage = nil
        selectedCountryName = countryName
        
        // ADDED: Update toLocation to country name when country is selected
        toLocation = countryName
        
        // FIXED: Set showingCities immediately, not in completion handler
        showingCities = true
        
        service.fetchDestinations(arrivalType: "city", arrivalId: countryId)
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
    
    func selectCity(city: ExploreDestination) {
        selectedCity = city
        toLocation = city.location.name
        toIataCode = city.location.iata  // ADDED: Set the IATA code when city is selected
        
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
            // Exit anytime mode when selecting a specific month
            isAnytimeMode = false
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
                    
                    // Update dates array
                    if !newDates.isEmpty {
                        dates = newDates
                        
                        // CHANGED: Check if we're already in flight results view
                        if hasSearchedFlights && !showingDetailedFlightList {
                            // If we're already in flight results view, use fetchFlightDetails instead of full search
                            if let city = selectedCity {
                                fetchFlightDetails(destination: city.location.iata)
                            } else if !selectedDestinationCode.isEmpty {
                                fetchFlightDetails(destination: selectedDestinationCode)
                            }
                            return
                        } else {
                            // Otherwise proceed with full search
                            updateDatesAndRunSearch()
                            return
                        }
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
                
                // CHANGED: Check if we're already in flight results view
                if hasSearchedFlights && !showingDetailedFlightList {
                    // If we're already in flight results view, use fetchFlightDetails
                    if let city = selectedCity {
                        fetchFlightDetails(destination: city.location.iata)
                    } else if !selectedDestinationCode.isEmpty {
                        fetchFlightDetails(destination: selectedDestinationCode)
                    }
                } else {
                    // Otherwise trigger search with the new month dates
                    searchFlightsForDates(
                        origin: fromIataCode,
                        destination: toIataCode,
                        returnDate: selectedReturnDatee,
                        departureDate: selectedDepartureDatee
                    )
                }
                
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
    
    func goBackToFlightResults() {
           print("goBackToFlightResults called")
           // Clear selected flight first
           selectedFlightId = nil
           
           // Reset all search-related states
           if isDirectSearch {
               print("Handling direct search back navigation - clearing form")
               // Clear the search form completely for direct searches from HomeView
               clearSearchFormAndReturnToExplore()
           } else {
               print("Handling explore flow back navigation")
               // If this came from exploration, go back to flight results
               showingDetailedFlightList = false
               detailedFlightResults = []
               detailedFlightError = nil
               isLoadingDetailedFlights = false
               // Keep hasSearchedFlights = true to stay on flight results page
           }
       }
    
    func clearSearchFormAndReturnToExplore() {
            // Clear all search-related flags
            isDirectSearch = false
            showingDetailedFlightList = false
            detailedFlightResults = []
            detailedFlightError = nil
            isLoadingDetailedFlights = false
            hasSearchedFlights = false
            flightResults = []
            flightSearchResponse = nil
            isAnytimeMode = false
            directFlightsOnlyFromHome = false // ADD: Clear direct flights preference
            
            // Clear search form data
            fromLocation = "Mumbai" // Reset to default
            toLocation = "Anywhere" // Reset to anywhere
            fromIataCode = "DEL" // Reset to default origin
            toIataCode = "" // Clear destination
            dates = [] // Clear selected dates
            selectedDepartureDatee = ""
            selectedReturnDatee = ""
            selectedOriginCode = ""
            selectedDestinationCode = ""
            
            // Clear selected states
            selectedCountryName = nil
            selectedCity = nil
            showingCities = false
            selectedFlightId = nil
            
            // Clear error states
            errorMessage = nil
            
            // Return to countries view
            fetchCountries()
        DispatchQueue.main.async {
               SharedSearchDataStore.shared.isInSearchMode = false
           }
            
            print("✅ Search form cleared and returned to explore countries")
        }

    func goBackToCities() {
        print("goBackToCities called")
        
        // If this was a direct search, clear the form completely
        if isDirectSearch {
            clearSearchFormAndReturnToExplore()
            return
        }
        
        // Otherwise use existing logic
        isAnytimeMode = false
        hasSearchedFlights = false
        flightResults = []
        flightSearchResponse = nil
        selectedCity = nil
        toIataCode = ""  // ADDED: Clear IATA code when going back to cities
        // Keep toLocation as country name - don't reset it here
        
        // Fetch cities again for the selected country
        if let countryName = selectedCountryName,
           let country = destinations.first(where: { $0.location.name == countryName }) {
            fetchCitiesFor(countryId: country.location.entityId, countryName: countryName)
        }
    }
    
    func goBackToCountries() {
        print("goBackToCountries called")
        
        // If this was a direct search, clear the form completely
        if isDirectSearch {
            clearSearchFormAndReturnToExplore()
            return
        }
        
        // Otherwise use existing logic
        isAnytimeMode = false
        selectedCountryName = nil
        selectedCity = nil
        toLocation = "Anywhere"
        toIataCode = ""  // ADDED: Clear IATA code when going back to countries
        showingCities = false
        hasSearchedFlights = false
        showingDetailedFlightList = false
        flightResults = []
        flightSearchResponse = nil
        detailedFlightResults = []
        detailedFlightError = nil
        fetchCountries()
        
        // Reset tab visibility when returning to countries
        DispatchQueue.main.async {
            if !SharedSearchDataStore.shared.isInSearchMode {
                SharedSearchDataStore.shared.isInSearchMode = false
            }
        }
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
    
    // ADD: Observe shared search data
    @StateObject private var sharedSearchData = SharedSearchDataStore.shared
    
    
    private var isInMainCountryView: Bool {
          return !viewModel.showingCities &&
                 !viewModel.hasSearchedFlights &&
                 !viewModel.showingDetailedFlightList &&
                 !sharedSearchData.isInSearchMode &&
                 viewModel.selectedCountryName == nil &&
                 viewModel.selectedCity == nil
      }
    
    // NEW: Flag to track if we're in country navigation mode
    @State private var isCountryNavigationActive = false
    
    // Collapsible card states
    @State private var isCollapsed = false
    @State private var scrollOffset: CGFloat = 0
    @Namespace private var searchCardNamespace
    
    let filterOptions = ["Cheapest flights", "Direct Flights", "Suggested for you"]
    
    // MODIFIED: Updated back navigation to handle "Anywhere" destination
    private func handleBackNavigation() {
            print("=== Back Navigation Debug ===")
            print("selectedFlightId: \(viewModel.selectedFlightId ?? "nil")")
            print("showingDetailedFlightList: \(viewModel.showingDetailedFlightList)")
            print("hasSearchedFlights: \(viewModel.hasSearchedFlights)")
            print("showingCities: \(viewModel.showingCities)")
            print("toLocation: \(viewModel.toLocation)")
            print("isDirectSearch: \(viewModel.isDirectSearch)")
            print("isInSearchMode: \(sharedSearchData.isInSearchMode)")
            
            // UPDATED: Special handling for search mode - return to home
            if sharedSearchData.isInSearchMode {
                print("Action: Search mode detected - returning to home")
                sharedSearchData.returnToHomeFromSearch()
                print("=== End Back Navigation Debug ===")
                return
            }
            
            // Special handling for direct searches from HomeView
            if viewModel.isDirectSearch {
                print("Action: Direct search detected - clearing form and returning to explore")
                
                if viewModel.selectedFlightId != nil {
                    // If a flight is selected, deselect it first
                    print("Action: Deselecting flight in direct search")
                    viewModel.selectedFlightId = nil
                } else if viewModel.showingDetailedFlightList && viewModel.hasSearchedFlights {
                    // CHANGED: If we have flight results and we're coming from search dates button
                    // Just go back to flight results instead of clearing the form
                    print("Action: Going back to flight results from search dates view")
                    viewModel.showingDetailedFlightList = false
                    // Don't clear search form here
                } else if viewModel.showingDetailedFlightList {
                    // If on flight list from direct search (not from View these dates), go back and clear form
                    print("Action: Going back from direct search flight list - clearing form")
                    isCountryNavigationActive = false // Reset the flag
                    viewModel.clearSearchFormAndReturnToExplore()
                } else {
                    // Fallback - clear form
                    print("Action: Fallback direct search back navigation - clearing form")
                    isCountryNavigationActive = false // Reset the flag
                    viewModel.clearSearchFormAndReturnToExplore()
                }
                print("=== End Back Navigation Debug ===")
                return
            }
            
            // Rest of the existing code remains unchanged
            // Special handling for "Anywhere" destination in explore flow
            if viewModel.toLocation == "Anywhere" {
                print("Action: Handling Anywhere destination - going back to countries")
                isCountryNavigationActive = false // Reset the flag
                sharedSearchData.resetAll() // Use the new resetAll method
                viewModel.resetToAnywhereDestination()
                return
            }
            
            // Regular explore flow navigation
            if viewModel.selectedFlightId != nil {
                // If a flight is selected, deselect it first (go back to flight list)
                print("Action: Deselecting flight (going back to flight list)")
                viewModel.selectedFlightId = nil
            } else if viewModel.showingDetailedFlightList {
                // If no flight is selected but we're on detailed flight list, go back to previous level
                print("Action: Going back from flight list to previous level")
                viewModel.goBackToFlightResults()
            } else if viewModel.hasSearchedFlights {
                // Go back from flight results to cities or countries
                if viewModel.toLocation == "Anywhere" {
                    print("Action: Going back from flight results to countries (Anywhere)")
                    isCountryNavigationActive = false // Reset the flag
                    viewModel.goBackToCountries()
                } else {
                    print("Action: Going back from flight results to cities")
                    viewModel.goBackToCities()
                }
            } else if viewModel.showingCities {
                // Go back from cities to countries
                print("Action: Going back from cities to countries")
                isCountryNavigationActive = false // Reset the flag
                viewModel.goBackToCountries()
            }
            print("=== End Back Navigation Debug ===")
        }

    private func getCurrentMonthName() -> String {
        if !viewModel.isAnytimeMode && viewModel.selectedMonthIndex < viewModel.availableMonths.count {
            let selectedMonth = viewModel.availableMonths[viewModel.selectedMonthIndex]
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM"
            return formatter.string(from: selectedMonth)
        } else {
            // Fallback to current month
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM"
            return formatter.string(from: Date())
        }
    }
    
    // Add this computed property in ExploreScreen
    private var shouldShowBackButton: Bool {
        // Show back button only when NOT showing the main country list
        return viewModel.showingCities ||
               viewModel.hasSearchedFlights ||
               viewModel.showingDetailedFlightList ||
               sharedSearchData.isInSearchMode ||
               viewModel.selectedCountryName != nil
    }
    
    // MARK: - Body
    var body: some View {
        VStack(spacing: 0) {
            // Custom navigation bar - Collapsible
            if isCollapsed {
                CollapsedSearchCard(
                    viewModel: viewModel,
                    searchCardNamespace: searchCardNamespace,
                    onTap: {
                        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                            isCollapsed = false
                        }
                    },
                    handleBackNavigation: handleBackNavigation,
                    shouldShowBackButton: shouldShowBackButton
                )
                .transition(.opacity.combined(with: .scale(scale: 0.95)))
            } else {
                ExpandedSearchCard(
                    viewModel: viewModel,
                    selectedTab: $selectedTab,
                    isRoundTrip: $isRoundTrip,
                    searchCardNamespace: searchCardNamespace,
                    handleBackNavigation: handleBackNavigation,
                    shouldShowBackButton: shouldShowBackButton,
                    onDragCollapse: {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                            isCollapsed = true
                        }
                    }
                )
                .transition(.opacity.combined(with: .scale(scale: 1.05)))
            }
            
            // Main content with scroll detection
            GeometryReader { geometry in
                ScrollViewWithOffset(
                    offset: $scrollOffset,
                    content: {
                        VStack(alignment: .center, spacing: 16) {
                            // Add some top padding to account for the search card

                            
                            // Main content based on current state
                            if viewModel.showingDetailedFlightList {
                                // Detailed flight list - highest priority
                                ModifiedDetailedFlightListView(viewModel: viewModel)
                                    .transition(.move(edge: .trailing))
                                    .zIndex(1)
                                    .edgesIgnoringSafeArea(.all)
                                    .background(Color(.systemBackground))
                            }
                            else if !viewModel.hasSearchedFlights {
                                // Original explore view content
                                // MODIFIED: Show different title based on destination
                                Text(getExploreTitle())
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
                                                viewModel: viewModel,
                                                onTap: {
                                                    if !viewModel.showingCities {
                                                        viewModel.fetchCitiesFor(
                                                            countryId: destination.location.entityId,
                                                            countryName: destination.location.name
                                                        )
                                                    } else {
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
                                    
                                    // Only show month selector when NOT in anytime mode
                                    if !viewModel.isAnytimeMode {
                                        MonthSelectorView(
                                            months: viewModel.availableMonths,
                                            selectedIndex: viewModel.selectedMonthIndex,
                                            onSelect: { index in
                                                viewModel.selectMonth(at: index)
                                            }
                                        )
                                        .padding(.top, 8)
                                    } else {
                                        Text("Best prices for the next 3 months")
                                            .font(.subheadline)
                                            .foregroundColor(.gray)
                                            .padding(.top, 8)
                                            .padding(.bottom, 8)
                                    }
                                    
                                    if viewModel.isLoadingFlights {
                                        ForEach(0..<3, id: \.self) { _ in
                                            SkeletonFlightResultCard()
                                                .padding(.bottom, 8)
                                        }
                                    } else if viewModel.errorMessage != nil || viewModel.flightResults.isEmpty {
                                        Text("No flights found")
                                            .font(.subheadline)
                                            .foregroundColor(.gray)
                                    } else {
                                        if !viewModel.isAnytimeMode && !viewModel.flightResults.isEmpty {
                                            Text("Estimated cheapest price during \(getCurrentMonthName())")
                                                .font(.subheadline)
                                                .foregroundColor(.primary)
                                                .padding(.horizontal)
                                                .padding(.bottom, 8)
                                        }
                                        
                                        ForEach(viewModel.flightResults) { result in
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
                        .background(Color("scroll"))
                    }
                )
            }
        }
        .background(Color("scroll"))
        .safeAreaInset(edge: .bottom) {
            Color.clear.frame(height: 50) // space equal to tab bar height
        }
        // MARK: - Updated onAppear for ExploreScreen (replace the existing .onAppear)
        .onAppear {
            print("🔍 ExploreScreen onAppear - checking states...")
            print("🔍 hasSearchedFlights: \(viewModel.hasSearchedFlights)")
            print("🔍 showingDetailedFlightList: \(viewModel.showingDetailedFlightList)")
            print("🔍 showingCities: \(viewModel.showingCities)")
            print("🔍 shouldNavigateToExploreCities: \(sharedSearchData.shouldNavigateToExploreCities)")
            print("🔍 shouldExecuteSearch: \(sharedSearchData.shouldExecuteSearch)")
            print("🔍 isInSearchMode: \(sharedSearchData.isInSearchMode)")
            print("🔍 isCountryNavigationActive: \(isCountryNavigationActive)")
            print("🔍 destinations count: \(viewModel.destinations.count)")
            print("🔍 sharedSearchData.selectedTab: \(sharedSearchData.selectedTab)")
            
            // UPDATED: Initialize selectedTab based on search mode
            if sharedSearchData.isInSearchMode {
                // If coming from direct search, use the original selectedTab but limit to available options
                if sharedSearchData.selectedTab == 2 {
                    // Multi-city search - keep as is
                    selectedTab = 2
                } else {
                    // Return or One-way - map appropriately
                    selectedTab = sharedSearchData.selectedTab
                }
                isRoundTrip = sharedSearchData.isRoundTrip
                print("🔍 Initialized from search mode: selectedTab=\(selectedTab), isRoundTrip=\(isRoundTrip)")
            } else {
                // Not in search mode - ensure we don't have multi-city selected
                if selectedTab >= 2 {
                    selectedTab = 0 // Reset to Return
                    isRoundTrip = true
                }
                print("🔍 Regular explore mode: selectedTab=\(selectedTab), isRoundTrip=\(isRoundTrip)")
            }
            
            // NEW: Check if we're in a clean explore state with countries already loaded
            let isInCleanExploreState = !viewModel.hasSearchedFlights &&
                                       !viewModel.showingDetailedFlightList &&
                                       !viewModel.showingCities &&
                                       viewModel.toLocation == "Anywhere" &&
                                       viewModel.selectedCountryName == nil &&
                                       viewModel.selectedCity == nil &&
                                       !viewModel.isDirectSearch
            
            let hasCountriesLoaded = !viewModel.destinations.isEmpty
            
            // If we're in clean state with countries loaded, don't do anything
            if isInCleanExploreState && hasCountriesLoaded &&
               !sharedSearchData.shouldExecuteSearch &&
               !sharedSearchData.shouldNavigateToExploreCities {
                print("🔍 Clean explore state with countries loaded - no action needed")
                return
            }
            
            // Handle incoming search from HomeView
            if sharedSearchData.isInSearchMode && sharedSearchData.shouldExecuteSearch {
                print("🔍 Handling incoming search from HomeView")
                handleIncomingSearchFromHome()
                return
            }
            
            // Handle country-to-cities navigation from HomeView
            if sharedSearchData.shouldNavigateToExploreCities && !sharedSearchData.selectedCountryId.isEmpty {
                print("🔍 Handling country navigation from HomeView")
                handleIncomingCountryNavigation()
                return
            }
            
            // Check if user manually navigated to explore (not from search mode) and needs reset
            if !sharedSearchData.isInSearchMode &&
               !sharedSearchData.shouldExecuteSearch &&
               !sharedSearchData.shouldNavigateToExploreCities &&
               !isInCleanExploreState {
                
                print("🔄 Manual navigation to explore detected with dirty state - resetting view model")
                resetExploreViewModelToInitialState()
                
                // FIXED: Set loading state immediately and fetch countries without delay
                viewModel.isLoading = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    viewModel.fetchCountries()
                }
                return
            }
            
            // FIXED: Check if we need to fetch countries and do it immediately with loading state
            let shouldFetchCountries = viewModel.destinations.isEmpty &&
                                     isInCleanExploreState &&
                                     !sharedSearchData.shouldNavigateToExploreCities &&
                                     !sharedSearchData.shouldExecuteSearch &&
                                     !isCountryNavigationActive
            
            if shouldFetchCountries {
                print("🔍 Setting loading state and fetching countries immediately...")
                // FIXED: Set loading state immediately
                viewModel.isLoading = true
                
                // FIXED: Fetch countries immediately (no delay)
                viewModel.fetchCountries()
            } else {
                print("🔍 Skipping country fetch - countries loaded or navigation state active")
            }
            
            viewModel.setupAvailableMonths()
            updateTabVisibility()
        }
        .onChange(of: viewModel.showingCities) { showingCities in
                    updateTabVisibility()
                }
                .onChange(of: viewModel.hasSearchedFlights) { hasSearchedFlights in
                    updateTabVisibility()
                }
                .onChange(of: viewModel.showingDetailedFlightList) { showingDetailedFlightList in
                    updateTabVisibility()
                }
                .onChange(of: viewModel.selectedCountryName) { selectedCountryName in
                    updateTabVisibility()
                }
                .onChange(of: isInMainCountryView) { isInMainView in
                    updateTabVisibility()
                }
        .onChange(of: scrollOffset) { newOffset in
            // Collapse when scrolled down more than 50 points and not already collapsed
            let shouldCollapse = newOffset > 50
            
            if shouldCollapse && !isCollapsed {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                    isCollapsed = true
                }
            } else if !shouldCollapse && isCollapsed && newOffset < 20 {
                // Expand when scrolled back up
                withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                    isCollapsed = false
                }
            }
        }
        // ADD: Handle incoming search data from HomeView
        .onReceive(sharedSearchData.$shouldExecuteSearch) { shouldExecute in
            if shouldExecute && sharedSearchData.hasValidSearchData {
                handleIncomingSearchFromHome()
            }
        }
        // NEW: Handle country-to-cities navigation from HomeView
        .onReceive(sharedSearchData.$shouldNavigateToExploreCities) { shouldNavigate in
            if shouldNavigate && !sharedSearchData.selectedCountryId.isEmpty {
                print("🏙️ Received country navigation signal - processing immediately")
                // Process immediately to beat the onAppear delay
                handleIncomingCountryNavigation()
            }
        }
    }
    
    private func updateTabVisibility() {
            // Don't interfere if we're already in search mode from HomeView
            guard !sharedSearchData.isInSearchMode else { return }
            
            DispatchQueue.main.async {
                let shouldShowTabs = isInMainCountryView
                
                // Update tab visibility based on current state
                if shouldShowTabs && sharedSearchData.isInExploreNavigation {
                    // We're back to main country view - show tabs
                    sharedSearchData.isInExploreNavigation = false
                    print("📱 Showing tabs - back to main country view")
                } else if !shouldShowTabs && !sharedSearchData.isInExploreNavigation {
                    // We're in cities/flights/details - hide tabs
                    sharedSearchData.isInExploreNavigation = true
                    print("📱 Hiding tabs - in cities/flights view")
                }
            }
        }
    
    // NEW: Handle country-to-cities navigation from HomeView
    private func handleIncomingCountryNavigation() {
        print("🏙️ ExploreScreen: Received country navigation from HomeView")
        print("🏙️ Country: \(sharedSearchData.selectedCountryName) (ID: \(sharedSearchData.selectedCountryId))")
        
        // IMMEDIATELY set the flag to prevent auto-fetching countries
        isCountryNavigationActive = true
        
        // Reset only the necessary search states (don't clear everything)
        viewModel.isDirectSearch = false
        viewModel.showingDetailedFlightList = false
        viewModel.hasSearchedFlights = false
        viewModel.flightResults = []
        viewModel.detailedFlightResults = []
        viewModel.selectedFlightId = nil
        
        // Set destination to "Anywhere" to show explore mode
        viewModel.toLocation = "Anywhere"
        viewModel.toIataCode = ""
        
        // IMMEDIATELY set up the view model to show cities for the specified country
        viewModel.showingCities = true
        viewModel.selectedCountryName = sharedSearchData.selectedCountryName
        
        // Store the navigation data locally before clearing it from shared store
        let countryId = sharedSearchData.selectedCountryId
        let countryName = sharedSearchData.selectedCountryName
        
        // Clear the shared search data immediately to prevent conflicts
        DispatchQueue.main.async {
            sharedSearchData.shouldNavigateToExploreCities = false
            sharedSearchData.selectedCountryId = ""
            sharedSearchData.selectedCountryName = ""
        }
        
        // Fetch cities for the selected country
        viewModel.fetchCitiesFor(countryId: countryId, countryName: countryName)
        
        // Reset the local flag after cities have loaded and settled
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            isCountryNavigationActive = false
            print("🏙️ Country navigation flag reset")
        }
        
        print("🏙️ ExploreScreen: City navigation initiated successfully")
    }
    
    private func resetExploreViewModelToInitialState() {
        print("🔄 Resetting ExploreViewModel to initial state")
        viewModel.resetToInitialState(preserveCountries: true) // Preserve countries by default
        print("✅ ExploreViewModel reset completed")
    }
    
    // Existing handleIncomingSearchFromHome method remains the same...
    private func handleIncomingSearchFromHome() {
        print("🔥 ExploreScreen: Received search data from HomeView")
        print("🔥 Original selectedTab: \(sharedSearchData.selectedTab)")
        print("🔥 Direct flights only: \(sharedSearchData.directFlightsOnly)")
        
        // Transfer all search data to the view model
        viewModel.fromLocation = sharedSearchData.fromLocation
        viewModel.toLocation = sharedSearchData.toLocation
        viewModel.fromIataCode = sharedSearchData.fromIataCode
        viewModel.toIataCode = sharedSearchData.toIataCode
        viewModel.dates = sharedSearchData.selectedDates
        viewModel.isRoundTrip = sharedSearchData.isRoundTrip
        viewModel.adultsCount = sharedSearchData.adultsCount
        viewModel.childrenCount = sharedSearchData.childrenCount
        viewModel.childrenAges = sharedSearchData.childrenAges
        viewModel.selectedCabinClass = sharedSearchData.selectedCabinClass
        viewModel.multiCityTrips = sharedSearchData.multiCityTrips
        
        // UPDATED: Set selectedTab and isRoundTrip based on shared data
        selectedTab = sharedSearchData.selectedTab
        isRoundTrip = sharedSearchData.isRoundTrip
        
        // Set the selected origin and destination codes
        viewModel.selectedOriginCode = sharedSearchData.fromIataCode
        viewModel.selectedDestinationCode = sharedSearchData.toIataCode
        
        // Mark as direct search to show detailed flight list
        viewModel.isDirectSearch = true
        viewModel.showingDetailedFlightList = true
        
        // Store direct flights preference in view model for later use
        viewModel.directFlightsOnlyFromHome = sharedSearchData.directFlightsOnly
        
        // Handle multi-city vs regular search
        if sharedSearchData.selectedTab == 2 && !sharedSearchData.multiCityTrips.isEmpty {
            print("🔥 Executing multi-city search")
            // Multi-city search
            viewModel.searchMultiCityFlights()
        } else {
            print("🔥 Executing regular search (selectedTab: \(selectedTab))")
            // Regular search - format dates for API
            if !sharedSearchData.selectedDates.isEmpty {
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd"
                
                if sharedSearchData.selectedDates.count >= 2 {
                    let sortedDates = sharedSearchData.selectedDates.sorted()
                    viewModel.selectedDepartureDatee = formatter.string(from: sortedDates[0])
                    viewModel.selectedReturnDatee = formatter.string(from: sortedDates[1])
                } else if sharedSearchData.selectedDates.count == 1 {
                    viewModel.selectedDepartureDatee = formatter.string(from: sharedSearchData.selectedDates[0])
                    if let nextDay = Calendar.current.date(byAdding: .day, value: 1, to: sharedSearchData.selectedDates[0]) {
                        viewModel.selectedReturnDatee = formatter.string(from: nextDay)
                    }
                }
            }
            
            // Initiate the regular search
            viewModel.searchFlightsForDates(
                origin: sharedSearchData.fromIataCode,
                destination: sharedSearchData.toIataCode,
                returnDate: sharedSearchData.isRoundTrip ? viewModel.selectedReturnDatee : "",
                departureDate: viewModel.selectedDepartureDatee,
                isDirectSearch: true
            )
        }
        
        // Reset the shared search data
        sharedSearchData.resetSearch()
        
        print("🔥 ExploreScreen: Search initiated successfully")
    }
    
    // NEW: Helper method to get appropriate explore title
    private func getExploreTitle() -> String {
        if viewModel.toLocation == "Anywhere" {
            return "Explore everywhere"
        } else if viewModel.showingCities {
            return "Explore \(viewModel.selectedCountryName ?? "")"
        } else {
            return "Explore everywhere"
        }
    }
}

// MARK: - Expanded Search Card Component (UPDATED with drag gesture)
struct ExpandedSearchCard: View {
    @ObservedObject var viewModel: ExploreViewModel
    @Binding var selectedTab: Int
    @Binding var isRoundTrip: Bool
    let searchCardNamespace: Namespace.ID
    let handleBackNavigation: () -> Void
    let shouldShowBackButton: Bool
    let onDragCollapse: () -> Void  // ADD: Closure to handle drag collapse
    
    // ADD: Drag gesture state
    @GestureState private var dragOffset: CGFloat = 0
    
    // ADD: Drag Gesture defined locally
    private var dragGesture: some Gesture {
        DragGesture(minimumDistance: 10, coordinateSpace: .global)
            .updating($dragOffset) { value, state, _ in
                state = value.translation.height
            }
            .onEnded { value in
                if value.translation.height < -20 {
                    onDragCollapse()
                }
            }
    }
    
    var body: some View {
        VStack {
            VStack(spacing: 0) {
                HStack {
                    // Back button
                    if shouldShowBackButton{
                        Button(action: handleBackNavigation) {
                            Image(systemName: "chevron.left")
                                .foregroundColor(.primary)
                                .font(.system(size: 18, weight: .semibold))
                        }
                        .matchedGeometryEffect(id: "backButton", in: searchCardNamespace)
                    }
                    
                    Spacer()
                    
                    // Centered trip type tabs with more balanced width
                    TripTypeTabView(selectedTab: $selectedTab, isRoundTrip: $isRoundTrip, viewModel: viewModel)
                        .frame(width: UIScreen.main.bounds.width * 0.55)
                        .matchedGeometryEffect(id: "tripTabs", in: searchCardNamespace)
                    
                    Spacer()
                    
                    // ADD: Invisible spacer to balance layout when back button is hidden
                    if !shouldShowBackButton {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.clear)
                            .font(.system(size: 18, weight: .semibold))
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
                .padding(.top, 5)
                
                // Search card with dynamic values
                SearchCard(viewModel: viewModel, isRoundTrip: $isRoundTrip, selectedTab: selectedTab)
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                    .matchedGeometryEffect(id: "searchContent", in: searchCardNamespace)
            }
            .background(
                ZStack {
                    // Background fill
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.systemBackground))
                        .matchedGeometryEffect(id: "cardBackground", in: searchCardNamespace)
                    
                    // Animated or static stroke based on loading state
                    // In your search card components, update the loading border condition:
                    if viewModel.isLoading ||
                       viewModel.isLoadingFlights ||
                       viewModel.isLoadingDetailedFlights ||
                       (viewModel.showingDetailedFlightList && viewModel.detailedFlightResults.isEmpty && viewModel.detailedFlightError == nil) {
                        LoadingBorderView()
                    } else {
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.orange, lineWidth: 2)
                    }
                }
            )
            .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 4)
            .padding()
            .gesture(dragGesture)  // MOVED: Apply drag gesture to entire search card area
        }
        .background(
            GeometryReader { geo in
                VStack(spacing: 0) {
                    Color("searchcardBackground")
                        .frame(height: geo.size.height)
                    Color("scroll")
                }
                .edgesIgnoringSafeArea(.all)
            }
        )
    }
}

// MARK: - Collapsed Search Card Component (with passenger count)

struct CollapsedSearchCard: View {
    @ObservedObject var viewModel: ExploreViewModel
    let searchCardNamespace: Namespace.ID
    let onTap: () -> Void
    let handleBackNavigation: () -> Void
    let shouldShowBackButton: Bool
    
    // Helper method to format date for display
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM"
        return formatter.string(from: date)
    }
    
    // UPDATED: Better display logic for collapsed state
    private func getLocationDisplayText() -> String {
        let fromText = viewModel.fromLocation.isEmpty || viewModel.fromLocation == "Mumbai" ? "From" : viewModel.fromLocation
        let toText = viewModel.toLocation == "Anywhere" || viewModel.toLocation.isEmpty ? "Anywhere" : viewModel.toLocation
        return "\(fromText) → \(toText)"
    }
    
    private func getDateDisplayText() -> String {
        // If we just cleared the form, show "Anytime"
        if viewModel.dates.isEmpty && viewModel.selectedDepartureDatee.isEmpty {
            return "Anytime"
        }
        
        if viewModel.dates.isEmpty && viewModel.hasSearchedFlights && !viewModel.flightResults.isEmpty {
            return "Anytime"
        } else if viewModel.dates.isEmpty {
            return "Anytime"
        } else if viewModel.dates.count == 1 {
            return formatDate(viewModel.dates[0])
        } else if viewModel.dates.count >= 2 {
            return "\(formatDate(viewModel.dates[0])) - \(formatDate(viewModel.dates[1]))"
        }
        return "Anytime"
    }
    
    // ADD: Passenger display text for collapsed state
    private func getPassengerDisplayText() -> String {
        let totalPassengers = viewModel.adultsCount + viewModel.childrenCount
        return "\(totalPassengers)"
    }
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 0) {
                HStack {
                    // Back button
                    if shouldShowBackButton{
                        Button(action: handleBackNavigation) {
                            Image(systemName: "chevron.left")
                                .foregroundColor(.primary)
                                .font(.system(size: 18, weight: .semibold))
                        }
                        .matchedGeometryEffect(id: "backButton", in: searchCardNamespace)
                    }
                    
                    Spacer()
                    
                    // Compact trip info - UPDATED with passenger count
                    HStack(spacing: 8) {
                        Text(getLocationDisplayText())
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.primary)
                        
                        Circle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 4, height: 4)
                        
                        // Date display
                        Text(getDateDisplayText())
                            .foregroundColor(.primary)
                            .font(.system(size: 14, weight: .medium))
                        
                        // ADD: Passenger count after date
                        Circle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 4, height: 4)
                        
                        HStack {
                            Image(systemName: "person.fill")
                                .foregroundColor(.black)
                            Text(getPassengerDisplayText())
                                .foregroundColor(.primary)
                                .font(.system(size: 14, weight: .medium))
                        }
                    }
                    .matchedGeometryEffect(id: "searchContent", in: searchCardNamespace)
                    
                    Spacer()
                    
                    // ADD: Invisible spacer to balance layout when back button is hidden
                                        if !shouldShowBackButton {
                                            Image(systemName: "chevron.left")
                                                .foregroundColor(.clear)
                                                .font(.system(size: 18, weight: .semibold))
                                        }
                    
                }
                .padding(.horizontal)
                .padding(.vertical, 12)
                .padding(.top, 5)
            }
            
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemBackground))
                    .matchedGeometryEffect(id: "cardBackground", in: searchCardNamespace)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.orange, lineWidth: 1)
                    )
            )
            .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 4)
            .padding()
        }
        .buttonStyle(PlainButtonStyle())
        .background(Color("searchcardBackground"))
    }
}

// MARK: - Custom ScrollView with Offset Detection
struct ScrollViewWithOffset<Content: View>: View {
    @Binding var offset: CGFloat
    let content: () -> Content
    
    var body: some View {
        ScrollView {
            GeometryReader { geometry in
                Color.clear
                    .preference(key: ScrollOffsetPreferenceKey.self,
                              value: geometry.frame(in: .named("scrollView")).minY)
            }
            .frame(height: 0)
            
            content()
        }
        .coordinateSpace(name: "scrollView")
        .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
            offset = -value
        }
    }
}

// MARK: - Preference Key for Scroll Offset
struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}




// MARK: - Search Card Component (Updated with Conditional Multi-City)
struct SearchCard: View {
    @ObservedObject var viewModel: ExploreViewModel
    @State private var showingSearchSheet = false
    @State private var initialFocus: LocationSearchSheet.SearchBarType = .origin
    @State private var showingCalendar = false
    
    // ADD: State for swap animation
    @State private var swapRotationDegrees: Double = 0
    
    @Binding var isRoundTrip: Bool
    
    var selectedTab: Int
    
    // ADD: Observe shared search data
    @StateObject private var sharedSearchData = SharedSearchDataStore.shared
    
    // Determine if multi-city should be shown
    private var shouldShowMultiCity: Bool {
        return sharedSearchData.isInSearchMode && sharedSearchData.selectedTab == 2 && selectedTab == 2
    }
    
    var body: some View {
        // Conditionally show multi-city or regular interface
        if shouldShowMultiCity {
            // Multi-city search card - only show when came from direct multi-city search
            MultiCitySearchCard(viewModel: viewModel)
        } else {
            // Regular interface for return/one-way trips
            VStack(spacing: 5) {
                Divider()
                    .padding(.horizontal,-16)
                // From row
                HStack {
                    Button(action: {
                        initialFocus = .origin
                        showingSearchSheet = true
                    }) {
                        Image(systemName: "airplane.departure")
                            .foregroundColor(.primary)
                        Text(getFromLocationDisplayText())
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(getFromLocationTextColor())
                    }
                    
                    Spacer()
                    
                    // Animated swap button
                    Button(action: {
                        animatedSwapLocations()
                    }) {
                        ZStack {
                            Circle()
                                .stroke(Color.gray.opacity(0.4), lineWidth: 1)
                                .frame(width: 20, height: 20)
                            Image(systemName: "arrow.left.arrow.right")
                                .fontWeight(.bold)
                                .foregroundColor(.blue)
                                .font(.system(size: 8))
                                .rotationEffect(.degrees(swapRotationDegrees))
                                .animation(.easeInOut(duration: 0.6), value: swapRotationDegrees)
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    Spacer()
                    
                    Button(action: {
                        initialFocus = .destination
                        showingSearchSheet = true
                    }) {
                        HStack {
                            Image(systemName: "airplane.arrival")
                                .foregroundColor(.primary)
                            
                            Text(getToLocationDisplayText())
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(getToLocationTextColor())
                        }
                    }
                }
                .padding(4)
                
                Divider()
                    .padding(.horizontal,-16)
                
                // Date and passengers row
                HStack {
                    Button(action: {
                        // Only show calendar if destination is not "Anywhere"
                        if viewModel.toLocation == "Anywhere" {
                            handleAnywhereDestination()
                        } else {
                            showingCalendar = true
                        }
                    }){
                        Image(systemName: "calendar")
                            .foregroundColor(.primary)
                      
                        Text(getDateDisplayText())
                            .foregroundColor(getDateTextColor())
                            .font(.system(size: 14, weight: .medium))
                    }
                    
                    Spacer()
                    
                    // Passenger selection button
                    Button(action: {
                        viewModel.showingPassengersSheet = true
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "person.fill")
                                .foregroundColor(.black)
                            
                            Text("\(viewModel.adultsCount + viewModel.childrenCount), \(viewModel.selectedCabinClass)")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.black)
                        }
                    }
                }
                .padding(.vertical, 4)
                .padding(.horizontal,4)
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
                CalendarView(
                    fromiatacode: $viewModel.fromIataCode,
                    toiatacode: $viewModel.toIataCode,
                    parentSelectedDates: $viewModel.dates,
                    onAnytimeSelection: { results in
                        viewModel.handleAnytimeResults(results)
                    },
                    onTripTypeChange: { newIsRoundTrip in
                        isRoundTrip = newIsRoundTrip
                        viewModel.isRoundTrip = newIsRoundTrip
                    },
                    isRoundTrip: isRoundTrip
                )
            }
            .sheet(isPresented: $viewModel.showingPassengersSheet, onDismiss: {
                triggerSearchAfterPassengerChange()
            }) {
                PassengersAndClassSelector(
                    adultsCount: $viewModel.adultsCount,
                    childrenCount: $viewModel.childrenCount,
                    selectedClass: $viewModel.selectedCabinClass,
                    childrenAges: $viewModel.childrenAges
                )
            }
            .onAppear {
                viewModel.isRoundTrip = isRoundTrip
            }
            .onChange(of: isRoundTrip) { newValue in
                viewModel.isRoundTrip = newValue
                viewModel.handleTripTypeChange()
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func animatedSwapLocations() {
        // Only allow swap if both locations are set and not "Anywhere"
        guard !viewModel.fromIataCode.isEmpty && !viewModel.toIataCode.isEmpty,
              viewModel.toLocation != "Anywhere" else {
            return
        }
        
        // Animate 360 degrees rotation
        withAnimation(.easeInOut(duration: 0.6)) {
            swapRotationDegrees += 360
        }

        // Delay swap logic to align with animation duration
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            // Store original values before swapping
            let originalFromLocation = viewModel.fromLocation
            let originalFromCode = viewModel.fromIataCode
            let originalToLocation = viewModel.toLocation
            let originalToCode = viewModel.toIataCode
            
            // Perform swap
            viewModel.fromLocation = originalToLocation
            viewModel.fromIataCode = originalToCode
            viewModel.toLocation = originalFromLocation
            viewModel.toIataCode = originalFromCode
            
            // Update search context with swapped values
            viewModel.selectedOriginCode = viewModel.fromIataCode
            viewModel.selectedDestinationCode = viewModel.toIataCode
            
            // Clear existing results before new search
            viewModel.detailedFlightResults = []
            viewModel.flightResults = []
            
            // Trigger refetch based on current context
            if viewModel.showingDetailedFlightList {
                print("🔄 Swapping and refetching detailed flights: \(viewModel.fromIataCode) → \(viewModel.toIataCode)")
                
                viewModel.searchFlightsForDates(
                    origin: viewModel.fromIataCode,
                    destination: viewModel.toIataCode,
                    returnDate: viewModel.isRoundTrip ? viewModel.selectedReturnDatee : "",
                    departureDate: viewModel.selectedDepartureDatee,
                    isDirectSearch: viewModel.isDirectSearch
                )
            } else if viewModel.hasSearchedFlights {
                print("🔄 Swapping and refetching basic flights: \(viewModel.fromIataCode) → \(viewModel.toIataCode)")
                
                if let selectedCity = viewModel.selectedCity {
                    viewModel.fetchFlightDetails(destination: viewModel.toIataCode)
                } else {
                    viewModel.searchFlightsForDates(
                        origin: viewModel.fromIataCode,
                        destination: viewModel.toIataCode,
                        returnDate: viewModel.isRoundTrip ? viewModel.selectedReturnDatee : "",
                        departureDate: viewModel.selectedDepartureDatee,
                        isDirectSearch: true
                    )
                }
            } else if !viewModel.dates.isEmpty {
                print("🔄 Swapping and starting new search with dates: \(viewModel.fromIataCode) → \(viewModel.toIataCode)")
                
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd"
                
                if viewModel.dates.count >= 2 {
                    let sortedDates = viewModel.dates.sorted()
                    viewModel.selectedDepartureDatee = formatter.string(from: sortedDates[0])
                    viewModel.selectedReturnDatee = formatter.string(from: sortedDates[1])
                } else if viewModel.dates.count == 1 {
                    viewModel.selectedDepartureDatee = formatter.string(from: viewModel.dates[0])
                    if let nextDay = Calendar.current.date(byAdding: .day, value: 1, to: viewModel.dates[0]) {
                        viewModel.selectedReturnDatee = formatter.string(from: nextDay)
                    }
                }
                
                viewModel.searchFlightsForDates(
                    origin: viewModel.fromIataCode,
                    destination: viewModel.toIataCode,
                    returnDate: viewModel.isRoundTrip ? viewModel.selectedReturnDatee : "",
                    departureDate: viewModel.selectedDepartureDatee,
                    isDirectSearch: true
                )
            } else {
                print("🔄 Swapping with default dates: \(viewModel.fromIataCode) → \(viewModel.toIataCode)")
                
                let calendar = Calendar.current
                let tomorrow = calendar.date(byAdding: .day, value: 1, to: Date()) ?? Date()
                let dayAfterTomorrow = calendar.date(byAdding: .day, value: 7, to: Date()) ?? Date()
                
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd"
                
                viewModel.selectedDepartureDatee = formatter.string(from: tomorrow)
                viewModel.selectedReturnDatee = formatter.string(from: dayAfterTomorrow)
                
                viewModel.dates = viewModel.isRoundTrip ? [tomorrow, dayAfterTomorrow] : [tomorrow]
                
                viewModel.searchFlightsForDates(
                    origin: viewModel.fromIataCode,
                    destination: viewModel.toIataCode,
                    returnDate: viewModel.isRoundTrip ? viewModel.selectedReturnDatee : "",
                    departureDate: viewModel.selectedDepartureDatee,
                    isDirectSearch: true
                )
            }
            
            print("✅ Swap completed and refetch initiated")
        }
    }

    private func getFromLocationDisplayText() -> String {
        if viewModel.fromIataCode.isEmpty {
            return "DEL Delhi"
        }
        return "\(viewModel.fromIataCode) \(viewModel.fromLocation)"
    }

    private func getFromLocationTextColor() -> Color {
        return .primary
    }

    private func getToLocationDisplayText() -> String {
        if viewModel.toIataCode.isEmpty {
            return viewModel.toLocation
        }
        return "\(viewModel.toIataCode) \(viewModel.toLocation)"
    }

    private func getToLocationTextColor() -> Color {
        return .primary
    }
        
    private func getDateDisplayText() -> String {
        if viewModel.dates.isEmpty && viewModel.selectedDepartureDatee.isEmpty {
            return "Anytime"
        }
        
        if viewModel.toLocation == "Anywhere" {
            return "Anytime"
        } else if viewModel.dates.isEmpty && viewModel.hasSearchedFlights && !viewModel.flightResults.isEmpty {
            return "Anytime"
        } else if viewModel.dates.isEmpty {
            return "Anytime"
        } else if viewModel.dates.count == 1 {
            return formatDate(viewModel.dates[0])
        } else if viewModel.dates.count >= 2 {
            return "\(formatDate(viewModel.dates[0])) - \(formatDate(viewModel.dates[1]))"
        }
        
        return "Anytime"
    }
    
    private func getDateTextColor() -> Color {
        if viewModel.dates.isEmpty || viewModel.toLocation == "Anywhere" {
            return .gray
        }
        return .primary
    }
    
    private func handleAnywhereDestination() {
        viewModel.goBackToCountries()
        viewModel.toLocation = "Anywhere"
        viewModel.toIataCode = ""
        viewModel.hasSearchedFlights = false
        viewModel.showingDetailedFlightList = false
        viewModel.flightResults = []
        viewModel.detailedFlightResults = []
    }
    
    private func triggerSearchAfterPassengerChange() {
        if viewModel.toLocation != "Anywhere" {
            if !viewModel.selectedOriginCode.isEmpty && !viewModel.selectedDestinationCode.isEmpty {
                viewModel.detailedFlightResults = []
                
                viewModel.searchFlightsForDates(
                    origin: viewModel.selectedOriginCode,
                    destination: viewModel.selectedDestinationCode,
                    returnDate: viewModel.isRoundTrip ? viewModel.selectedReturnDatee : "",
                    departureDate: viewModel.selectedDepartureDatee
                )
            }
            else if let city = viewModel.selectedCity {
                viewModel.fetchFlightDetails(destination: city.location.iata)
            }
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM"
        return formatter.string(from: date)
    }
}



// MARK: - Flight Result Card
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
    
    // Helper function to check if we should hide the card
    private var shouldHideCard: Bool {
        let currentDate = Date()
        let calendar = Calendar.current
        let currentHour = calendar.component(.hour, from: currentDate)
        
        // Check if current time is after 7 PM (19:00)
        guard currentHour >= 19 else { return false }
        
        // Parse the departure date string
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE, d MMM yyyy"
        
        guard let flightDate = formatter.date(from: departureDate) else { return false }
        
        // Check if the flight date is today
        return calendar.isDate(flightDate, inSameDayAs: currentDate)
    }
    
    var body: some View {
        // If we should hide the card, return empty view
        if shouldHideCard {
            EmptyView()
        } else {
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
                            .background(Color.orange)
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
        
        // FIXED: Ensure proper context is set for trip type changes
        viewModel.selectedOriginCode = origin
        viewModel.selectedDestinationCode = destination
        viewModel.fromIataCode = origin
        viewModel.toIataCode = destination
        
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
        
        // FIXED: Mark as direct search to ensure proper handling
        viewModel.isDirectSearch = true
        
        // Then call the search function with these dates
        viewModel.searchFlightsForDates(
            origin: origin,
            destination: destination,
            returnDate: viewModel.isRoundTrip ? formattedCardReturnDate : "",
            departureDate: formattedCardDepartureDate,
            isDirectSearch: true // Mark as direct search
        )
    }
}

// MARK: - API Destination Card
struct APIDestinationCard: View {
    @State private var cardScale: CGFloat = 1.0  // Start at normal scale
    @State private var isPressed = false
    let item: ExploreDestination
    let viewModel: ExploreViewModel
    let onTap: () -> Void
    
    var body: some View {
        Button(action: {
            // Press feedback
            let impactFeedback = UIImpactFeedbackGenerator(style: .light)
            impactFeedback.impactOccurred()
            
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                cardScale = 0.96
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    cardScale = 1.0
                }
                onTap()
            }
        }) {
            HStack(spacing: 12) {
                // OPTIMIZED AsyncImage with better caching and immediate placeholders
                CachedAsyncImage(
                                    url: URL(string: "https://image.explore.lascadian.com/\(viewModel.showingCities ? "city" : "country")_\(item.location.entityId).webp")
                                ) { image in
                                    image
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 80, height: 80)
                                        .clipped()
                                        .cornerRadius(8)
                                                                        } placeholder: {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(Color.gray.opacity(0.15))
                                            .frame(width: 80, height: 80)
                                        
                                        VStack(spacing: 3) {
                                            Image(systemName: viewModel.showingCities ? "building.2" : "globe")
                                                .font(.system(size: 22))
                                                .foregroundColor(.gray.opacity(0.7))
                                            
                                            Text(String(item.location.name.prefix(3)).uppercased())
                                                .font(.system(size: 10, weight: .semibold))
                                                .foregroundColor(.gray.opacity(0.8))
                                        }
                                    }
                                }
                // Content text
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
                
                Text(viewModel.formatPrice(item.price))
                    .font(.system(size: 20, weight: .bold))
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(cardScale)
        // REMOVED: All slide-in animations (opacity, offset, cardAppeared state)
        .shadow(color: Color.black.opacity(isPressed ? 0.15 : 0.05), radius: isPressed ? 8 : 4, x: 0, y: isPressed ? 4 : 2)
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: isPressed) // Only animate press state
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                isPressed = pressing
            }
        }, perform: {})
    }
}

class ImageCacheManager: ObservableObject {
    static let shared = ImageCacheManager()
    
    private let memoryCache = NSCache<NSString, UIImage>()
    private let fileManager = FileManager.default
    private let cacheDirectory: URL
    
    private init() {
        // Configure memory cache
        memoryCache.countLimit = 100 // Max 100 images in memory
        memoryCache.totalCostLimit = 50 * 1024 * 1024 // 50MB memory limit
        
        // Set up disk cache directory
        let cachesDirectory = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first!
        cacheDirectory = cachesDirectory.appendingPathComponent("ImageCache")
        
        // Create cache directory if it doesn't exist
        try? fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
        
        // Clean old cache on startup
        cleanOldCache()
    }
    
    private func cacheKey(for url: URL) -> String {
        return url.absoluteString.data(using: .utf8)?.base64EncodedString() ?? url.absoluteString
    }
    
    private func diskCacheURL(for key: String) -> URL {
        return cacheDirectory.appendingPathComponent(key)
    }
    
    // MARK: - Cache Operations
    
    func cachedImage(for url: URL) -> UIImage? {
        let key = cacheKey(for: url)
        
        // Check memory cache first
        if let memoryImage = memoryCache.object(forKey: NSString(string: key)) {
            return memoryImage
        }
        
        // Check disk cache
        let diskURL = diskCacheURL(for: key)
        if fileManager.fileExists(atPath: diskURL.path),
           let data = try? Data(contentsOf: diskURL),
           let image = UIImage(data: data) {
            
            // Store in memory cache for next time
            memoryCache.setObject(image, forKey: NSString(string: key))
            return image
        }
        
        return nil
    }
    
    func cache(image: UIImage, for url: URL) {
        let key = cacheKey(for: url)
        
        // Store in memory cache
        memoryCache.setObject(image, forKey: NSString(string: key))
        
        // Store in disk cache
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let self = self,
                  let data = image.jpegData(compressionQuality: 0.8) else { return }
            
            let diskURL = self.diskCacheURL(for: key)
            try? data.write(to: diskURL)
        }
    }
    
    func loadImage(from url: URL) -> AnyPublisher<UIImage, Error> {
        // Check cache first
        if let cachedImage = cachedImage(for: url) {
            return Just(cachedImage)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
        
        // Download and cache
        return URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .tryMap { data -> UIImage in
                guard let image = UIImage(data: data) else {
                    throw URLError(.badServerResponse)
                }
                return image
            }
            .handleEvents(receiveOutput: { [weak self] image in
                self?.cache(image: image, for: url)
            })
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    // MARK: - Cache Management
    
    private func cleanOldCache() {
        DispatchQueue.global(qos: .utility).async { [weak self] in
            guard let self = self else { return }
            
            let oneWeekAgo = Date().addingTimeInterval(-7 * 24 * 60 * 60)
            
            do {
                let contents = try self.fileManager.contentsOfDirectory(at: self.cacheDirectory, includingPropertiesForKeys: [.contentModificationDateKey])
                
                for fileURL in contents {
                    let attributes = try self.fileManager.attributesOfItem(atPath: fileURL.path)
                    if let modificationDate = attributes[.modificationDate] as? Date,
                       modificationDate < oneWeekAgo {
                        try self.fileManager.removeItem(at: fileURL)
                    }
                }
            } catch {
                print("Error cleaning cache: \(error)")
            }
        }
    }
    
    func clearCache() {
        memoryCache.removeAllObjects()
        
        DispatchQueue.global(qos: .utility).async { [weak self] in
            guard let self = self else { return }
            try? self.fileManager.removeItem(at: self.cacheDirectory)
            try? self.fileManager.createDirectory(at: self.cacheDirectory, withIntermediateDirectories: true)
        }
    }
}

// MARK: - Cached AsyncImage View
struct CachedAsyncImage<Content: View, Placeholder: View>: View {
    let url: URL?
    let content: (Image) -> Content
    let placeholder: () -> Placeholder
    
    @StateObject private var cacheManager = ImageCacheManager.shared
    @State private var image: UIImage?
    @State private var isLoading = false
    @State private var cancellable: AnyCancellable?
    
    init(
        url: URL?,
        @ViewBuilder content: @escaping (Image) -> Content,
        @ViewBuilder placeholder: @escaping () -> Placeholder
    ) {
        self.url = url
        self.content = content
        self.placeholder = placeholder
    }
    
    var body: some View {
        Group {
            if let uiImage = image {
                content(Image(uiImage: uiImage))
            } else {
                placeholder()
                    .onAppear {
                        loadImage()
                    }
            }
        }
    }
    
    private func loadImage() {
        guard let url = url, !isLoading else { return }
        
        // Check if already cached
        if let cachedImage = cacheManager.cachedImage(for: url) {
            self.image = cachedImage
            return
        }
        
        isLoading = true
        
        cancellable = cacheManager.loadImage(from: url)
            .sink(
                receiveCompletion: { _ in
                    isLoading = false
                },
                receiveValue: { downloadedImage in
                    image = downloadedImage
                    isLoading = false
                }
            )
    }
}

// MARK: - Convenience Initializers
extension CachedAsyncImage where Content == Image, Placeholder == Color {
    init(url: URL?) {
        self.init(
            url: url,
            content: { image in image },
            placeholder: { Color.gray.opacity(0.15) }
        )
    }
}

extension CachedAsyncImage where Placeholder == Color {
    init(url: URL?, @ViewBuilder content: @escaping (Image) -> Content) {
        self.init(
            url: url,
            content: content,
            placeholder: { Color.gray.opacity(0.15) }
        )
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


// MARK: - Updated TripTypeTabView with Conditional Multi-City Display
struct TripTypeTabView: View {
    @Binding var selectedTab: Int
    @Binding var isRoundTrip: Bool
    @ObservedObject var viewModel: ExploreViewModel
    
    // ADD: Observe shared search data to determine if multi-city should be shown
    @StateObject private var sharedSearchData = SharedSearchDataStore.shared
    
    // Conditional tabs based on search mode and original search type
    private var availableTabs: [String] {
        // Only show multi-city if user came from direct search AND original search was multi-city
        if sharedSearchData.isInSearchMode && sharedSearchData.selectedTab == 2 {
            return ["Return", "One way", "Multi city"]
        } else {
            return ["Return", "One way"]
        }
    }
    
    // Calculate dimensions based on available tabs
    private var totalWidth: CGFloat {
        return UIScreen.main.bounds.width * 0.6
    }
    
    private var tabWidth: CGFloat {
        return totalWidth / CGFloat(availableTabs.count)
    }
    
    private var rightShift: CGFloat {
        return 5
    }
    
    // MARK: - Targeted Loading State Check
    private var isLoadingInDetailedView: Bool {
        return viewModel.showingDetailedFlightList &&
               (viewModel.isLoadingDetailedFlights ||
                (viewModel.detailedFlightResults.isEmpty && viewModel.isLoadingDetailedFlights))
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
                .frame(width: tabWidth - 10)
                .offset(x: (CGFloat(selectedTab) * tabWidth) + rightShift)
                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: selectedTab)
            
            // Tab buttons row with conditional tabs
            HStack(spacing: 0) {
                ForEach(0..<availableTabs.count, id: \.self) { index in
                    Button(action: {
                        // TARGETED SAFETY CHECK: Only block changes in ModifiedDetailedFlightListView during loading
                        if isLoadingInDetailedView {
                            print("Trip type change blocked - skeleton loading in detailed flight view")
                            return
                        }
                        
                        selectedTab = index
                        
                        // Handle multi-city selection (only if available)
                        if index == 2 && availableTabs.count > 2 {
                            // Initialize multi city trips
                            viewModel.initializeMultiCityTrips()
                        } else {
                            // Handle return/one-way trip types
                            let newIsRoundTrip = (index == 0)
                            
                            if isRoundTrip != newIsRoundTrip {
                                // Update the trip type
                                isRoundTrip = newIsRoundTrip
                                viewModel.isRoundTrip = newIsRoundTrip
                                
                                // Call the centralized method
                                viewModel.handleTripTypeChange()
                            }
                        }
                    }) {
                        Text(availableTabs[index])
                            .font(.system(size: 13, weight: selectedTab == index ? .semibold : .regular))
                            .foregroundColor(
                                isLoadingInDetailedView ? .gray.opacity(0.5) : (selectedTab == index ? .blue : .black)
                            )
                            .frame(width: tabWidth)
                            .padding(.vertical, 8)
                    }
                    .disabled(isLoadingInDetailedView)
                }
            }
            .onChange(of: isRoundTrip) { newValue in
                // Update selectedTab to match the trip type only if not loading in detailed view
                if !isLoadingInDetailedView {
                    selectedTab = newValue ? 0 : 1 // 0 for "Return", 1 for "One way"
                }
            }
        }
        .frame(width: totalWidth, height: 36)
        .padding(.horizontal, 4)
        .opacity(isLoadingInDetailedView ? 0.6 : 1.0)
        .onReceive(sharedSearchData.$isInSearchMode) { _ in
            // Reset selectedTab when search mode changes and multi-city is not available
            if !sharedSearchData.isInSearchMode || sharedSearchData.selectedTab != 2 {
                if selectedTab >= availableTabs.count {
                    selectedTab = 0 // Reset to "Return" if current tab is not available
                }
            }
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

struct MultiCitySearchCard: View {
    @ObservedObject var viewModel: ExploreViewModel
    @State private var showingSearchSheet = false
    @State private var initialFocus: LocationSearchSheet.SearchBarType = .origin
    @State private var showingCalendar = false
    @State private var editingTripIndex: Int = 0
    
    var body: some View {
        VStack(spacing: 0) {
            // Multi-city trips grid
            VStack(spacing: 0) {
                ForEach(0..<viewModel.multiCityTrips.count, id: \.self) { index in
                    multiCityTripRow(for: index)
                    
                    // Add divider between rows (except for last row)
                    if index < viewModel.multiCityTrips.count - 1 {
                        Divider()
                            .padding(.horizontal, 16)
                    }
                }
            }
            
            // Bottom section with passenger info and add flight
            VStack(spacing: 0) {
                Divider()
                    .padding(.horizontal, 16)
                
                HStack {
                    // Passenger info button
                    Button(action: {
                        // Handle passenger selection
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: "person.fill")
                                .foregroundColor(.primary)
                                .font(.system(size: 16))
                            
                            Text(getPassengerDisplayText())
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.primary)
                        }
                    }
                    
                    Spacer()
                    
                    // Add flight button
                    Button(action: {
                        addNewTrip()
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: "plus")
                                .foregroundColor(.blue)
                                .font(.system(size: 16, weight: .medium))
                            
                            Text("Add flight")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.blue)
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }
        }
        .sheet(isPresented: $showingSearchSheet) {
            LocationSearchSheet(
                viewModel: viewModel,
                initialFocus: initialFocus,
             
            )
        }
        .sheet(isPresented: $showingCalendar) {
            CalendarView(
                fromiatacode: .constant(viewModel.multiCityTrips[editingTripIndex].fromIataCode),
                toiatacode: .constant(viewModel.multiCityTrips[editingTripIndex].toIataCode),
                parentSelectedDates: .constant([viewModel.multiCityTrips[editingTripIndex].date]),
                onAnytimeSelection: { _ in },
                onTripTypeChange: { _ in },
                isRoundTrip: false
            )
        }
    }
    
    // MARK: - Individual Trip Row
    @ViewBuilder
    private func multiCityTripRow(for index: Int) -> some View {
        let trip = viewModel.multiCityTrips[index]
        
        HStack(spacing: 12) {
            // Origin and Destination section
            HStack(spacing: 8) {
                // From location
                Button(action: {
                    editingTripIndex = index
                    initialFocus = .origin
                    showingSearchSheet = true
                }) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(trip.fromIataCode.isEmpty ? "COK" : trip.fromIataCode)
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.primary)
                        
                        Text(trip.fromLocation.isEmpty ? "From" : trip.fromLocation)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.gray)
                            .lineLimit(1)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                // Arrow or connector
                Image(systemName: "arrow.right")
                    .foregroundColor(.gray)
                    .font(.system(size: 12))
                
                // To location
                Button(action: {
                    editingTripIndex = index
                    initialFocus = .destination
                    showingSearchSheet = true
                }) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(trip.toIataCode.isEmpty ? "DXB" : trip.toIataCode)
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.primary)
                        
                        Text(trip.toLocation.isEmpty ? "To" : trip.toLocation)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.gray)
                            .lineLimit(1)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(maxWidth: .infinity)
            
            Spacer()
            
            // Date section
            Button(action: {
                editingTripIndex = index
                showingCalendar = true
            }) {
                Text(formatTripDate(trip.date))
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.primary)
                    .frame(minWidth: 80, alignment: .leading)
            }
            
            // Delete button
            if viewModel.multiCityTrips.count > 2 {
                Button(action: {
                    removeTrip(at: index)
                }) {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                        .font(.system(size: 16))
                        .frame(width: 24, height: 24)
                }
            } else {
                // Invisible spacer to maintain layout
                Spacer()
                    .frame(width: 24, height: 24)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
    
    // MARK: - Helper Methods
    private func getPassengerDisplayText() -> String {
        let adults = viewModel.adultsCount
        let children = viewModel.childrenCount
        let totalPassengers = adults + children
        
        if totalPassengers == 1 {
            return "1, Economy"
        } else if children == 0 {
            return "\(adults), Economy"
        } else {
            return "\(totalPassengers), Economy"
        }
    }
    
    private func formatTripDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "E, d MMM"
        return formatter.string(from: date)
    }
    
    private func addNewTrip() {
        guard viewModel.multiCityTrips.count < 5 else { return }
        
        let lastTrip = viewModel.multiCityTrips.last!
        let nextDay = Calendar.current.date(byAdding: .day, value: 1, to: lastTrip.date) ?? Date()
        
        let newTrip = MultiCityTrip(
            fromLocation: lastTrip.toLocation,
            fromIataCode: lastTrip.toIataCode,
            toLocation: "To",
            toIataCode: "",
            date: nextDay
        )
        
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
            viewModel.multiCityTrips.append(newTrip)
        }
    }
    
    private func removeTrip(at index: Int) {
        guard viewModel.multiCityTrips.count > 2,
              index < viewModel.multiCityTrips.count else { return }
        
        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
            viewModel.multiCityTrips.remove(at: index)
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


// MARK: - Updated Loading Border View with Rotating Gradient Segments
struct LoadingBorderView: View {
    @State private var rotationAngle: Double = 0
    
    var body: some View {
        ZStack {
            // Base stroke
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.orange.opacity(0.3), lineWidth: 3.0)
            
            // Continuous rotating gradient border
            RoundedRectangle(cornerRadius: 12)
                .stroke(
                    AngularGradient(
                        gradient: Gradient(stops: [
                            .init(color: Color.orange, location: 0.0),
                            .init(color: Color.orange, location: 0.2),
                            .init(color: Color.orange.opacity(0.1), location: 0.5),
                            .init(color: Color.clear, location: 0.7)
                        ]),
                        center: .center,
                        startAngle: .degrees(rotationAngle),
                        endAngle: .degrees(rotationAngle + 360)
                    ),
                    lineWidth: 3.0
                )
        }
        .onAppear {
            withAnimation(.linear(duration: 6.0).repeatForever(autoreverses: false)) {
                rotationAngle = 360
            }
        }
    }
}



// MARK: - Enhanced Skeleton Destination Card
struct SkeletonDestinationCard: View {
    var body: some View {
        EnhancedSkeletonDestinationCard()
    }
}


// MARK: - Enhanced Skeleton Flight Result Card
struct SkeletonFlightResultCard: View {
    var body: some View {
        EnhancedSkeletonFlightResultCard()
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



// MARK: - Modified LocationSearchSheet with "Anywhere" option

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
    
    // MODIFIED: Updated results view to include "Anywhere" option for destination
    private func resultsView() -> some View {
        Group {
            if isSearching {
                searchingView()
            } else if let error = searchError {
                // Make the error more visible to the user
                Text(error)
                    .foregroundColor(.red)
                    .padding()
                    .background(Color.red.opacity(0.1))
                    .cornerRadius(8)
                    .padding()
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
    
    private func noResultsView() -> some View {
        Text("No results found")
            .foregroundColor(.gray)
            .padding()
    }
    
    // MODIFIED: Updated results list to include "Anywhere" option
    private func resultsList() -> some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                // Show "Anywhere" option only for destination search
                if activeSearchBar == .destination {
                    AnywhereOptionRow()
                        .onTapGesture {
                            handleAnywhereSelection()
                        }
                    
                    // Add a divider after "Anywhere" option if there are other results
                    if !results.isEmpty {
                        Divider()
                            .padding(.horizontal)
                    }
                }
                
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
    
    // NEW: Handle "Anywhere" selection
    private func handleAnywhereSelection() {
        if multiCityMode {
            viewModel.multiCityTrips[multiCityTripIndex].toLocation = "Anywhere"
            viewModel.multiCityTrips[multiCityTripIndex].toIataCode = ""
        } else {
            viewModel.toLocation = "Anywhere"
            viewModel.toIataCode = ""
            destinationSearchText = "Anywhere"
        }
        
        dismiss()
    }
    
    private func handleResultSelection(result: AutocompleteResult) {
        if activeSearchBar == .origin {
            selectOrigin(result: result)
        } else {
            // Check if the selected destination is the same as origin
            if result.iataCode == viewModel.fromIataCode {
                // Don't allow selection of the same destination as origin
                // Show a message to the user
                searchError = "Origin and destination cannot be the same"
                return
            }
            selectDestination(result: result)
        }
    }
    
    private func selectOrigin(result: AutocompleteResult) {
        // Check if this would match the current destination
        if !viewModel.toIataCode.isEmpty && result.iataCode == viewModel.toIataCode {
            searchError = "Origin and destination cannot be the same"
            return
        }
        
        if multiCityMode {
            viewModel.multiCityTrips[multiCityTripIndex].fromLocation = result.cityName
            viewModel.multiCityTrips[multiCityTripIndex].fromIataCode = result.iataCode
        } else {
            viewModel.fromLocation = result.cityName
            viewModel.fromIataCode = result.iataCode
            originSearchText = result.cityName
        }
        
        // Check if we should proceed with search or just dismiss
        if multiCityMode {
            // For multi-city, just auto-focus destination if it's empty
            if viewModel.multiCityTrips[multiCityTripIndex].toIataCode.isEmpty {
                activeSearchBar = .destination
                focusedField = .destination
            } else {
                dismiss()
            }
        } else {
            // For regular mode, check if we have both locations for automatic search
            if !viewModel.toIataCode.isEmpty {
                // Both origin and destination are selected, dismiss and potentially search
                dismiss()
                
                // If user has selected dates, trigger search
                if !viewModel.dates.isEmpty {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        viewModel.updateDatesAndRunSearch()
                    }
                } else {
                    // If no dates selected, use dynamic default dates for search
                    initiateSearchWithDefaultDates()
                }
            } else {
                // Only origin selected, auto-focus the destination field
                activeSearchBar = .destination
                focusedField = .destination
            }
        }
    }
    
    private func selectDestination(result: AutocompleteResult) {
        if multiCityMode {
            viewModel.multiCityTrips[multiCityTripIndex].toLocation = result.cityName
            viewModel.multiCityTrips[multiCityTripIndex].toIataCode = result.iataCode
            dismiss()
        } else {
            // Update the destination in view model
            viewModel.toLocation = result.cityName
            viewModel.toIataCode = result.iataCode
            destinationSearchText = result.cityName
            
            // Check if we should proceed with search or just dismiss
            if !viewModel.fromIataCode.isEmpty {
                // Both origin and destination are selected, dismiss and potentially search
                dismiss()
                
                // If user has selected dates, trigger search
                if !viewModel.dates.isEmpty {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        viewModel.updateDatesAndRunSearch()
                    }
                } else {
                    // If no dates selected, use dynamic default dates for search
                    initiateSearchWithDefaultDates()
                }
            } else {
                // Only destination selected, auto-focus the origin field
                activeSearchBar = .origin
                focusedField = .origin
            }
        }
    }
    
    // Add this helper function to handle default date search
    private func initiateSearchWithDefaultDates() {
        let calendar = Calendar.current
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: Date()) ?? Date()
        let dayAfterTomorrow = calendar.date(byAdding: .day, value: 2, to: Date()) ?? Date()
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        let departureDate = formatter.string(from: tomorrow)
        let returnDate = formatter.string(from: dayAfterTomorrow)
        
        viewModel.selectedDepartureDatee = departureDate
        viewModel.selectedReturnDatee = returnDate
        
        // Also update the dates array to keep calendar in sync
        viewModel.dates = [tomorrow, dayAfterTomorrow]
        
        // Initiate flight search with dynamic default dates - mark as direct search
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            viewModel.searchFlightsForDates(
                origin: viewModel.fromIataCode,
                destination: viewModel.toIataCode,
                returnDate: returnDate,
                departureDate: departureDate,
                isDirectSearch: true
            )
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

// NEW: Custom view for the "Anywhere" option
struct AnywhereOptionRow: View {
    var body: some View {
        HStack(spacing: 16) {
            // Icon for "Anywhere"
            ZStack {
                Circle()
                    .fill(Color.orange.opacity(0.1))
                    .frame(width: 40, height: 40)
                
                Image(systemName: "globe")
                    .font(.system(size: 18))
                    .foregroundColor(.orange)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Anywhere")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.primary)
                
                Text("Explore destinations")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Image(systemName: "arrow.up.right")
                .font(.system(size: 14))
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color.white)
        .contentShape(Rectangle())
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



// Updated Flight Card Components to match the UI design

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
                if viewModel.isRoundTrip && returnLeg != nil && returnSegment != nil {
                    // Round trip flight card
                    ModernFlightCard(
                        // Tags
                        isBest: result.isBest,
                        isCheapest: result.isCheapest,
                        isFastest: result.isFastest,
                        
                        // Outbound flight
                        outboundDepartureTime: outboundDepartureTime,
                        outboundDepartureCode: outboundSegment.originCode,
                        outboundDepartureDate: formatDateShort(from: outboundSegment.departureTimeAirport),
                        outboundArrivalTime: outboundArrivalTime,
                        outboundArrivalCode: outboundSegment.destinationCode,
                        outboundArrivalDate: formatDateShort(from: outboundSegment.arriveTimeAirport),
                        outboundDuration: formatDuration(minutes: outboundLeg.duration),
                        isOutboundDirect: outboundLeg.stopCount == 0,
                        outboundStops: outboundLeg.stopCount,
                        
                        // Return flight
                        returnDepartureTime: formatTime(from: returnSegment!.departureTimeAirport),
                        returnDepartureCode: returnSegment!.originCode,
                        returnDepartureDate: formatDateShort(from: returnSegment!.departureTimeAirport),
                        returnArrivalTime: formatTime(from: returnSegment!.arriveTimeAirport),
                        returnArrivalCode: returnSegment!.destinationCode,
                        returnArrivalDate: formatDateShort(from: returnSegment!.arriveTimeAirport),
                        returnDuration: formatDuration(minutes: returnLeg!.duration),
                        isReturnDirect: returnLeg!.stopCount == 0,
                        returnStops: returnLeg!.stopCount,
                        
                        // Airline and price - Updated with airline details
                        airline: outboundSegment.airlineName,
                        airlineCode: outboundSegment.airlineIata,
                        airlineLogo: outboundSegment.airlineLogo,
                        price: "₹\(Int(result.minPrice))",
                        priceDetail: "For \(viewModel.adultsCount + viewModel.childrenCount) People ₹\(Int(result.minPrice * Double(viewModel.adultsCount + viewModel.childrenCount)))",
                        
                        isRoundTrip: true
                    )
                } else {
                    // One way flight card
                    ModernFlightCard(
                        // Tags
                        isBest: result.isBest,
                        isCheapest: result.isCheapest,
                        isFastest: result.isFastest,
                        
                        // Outbound flight
                        outboundDepartureTime: outboundDepartureTime,
                        outboundDepartureCode: outboundSegment.originCode,
                        outboundDepartureDate: formatDateShort(from: outboundSegment.departureTimeAirport),
                        outboundArrivalTime: outboundArrivalTime,
                        outboundArrivalCode: outboundSegment.destinationCode,
                        outboundArrivalDate: formatDateShort(from: outboundSegment.arriveTimeAirport),
                        outboundDuration: formatDuration(minutes: outboundLeg.duration),
                        isOutboundDirect: outboundLeg.stopCount == 0,
                        outboundStops: outboundLeg.stopCount,
                        
                        // Airline and price - Updated with airline details
                        airline: outboundSegment.airlineName,
                        airlineCode: outboundSegment.airlineIata,
                        airlineLogo: outboundSegment.airlineLogo,
                        price: "₹\(Int(result.minPrice))",
                        priceDetail: "For \(viewModel.adultsCount + viewModel.childrenCount) People ₹\(Int(result.minPrice * Double(viewModel.adultsCount + viewModel.childrenCount)))",
                        
                        isRoundTrip: false
                    )
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
    
    private func formatDateShort(from timestamp: Int) -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(timestamp))
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM"
        return formatter.string(from: date)
    }
    
    private func formatDuration(minutes: Int) -> String {
        let hours = minutes / 60
        let mins = minutes % 60
        return "\(hours)h \(mins)m"
    }
}

// Updated ModernFlightCard with reduced padding to match sample UI
struct ModernFlightCard: View {
    // Tags
    let isBest: Bool
    let isCheapest: Bool
    let isFastest: Bool
    
    // Outbound flight
    let outboundDepartureTime: String
    let outboundDepartureCode: String
    let outboundDepartureDate: String
    let outboundArrivalTime: String
    let outboundArrivalCode: String
    let outboundArrivalDate: String
    let outboundDuration: String
    let isOutboundDirect: Bool
    let outboundStops: Int
    
    // Return flight (optional)
    var returnDepartureTime: String? = nil
    var returnDepartureCode: String? = nil
    var returnDepartureDate: String? = nil
    var returnArrivalTime: String? = nil
    var returnArrivalCode: String? = nil
    var returnArrivalDate: String? = nil
    var returnDuration: String? = nil
    var isReturnDirect: Bool? = nil
    var returnStops: Int? = nil
    
    // Airline and price
    let airline: String
    let airlineCode: String
    let airlineLogo: String
    let price: String
    let priceDetail: String
    
    let isRoundTrip: Bool
    
    var body: some View {
        VStack(spacing: 5) {
            // Tags at the top inside the card - REDUCED PADDING
            if isBest || isCheapest || isFastest {
                HStack(spacing: 4) { // Reduced from 6 to 4
                    if isBest {
                        TagView(text: "Best", color: Color("best"))
                    }
                    if isCheapest {
                        TagView(text: "Cheapest",color: Color("cheap"))
                    }
                    if isFastest {
                        TagView(text: "Fastest", color: Color("fast"))
                    }
                    Spacer()
                }
                .padding(.horizontal, 12) // Reduced from 16 to 12
                .padding(.top, 12) // Reduced from 12 to 8
                .padding(.bottom, 4) // Reduced from 8 to 4
            }
            
            // Outbound flight - REDUCED PADDING
            FlightRowView(
                departureTime: outboundDepartureTime,
                departureCode: outboundDepartureCode,
                departureDate: outboundDepartureDate,
                arrivalTime: outboundArrivalTime,
                arrivalCode: outboundArrivalCode,
                arrivalDate: outboundArrivalDate,
                duration: outboundDuration,
                isDirect: isOutboundDirect,
                stops: outboundStops,
                airlineName: airline,
                airlineCode: airlineCode,
                airlineLogo: airlineLogo
            )
            .padding(.horizontal, 12) // Reduced from 16 to 12
            .padding(.vertical, 8) // Reduced from default to 8
            
            // Return flight (if round trip) - REDUCED PADDING
            if isRoundTrip,
               let retDepTime = returnDepartureTime,
               let retDepCode = returnDepartureCode,
               let retDepDate = returnDepartureDate,
               let retArrTime = returnArrivalTime,
               let retArrCode = returnArrivalCode,
               let retArrDate = returnArrivalDate,
               let retDuration = returnDuration,
               let retDirect = isReturnDirect,
               let retStops = returnStops {
                
                FlightRowView(
                    departureTime: retDepTime,
                    departureCode: retDepCode,
                    departureDate: retDepDate,
                    arrivalTime: retArrTime,
                    arrivalCode: retArrCode,
                    arrivalDate: retArrDate,
                    duration: retDuration,
                    isDirect: retDirect,
                    stops: retStops,
                    airlineName: airline,
                    airlineCode: airlineCode,
                    airlineLogo: airlineLogo
                )
                .padding(.horizontal, 12) // Reduced from 16 to 12
                .padding(.vertical, 6) // Reduced from 8 to 6
            }
            
            // Bottom section with airline and price - REDUCED PADDING
            Divider()
                .padding(.horizontal, 12) // Reduced from 16 to 12
                .padding(.bottom) // Reduced from default to 6
            
            HStack {
                Text(airline)
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    Text(price)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.black)
                    
                    Text(priceDetail)
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                }
            }
            .padding(.horizontal, 12) // Reduced from 16 to 12
            .padding(.vertical, 8) // Reduced from 12 to 8
        }
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.08), radius: 4, x: 0, y: 2)
    }
}

// Updated FlightRowView with reduced spacing and padding
struct FlightRowView: View {
    let departureTime: String
    let departureCode: String
    let departureDate: String
    let arrivalTime: String
    let arrivalCode: String
    let arrivalDate: String
    let duration: String
    let isDirect: Bool
    let stops: Int
    
    // Add airline information for the flight image
    let airlineName: String
    let airlineCode: String
    let airlineLogo: String
    
    var body: some View {
        HStack(alignment: .center, spacing: 10) { // Reduced from 12 to 8
            // Flight/Airline image section - SMALLER SIZE
            AsyncImage(url: URL(string: airlineLogo)) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 28, height: 28) // Reduced from 32 to 28
                        .clipShape(RoundedRectangle(cornerRadius: 5)) // Reduced from 6 to 5
                case .failure(_), .empty:
                    // Fallback airline logo
                    ZStack {
                        RoundedRectangle(cornerRadius: 5) // Reduced from 6 to 5
                            .fill(Color.blue.opacity(0.1))
                            .frame(width: 28, height: 28) // Reduced from 32 to 28
                        
                        Text(String(airlineCode.prefix(2)))
                            .font(.system(size: 11, weight: .bold)) // Reduced from 12 to 11
                            .foregroundColor(.blue)
                    }
                @unknown default:
                    // Default placeholder
                    ZStack {
                        RoundedRectangle(cornerRadius: 5)
                            .fill(Color.gray.opacity(0.2))
                            .frame(width: 28, height: 28)
                        
                        Image(systemName: "airplane")
                            .font(.system(size: 12)) // Reduced from 14 to 12
                            .foregroundColor(.gray)
                    }
                }
            }
            
            // Departure section - TIGHTER SPACING
            VStack(alignment: .leading, spacing: 2) { // Reduced from 4 to 2
                Text(departureTime)
                    .font(.system(size: 16, weight: .semibold)) // Reduced from 18 to 16
                    .foregroundColor(.black)
                
                // Departure code and date in the same row (HStack)
                HStack(spacing: 4) { // Reduced from 8 to 6
                    Text(departureCode)
                        .font(.system(size: 13)) // Reduced from 14 to 13
                        .foregroundColor(.gray)
                    
                    Circle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(width: 4, height: 4)
                    
                    Text(departureDate)
                        .font(.system(size: 11)) // Reduced from 12 to 11
                        .foregroundColor(.gray)
                }
            }
            .frame(width: 80, alignment: .leading) // Reduced from 80 to 75
            
            Spacer()
            
            // Flight path section - SMALLER ELEMENTS
            VStack(spacing: 4) { // Reduced from 6 to 4
                // Flight path visualization
                HStack(spacing: 0) {
                    // Left circle
                    Circle()
                        .stroke(Color.gray, lineWidth: 1)
                        .frame(width: 6, height: 6) // Reduced from 6 to 5
                    
                    // Left line segment
                    Rectangle()
                        .fill(Color.gray)
                        .frame(width:12,height: 1)
                       
                    
                    // Date/Time capsule in the middle
                    Text(duration)
                        .font(.system(size: 11)) // Reduced from 12 to 11
                        .foregroundColor(.gray)
                        .padding(.horizontal, 10) // Reduced from 8 to 6
                        .padding(.vertical, 1) // Reduced from 2 to 1
                        .background(
                            Capsule()
                                .fill(Color.white)
                                .overlay(
                                    Capsule()
                                        .stroke(Color.gray.opacity(0.3), lineWidth: 0.5)
                                )
                        )
                        .padding(.horizontal,6)
                    
                    // Right line segment
                    Rectangle()
                        .fill(Color.gray)
                        .frame(width:12,height: 1)
                        
                    
                    // Right circle
                    Circle()
                        .stroke(Color.gray, lineWidth: 1)
                        .frame(width: 6, height: 6) // Reduced from 6 to 5
                }
                .frame(width: 110) // Reduced from 120 to 110
                
                // Direct/Stops indicator - SMALLER BADGES
                if isDirect {
                    Text("Direct")
                        .font(.system(size: 10, weight: .medium)) // Reduced from 11 to 10
                        .foregroundColor(.green)
                        .padding(.horizontal, 6) // Reduced from 8 to 6
                        .padding(.vertical, 1) // Reduced from 2 to 1
                        
                } else {
                    Text("\(stops) Stop\(stops > 1 ? "s" : "")")
                        .font(.system(size: 10, weight: .medium)) // Reduced from 11 to 10
                        .foregroundColor(.primary)
                        .padding(.horizontal, 6) // Reduced from 8 to 6
                        .padding(.vertical, 1) // Reduced from 2 to 1
                }
            }
            
            Spacer()
            
            // Arrival section - TIGHTER SPACING
            VStack(alignment: .trailing, spacing: 2) { // Reduced from 4 to 2
                Text(arrivalTime)
                    .font(.system(size: 16, weight: .semibold)) // Reduced from 18 to 16
                    .foregroundColor(.black)
                
                // Arrival code and date in the same row (HStack)
                HStack(spacing: 4) { // Reduced from 8 to 6
                    Text(arrivalCode)
                        .font(.system(size: 13)) // Reduced from 14 to 13
                        .foregroundColor(.gray)
                    Circle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(width: 4, height: 4)
                    Text(arrivalDate)
                        .font(.system(size: 11)) // Reduced from 12 to 11
                        .foregroundColor(.gray)
                }
            }
            .frame(width: 80, alignment: .trailing) // Reduced from 80 to 75
        }
    }
}

// Updated TagView to be more compact
struct TagView: View {
    let text: String
    let color: Color
    
    var body: some View {
        Text(text)
            .font(.system(size: 10, weight: .medium)) // Reduced from 11 to 10
            .foregroundColor(.white)
            .padding(.horizontal, 6) // Reduced from 8 to 6
            .padding(.vertical, 3) // Reduced from 4 to 3
            .background(color)
            .cornerRadius(3) // Reduced from 4 to 3
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
    let airlineLogo: String // Add this property
    
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
        airlineLogo: String, // Add this parameter
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
        self.airlineLogo = airlineLogo // Initialize this property
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
        self.airlineLogo = "" // Initialize this property for connecting flights
        self.arrivalDate = ""
        self.arrivalTime = nil
        self.arrivalAirportCode = ""
        self.arrivalAirportName = ""
        self.arrivalTerminal = ""
        self.arrivalNextDay = false
        self.connectionSegments = connectionSegments
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Header section
            VStack(alignment: .leading, spacing: 15) {
                Text("Flight to \(destination)")
                    .font(.system(size: 18, weight: .bold))
                
                HStack(spacing: 16) {
                    HStack(spacing: 4) {
                        Text(isDirectFlight ? "Direct" : "\((connectionSegments?.count ?? 1) - 1) Stop")

                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(isDirectFlight ? .green : .primary)
                    }
                    
                    Text("|").opacity(0.5)
                    
                    HStack(spacing: 4) {
                        Text(flightDuration)
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                    }
                    Text("|").opacity(0.5)
                    
                    HStack(spacing: 4) {
                        Image(systemName: "carseat.right.fill")
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
                    airlineLogo: airlineLogo, // Pass the airline logo
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
    let airlineLogo: String
    
    let arrivalDate: String
    let arrivalTime: String?
    let arrivalAirportCode: String
    let arrivalAirportName: String
    let arrivalTerminal: String
    let arrivalNextDay: Bool
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            // Timeline positioned to align with airport codes - UPDATED alignment
            VStack(spacing: 0) {
                // UPDATED: Slightly moved down for perfect alignment
                Spacer()
                    .frame(height: 42) // Increased from 35 to 42 to move timeline down
                
                // Departure circle
                Circle()
                    .stroke(Color.primary, lineWidth: 1)
                    .frame(width: 8, height: 8)
                
                // Connecting line - UPDATED: Reduced straight line height
                Rectangle()
                    .fill(Color.primary)
                    .frame(width: 1, height: 130) // Reduced from 155 to 130
                    .padding(.top, 4) // Reduced from 6 to 4
                    .padding(.bottom, 4) // Reduced from 6 to 4
                
                // Arrival circle
                Circle()
                    .stroke(Color.primary, lineWidth: 1)
                    .frame(width: 8, height: 8)
                
                // Space for remaining content
                Spacer()
            }
            
            // Flight details with proper spacing
            VStack(alignment: .leading, spacing: 32) { // Good spacing between sections
                
                // DEPARTURE SECTION
                VStack(alignment: .leading, spacing: 12) {
                    HStack(spacing: 8) {
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
                        ZStack {
                            Rectangle()
                                .fill(Color.gray.opacity(0.1))
                                .frame(width: 40, height: 32)
                                .cornerRadius(4)
                            Text(departureAirportCode)
                                .font(.system(size: 16, weight: .semibold))
                        }
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(departureAirportName)
                                .font(.system(size: 14, weight: .medium))
                            Text("Terminal \(departureTerminal)")
                                .font(.system(size: 13))
                                .foregroundColor(.gray)
                        }
                        
                        Spacer()
                    }
                }
                
                // AIRLINE SECTION - Centered between departure and arrival
                HStack(spacing: 12) {
                    AsyncImage(url: URL(string: airlineLogo)) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 36, height: 32)
                                .clipShape(RoundedRectangle(cornerRadius: 4))
                        case .failure(_), .empty:
                            // Fallback with airline initials
                            ZStack {
                                Rectangle()
                                    .fill(Color.blue.opacity(0.1))
                                    .frame(width: 36, height: 32)
                                    .cornerRadius(4)
                                
                                Text(String(airline.prefix(2)))
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(.blue)
                            }
                        @unknown default:
                            // Default placeholder
                            ZStack {
                                Rectangle()
                                    .fill(Color.gray.opacity(0.2))
                                    .frame(width: 36, height: 32)
                                    .cornerRadius(4)
                                
                                Image(systemName: "airplane")
                                    .font(.system(size: 16))
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(airline)
                            .font(.system(size: 14))
                        Text(flightNumber)
                            .font(.system(size: 13))
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                }
                
                // ARRIVAL SECTION
                VStack(alignment: .leading, spacing: 12) {
                    HStack(spacing: 8) {
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
                        ZStack {
                            Rectangle()
                                .fill(Color.gray.opacity(0.1))
                                .frame(width: 40, height: 32)
                                .cornerRadius(4)
                            Text(arrivalAirportCode)
                                .font(.system(size: 16, weight: .semibold))
                        }
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(arrivalAirportName)
                                .font(.system(size: 14, weight: .medium))
                            Text("Terminal \(arrivalTerminal)")
                                .font(.system(size: 13))
                                .foregroundColor(.gray)
                        }
                        
                        Spacer()
                    }
                }
            }
            .padding(.bottom, 16)
        }
        .padding(.leading, 16)
    }
}

// Updated ConnectionSegment model with airline logo support
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
    let airlineLogo: String // Added airline logo URL
    
    // Connection info (if not the last segment)
    let connectionDuration: String? // e.g. "2h 50m connection"
}

struct ConnectingFlightView: View {
    let segments: [ConnectionSegment]
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            // Timeline positioned to align with airport codes - UPDATED alignment
            VStack(spacing: 0) {
                // UPDATED: Slightly moved down for perfect alignment
                Spacer()
                    .frame(height: 42) // Increased from 35 to 42 to move timeline down
                
                // First departure circle
                Circle()
                    .stroke(Color.primary, lineWidth: 1)
                    .frame(width: 8, height: 8)
                
                // For each segment, create connecting elements
                ForEach(0..<segments.count, id: \.self) { index in
                    // Solid line for flight segment - UPDATED: Reduced straight line height
                    Rectangle()
                        .fill(Color.primary)
                        .frame(width: 1, height: 150) // Reduced from 190 to 150
                        .padding(.top, 4) // Reduced from 6 to 4
                        .padding(.bottom, 4) // Reduced from 6 to 4
                    
                    // Connection point (if not the last segment)
                    if index < segments.count - 1 {
                        Circle()
                            .stroke(Color.primary, lineWidth: 1)
                            .frame(width: 8, height: 8)
                        
                        // Dotted line for layover/connection - KEPT same height
                        Rectangle()
                            .fill(Color.clear)
                            .frame(width: 1, height: 130) // Kept at 130 (dotted line unchanged)
                            .overlay(
                                Path { path in
                                    path.move(to: CGPoint(x: 0.5, y: 0))
                                    path.addLine(to: CGPoint(x: 0.5, y: 130)) // Kept path height at 130
                                }
                                .stroke(Color.primary, style: StrokeStyle(lineWidth: 1, dash: [3, 3]))
                            )
                            .padding(.top, 4) // Reduced from 6 to 4
                            .padding(.bottom, 4) // Reduced from 6 to 4
                        
                        Circle()
                            .stroke(Color.primary, lineWidth: 1)
                            .frame(width: 8, height: 8)
                    }
                }
                
                // Final arrival circle
                Circle()
                    .stroke(Color.primary, lineWidth: 1)
                    .frame(width: 8, height: 8)
                
                // Space for remaining content
                Spacer()
            }
            
            // Flight details with proper spacing matching DirectFlightView
            VStack(alignment: .leading, spacing: 32) {
                ForEach(0..<segments.count, id: \.self) { segmentIndex in
                    let segment = segments[segmentIndex]
                    
                    // DEPARTURE SECTION
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(spacing: 8) {
                            Text(segment.departureDate)
                                .font(.system(size: 14))
                                .foregroundColor(.black)
                            
                            Text(segment.departureTime)
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.black)
                        }
                        
                        HStack(alignment: .center, spacing: 12) {
                            ZStack {
                                Rectangle()
                                    .fill(Color.gray.opacity(0.1))
                                    .frame(width: 40, height: 32)
                                    .cornerRadius(4)
                                Text(segment.departureAirportCode)
                                    .font(.system(size: 16, weight: .semibold))
                            }
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(segment.departureAirportName)
                                    .font(.system(size: 14, weight: .medium))
                                Text("Terminal \(segment.departureTerminal)")
                                    .font(.system(size: 13))
                                    .foregroundColor(.gray)
                            }
                            
                            Spacer()
                        }
                    }
                    
                    // AIRLINE SECTION
                    HStack(spacing: 12) {
                        AsyncImage(url: URL(string: segment.airlineLogo)) { phase in
                            switch phase {
                            case .success(let image):
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 36, height: 32)
                                    .clipShape(RoundedRectangle(cornerRadius: 4))
                            case .failure(_), .empty:
                                // Fallback with airline initials
                                ZStack {
                                    Rectangle()
                                        .fill(Color.blue.opacity(0.1))
                                        .frame(width: 36, height: 32)
                                        .cornerRadius(4)
                                    
                                    Text(String(segment.airline.prefix(2)))
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundColor(.blue)
                                }
                            @unknown default:
                                // Default placeholder
                                ZStack {
                                    Rectangle()
                                        .fill(Color.gray.opacity(0.2))
                                        .frame(width: 36, height: 32)
                                        .cornerRadius(4)
                                    
                                    Image(systemName: "airplane")
                                        .font(.system(size: 16))
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(segment.airline)
                                .font(.system(size: 14))
                            Text(segment.flightNumber)
                                .font(.system(size: 13))
                                .foregroundColor(.gray)
                        }
                        
                        Spacer()
                    }
                    
                    // ARRIVAL SECTION
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(spacing: 8) {
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
                            ZStack {
                                Rectangle()
                                    .fill(Color.gray.opacity(0.1))
                                    .frame(width: 40, height: 32)
                                    .cornerRadius(4)
                                Text(segment.arrivalAirportCode)
                                    .font(.system(size: 16, weight: .semibold))
                            }
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(segment.arrivalAirportName)
                                    .font(.system(size: 14, weight: .medium))
                                Text("Terminal \(segment.arrivalTerminal)")
                                    .font(.system(size: 13))
                                    .foregroundColor(.gray)
                            }
                            
                            Spacer()
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

// Helper view for creating dotted lines
struct DottedLine: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
        return path
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
    @State private var tabPressStates: [Bool] = Array(repeating: false, count: FilterOption.allCases.count)
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
                ForEach(Array(FilterOption.allCases.enumerated()), id: \.element) { index, filter in
                    Button(action: {
                        // Haptic feedback
                        let selectionFeedback = UISelectionFeedbackGenerator()
                        selectionFeedback.selectionChanged()
                        
                        // Tab press animation
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                            tabPressStates[index] = true
                        }
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                tabPressStates[index] = false
                            }
                        }
                        
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
                            .scaleEffect(tabPressStates[index] ? 0.95 : 1.0)
                    }
                }
            }
            .padding(.horizontal)
        }
    }
}


struct ModifiedDetailedFlightListView: View {
    @State private var skeletonOpacity: Double = 0
    @State private var skeletonOffset: CGFloat = 20
    @ObservedObject var viewModel: ExploreViewModel
    @State private var selectedFilter: FlightFilterTabView.FilterOption = .all
    @State private var filteredResults: [FlightDetailResult] = []
    @State private var showingFilterSheet = false
    @State private var hasAppliedInitialDirectFilter = false
    @State private var showingFlightDetails = false
    
    @State private var showingLoadingSkeletons = true
    
    @State private var hasReceivedEmptyResults = false
    
    // Auto-retry mechanism
    @State private var retryCount = 0
    @State private var retryTimer: Timer? = nil
    @State private var lastDataTimestamp = Date()
    
    // Simplified loading state management with Equatable
    @State private var viewState: ViewState = .loading
    
    enum ViewState: Equatable {
        case loading
        case loaded
        case error(String)
        case empty
        
        static func == (lhs: ViewState, rhs: ViewState) -> Bool {
            switch (lhs, rhs) {
            case (.loading, .loading): return true
            case (.loaded, .loaded): return true
            case (.empty, .empty): return true
            case (.error(let lhsMsg), .error(let rhsMsg)): return lhsMsg == rhsMsg
            default: return false
            }
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            // Filter tabs section
            HStack {
                FilterButton {
                    showingFilterSheet = true
                }
                .padding(.leading, 20)
                
                FlightFilterTabView(
                    selectedFilter: selectedFilter,
                    onSelectFilter: { filter in
                        selectedFilter = filter
                        applyFilterOption(filter)
                    }
                )
            }
            .padding(.trailing, 16)
            .padding(.vertical, 8)
            .background(Color("scroll"))
            

            // Flight count display - show whenever we have a valid total count
            // Flight count display - show whenever we have a valid total count
            if viewModel.totalFlightCount > 0 {
                HStack {
                    if filteredResults.isEmpty && !viewModel.isLoadingDetailedFlights {
                        // When we have a count but no visible results after filtering
                        Text("\(viewModel.totalFlightCount) flights found")
                            .font(.subheadline)
                            .foregroundColor(.primary)
                    } else {
                        // Standard display showing total available flights
                        Text("\(viewModel.totalFlightCount) flights found")
                            .font(.subheadline)
                            .foregroundColor(.primary)
                    }
                    Spacer()
                }
                .padding(.horizontal)
                .padding(8)
                .background(Color("scroll"))
            }
            
            // Main content area
            ZStack {
                // Background color for the entire content area
                Color("scroll").edgesIgnoringSafeArea(.all)
                
                if case .loading = viewState {
                    VStack {
                        Spacer()
                        ForEach(0..<4, id: \.self) { index in
                            DetailedFlightCardSkeleton()
                                .padding(.bottom, 5)
                                .opacity(skeletonOpacity)
                                .offset(y: skeletonOffset)
                                .animation(
                                    .spring(response: 0.6, dampingFraction: 0.8)
                                    .delay(Double(index) * 0.1), // Staggered appearance
                                    value: skeletonOpacity
                                )
                        }
                        Spacer()
                    }
                    .onAppear {
                        withAnimation {
                            skeletonOpacity = 1.0
                            skeletonOffset = 0
                        }
                    }
                }else if case .error(let message) = viewState {
                    VStack {
                        Spacer()
                        Text(message)
                            .foregroundColor(.red)
                            .padding()
                        Button("Retry") {
                            initiateSearch()
                        }
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                        Spacer()
                    }
                } else if hasReceivedEmptyResults {
                    // ONLY show this when we've received a confirmed empty result
                    VStack {
                        Spacer()
                        Text("No flights found")
                            .foregroundColor(.gray)
                        Spacer()
                    }
                } else if !filteredResults.isEmpty {
                    // Only show flight list when we have results
                    PaginatedFlightList(
                        viewModel: viewModel,
                        filteredResults: filteredResults,
                        isMultiCity: isMultiCity,
                        onFlightSelected: { result in
                            viewModel.selectedFlightId = result.id
                            showingFlightDetails = true
                        }
                    )
                    .onAppear {
                        // Data is visible, cancel any pending retries
                        cancelRetryTimer()
                        hasReceivedEmptyResults = false
                    }
                } else {
                    // Show skeleton loading while waiting for retries
                    VStack {
                        Spacer()
                        ForEach(0..<4, id: \.self) { _ in
                            DetailedFlightCardSkeleton()
                                .padding(.bottom, 5)
                        }
                        Spacer()
                    }
                }
            }

        }
        .sheet(isPresented: $showingFilterSheet) {
            FlightFilterSheet(viewModel: viewModel)
        }
        .fullScreenCover(isPresented: $showingFlightDetails) {
            if let selectedId = viewModel.selectedFlightId,
               let selectedFlight = viewModel.detailedFlightResults.first(where: { $0.id == selectedId }) {
                FlightDetailsView(
                    selectedFlight: selectedFlight,
                    viewModel: viewModel
                )
            }
        }
        .onAppear {
            print("View appeared - starting auto data flow")
            applyInitialDirectFilterIfNeeded()
            initiateSearch()
            if !viewModel.detailedFlightResults.isEmpty {
                    viewModel.debugDuplicateFlightIDs()
                }
            // Start the auto-retry timer
            startRetryTimer()
        }
        .onDisappear {
            // Clean up timer when view disappears
            cancelRetryTimer()
        }
        .onReceive(viewModel.$detailedFlightResults) { newResults in
                    print("📱 UI received \(newResults.count) results from viewModel")
                    
                    if !newResults.isEmpty {
                        // We have results
                        hasReceivedEmptyResults = false
                        viewModel.debugDuplicateFlightIDs()
                        updateResults(newResults)
                        cancelRetryTimer()
                    } else if !viewModel.isLoadingDetailedFlights && viewModel.isDataCached {
                        // We've finished loading, data is cached, and results are empty
                        // This means it's a confirmed empty result
                        hasReceivedEmptyResults = true
                    }
                }
            
        
        .onReceive(viewModel.$isLoadingDetailedFlights) { isLoading in
                    print("Loading state changed: \(isLoading)")
                    
                    if isLoading {
                        viewState = .loading
                        return
                    }
                    
                    // Loading finished
                    if !viewModel.detailedFlightResults.isEmpty {
                        hasReceivedEmptyResults = false
                        viewState = .loaded
                        updateResults(viewModel.detailedFlightResults)
                        cancelRetryTimer()
                    } else if let error = viewModel.detailedFlightError, !error.isEmpty {
                        viewState = .error(error)
                        startRetryTimer()
                    } else if viewModel.detailedFlightResults.isEmpty && viewModel.isDataCached {
                        // Only show empty state when we're certain the API returned empty results
                        hasReceivedEmptyResults = true
                    }
                }
        .onReceive(viewModel.$selectedFlightId) { newValue in
            showingFlightDetails = newValue != nil
        }
    }
    
    // MARK: - Auto Retry Methods
    
    private func startRetryTimer() {
        // Cancel any existing timer first
        cancelRetryTimer()
        
        // Only start timer if we haven't exceeded retry limit
        if retryCount < 5 {
            print("Starting retry timer (attempt \(retryCount + 1))")
            retryTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) { _ in
                // Check if data is stale (no updates for 3+ seconds)
                let timeSinceLastData = Date().timeIntervalSince(lastDataTimestamp)
                let dataIsStale = timeSinceLastData > 3.0
                
                // Auto-retry if the data is stale and we're not currently loading
                if dataIsStale && !viewModel.isLoadingDetailedFlights {
                    print("Auto-retry triggered (attempt \(retryCount + 1))")
                    retryCount += 1
                    forceReloadData()
                }
                
                // Restart timer for next attempt if needed
                if retryCount < 5 {
                    startRetryTimer()
                } else {
                    print("Max retry attempts reached (\(retryCount))")
                }
            }
        }
    }
    
    private func cancelRetryTimer() {
        retryTimer?.invalidate()
        retryTimer = nil
    }
    
    // MARK: - Helper Methods
    
    private var isMultiCity: Bool {
        return viewModel.multiCityTrips.count >= 2
    }
    
    private func forceReloadData() {
        print("Force reloading data")
        viewState = .loading
        
        // If we have search results but they're not showing, try to use them
        if !viewModel.detailedFlightResults.isEmpty {
            print("Using \(viewModel.detailedFlightResults.count) existing results")
            updateResults(viewModel.detailedFlightResults)
            
            // Transition to loaded state
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                viewState = .loaded
            }
        } else if viewModel.currentSearchId != nil {
            // We have a search ID but no results, try polling again
            print("Re-polling with existing search ID")
            let filterRequest = viewModel.currentFilterRequest ?? FlightFilterRequest()
            viewModel.applyPollFilters(filterRequest: filterRequest)
        } else {
            // Last resort - start a new search
            print("Starting fresh search")
            initiateSearch()
        }
    }
    
    private func initiateSearch() {
        print("Initiating search")
        viewState = .loading
        
        // Only trigger a new search if we don't already have one in progress
        if !viewModel.isLoadingDetailedFlights {
            let filterRequest = FlightFilterRequest()
            viewModel.applyPollFilters(filterRequest: filterRequest)
        } else if !viewModel.detailedFlightResults.isEmpty {
            // We already have results, just update our filtered results
            print("Using existing \(viewModel.detailedFlightResults.count) results")
            updateResults(viewModel.detailedFlightResults)
        }
    }
    
    private func updateResults(_ results: [FlightDetailResult]) {
        // Update view state based on results
        if results.isEmpty {
            if viewModel.isLoadingDetailedFlights {
                print("Empty results but still loading")
                viewState = .loading
            } else if let error = viewModel.detailedFlightError, !error.isEmpty {
                print("Error state: \(error)")
                viewState = .error(error)
            } else {
                print("No results found")
                viewState = .empty
            }
        } else {
            print("Updated with \(results.count) results")
            viewState = .loaded
            filteredResults = results
            applyLocalFilters()
        }
    }
    
    private func applyInitialDirectFilterIfNeeded() {
        if viewModel.directFlightsOnlyFromHome && !hasAppliedInitialDirectFilter {
            print("Applying initial direct filter")
            selectedFilter = .direct
            hasAppliedInitialDirectFilter = true
        }
    }
    
    private func applyFilterOption(_ filter: FlightFilterTabView.FilterOption) {
        print("Applying filter: \(filter.rawValue)")
        selectedFilter = filter
        
        // First try to apply filter through local filtering
        applyLocalFilters()
        
        // For certain filters that need server-side processing, also make an API call
        if filter == .direct || filter == .cheapest || filter == .fastest {
            var filterRequest = FlightFilterRequest()
            
            switch filter {
            case .cheapest:
                filterRequest.sortBy = "price"
                filterRequest.sortOrder = "asc"
            case .fastest:
                filterRequest.sortBy = "duration"
                filterRequest.sortOrder = "asc"
            case .direct:
                filterRequest.stopCountMax = 0
            default:
                break
            }
            
            // Only make API call if we have valid search context
            if !viewModel.selectedOriginCode.isEmpty && !viewModel.selectedDestinationCode.isEmpty {
                viewState = .loading
                viewModel.applyPollFilters(filterRequest: filterRequest)
            }
        }
    }
    
    private func applyLocalFilters() {
        let sourceResults = viewModel.detailedFlightResults
        print("Applying local filters to \(sourceResults.count) results")
        
        switch selectedFilter {
        case .all:
            filteredResults = sourceResults
            
        case .best:
            // Handle "best" locally since API doesn't support it
            let bestResults = sourceResults.filter { $0.isBest }
            let otherResults = sourceResults.filter { !$0.isBest }
            filteredResults = bestResults + otherResults
            
        case .cheapest:
            let cheapestResults = sourceResults.filter { $0.isCheapest }
            let otherResults = sourceResults.filter { !$0.isCheapest }.sorted { $0.minPrice < $1.minPrice }
            filteredResults = cheapestResults + otherResults
            
        case .fastest:
            let fastestResults = sourceResults.filter { $0.isFastest }
            let otherResults = sourceResults.filter { !$0.isFastest }.sorted { $0.totalDuration < $1.totalDuration }
            filteredResults = fastestResults + otherResults
            
        case .direct:
            let directFlights = sourceResults.filter { flight in
                flight.legs.allSatisfy { $0.stopCount == 0 }
            }.sorted { $0.minPrice < $1.minPrice }
            
            let connectingFlights = sourceResults.filter { flight in
                !flight.legs.allSatisfy { $0.stopCount == 0 }
            }.sorted { $0.minPrice < $1.minPrice }
            
            filteredResults = directFlights + connectingFlights
        }
        
        print("Filter \(selectedFilter.rawValue) applied: \(filteredResults.count) results")
    }
}




// Also update the ModernMultiCityFlightCardWrapper to include airline logos
struct ModernMultiCityFlightCardWrapper: View {
    let result: FlightDetailResult
    @ObservedObject var viewModel: ExploreViewModel
    var onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 0) {
                // Tags at the top inside the card
                if result.isBest || result.isCheapest || result.isFastest {
                    HStack(spacing: 6) {
                        if result.isBest {
                            TagView(text: "Best", color: .blue)
                        }
                        if result.isCheapest {
                            TagView(text: "Cheapest", color: .green)
                        }
                        if result.isFastest {
                            TagView(text: "Fastest", color: .purple)
                        }
                        Spacer()
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 12)
                    .padding(.bottom, 8)
                }
                
                // Display each leg
                ForEach(0..<result.legs.count, id: \.self) { index in
                    let leg = result.legs[index]
                    
                    if index > 0 {
                        Divider()
                            .padding(.horizontal, 16)
                    }
 
                    // Flight leg details with airline logo
                    if let segment = leg.segments.first {
                        HStack(alignment: .center, spacing: 12) {
                            // Airline logo
                            AsyncImage(url: URL(string: segment.airlineLogo)) { phase in
                                switch phase {
                                case .success(let image):
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 24, height: 24)
                                        .clipShape(RoundedRectangle(cornerRadius: 4))
                                case .failure(_), .empty:
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 4)
                                            .fill(Color.blue.opacity(0.1))
                                            .frame(width: 24, height: 24)
                                        
                                        Text(String(segment.airlineIata.prefix(1)))
                                            .font(.system(size: 10, weight: .bold))
                                            .foregroundColor(.blue)
                                    }
                                @unknown default:
                                    EmptyView()
                                }
                            }
                            
                            // Flight details
                            VStack(alignment: .leading, spacing: 2) {
                                HStack {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(formatTime(from: segment.departureTimeAirport))
                                            .font(.system(size: 16, weight: .semibold))
                                        HStack(spacing: 4) {
                                            Text(segment.originCode)
                                                .font(.system(size: 12, weight: .medium))
                                            Text(formatDateShort(from: segment.departureTimeAirport))
                                                .font(.system(size: 10))
                                                .foregroundColor(.gray)
                                        }
                                    }
                                    
                                    Spacer()
                                    
                                    // Duration and direct info
                                    VStack(spacing: 2) {
                                        Text(formatDuration(minutes: leg.duration))
                                            .font(.system(size: 10))
                                            .foregroundColor(.gray)
                                        
                                        if leg.stopCount == 0 {
                                            Text("Direct")
                                                .font(.system(size: 9, weight: .medium))
                                                .foregroundColor(.green)
                                                .padding(.horizontal, 6)
                                                .padding(.vertical, 1)
                                                .background(Color.green.opacity(0.1))
                                                .cornerRadius(3)
                                        } else {
                                            Text("\(leg.stopCount) Stop\(leg.stopCount > 1 ? "s" : "")")
                                                .font(.system(size: 9, weight: .medium))
                                                .foregroundColor(.orange)
                                                .padding(.horizontal, 6)
                                                .padding(.vertical, 1)
                                                .background(Color.orange.opacity(0.1))
                                                .cornerRadius(3)
                                        }
                                    }
                                    
                                    Spacer()
                                    
                                    VStack(alignment: .trailing, spacing: 2) {
                                        Text(formatTime(from: segment.arriveTimeAirport))
                                            .font(.system(size: 16, weight: .semibold))
                                        HStack(spacing: 4) {
                                            Text(formatDateShort(from: segment.arriveTimeAirport))
                                                .font(.system(size: 10))
                                                .foregroundColor(.gray)
                                            Text(segment.destinationCode)
                                                .font(.system(size: 12, weight: .medium))
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 8)
                    }
                }
                
                Divider()
                    .padding(.horizontal, 16)
                
                // Price and total duration
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Total Duration: \(formatDuration(minutes: result.totalDuration))")
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                        
                        Text("₹\(Int(result.minPrice))")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.black)
                        
                        Text("For \(viewModel.adultsCount + viewModel.childrenCount) People ₹\(Int(result.minPrice * Double(viewModel.adultsCount + viewModel.childrenCount)))")
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
            .shadow(color: Color.black.opacity(0.08), radius: 4, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // Helper functions for formatting
    private func formatTime(from timestamp: Int) -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(timestamp))
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
    
    private func formatDateShort(from timestamp: Int) -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(timestamp))
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM"
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
                        .background(Color.orange)
                        .cornerRadius(8)
                }
            }
        }
    }
}


// MARK: - Enhanced Detailed Flight Card Skeleton
struct DetailedFlightCardSkeleton: View {
    var body: some View {
        EnhancedDetailedFlightCardSkeleton()
    }
}



struct FlightFilterSheet: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: ExploreViewModel
    
    // Sort options
    @State private var sortOption: SortOption = .best
    @State private var hasSortChanged = false
    
    // Stop filters
    @State private var directFlightsSelected = true
    @State private var oneStopSelected = false
    @State private var multiStopSelected = false
    @State private var hasStopsChanged = false
    
    // Price range
    @State private var priceRange: [Double] = [0.0, 2000.0]
    @State private var hasPriceChanged = false
    
    // Time range sliders
    @State private var departureTimes = [0.0, 24.0]
    @State private var arrivalTimes = [0.0, 24.0]
    @State private var hasTimesChanged = false
    
    // Duration slider
    @State private var durationRange = [1.75, 8.5]
    @State private var hasDurationChanged = false
    
    // Airlines - populated from API response
    @State private var selectedAirlines: Set<String> = []
    @State private var hasAirlinesChanged = false
    @State private var availableAirlines: [(name: String, code: String, logo: String)] = []
    
    enum SortOption: String, CaseIterable {
        case best = "Best"
        case cheapest = "Cheapest"
        case fastest = "Fastest"
        case outboundTakeOff = "Outbound Take Off Time"
        case outboundLanding = "Outbound Landing Time"
    }
    
    // Map FlightFilterTabView.FilterOption to SortOption
        private func mapFilterOptionToSortOption(_ option: FlightFilterTabView.FilterOption) -> SortOption {
            switch option {
            case .best:
                return .best
            case .cheapest:
                return .cheapest
            case .fastest:
                return .fastest
            default:
                return .best
            }
        }
        
        // Map SortOption to FlightFilterTabView.FilterOption
        private func mapSortOptionToFilterOption(_ option: SortOption) -> FlightFilterTabView.FilterOption {
            switch option {
            case .best:
                return .best
            case .cheapest:
                return .cheapest
            case .fastest:
                return .fastest
            default:
                return .best
            }
        }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Sort options section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Sort")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        ForEach(SortOption.allCases, id: \.self) { option in
                            HStack {
                                Text(option.rawValue)
                                    .foregroundColor(.primary)
                                
                                Spacer()
                                
                                // Checkmark for selected option
                                Image(systemName: sortOption == option ? "inset.filled.square" : "square")
                                    .foregroundColor(sortOption == option ? .blue : .gray)
                                    .onTapGesture {
                                        sortOption = option
                                        hasSortChanged = true
                                    }
                            }
                        }
                    }
                    
                    Divider()
                    
                    // Stops section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Stops")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        // Direct flights
                        HStack {
                            VStack(alignment: .leading) {
                                Text("Direct flights")
                                    .foregroundColor(.primary)
                                Text("From ₹3200")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            
                            Spacer()
                            
                            Image(systemName: directFlightsSelected ? "checkmark.square.fill" : "square")
                                .foregroundColor(directFlightsSelected ? .blue : .gray)
                                .onTapGesture {
                                    directFlightsSelected.toggle()
                                    hasStopsChanged = true
                                }
                        }
                        
                        // 1 Stop
                        HStack {
                            VStack(alignment: .leading) {
                                Text("1 Stop")
                                    .foregroundColor(.primary)
                                Text("From ₹2800")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            
                            Spacer()
                            
                            Image(systemName: oneStopSelected ? "checkmark.square.fill" : "square")
                                .foregroundColor(oneStopSelected ? .blue : .gray)
                                .onTapGesture {
                                    oneStopSelected.toggle()
                                    hasStopsChanged = true
                                }
                        }
                        
                        // 2+ Stops
                        HStack {
                            VStack(alignment: .leading) {
                                Text("2+ Stops")
                                    .foregroundColor(.primary)
                                Text("From ₹2400")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            
                            Spacer()
                            
                            Image(systemName: multiStopSelected ? "checkmark.square.fill" : "square")
                                .foregroundColor(multiStopSelected ? .blue : .gray)
                                .onTapGesture {
                                    multiStopSelected.toggle()
                                    hasStopsChanged = true
                                }
                        }
                    }
                    
                    Divider()
                    
                    // Price range section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Price Range")
                            .font(.headline)
                        
                        Text("\(formatPrice(priceRange[0])) - \(formatPrice(priceRange[1]))")
                            .foregroundColor(.primary)
                        
                        RangeSliderView(values: $priceRange, minValue: 0, maxValue: max(2000, priceRange[1] * 1.2), onChangeHandler: {
                            hasPriceChanged = true
                        })
                        
                        HStack {
                            Text(formatPrice(priceRange[0]))
                                .font(.caption)
                                .foregroundColor(.gray)
                            
                            Spacer()
                            
                            Text(formatPrice(priceRange[1]))
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                    
                    Divider()
                    
                    // Times section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Times")
                            .font(.headline)
                        
                        Text("\(viewModel.selectedOriginCode) - \(viewModel.selectedDestinationCode)")
                            .foregroundColor(.gray)
                        
                        // Departure time slider
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Departure")
                                .foregroundColor(.primary)
                            
                            RangeSliderView(values: $departureTimes, minValue: 0, maxValue: 24, onChangeHandler: {
                                hasTimesChanged = true
                            })
                            
                            HStack {
                                Text(formatTime(hours: Int(departureTimes[0])))
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                
                                Spacer()
                                
                                Text(formatTime(hours: Int(departureTimes[1])))
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                        }
                        
                        // Arrival time slider
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Arrival")
                                .foregroundColor(.primary)
                            
                            RangeSliderView(values: $arrivalTimes, minValue: 0, maxValue: 24, onChangeHandler: {
                                hasTimesChanged = true
                            })
                            
                            HStack {
                                Text(formatTime(hours: Int(arrivalTimes[0])))
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                
                                Spacer()
                                
                                Text(formatTime(hours: Int(arrivalTimes[1])))
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    
                    Divider()
                    
                    // Duration section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Journey Duration")
                            .font(.headline)
                        
                        Text("\(formatDuration(hours: durationRange[0])) - \(formatDuration(hours: durationRange[1]))")
                            .foregroundColor(.primary)
                        
                        RangeSliderView(values: $durationRange, minValue: 1, maxValue: 8.5, onChangeHandler: {
                            hasDurationChanged = true
                        })
                        
                        HStack {
                            Text(formatDuration(hours: durationRange[0]))
                                .font(.caption)
                                .foregroundColor(.gray)
                            
                            Spacer()
                            
                            Text(formatDuration(hours: durationRange[1]))
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                    
                    Divider()
                    
                    // Airlines section - only show if we have airline data
                    if !availableAirlines.isEmpty {
                        airlinesSection
                    }
                }
                .padding()
            }
            .navigationTitle("Filter")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                // Close button
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark")
                            .foregroundColor(.primary)
                    }
                }
                
                // Clear all button
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Clear all") {
                        resetFilters()
                    }
                    .foregroundColor(.blue)
                }
            }
            // Apply button at the bottom
            .safeAreaInset(edge: .bottom) {
                Button(action: {
                    applyFilters()
                }) {
                    Text("Apply Filters")
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.orange)
                        .cornerRadius(8)
                        .padding()
                }
                .background(Color(.systemBackground))
            }
        }
        .onAppear {
            // Load airlines from the viewModel's current results if available
            populateAirlinesFromResults()
            
            // Set initial price range based on min/max prices from results if available
            initializePriceRange()
            
            // Load saved filter state from the viewModel
            loadFilterStateFromViewModel()
        }    }
    
    // MARK: - UI Sections
    
    private var airlinesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Airlines")
                    .font(.headline)
                
                Spacer()
                
                Button("Clear all") {
                    selectedAirlines.removeAll()
                    hasAirlinesChanged = true
                }
                .foregroundColor(.blue)
                .font(.subheadline)
            }
            
            ForEach(availableAirlines, id: \.code) { airline in
                HStack {
                    // Airline logo using AsyncImage
                    if !airline.logo.isEmpty {
                        AsyncImage(url: URL(string: airline.logo)) { phase in
                            if let image = phase.image {
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 24, height: 24)
                            } else {
                                // Placeholder for loading or failed loads
                                ZStack {
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(Color.gray.opacity(0.2))
                                        .frame(width: 24, height: 24)
                                    
                                    Text(String(airline.code.prefix(1)))
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                    } else {
                        // Fallback if no logo URL
                        ZStack {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.gray.opacity(0.2))
                                .frame(width: 24, height: 24)
                            
                            Text(String(airline.code.prefix(1)))
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                    
                    Text(airline.name)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    // Checkmark for selected airlines
                    Image(systemName: selectedAirlines.contains(airline.code) ? "checkmark.square.fill" : "square")
                        .foregroundColor(selectedAirlines.contains(airline.code) ? .blue : .gray)
                        .onTapGesture {
                            if selectedAirlines.contains(airline.code) {
                                selectedAirlines.remove(airline.code)
                            } else {
                                selectedAirlines.insert(airline.code)
                            }
                            hasAirlinesChanged = true
                        }
                }
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func formatTime(hours: Int) -> String {
        let hour = hours % 12 == 0 ? 12 : hours % 12
        let amPm = hours < 12 ? "am" : "pm"
        return "\(hour):00 \(amPm)"
    }
    
    private func formatDuration(hours: Double) -> String {
        let wholeHours = Int(hours)
        let minutes = Int((hours - Double(wholeHours)) * 60)
        return "\(wholeHours)h \(minutes)m"
    }
    
    private func formatPrice(_ price: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "₹" // Update based on user's locale or app settings
        formatter.maximumFractionDigits = 0
        
        return formatter.string(from: NSNumber(value: price)) ?? "₹\(Int(price))"
    }
    
    private func resetFilters() {
        // Reset all filters to default values
        sortOption = .best
        hasSortChanged = false
        
        directFlightsSelected = true
        oneStopSelected = false
        multiStopSelected = false
        hasStopsChanged = false
        
        departureTimes = [0.0, 24.0]
        arrivalTimes = [0.0, 24.0]
        hasTimesChanged = false
        
        durationRange = [1.75, 8.5]
        hasDurationChanged = false
        
        selectedAirlines.removeAll()
        hasAirlinesChanged = false
        
        // Reset price range based on available flights
        initializePriceRange()
        hasPriceChanged = false
    }
    
    private func populateAirlinesFromResults() {
        // Get unique airlines from current flight results
        if let pollResponse = viewModel.lastPollResponse {
            self.availableAirlines = pollResponse.airlines.map { airline in
                return (name: airline.airlineName, code: airline.airlineIata, logo: airline.airlineLogo)
            }
            
            // If airlines were previously selected, filter to only include airlines that exist in the response
            if !selectedAirlines.isEmpty {
                let availableCodes = Set(availableAirlines.map { $0.code })
                selectedAirlines = selectedAirlines.intersection(availableCodes)
            }
        }
    }
    
    private func initializePriceRange() {
        // Set price range based on min/max price in results
        if let pollResponse = viewModel.lastPollResponse {
            let minPrice = pollResponse.minPrice
            let maxPrice = pollResponse.maxPrice
            
            // Only update if we have valid prices
            if minPrice > 0 && maxPrice >= minPrice {
                priceRange = [minPrice, maxPrice]
            }
        }
    }
    
    // Modified to only include filters that user has interacted with
    private func applyFilters() {
        // Create an empty filter request
        var filterRequest = FlightFilterRequest()
        
        // Only add sort options if changed by user
        if hasSortChanged {
            switch sortOption {
            case .best:
                // Don't set sortBy for "best" - it's not supported by API
                filterRequest.sortBy = nil
            case .cheapest:
                filterRequest.sortBy = "price"
                filterRequest.sortOrder = "asc"
            case .fastest:
                filterRequest.sortBy = "duration"
                filterRequest.sortOrder = "asc"
            case .outboundTakeOff:
                filterRequest.sortBy = "departure"
            case .outboundLanding:
                filterRequest.sortBy = "arrival"
            }
        }
        
        // Only add stop count if changed by user
        if hasStopsChanged {
            if directFlightsSelected && !oneStopSelected && !multiStopSelected {
                filterRequest.stopCountMax = 0
            } else if (directFlightsSelected && oneStopSelected) || (!directFlightsSelected && oneStopSelected && !multiStopSelected) {
                filterRequest.stopCountMax = 1
            }
        }
        
        // Only add price range if changed by user
        if hasPriceChanged {
            filterRequest.priceMin = Int(priceRange[0])
            filterRequest.priceMax = Int(priceRange[1])
        }
        
        // Only add duration if changed by user
        if hasDurationChanged {
            filterRequest.durationMax = Int(durationRange[1] * 60)
        }
        
        // Only add time ranges if changed by user
        if hasTimesChanged {
            let departureMin = Int(departureTimes[0] * 3600) // Convert to seconds
            let departureMax = Int(departureTimes[1] * 3600)
            let arrivalMin = Int(arrivalTimes[0] * 3600)
            let arrivalMax = Int(arrivalTimes[1] * 3600)
            
            let timeRange = ArrivalDepartureRange(
                arrival: TimeRange(min: arrivalMin, max: arrivalMax),
                departure: TimeRange(min: departureMin, max: departureMax)
            )
            filterRequest.arrivalDepartureRanges = [timeRange]
        }
        
        // Only add airline filters if changed by user
        if hasAirlinesChanged && !selectedAirlines.isEmpty && selectedAirlines.count < availableAirlines.count {
            filterRequest.iataCodesInclude = Array(selectedAirlines)
        }
        
        // SAVE FILTER STATE TO VIEW MODEL
        saveFilterStateToViewModel()
        
        // Apply the filter through the API
        viewModel.applyPollFilters(filterRequest: filterRequest)
        
        // Dismiss the sheet
        dismiss()
    }
    
    private func saveFilterStateToViewModel() {
            viewModel.filterSheetState.sortOption = mapSortOptionToFilterOption(sortOption)
            viewModel.filterSheetState.directFlightsSelected = directFlightsSelected
            viewModel.filterSheetState.oneStopSelected = oneStopSelected
            viewModel.filterSheetState.multiStopSelected = multiStopSelected
            viewModel.filterSheetState.priceRange = priceRange
            viewModel.filterSheetState.departureTimes = departureTimes
            viewModel.filterSheetState.arrivalTimes = arrivalTimes
            viewModel.filterSheetState.durationRange = durationRange
            viewModel.filterSheetState.selectedAirlines = selectedAirlines
        }
        
        private func loadFilterStateFromViewModel() {
            sortOption = mapFilterOptionToSortOption(viewModel.filterSheetState.sortOption)
            directFlightsSelected = viewModel.filterSheetState.directFlightsSelected
            oneStopSelected = viewModel.filterSheetState.oneStopSelected
            multiStopSelected = viewModel.filterSheetState.multiStopSelected
            
            // Only load price range if it's been previously set
            if viewModel.filterSheetState.priceRange != [0.0, 2000.0] {
                priceRange = viewModel.filterSheetState.priceRange
            }
            
            departureTimes = viewModel.filterSheetState.departureTimes
            arrivalTimes = viewModel.filterSheetState.arrivalTimes
            durationRange = viewModel.filterSheetState.durationRange
            selectedAirlines = viewModel.filterSheetState.selectedAirlines
        }
    
    
    // Helper method to print applied filters for debugging
    private func printAppliedFilters(_ request: FlightFilterRequest) {
        var filterDescription = "Applied filters: "
        
        if let sortBy = request.sortBy {
            filterDescription += "Sort by \(sortBy) "
            if let sortOrder = request.sortOrder {
                filterDescription += "(\(sortOrder)), "
            }
        }
        
        if let stopCountMax = request.stopCountMax {
            filterDescription += "Max stops: \(stopCountMax), "
        }
        
        if let priceMin = request.priceMin, let priceMax = request.priceMax {
            filterDescription += "Price: \(priceMin)-\(priceMax), "
        }
        
        if let durationMax = request.durationMax {
            filterDescription += "Max duration: \(durationMax/60)h \(durationMax%60)m, "
        }
        
        if let airlines = request.iataCodesInclude, !airlines.isEmpty {
            filterDescription += "Airlines: \(airlines.joined(separator: ", ")), "
        }
        
        print(filterDescription)
    }
}

// Updated RangeSliderView with callback for change detection
struct RangeSliderView: View {
    @Binding var values: [Double]
    let minValue: Double
    let maxValue: Double
    var onChangeHandler: (() -> Void)? = nil
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Track
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 4)
                
                // Selected Range
                Rectangle()
                    .fill(Color.blue)
                    .frame(width: CGFloat((values[1] - values[0]) / (maxValue - minValue)) * geometry.size.width,
                           height: 4)
                    .offset(x: CGFloat((values[0] - minValue) / (maxValue - minValue)) * geometry.size.width)
                
                // Low Thumb
                Circle()
                    .fill(Color.white)
                    .frame(width: 20, height: 20)
                    .shadow(radius: 2)
                    .offset(x: CGFloat((values[0] - minValue) / (maxValue - minValue)) * geometry.size.width - 10)
                    .gesture(
                        DragGesture()
                            .onChanged { gesture in
                                let ratio = gesture.location.x / geometry.size.width
                                let newValue = min(values[1] - 0.5, max(minValue, minValue + ratio * (maxValue - minValue)))
                                values[0] = newValue
                                onChangeHandler?()
                            }
                    )
                
                // High Thumb
                Circle()
                    .fill(Color.white)
                    .frame(width: 20, height: 20)
                    .shadow(radius: 2)
                    .offset(x: CGFloat((values[1] - minValue) / (maxValue - minValue)) * geometry.size.width - 10)
                    .gesture(
                        DragGesture()
                            .onChanged { gesture in
                                let ratio = gesture.location.x / geometry.size.width
                                let newValue = max(values[0] + 0.5, min(maxValue, minValue + ratio * (maxValue - minValue)))
                                values[1] = newValue
                                onChangeHandler?()
                            }
                    )
            }
        }
        .frame(height: 30)
    }
}


struct PaginatedFlightList: View {
    @ObservedObject var viewModel: ExploreViewModel
    let filteredResults: [FlightDetailResult]
    let isMultiCity: Bool
    let onFlightSelected: (FlightDetailResult) -> Void
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                // Flight results
                ForEach(filteredResults, id: \.id) { result in
                    if isMultiCity {
                        ModernMultiCityFlightCardWrapper(
                            result: result,
                            viewModel: viewModel,
                            onTap: {
                                onFlightSelected(result)
                            }
                        )
                        .padding(.horizontal)
                    } else {
                        DetailedFlightCardWrapper(
                            result: result,
                            viewModel: viewModel,
                            onTap: {
                                onFlightSelected(result)
                            }
                        )
                        .padding(.horizontal)
                    }
                }
                
                // FIXED: Updated footer with proper logic
                ScrollViewFooter(
                    viewModel: viewModel,
                    loadMore: {
                        viewModel.loadMoreFlights()
                    }
                )
                
                // Bottom spacer
                Spacer(minLength: 50)
            }
            .padding(.vertical)
        }
        .background(Color("scroll"))
    }
}

// Preference keys for tracking scroll state
struct ScrollViewHeightPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

struct ScrollViewOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}


// MARK: - Good to Know Section
struct GoodToKnowSection: View {
    let originCode: String
    let destinationCode: String
    let isRoundTrip: Bool
    @State private var showingSelfTransferInfo = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Good to Know")
                .font(.headline)
                .foregroundColor(.primary)
                .padding(.horizontal)
            
            VStack(spacing: 12) {
                // Departure/Return info
                if isRoundTrip {
                    HStack {
                        Image(systemName: "info.circle.fill")
                            .foregroundColor(.secondary)
                            .font(.system(size: 16))
                        
                        Text("You are departing from \(originCode)\n but returning to \(destinationCode)")
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                        
                        Spacer()
                    }
                    .padding(.horizontal)
                }
                
                // Self Transfer row
                Button(action: {
                    showingSelfTransferInfo = true
                }) {
                    HStack {
                        Image(systemName: "suitcase.fill")
                            .foregroundColor(.secondary)
                            .font(.system(size: 16))
                        
                        Text("Self Transfer")
                            .font(.system(size: 16))
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .foregroundColor(.gray)
                            .font(.system(size: 14))
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                }
                .background(Color(.systemBackground))
            }
        }
        .padding(.vertical)
        .background(Color(.white))
        .cornerRadius(16)
        .padding(.horizontal)
        .sheet(isPresented: $showingSelfTransferInfo) {
            SelfTransferInfoSheet()
                .presentationDetents([.fraction(0.75)])
        }
    }
}

// MARK: - Self Transfer Info Sheet
struct SelfTransferInfoSheet: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.primary)
                }
                
                Spacer()
                
                Text("Self-transfer")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.primary)
                
                Spacer()
                
                // Invisible spacer to center the title
                Image(systemName: "xmark")
                    .font(.system(size: 18))
                    .opacity(0)
            }
            .padding(.horizontal)
            .padding(.vertical, 16)
            .background(Color(.systemBackground))
            
            Divider()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Main explanation text
                    Text("In a self-transfer trip, you book separate flights, and you're responsible for moving between them — including baggage, check-ins, and reaching the next gate or airport on time.")
                        .font(.system(size: 16))
                        .foregroundColor(.primary)
                        .lineSpacing(4)
                        .padding(.top, 20)
                    
                    // What You'll Need to Do section
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(spacing: 6) {
                            Text("🧳")
                                .font(.system(size: 16))
                            
                            Text("What You'll Need to Do:")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.primary)
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            bulletPoint("Collect and recheck baggage between flights.")
                            bulletPoint("Clear immigration/customs if switching countries.")
                            bulletPoint("Check in again for your next flight.")
                            bulletPoint("Leave extra time between flights — delays can affect your next journey.")
                        }
                        .padding(.leading, 22)
                    }
                    
                    // Example section
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(spacing: 6) {
                            Text("📍")
                                .font(.system(size: 16))
                            
                            Text("Example:")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.primary)
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Flight 1: New York → Paris")
                                .font(.system(size: 15))
                                .foregroundColor(.primary)
                            
                            Text("Flight 2: Paris → Rome")
                                .font(.system(size: 15))
                                .foregroundColor(.primary)
                        }
                        .padding(.leading, 22)
                        
                        HStack(spacing: 6) {
                            Text("✈️")
                                .font(.system(size: 14))
                            
                            Text("Once you land in Paris, you'll collect your bags, clear immigration, and check in again.")
                                .font(.system(size: 15))
                                .foregroundColor(.secondary)
                                .lineSpacing(2)
                        }
                        .padding(.leading, 22)
                        .padding(.top, 8)
                    }
                    
                    // You're in control section
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(spacing: 6) {
                            Text("⚠️")
                                .font(.system(size: 16))
                            
                            Text("You're in control:")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.primary)
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("These flights aren't connected. If delayed, airlines aren't responsible for missed connections.")
                                .font(.system(size: 15))
                                .foregroundColor(.primary)
                                .lineSpacing(2)
                            
                            Text("We recommend at least 4-6 hours between flights.")
                                .font(.system(size: 15))
                                .foregroundColor(.primary)
                                .lineSpacing(2)
                        }
                        .padding(.leading, 22)
                    }
                    
                    Spacer(minLength: 40)
                }
                .padding(.horizontal, 20)
            }
        }
        .background(Color(.systemBackground))
    }
    
    @ViewBuilder
    private func bulletPoint(_ text: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Text("•")
                .font(.system(size: 15, weight: .bold))
                .foregroundColor(.primary)
                .padding(.top, 1)
            
            Text(text)
                .font(.system(size: 15))
                .foregroundColor(.primary)
                .lineSpacing(2)
        }
    }
}

// MARK: - Deals Section
struct DealsSection: View {
    let providers: [FlightProvider]
    let cheapestProvider: FlightProvider?
    
    // Combined state to track both URL and whether to show the sheet
    @State private var dealToShow: String? = nil
    @State private var showingAllDeals = false
    
    private var additionalDealsCount: Int {
        return max(0, providers.count - 1)
    }
    
    var body: some View {
        VStack(spacing: 12) {
            // More deals available button
            if additionalDealsCount > 0 {
                Button(action: {
                    showingAllDeals = true
                }) {
                    HStack {
                        Text("\(additionalDealsCount) more deals available")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.blue)
                        
                        Image(systemName: "chevron.up")
                            .foregroundColor(.blue)
                            .font(.system(size: 14))
                    }
                }
                .padding(.horizontal)
                .padding(.top, 20)
            }
            
            if additionalDealsCount > 0 {
                Divider()
            }
            
            // Cheapest deal section
            if let cheapest = cheapestProvider,
               let splitProvider = cheapest.splitProviders.first {
                
                HStack {
                    Text("Cheap Deal for you")
                        .font(.system(size: 16,))
                        .foregroundColor(.secondary)
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.top, 12)
                
                HStack {
                    Text(splitProvider.name)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    // View Deal button
                    Button(action: {
                        // Store the URL first, then show the sheet
                        if !splitProvider.deeplink.isEmpty {
                            print("Setting URL and showing sheet: \(splitProvider.deeplink)")
                            dealToShow = splitProvider.deeplink
                        } else {
                            print("Empty URL, using fallback")
                            dealToShow = "https://google.com" // Fallback URL
                        }
                    }) {
                        Text("View Deal")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white)
                            .padding(16)
                            .background(Color.orange)
                            .cornerRadius(12)
                    }
                    .buttonStyle(BorderlessButtonStyle()) // This helps with button responsiveness
                }
                .padding(.horizontal)
                .padding(.bottom, 16)
            }
        }
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
        .padding(.horizontal)
        .padding(.bottom, 20)
        
        // Sheet for showing all deals
        .sheet(isPresented: $showingAllDeals) {
            ProviderSelectionSheet(
                providers: providers,
                onProviderSelected: { deeplink in
                    // Store the URL to show after dismissing this sheet
                    if !deeplink.isEmpty {
                        dealToShow = deeplink
                    }
                    showingAllDeals = false
                }
            )
        }
        
        // Use this technique to show the web view with a URL
        .fullScreenCover(item: Binding(
            get: { dealToShow.map { WebViewURL(url: $0) } },
            set: { newValue in dealToShow = newValue?.url }
        )) { webViewURL in
            SafariView(url: webViewURL.url)
                .edgesIgnoringSafeArea(.all)
        }
    }
}

// Helper struct to make the URL identifiable for fullScreenCover
struct WebViewURL: Identifiable {
    let id = UUID()
    let url: String
}

// Clean SafariView that directly uses SFSafariViewController
struct SafariView: UIViewControllerRepresentable {
    let url: String
    
    func makeUIViewController(context: Context) -> SFSafariViewController {
        let finalURL: URL
        
        if let validURL = URL(string: url) {
            finalURL = validURL
        } else {
            print("⚠️ Invalid URL: \(url). Using fallback.")
            finalURL = URL(string: "https://google.com")!
        }
        
        let controller = SFSafariViewController(url: finalURL)
        controller.preferredControlTintColor = UIColor.systemOrange
        return controller
    }
    
    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {
        // Nothing to update
    }
}


// MARK: - Provider Selection Sheet - Updated to match exact UI
struct ProviderSelectionSheet: View {
    @Environment(\.dismiss) private var dismiss
    let providers: [FlightProvider]
    let onProviderSelected: (String) -> Void
    
    @State private var isReadBeforeBookingExpanded = false
    
    private var sortedProviders: [SplitProvider] {
        let allProviders = providers.flatMap { $0.splitProviders }
        return allProviders.sorted { $0.price < $1.price }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                HStack {
                    Text("\(sortedProviders.count) providers - Price in USD")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
                
                // Read Before Booking expandable section - EXACT UI MATCH
                VStack(spacing: 0) {
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            isReadBeforeBookingExpanded.toggle()
                        }
                    }) {
                        HStack {
                            Text("Read Before Booking")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.blue)
                            

                            
                            Image(systemName: isReadBeforeBookingExpanded ? "chevron.up" : "chevron.down")
                                .foregroundColor(.blue)
                                .font(.system(size: 14))
                                .rotationEffect(.degrees(isReadBeforeBookingExpanded ? 0 : 0))
                                .animation(.easeInOut(duration: 0.3), value: isReadBeforeBookingExpanded)
                            
                            Spacer()
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 12)
                    }
                    
                    if isReadBeforeBookingExpanded {
                        VStack(alignment: .leading, spacing: 16) {
                            // First paragraph - Prices information
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Prices shown always include an estimate of all mandatory taxes and charges, but remember ")
                                    .font(.system(size: 14))
                                    .foregroundColor(.primary)
                                + Text("to check all ticket details, final prices and terms and conditions")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.primary)
                                + Text(" on the booking website before you book.")
                                    .font(.system(size: 14))
                                    .foregroundColor(.primary)
                            }
                            
                            // Second section - Check for extra fees
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Check for extra fees")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.primary)
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Some airlines / travel agencies charge extra for baggage, insurance or use of credit cards and include a service fee.")
                                        .font(.system(size: 14))
                                        .foregroundColor(.primary)
                                    
                                    Text("View airlines fees.")
                                        .font(.system(size: 14))
                                        .foregroundColor(.primary)
                                       
                                }
                            }
                            
                            // Third section - Check T&Cs for travellers aged 12-16
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Check T&Cs for travellers aged 12-16")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.primary)
                                
                                Text("Restrictions may apply to young passengers travelling alone.")
                                    .font(.system(size: 14))
                                    .foregroundColor(.primary)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 16)
                        .transition(.opacity.combined(with: .move(edge: .top)))
                    }
                }
                
                
                // Provider list
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(Array(sortedProviders.enumerated()), id: \.element.deeplink) { index, provider in
                            ProviderRow(
                                provider: provider,
                                onSelected: {
                                    onProviderSelected(provider.deeplink)
                                    dismiss()
                                }
                            )
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                }
            }
            .background(Color("scroll"))
            .navigationTitle("Choose Provider")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark")
                            .foregroundColor(.white)
                    }
                }
            }
        }
    }
}

// MARK: - Provider Row
struct ProviderRow: View {
    let provider: SplitProvider
    let onSelected: () -> Void
    
    private var supportFeatures: [String] {
        var features: [String] = []
        
        // Add features based on provider rating and other criteria
        if let rating = provider.rating, rating >= 4.5 {
            features.append("24/7 Customer support")
        }
        if provider.name.lowercased().contains("cleartrip") ||
           provider.name.lowercased().contains("makemytrip") {
            features.append("Email Notifications")
            features.append("Chat Support")
        } else if provider.name.lowercased().contains("goibibo") {
            features.append("Telephone Support")
        } else {
            features.append("Phone & Email Support")
        }
        
        return features
    }
    
    var body: some View {
        HStack(spacing: 16) {
            // Provider logo
            AsyncImage(url: URL(string: provider.imageURL)) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 40, height: 40)
                case .failure(_), .empty:
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.gray.opacity(0.2))
                        .frame(width: 40, height: 40)
                        .overlay(
                            Text(String(provider.name.prefix(2)))
                                .font(.caption)
                                .fontWeight(.bold)
                        )
                @unknown default:
                    EmptyView()
                }
            }
            
            // Provider info
            VStack(alignment: .leading, spacing: 4) {
                VStack(spacing:2){
                    Text(provider.name)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.primary)
                    
                    if let rating = provider.rating,
                       let ratingCount = provider.ratingCount {
                        HStack(spacing: 2) {
                            Image(systemName: "star.fill")
                                .foregroundColor(.orange)
                                .font(.system(size: 10))
                            
                            Text("\(String(format: "%.1f", rating))")
                                .font(.system(size: 12))
                                .foregroundColor(.secondary)
                            
                            Text("•")
                                .font(.system(size: 12))
                                .foregroundColor(.secondary)
                            
                            Text("\(ratingCount)")
                                .font(.system(size: 12))
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                // Support features
                VStack(alignment: .leading, spacing: 2) {
                    ForEach(supportFeatures, id: \.self) { feature in
                        HStack(spacing: 4) {
                            Image(systemName: "checkmark")
                                .foregroundColor(.green)
                                .font(.system(size: 10))
                            
                            Text(feature)
                                .font(.system(size: 12))
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            
            Spacer()
            
            // Price and button
            VStack(alignment: .trailing, spacing: 8) {
                Text("₹\(String(format: "%.2f", provider.price))")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.primary)
                
                Button(action: {
                    print("View Deal button tapped for: \(provider.name)")
                    onSelected()
                }) {
                    Text("View Deal")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.orange)
                        .cornerRadius(6)
                }
                .buttonStyle(BorderlessButtonStyle()) // Helps with responsiveness
            }
        }
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}

// MARK: - WebView Sheet
struct WebViewSheet: View {
    @Environment(\.dismiss) private var dismiss
    let url: String
    
    var body: some View {
        NavigationView {
            // Check if URL is valid before trying to load it
            Group {
                if url.isEmpty {
                    VStack(spacing: 20) {
                        Text("Error: No URL provided")
                            .font(.headline)
                            .foregroundColor(.red)
                        
                        Button("Close") {
                            dismiss()
                        }
                        .buttonStyle(.borderedProminent)
                    }
                } else if URL(string: url) == nil {
                    VStack(spacing: 20) {
                        Text("Error: Invalid URL format")
                            .font(.headline)
                            .foregroundColor(.red)
                        
                        Text(url)
                            .font(.caption)
                            .foregroundColor(.gray)
                            .padding()
                        
                        Button("Close") {
                            dismiss()
                        }
                        .buttonStyle(.borderedProminent)
                    }
                } else {
                    WebView(url: url)
                        .edgesIgnoringSafeArea(.all)
                        .onAppear {
                            print("WebView loaded with URL: \(url)")
                        }
                }
            }
            .navigationBarItems(trailing: Button("Done") {
                dismiss()
            })
        }
    }
}

// MARK: - WebView
struct WebView: UIViewControllerRepresentable {
    let url: String
    
    func makeUIViewController(context: Context) -> SFSafariViewController {
        // Debug the URL before creating the view controller
        print("Creating SafariViewController with URL: \(url)")
        
        // Use a default URL if the provided one is invalid
        guard let validURL = URL(string: url), !url.isEmpty else {
            print("⚠️ Invalid URL: \(url) - using fallback")
            let fallbackURL = URL(string: "https://google.com")!
            let safariVC = SFSafariViewController(url: fallbackURL)
            safariVC.preferredControlTintColor = UIColor.systemOrange
            return safariVC
        }
        
        // Use the valid URL
        let safariVC = SFSafariViewController(url: validURL)
        safariVC.preferredControlTintColor = UIColor.systemOrange
        return safariVC
    }
    
    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {
        // No updates needed
    }
}

// MARK: - Updated Price Section (Replace existing PriceSection)
struct EnhancedPriceSection: View {
    let selectedFlight: FlightDetailResult
    let viewModel: ExploreViewModel
    
    private var cheapestProvider: FlightProvider? {
        return selectedFlight.providers.min(by: { $0.price < $1.price })
    }
    
    var body: some View {
        VStack(spacing: 16) {
            // Good to Know Section
            GoodToKnowSection(
                originCode: viewModel.selectedOriginCode,
                destinationCode: viewModel.selectedDestinationCode,
                isRoundTrip: viewModel.isRoundTrip
            )
            
            // Deals Section
            DealsSection(
                providers: selectedFlight.providers,
                cheapestProvider: cheapestProvider
            )
        }
    }
}


struct FlightDetailsView: View {
    @Environment(\.presentationMode) var presentationMode
    let selectedFlight: FlightDetailResult
    let viewModel: ExploreViewModel
    @State private var showingShareSheet = false
    
    init(selectedFlight: FlightDetailResult, viewModel: ExploreViewModel) {
            self.selectedFlight = selectedFlight
            self.viewModel = viewModel

            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = UIColor(named: "homeGrad") // Use your asset color here
            appearance.titleTextAttributes = [.foregroundColor: UIColor.white] // Title text color
            appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]

            UINavigationBar.appearance().standardAppearance = appearance
            UINavigationBar.appearance().scrollEdgeAppearance = appearance
        }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 0) {
                    // Flight details content
                    if viewModel.multiCityTrips.count >= 2 {
                        // Multi-city flight details display
                        ForEach(0..<selectedFlight.legs.count, id: \.self) { legIndex in
                            let leg = selectedFlight.legs[legIndex]
                            
                            HStack {
                                Text("Flight \(legIndex + 1): \(leg.originCode) → \(leg.destinationCode)")
                                    .font(.headline)
                                    .padding(.bottom, 4)
                                Spacer()
                            }
                            .padding(.horizontal)
                            .padding(.top, legIndex > 0 ? 16 : 0)
                            
                            if leg.stopCount == 0 && !leg.segments.isEmpty {
                                let segment = leg.segments.first!
                                displayDirectFlight(leg: leg, segment: segment)
                            } else if leg.stopCount > 0 && leg.segments.count > 1 {
                                displayConnectingFlight(leg: leg)
                            }
                            
                            if legIndex < selectedFlight.legs.count - 1 {
                                Divider()
                                    .padding(.horizontal)
                                    .padding(.vertical, 8)
                            }
                        }
                    } else {
                        // Regular flights display
                        if let outboundLeg = selectedFlight.legs.first {
                            if outboundLeg.stopCount == 0 && !outboundLeg.segments.isEmpty {
                                let segment = outboundLeg.segments.first!
                                displayDirectFlight(leg: outboundLeg, segment: segment)
                            } else if outboundLeg.stopCount > 0 && outboundLeg.segments.count > 1 {
                                displayConnectingFlight(leg: outboundLeg)
                            }
                            
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
                    
                    // Enhanced Price section with deals
                    EnhancedPriceSection(selectedFlight: selectedFlight, viewModel: viewModel)
                        .padding(.top)
                }
            }
            .navigationBarTitle("Flight Details", displayMode: .inline)
            .navigationBarItems(
                leading: Button(action: {
                    // This is equivalent to dismissing the view
                    viewModel.selectedFlightId = nil
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.white)
                },
                trailing: Button(action: {
                    showingShareSheet = true
                }) {
                    Image(systemName: "square.and.arrow.up")
                        .foregroundColor(.white)
                }
            )
            .sheet(isPresented: $showingShareSheet) {
                // Share sheet implementation
                ShareSheet(items: ["Check out this flight I found!"])
            }
            .background(Color("scroll"))
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    // Helper methods for displaying flight details
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
            departureTerminal: "1",
            airline: segment.airlineName,
            flightNumber: segment.flightNumber,
            airlineLogo: segment.airlineLogo,
            arrivalDate: formatDate(from: segment.arriveTimeAirport),
            arrivalTime: formatTime(from: segment.arriveTimeAirport),
            arrivalAirportCode: segment.destinationCode,
            arrivalAirportName: segment.destination,
            arrivalTerminal: "2",
            arrivalNextDay: segment.arrivalDayDifference > 0
        )
        .padding(.horizontal)
        .padding(.bottom, 16)
    }
    
    @ViewBuilder
    private func displayConnectingFlight(leg: FlightLegDetail) -> some View {
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
        
        for (index, segment) in leg.segments.enumerated() {
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
                    departureTerminal: "1",
                    arrivalDate: formatDate(from: segment.arriveTimeAirport),
                    arrivalTime: formatTime(from: segment.arriveTimeAirport),
                    arrivalAirportCode: segment.destinationCode,
                    arrivalAirportName: segment.destination,
                    arrivalTerminal: "2",
                    arrivalNextDay: segment.arrivalDayDifference > 0,
                    airline: segment.airlineName,
                    flightNumber: segment.flightNumber,
                    airlineLogo: segment.airlineLogo,
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

// Simple share sheet implementation for iOS
struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        return UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
        // No updates needed
    }
}


struct ScrollViewFooter: View {
    let viewModel: ExploreViewModel
    var loadMore: () -> Void
    
    // Computed properties for better logic
    private var shouldLoadMore: Bool {
        return viewModel.hasMoreFlights && !viewModel.isLoadingMoreFlights && !viewModel.isLoadingDetailedFlights
    }
    
    private var isLoading: Bool {
        return viewModel.isLoadingMoreFlights
    }
    
    private var hasAllFlights: Bool {
        // FIXED: Only show "all flights loaded" when we truly have all flights
        return viewModel.isDataCached &&
               viewModel.actualLoadedCount >= viewModel.totalFlightCount &&
               viewModel.totalFlightCount > 0
    }
    
    private var isWaitingForBackend: Bool {
        // Backend is still processing data
        return !viewModel.isDataCached && viewModel.totalFlightCount > 0
    }
    
    var body: some View {
        GeometryReader { geometry in
            if shouldLoadMore {
                // Trigger loading when this view becomes visible
                Color.clear
                    .preference(key: InViewKey.self, value: geometry.frame(in: .global).minY)
                    .onPreferenceChange(InViewKey.self) { value in
                        let screenHeight = UIScreen.main.bounds.height
                        if value < screenHeight + 100 {
                            print("📱 Footer in view - triggering load more")
                            loadMore()
                        }
                    }
            } else if isLoading {
                // Show loading indicator
                HStack {
                    Spacer()
                    VStack(spacing: 8) {
                        ProgressView()
                            .scaleEffect(1.0)
                        Text("Loading more flights...")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    Spacer()
                }
                .frame(height: 60)
            } else if isWaitingForBackend {
                // FIXED: Show waiting message when backend is still processing
                HStack {
                    Spacer()
                    VStack(spacing: 8) {
                        ProgressView()
                            .scaleEffect(0.8)
                        Text("Searching for more flights...")
                            .font(.caption)
                            .foregroundColor(.gray)
                        Text("(\(viewModel.actualLoadedCount) of \(viewModel.totalFlightCount)+ flights)")
                            .font(.caption2)
                            .foregroundColor(.gray)
                    }
                    Spacer()
                }
                .frame(height: 80)
                .onAppear {
                    // Automatically try to load more after a delay when waiting for backend
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                        if self.isWaitingForBackend {
                            print("🔄 Auto-retry for backend data")
                            loadMore()
                        }
                    }
                }
            } else if hasAllFlights {
                // FIXED: Only show this when we genuinely have all flights
                HStack {
                    Spacer()
                    VStack(spacing: 4) {
                        Text("All flights loaded")
                            .font(.caption)
                            .foregroundColor(.gray)
                        Text("(\(viewModel.actualLoadedCount) flights)")
                            .font(.caption2)
                            .foregroundColor(.gray)
                    }
                    Spacer()
                }
                .frame(height: 60)
            } else {
                // FIXED: Show appropriate message for other states
                HStack {
                    Spacer()
                    Text("No more flights available")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Spacer()
                }
                .frame(height: 60)
            }
        }
        .frame(height: 80)
    }
}

// 2. Create a preference key to track scroll position
struct InViewKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}


// MARK: - Enhanced Shimmer Effect
struct ShimmerEffect: ViewModifier {
    @State private var phase: CGFloat = 0
    var duration: Double = 1.5
    var bounce: Bool = false
    
    func body(content: Content) -> some View {
        content
            .overlay(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.clear,
                        Color.white.opacity(0.4),
                        Color.white.opacity(0.7),
                        Color.white.opacity(0.4),
                        Color.clear
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .rotationEffect(.degrees(30))
                .offset(x: phase)
                .animation(
                    .easeInOut(duration: duration)
                    .repeatForever(autoreverses: bounce),
                    value: phase
                )
            )
            .onAppear {
                phase = 300
            }
            .clipped()
    }
}

extension View {
    func shimmer(duration: Double = 1.5, bounce: Bool = false) -> some View {
        modifier(ShimmerEffect(duration: duration, bounce: bounce))
    }
}

// MARK: - Enhanced Skeleton Destination Card
struct EnhancedSkeletonDestinationCard: View {
    @State private var isAnimating = false
    @State private var breatheScale: CGFloat = 1.0
    @State private var glowOpacity: Double = 0.3
    @State private var cardAppeared = false  // Keep animation for skeleton
    
    var body: some View {
        HStack(spacing: 12) {
            // Enhanced image placeholder with gradient
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(.systemGray6),
                                Color(.systemGray5),
                                Color(.systemGray6)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 80, height: 80)
                    .shimmer(duration: 1.5)
                
                // Floating icon animation
                Image(systemName: "photo")
                    .font(.system(size: 24))
                    .foregroundColor(.gray.opacity(0.4))
                    .scaleEffect(breatheScale)
            }
            
            // Enhanced text placeholders
            VStack(alignment: .leading, spacing: 8) {
                // "Flights from" placeholder
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color(.systemGray5))
                    .frame(width: 80, height: 12)
                    .shimmer(duration: 1.8)
                
                // Location name placeholder
                RoundedRectangle(cornerRadius: 6)
                    .fill(
                        LinearGradient(
                            colors: [Color(.systemGray4), Color(.systemGray5)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: 140, height: 20)
                    .shimmer(duration: 1.6)
                
                // Direct/Connecting placeholder
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color(.systemGray5))
                    .frame(width: 60, height: 12)
                    .shimmer(duration: 2.0)
            }
            
            Spacer()
            
            // Enhanced price placeholder
            VStack(alignment: .trailing, spacing: 4) {
                RoundedRectangle(cornerRadius: 8)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(.systemGray4),
                                Color(.systemGray3),
                                Color(.systemGray4)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: 80, height: 24)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color(.systemGray3).opacity(glowOpacity), lineWidth: 1)
                    )
                    .shimmer(duration: 1.4)
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color(.systemGray6), lineWidth: 1)
                )
        )
        .scaleEffect(breatheScale)
        // KEEP: Slide-in animations for skeleton only
        .opacity(cardAppeared ? 1 : 0)
        .offset(x: cardAppeared ? 0 : 20)
        .animation(
            .spring(response: 0.6, dampingFraction: 0.8)
            .delay(Double.random(in: 0...0.3)), // Staggered appearance for skeletons
            value: cardAppeared
        )
        .onAppear {
            withAnimation {
                cardAppeared = true
            }
            
            // Continuous breathing animation
            withAnimation(
                Animation.easeInOut(duration: 2.0)
                    .repeatForever(autoreverses: true)
            ) {
                breatheScale = 1.01
                glowOpacity = 0.1
            }
        }
    }
}

// MARK: - Enhanced Skeleton Flight Result Card
struct EnhancedSkeletonFlightResultCard: View {
    @State private var pulseOpacity: Double = 0.6
    @State private var breatheScale: CGFloat = 1.0
    
    var body: some View {
        VStack(spacing: 0) {
            // Outbound flight section
            flightSection(isReturn: false)
            
            Divider()
                .opacity(0.3)
                .padding(.horizontal, 16)
            
            // Return flight section
            flightSection(isReturn: true)
            
            Divider()
                .opacity(0.3)
                .padding(.horizontal, 16)
            
            // Enhanced price section
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    // "Flights from" placeholder
                    RoundedRectangle(cornerRadius: 6)
                        .fill(
                            LinearGradient(
                                colors: [Color(.systemGray6), Color(.systemGray5)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: 90, height: 14)
                        .shimmer(duration: 1.8)
                    
                    // Price placeholder with enhanced styling
                    RoundedRectangle(cornerRadius: 8)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(.systemGray4),
                                    Color(.systemGray3),
                                    Color(.systemGray4)
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: 120, height: 24)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color(.systemGray3).opacity(0.3), lineWidth: 1)
                        )
                        .shimmer(duration: 1.4)
                    
                    // Trip duration placeholder
                    RoundedRectangle(cornerRadius: 6)
                        .fill(
                            LinearGradient(
                                colors: [Color(.systemGray6), Color(.systemGray5)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: 100, height: 14)
                        .shimmer(duration: 2.0)
                }
                
                Spacer()
                
                // Enhanced button placeholder
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.orange.opacity(0.3),
                                    Color.orange.opacity(0.2),
                                    Color.orange.opacity(0.3)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 140, height: 44)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.orange.opacity(0.2), lineWidth: 1)
                        )
                        .shimmer(duration: 1.6)
                    
                    // Button text placeholder
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.white.opacity(0.8))
                        .frame(width: 100, height: 16)
                }
            }
            .padding(16)
        }
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color(.systemGray5).opacity(0.4),
                                    Color(.systemGray4).opacity(0.1)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
        )
        .shadow(
            color: Color.black.opacity(0.06),
            radius: 12,
            x: 0,
            y: 6
        )
        .scaleEffect(breatheScale)
        .opacity(pulseOpacity)
        .padding(.horizontal)
        .onAppear {
            startAnimations()
        }
    }
    
    @ViewBuilder
    private func flightSection(isReturn: Bool) -> some View {
        HStack(alignment: .center, spacing: 0) {
            // Departure info
            VStack(alignment: .leading, spacing: 6) {
                // Time placeholder
                RoundedRectangle(cornerRadius: 6)
                    .fill(
                        LinearGradient(
                            colors: [Color(.systemGray5), Color(.systemGray4)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: 55, height: 18)
                    .shimmer(duration: 1.6)
                
                // Airport code
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color(.systemGray6))
                    .frame(width: 35, height: 14)
                    .shimmer(duration: 1.8)
                
                // Date
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color(.systemGray6))
                    .frame(width: 65, height: 14)
                    .shimmer(duration: 2.0)
            }
            .frame(width: 70, alignment: .leading)
            
            // Enhanced flight path visualization
            VStack(spacing: 4) {
                HStack(spacing: 2) {
                    Circle()
                        .fill(Color(.systemGray4))
                        .frame(width: 8, height: 8)
                        .opacity(pulseOpacity)
                    
                    // Animated dashed line
                    ForEach(0..<8, id: \.self) { index in
                        Rectangle()
                            .fill(Color(.systemGray4))
                            .frame(width: 6, height: 1)
                            .opacity(pulseOpacity * (isReturn ? (1.0 - Double(index) * 0.1) : (Double(index) * 0.1 + 0.3)))
                    }
                    
                    Circle()
                        .fill(Color(.systemGray4))
                        .frame(width: 8, height: 8)
                        .opacity(pulseOpacity)
                }
                
                // Duration placeholder
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color(.systemGray6))
                    .frame(width: 45, height: 12)
                    .shimmer(duration: 1.4)
                
                // Direct/connecting status
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color(.systemGray6))
                    .frame(width: 50, height: 12)
                    .shimmer(duration: 1.6)
            }
            .frame(maxWidth: .infinity)
            
            // Arrival info
            VStack(alignment: .trailing, spacing: 6) {
                // Time placeholder
                RoundedRectangle(cornerRadius: 6)
                    .fill(
                        LinearGradient(
                            colors: [Color(.systemGray4), Color(.systemGray5)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: 55, height: 18)
                    .shimmer(duration: 1.8)
                
                // Airport code
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color(.systemGray6))
                    .frame(width: 35, height: 14)
                    .shimmer(duration: 2.0)
                
                // Date
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color(.systemGray6))
                    .frame(width: 65, height: 14)
                    .shimmer(duration: 1.6)
            }
            .frame(width: 70, alignment: .trailing)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
    }
    
    private func startAnimations() {
        // Pulse animation
        withAnimation(
            .easeInOut(duration: 1.8)
            .repeatForever(autoreverses: true)
        ) {
            pulseOpacity = 1.0
        }
        
        // Subtle breathing
        withAnimation(
            .easeInOut(duration: 3.0)
            .repeatForever(autoreverses: true)
        ) {
            breatheScale = 1.01
        }
    }
}

// MARK: - Enhanced Detailed Flight Card Skeleton
struct EnhancedDetailedFlightCardSkeleton: View {
    @State private var waveOffset: CGFloat = -200
    @State private var glowIntensity: Double = 0.3
    @State private var breatheScale: CGFloat = 1.0
    
    var body: some View {
        VStack(spacing: 0) {
            // Tags section with enhanced animation
            HStack(spacing: 8) {
                ForEach(0..<2, id: \.self) { index in
                    RoundedRectangle(cornerRadius: 12)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.blue.opacity(0.2),
                                    Color.blue.opacity(0.1),
                                    Color.blue.opacity(0.2)
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: 60 + CGFloat(index * 20), height: 24)
                        .shimmer(duration: 1.5 + Double(index) * 0.3)
                }
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)
            .padding(.bottom, 8)
            
            // Flight row with enhanced visualization
            enhancedFlightRow()
            
            // Return flight row
            enhancedFlightRow()
            
            Divider()
                .opacity(0.2)
                .padding(.horizontal, 16)
            
            // Enhanced bottom section
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    // Airline placeholder
                    RoundedRectangle(cornerRadius: 6)
                        .fill(
                            LinearGradient(
                                colors: [Color(.systemGray6), Color(.systemGray5)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: 120, height: 14)
                        .shimmer(duration: 1.8)
                    
                    // Price with premium styling
                    ZStack {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color(.systemGray4),
                                        Color(.systemGray3),
                                        Color(.systemGray4)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 100, height: 22)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(
                                        Color(.systemGray2).opacity(glowIntensity),
                                        lineWidth: 1
                                    )
                            )
                            .shimmer(duration: 1.4)
                    }
                    
                    // Price detail
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color(.systemGray6))
                        .frame(width: 140, height: 12)
                        .shimmer(duration: 2.0)
                }
                
                Spacer()
                
 
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color(.systemGray5).opacity(0.4),
                                    Color(.systemGray4).opacity(0.1),
                                    Color(.systemGray5).opacity(0.4)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
        )
        .shadow(
            color: Color.black.opacity(0.08),
            radius: 16,
            x: 0,
            y: 8
        )
        .scaleEffect(breatheScale)
        .onAppear {
            startPremiumAnimations()
        }
    }
    
    @ViewBuilder
    private func enhancedFlightRow() -> some View {
        HStack(alignment: .center, spacing: 12) {
            // Airline logo placeholder with glow
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(.systemGray5),
                                Color(.systemGray4),
                                Color(.systemGray5)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 32, height: 32)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color(.systemGray3).opacity(0.3), lineWidth: 1)
                    )
                    .shimmer(duration: 1.6)
                
                Image(systemName: "airplane")
                    .font(.system(size: 14))
                    .foregroundColor(Color(.systemGray3))
                    .opacity(0.6)
            }
            
            // Departure section
            VStack(alignment: .leading, spacing: 4) {
                // Time with gradient
                RoundedRectangle(cornerRadius: 6)
                    .fill(
                        LinearGradient(
                            colors: [Color(.systemGray5), Color(.systemGray4)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: 50, height: 16)
                    .shimmer(duration: 1.4)
                
                // Code and date row
                HStack(spacing: 4) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color(.systemGray6))
                        .frame(width: 30, height: 12)
                        .shimmer(duration: 1.8)
                    
                    Circle()
                        .fill(Color(.systemGray5))
                        .frame(width: 3, height: 3)
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color(.systemGray6))
                        .frame(width: 40, height: 10)
                        .shimmer(duration: 2.0)
                }
            }
            .frame(width: 75, alignment: .leading)
            
            Spacer()
            
            // Enhanced flight path with wave animation
            VStack(spacing: 6) {
                // Animated flight path
                HStack(spacing: 0) {
                    Circle()
                        .stroke(Color(.systemGray4), lineWidth: 1)
                        .frame(width: 6, height: 6)
                    
                    ZStack {
                        // Base line
                        Rectangle()
                            .fill(Color(.systemGray5))
                            .frame(height: 1)
                        
                        // Animated wave overlay
                        Rectangle()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color.clear,
                                        Color.blue.opacity(0.3),
                                        Color.blue.opacity(0.6),
                                        Color.blue.opacity(0.3),
                                        Color.clear
                                    ],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: 30, height: 2)
                            .offset(x: waveOffset)
                            .animation(
                                .linear(duration: 2.0)
                                .repeatForever(autoreverses: false),
                                value: waveOffset
                            )
                    }
                    .frame(width: 90)
                    
                    Circle()
                        .stroke(Color(.systemGray4), lineWidth: 1)
                        .frame(width: 6, height: 6)
                }
                
                // Duration
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color(.systemGray6))
                    .frame(width: 45, height: 10)
                    .shimmer(duration: 1.6)
                
                // Status
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color(.systemGray6))
                    .frame(width: 50, height: 10)
                    .shimmer(duration: 1.8)
            }
            
            Spacer()
            
            // Arrival section
            VStack(alignment: .trailing, spacing: 4) {
                // Time
                RoundedRectangle(cornerRadius: 6)
                    .fill(
                        LinearGradient(
                            colors: [Color(.systemGray4), Color(.systemGray5)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: 50, height: 16)
                    .shimmer(duration: 1.6)
                
                // Code and date row
                HStack(spacing: 4) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color(.systemGray6))
                        .frame(width: 40, height: 10)
                        .shimmer(duration: 1.8)
                    
                    Circle()
                        .fill(Color(.systemGray5))
                        .frame(width: 3, height: 3)
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color(.systemGray6))
                        .frame(width: 30, height: 12)
                        .shimmer(duration: 2.0)
                }
            }
            .frame(width: 75, alignment: .trailing)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
    
    private func startPremiumAnimations() {
        // Wave animation
        waveOffset = 120
        
        // Glow pulse
        withAnimation(
            .easeInOut(duration: 2.0)
            .repeatForever(autoreverses: true)
        ) {
            glowIntensity = 0.8
        }
        
        // Subtle breathing
        withAnimation(
            .easeInOut(duration: 4.0)
            .repeatForever(autoreverses: true)
        ) {
            breatheScale = 1.005
        }
    }
}
