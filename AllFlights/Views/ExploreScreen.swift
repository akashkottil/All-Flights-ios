import SwiftUI
import Alamofire
import Combine


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
    
    private(set) var lastFetchedCurrencyInfo: CurrencyDetail?
    
    // At the top of ExploreAPIService
    weak var viewModelReference: ExploreViewModel?
    
    let currency:String = "INR"
    let country:String = "IN"
    
    private let baseURL = "https://staging.plane.lascade.com/api/explore/"
    private let flightsURL = "https://staging.plane.lascade.com/api/explore/?currency=INR&country=IN"
    private var currentFlightSearchRequest: DataRequest?
    private let session = Session()
    
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
        // Change in ExploreAPIService.pollFlightResultsWithFilters:
        if let sortBy = filterRequest.sortBy {
            // Add support for "best" as a valid sort option
            if sortBy == "price" || sortBy == "duration" || sortBy == "best" {
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
        pollProgressivelyAndSaveLatest(request: request, subject: progressiveResults)
        
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

    
    @Published var adultsCount = 1
    @Published var childrenCount = 0
    @Published var childrenAges: [Int?] = []
    @Published var selectedCabinClass = "Economy"
    @Published var showingPassengersSheet = false
    
    @Published var currencyInfo: CurrencyDetail?
    
    @Published var isAnytimeMode: Bool = false
    
    @Published var selectedFlightId: String? = nil
    
    func resetToAnywhereDestination() {
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
                // If destination is "Anywhere", just go back to countries
                goBackToCountries()
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
        // Reset all search-related states
        isDirectSearch = false
        showingDetailedFlightList = false
        detailedFlightResults = []
        detailedFlightError = nil
        isLoadingDetailedFlights = false
        
        // Clear search data but keep the form filled
        // Don't clear fromLocation, toLocation, fromIataCode, toIataCode, dates
        // so user can search again easily
        
        // Make sure we're back to countries view
        selectedCountryName = nil
        selectedCity = nil
        showingCities = false
        hasSearchedFlights = false
        flightResults = []
        flightSearchResponse = nil
        
        // Fetch countries to show the main explore screen
        fetchCountries()
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
        var filterRequest = FlightFilterRequest()
        
        switch filter {
        case .all:
            // No specific filters needed
            currentFilterRequest = nil  // Clear the filter
        case .best:
            filterRequest.sortBy = "best"
            currentFilterRequest = filterRequest
        case .cheapest:
            filterRequest.sortBy = "price"
            filterRequest.sortOrder = "asc"
            currentFilterRequest = filterRequest
        case .fastest:
            filterRequest.sortBy = "duration"
            filterRequest.sortOrder = "asc"
            currentFilterRequest = filterRequest
        case .direct:
            filterRequest.stopCountMax = 0
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
        // Create a minimal filter request with only the specified fields
        var minimalRequest = FlightFilterRequest()
        
        // Only include fields that are actually set
        if let durationMax = filterRequest.durationMax {
            minimalRequest.durationMax = durationMax
        }
        
        if let stopCountMax = filterRequest.stopCountMax {
            minimalRequest.stopCountMax = stopCountMax
        }
        
        if let ranges = filterRequest.arrivalDepartureRanges, !ranges.isEmpty {
            minimalRequest.arrivalDepartureRanges = ranges
        }
        
        if let exclude = filterRequest.iataCodesExclude, !exclude.isEmpty {
            minimalRequest.iataCodesExclude = exclude
        }
        
        if let include = filterRequest.iataCodesInclude, !include.isEmpty {
            minimalRequest.iataCodesInclude = include
        }
        
        if let sortBy = filterRequest.sortBy {
            minimalRequest.sortBy = sortBy
        }
        
        if let sortOrder = filterRequest.sortOrder {
            minimalRequest.sortOrder = sortOrder
        }
        
        if let agencyExclude = filterRequest.agencyExclude, !agencyExclude.isEmpty {
            minimalRequest.agencyExclude = agencyExclude
        }
        
        if let agencyInclude = filterRequest.agencyInclude, !agencyInclude.isEmpty {
            minimalRequest.agencyInclude = agencyInclude
        }
        
        if let priceMin = filterRequest.priceMin {
            minimalRequest.priceMin = priceMin
        }
        
        if let priceMax = filterRequest.priceMax {
            minimalRequest.priceMax = priceMax
        }
        
        // Store the filter request
        self.currentFilterRequest = minimalRequest
        
        // If we already have search results, we need to restart the search with filters
        if !self.selectedOriginCode.isEmpty && !self.selectedDestinationCode.isEmpty {
            // Clear existing results
            self.detailedFlightResults = []
            
            // Restart search with filters
            searchFlightsForDates(
                origin: self.selectedOriginCode,
                destination: self.selectedDestinationCode,
                returnDate: self.isRoundTrip ? self.selectedReturnDatee : "",
                departureDate: self.selectedDepartureDatee
            )
        }
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
                returnDate = isRoundTrip ? formatter.string(from: Calendar.current.date(byAdding: .day, value: 1, to: dates[0])!) : ""
            } else {
                departureDate = "2025-12-29"
                returnDate = isRoundTrip ? "2025-12-30" : ""
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
        
        // Filter out nil values from childrenAges
           let validChildrenAges = childrenAges.compactMap { $0 }
        
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
    func searchFlightsForDates(origin: String, destination: String, returnDate: String, departureDate: String, isDirectSearch: Bool = false) {
        self.isDirectSearch = isDirectSearch
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
        
        // Filter out nil values from childrenAges
        let validChildrenAges = childrenAges.compactMap { $0 }
        
        // Rest of the existing method remains the same...
        // First, get the search ID
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
        .flatMap { searchResponse -> AnyPublisher<FlightPollResponse, Error> in
            print("Search successful, got searchId: \(searchResponse.searchId)")
            
            // Check if we need to apply filters
            if let filterRequest = self._currentFilterRequest {
                return self.service.pollFlightResultsWithFilters(searchId: searchResponse.searchId, filterRequest: filterRequest)
            } else {
                return self.service.pollFlightResults(searchId: searchResponse.searchId)
            }
        }
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
                   
                   // You should also update the currency info here if you've modified
                   // the service to return it separately
                   if let currencyInfo = self?.service.lastFetchedCurrencyInfo {
                       self?.updateCurrencyInfo(currencyInfo)
                   }
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
    
    func goBackToFlightResults() {
            print("goBackToFlightResults called")
            // Clear selected flight first
            selectedFlightId = nil
            
            // Reset all search-related states
            if isDirectSearch {
                print("Handling direct search back navigation")
                isDirectSearch = false
                showingDetailedFlightList = false
                detailedFlightResults = []
                detailedFlightError = nil
                isLoadingDetailedFlights = false
                
                // Clear search data but keep the form filled
                // Don't clear fromLocation, toLocation, fromIataCode, toIataCode, dates
                // so user can search again easily
                
                // Make sure we're back to countries view
                selectedCountryName = nil
                selectedCity = nil
                showingCities = false
                hasSearchedFlights = false
                flightResults = []
                flightSearchResponse = nil
                
                // Fetch countries to show the main explore screen
                fetchCountries()
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

    func goBackToCities() {
        isAnytimeMode = false
        hasSearchedFlights = false
        flightResults = []
        flightSearchResponse = nil
        selectedCity = nil
        toLocation = "Anywhere"
        // Keep showingCities = true to show cities
        // Fetch cities again for the selected country
        if let countryName = selectedCountryName,
           let country = destinations.first(where: { $0.location.name == countryName }) {
            fetchCitiesFor(countryId: country.location.entityId, countryName: countryName)
        }
    }
    
    func goBackToCountries() {
        isAnytimeMode = false
        selectedCountryName = nil
        selectedCity = nil
        toLocation = "Anywhere"
        showingCities = false
        hasSearchedFlights = false
        showingDetailedFlightList = false
        flightResults = []
        flightSearchResponse = nil
        detailedFlightResults = []
        detailedFlightError = nil
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

// Updated ExploreScreen with proper back navigation handling for selected flights

struct ExploreScreen: View {
    // MARK: - Properties
    @StateObject private var viewModel = ExploreViewModel()
    @State private var selectedTab = 0
    @State private var selectedFilterTab = 0
    @State private var selectedMonthTab = 0
    @State private var isRoundTrip: Bool = true
    
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
        
        // Special handling for "Anywhere" destination
        if viewModel.toLocation == "Anywhere" {
            print("Action: Handling Anywhere destination - going back to countries")
            viewModel.resetToAnywhereDestination()
            return
        }
        
        // First check if we have a selected flight in the detailed view
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
                viewModel.goBackToCountries()
            } else {
                print("Action: Going back from flight results to cities")
                viewModel.goBackToCities()
            }
        } else if viewModel.showingCities {
            // Go back from cities to countries
            print("Action: Going back from cities to countries")
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
                    handleBackNavigation: handleBackNavigation
                )
                .transition(.opacity.combined(with: .scale(scale: 0.95)))
            } else {
                ExpandedSearchCard(
                    viewModel: viewModel,
                    selectedTab: $selectedTab,
                    isRoundTrip: $isRoundTrip,
                    searchCardNamespace: searchCardNamespace,
                    handleBackNavigation: handleBackNavigation
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
                            Spacer()
                                .frame(height: 20)
                            
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
        .ignoresSafeArea(edges: .bottom)
        .onAppear {
            if !viewModel.hasSearchedFlights && !viewModel.showingDetailedFlightList {
                viewModel.fetchCountries()
            }
            viewModel.setupAvailableMonths()
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

// MARK: - Expanded Search Card Component
struct ExpandedSearchCard: View {
    @ObservedObject var viewModel: ExploreViewModel
    @Binding var selectedTab: Int
    @Binding var isRoundTrip: Bool
    let searchCardNamespace: Namespace.ID
    let handleBackNavigation: () -> Void
    
    var body: some View {
        VStack {
            VStack(spacing: 0) {
                HStack {
                    // Back button
                    Button(action: handleBackNavigation) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.primary)
                            .font(.system(size: 18, weight: .semibold))
                    }
                    .matchedGeometryEffect(id: "backButton", in: searchCardNamespace)
                    
                    Spacer()
                    
                    // Centered trip type tabs with more balanced width
                    TripTypeTabView(selectedTab: $selectedTab, isRoundTrip: $isRoundTrip, viewModel: viewModel)
                        .frame(width: UIScreen.main.bounds.width * 0.55)
                        .matchedGeometryEffect(id: "tripTabs", in: searchCardNamespace)
                    
                    Spacer()
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
                    if viewModel.isLoading || viewModel.isLoadingFlights {
                        LoadingBorderView()
                    } else {
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.orange, lineWidth: 1)
                    }
                }
            )
            .padding()
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

// MARK: - Collapsed Search Card Component
struct CollapsedSearchCard: View {
    @ObservedObject var viewModel: ExploreViewModel
    let searchCardNamespace: Namespace.ID
    let onTap: () -> Void
    let handleBackNavigation: () -> Void
    
    // Helper method to format date for display
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM"
        return formatter.string(from: date)
    }
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 0) {
                HStack {
                    // Back button
                    Button(action: handleBackNavigation) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.primary)
                            .font(.system(size: 18, weight: .semibold))
                    }
                    .matchedGeometryEffect(id: "backButton", in: searchCardNamespace)
                    
                    Spacer()
                    
                    // Compact trip info
                    HStack(spacing: 8) {
                        Text(viewModel.fromLocation)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.primary)
                        
                        Text("→")
                            .foregroundColor(.gray)
                        
                        Text(viewModel.toLocation)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.primary)
                        
                        Circle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 4, height: 4)
                        
                        // Date display logic
                        if viewModel.dates.isEmpty && viewModel.hasSearchedFlights && !viewModel.flightResults.isEmpty {
                            Text("Anytime")
                                .foregroundColor(.primary)
                                .font(.system(size: 14, weight: .medium))
                        } else if viewModel.dates.isEmpty {
                            Text("Anytime")
                                .foregroundColor(.primary)
                                .font(.system(size: 14, weight: .medium))
                        } else if viewModel.dates.count == 1 {
                            Text(formatDate(viewModel.dates[0]))
                                .foregroundColor(.primary)
                                .font(.system(size: 14, weight: .medium))
                        } else if viewModel.dates.count >= 2 {
                            Text("\(formatDate(viewModel.dates[0])) - \(formatDate(viewModel.dates[1]))")
                                .foregroundColor(.primary)
                                .font(.system(size: 14, weight: .medium))
                        }
                    }
                    .matchedGeometryEffect(id: "searchContent", in: searchCardNamespace)
                    
                    Spacer()
                    
                    // Expand indicator
                    Image(systemName: "chevron.down")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.gray)
                        .rotationEffect(.degrees(180))
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
                            .foregroundColor(.primary)
                        Text(viewModel.fromLocation)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.primary)
                    }
                    
                    Spacer()
                    
                    ZStack {
                        Circle()
                            .stroke(Color.gray.opacity(0.4), lineWidth: 1)
                            .frame(width: 20, height: 20)
                        Image(systemName: "arrow.left.arrow.right")
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                            .font(.system(size: 8))
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        initialFocus = .destination
                        showingSearchSheet = true
                    }) {
                        HStack {
                            Image(systemName: "airplane.arrival")
                                .foregroundColor(.primary)
                            
                            // MODIFIED: Show different styling for "Anywhere"
                            if viewModel.toLocation == "Anywhere" {
                                HStack(spacing: 4) {

                                    Text("Anywhere")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(.primary)
                                }
                            } else {
                                Text(viewModel.toLocation)
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.primary)
                            }
                        }
                    }
                }
                .padding(4)
                
                Divider()
                
                // Date and passengers row
                HStack {
                    Button(action: {
                        // MODIFIED: Only show calendar if destination is not "Anywhere"
                        if viewModel.toLocation == "Anywhere" {
                            // If destination is "Anywhere", go back to explore mode
                            handleAnywhereDestination()
                        } else {
                            showingCalendar = true
                        }
                    }){
                        Image(systemName: "calendar")
                            .foregroundColor(.primary)
                      
                        // Display "Anytime" if using anytime results or if destination is "Anywhere"
                        if viewModel.toLocation == "Anywhere" {
                            Text("Anytime")
                                .foregroundColor(.primary)
                                .font(.system(size: 14, weight: .medium))
                        } else if viewModel.dates.isEmpty && viewModel.hasSearchedFlights && !viewModel.flightResults.isEmpty {
                            Text("Anytime")
                                .foregroundColor(.primary)
                                .font(.system(size: 14, weight: .medium))
                        } else if viewModel.dates.isEmpty {
                            Text("Anytime")
                                .foregroundColor(.primary)
                                .font(.system(size: 14, weight: .medium))
                        } else if viewModel.dates.count == 1 {
                            Text(formatDate(viewModel.dates[0]))
                                .foregroundColor(.primary)
                                .font(.system(size: 14, weight: .medium))
                        } else if viewModel.dates.count >= 2 {
                            Text("\(formatDate(viewModel.dates[0])) - \(formatDate(viewModel.dates[1]))")
                                .foregroundColor(.primary)
                                .font(.system(size: 14, weight: .medium))
                        }
                    }
                    
                    Spacer()
                    
                    // Passenger selection button - now clickable
                    Button(action: {
                        viewModel.showingPassengersSheet = true
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "person.fill")
                                .foregroundColor(.black)
                            
                            // Display the passenger and cabin class info
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
                            // Handle flight results from "Anytime" button
                            viewModel.handleAnytimeResults(results)
                        }, onTripTypeChange: { newIsRoundTrip in
                            // Update the trip type when calendar requests it
                            isRoundTrip = newIsRoundTrip
                            viewModel.isRoundTrip = newIsRoundTrip
                        },
                        isRoundTrip: isRoundTrip
                    )
            }
            .sheet(isPresented: $viewModel.showingPassengersSheet, onDismiss: {
                // ADDED: Trigger search when passenger sheet is dismissed (Apply clicked)
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
    
    // NEW: Handle when destination is "Anywhere"
    private func handleAnywhereDestination() {
        // Reset to explore mode
        viewModel.goBackToCountries()
        
        // Clear the specific destination
        viewModel.toLocation = "Anywhere"
        viewModel.toIataCode = ""
        
        // Clear any search results
        viewModel.hasSearchedFlights = false
        viewModel.showingDetailedFlightList = false
        viewModel.flightResults = []
        viewModel.detailedFlightResults = []
    }
    
    // Helper function to trigger search after passenger changes
    private func triggerSearchAfterPassengerChange() {
        // Only trigger if destination is not "Anywhere"
        if viewModel.toLocation != "Anywhere" {
            // Check if we have active search context
            if !viewModel.selectedOriginCode.isEmpty && !viewModel.selectedDestinationCode.isEmpty {
                // Clear existing results
                viewModel.detailedFlightResults = []
                
                // Restart search with new passenger data
                viewModel.searchFlightsForDates(
                    origin: viewModel.selectedOriginCode,
                    destination: viewModel.selectedDestinationCode,
                    returnDate: viewModel.isRoundTrip ? viewModel.selectedReturnDatee : "",
                    departureDate: viewModel.selectedDepartureDatee
                )
            }
            // If we're in the explore flow with a selected city
            else if let city = viewModel.selectedCity {
                viewModel.fetchFlightDetails(destination: city.location.iata)
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
        
        // Update these stored dates in viewModel
        viewModel.selectedDepartureDatee = formattedCardDepartureDate
        viewModel.selectedReturnDatee = formattedCardReturnDate
        
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
    let viewModel: ExploreViewModel
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                // OPTIMIZED AsyncImage with better caching and immediate placeholders
                AsyncImage(url: URL(string: "https://image.explore.lascadian.com/\(viewModel.showingCities ? "city" : "country")_\(item.location.entityId).webp")) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(width: 80, height: 80)
                            .clipped()
                            .cornerRadius(8)
                            .transition(.opacity.animation(.easeIn(duration: 0.2))) // Smooth transition
                    
                    case .failure(_), .empty:
                        // Immediate placeholder - no loading delay
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
                    
                    @unknown default:
                        Color.gray.opacity(0.15)
                            .frame(width: 80, height: 80)
                            .cornerRadius(8)
                    }
                }
                
                // Everything else stays exactly the same
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
                                        
                                        // Clear dates if switching from round trip to one way and we have 2+ dates
                                                                    if !newIsRoundTrip && viewModel.dates.count > 1 {
                                                                        // Keep only the first date for one-way
                                                                        viewModel.dates = Array(viewModel.dates.prefix(1))
                                                                    }
                                        
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
            .onChange(of: isRoundTrip) { newValue in
                        // Update selectedTab to match the trip type
                        selectedTab = newValue ? 0 : 1 // 0 for "Return", 1 for "One way"
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
                            // Updated passenger info button - now clickable
                            Button(action: {
                                viewModel.showingPassengersSheet = true
                            }) {
                                HStack(spacing: 4) {
                                    Image(systemName: "person")
                                        .foregroundColor(.blue)
                                    
                                    // Display the passenger and cabin class info
                                    Text("\(viewModel.adultsCount + viewModel.childrenCount), \(viewModel.selectedCabinClass)")
                                        .font(.system(size: 14, weight: .medium))
                                }
                            }
                
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
        .sheet(isPresented: $viewModel.showingPassengersSheet, onDismiss: {
                    // ADDED: Trigger search when passenger sheet is dismissed for multi-city
                    triggerMultiCitySearchAfterPassengerChange()
                }) {
                    PassengersAndClassSelector(
                        adultsCount: $viewModel.adultsCount,
                        childrenCount: $viewModel.childrenCount,
                        selectedClass: $viewModel.selectedCabinClass,
                        childrenAges: $viewModel.childrenAges
                    )
                }
    }
    
    // Helper function for multi-city search after passenger changes
       private func triggerMultiCitySearchAfterPassengerChange() {
           // Check if multi-city trips are valid
           let isValid = viewModel.multiCityTrips.allSatisfy { trip in
               return !trip.fromIataCode.isEmpty && !trip.toIataCode.isEmpty
           }
           
           if isValid {
               // Clear existing results and trigger new multi-city search
               viewModel.detailedFlightResults = []
               viewModel.searchMultiCityFlights()
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
                        .frame(width:16,height: 1)
                       
                    
                    // Date/Time capsule in the middle
                    Text(duration)
                        .font(.system(size: 11)) // Reduced from 12 to 11
                        .foregroundColor(.gray)
                        .padding(.horizontal, 8) // Reduced from 8 to 6
                        .padding(.vertical, 1) // Reduced from 2 to 1
                        .background(
                            Capsule()
                                .fill(Color.white)
                                .overlay(
                                    Capsule()
                                        .stroke(Color.gray.opacity(0.3), lineWidth: 0.5)
                                )
                        )
                        .padding(.horizontal,4)
                    
                    // Right line segment
                    Rectangle()
                        .fill(Color.gray)
                        .frame(width:16,height: 1)
                        
                    
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
            // Timeline positioned to align with airport codes
            VStack(spacing: 0) {
                // Space to align with departure airport code
                Spacer()
                    .frame(height: 50) // Aligns with departure date/time + some spacing
                
                // Departure circle
                Circle()
                    .stroke(Color.primary, lineWidth: 1)
                    .frame(width: 8, height: 8)
                
                // Connecting line
                Rectangle()
                    .fill(Color.primary)
                    .frame(width: 1, height: 140)
                    .padding(.top,6)
                    .padding(.bottom,6)// Height spans between the two sections
                
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
            // Timeline positioned to align with airport codes - similar to DirectFlightView
            VStack(spacing: 0) {
                // Space to align with first departure airport code
                Spacer()
                    .frame(height: 50)
                
                // First departure circle
                Circle()
                    .stroke(Color.primary, lineWidth: 1)
                    .frame(width: 8, height: 8)
                
                // For each segment, create connecting elements
                ForEach(0..<segments.count, id: \.self) { index in
                    // Solid line for flight segment - INCREASED HEIGHT
                    Rectangle()
                        .fill(Color.primary)
                        .frame(width: 1, height: 180) // Changed from 140 to 180
                        .padding(.top, 6)
                        .padding(.bottom, 6)
                    
                    // Connection point (if not the last segment)
                    if index < segments.count - 1 {
                        Circle()
                            .stroke(Color.primary, lineWidth: 1)
                            .frame(width: 8, height: 8)
                        
                        // Dotted line for layover/connection - INCREASED HEIGHT
                        Rectangle()
                            .fill(Color.clear)
                            .frame(width: 1, height: 120) // Changed from 80 to 120
                            .overlay(
                                Path { path in
                                    path.move(to: CGPoint(x: 0.5, y: 0))
                                    path.addLine(to: CGPoint(x: 0.5, y: 120)) // Update path height too
                                }
                                .stroke(Color.primary, style: StrokeStyle(lineWidth: 1, dash: [3, 3]))
                            )
                            .padding(.top, 6)
                            .padding(.bottom, 6)
                        
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
                    
                    // AIRLINE SECTION - Updated to match DirectFlightView
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


// Updated ModifiedDetailedFlightListView and MultiCityFlightCardWrapper
// Updated ModifiedDetailedFlightListView with consistent scroll background

struct ModifiedDetailedFlightListView: View {
    @ObservedObject var viewModel: ExploreViewModel
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
        VStack(spacing: 0) {
            // Filter tabs with scroll background
            HStack {
                // New Filter button
                FilterButton {
                    showingFilterSheet = true
                }
                .padding(.leading,20)
                
                FlightFilterTabView(
                    selectedFilter: selectedFilter,
                    onSelectFilter: { filter in
                        // Just update the local filter selection
                        selectedFilter = filter
                        
                        // Apply local filtering
                        applyLocalFilters()
                    }
                )
            }
            .padding(.trailing, 16)
            .padding(.vertical, 8)
            .background(Color("scroll")) // Add scroll background to filter section
      
            // Only show filter tabs when we have results and no flight is selected
            if !filteredResults.isEmpty && viewModel.selectedFlightId == nil {
                // Show flight count with scroll background
                HStack {
                    Text("\(filteredResults.count) flights found")
                        .font(.subheadline)
                        .foregroundColor(.primary)
                    Spacer()
                }
                .padding(.horizontal)
                .padding(8)
                .background(Color("scroll")) // Add scroll background to count section
            }
            
            // Content - FIXED CONDITION LOGIC
            if viewModel.isLoadingDetailedFlights && viewModel.detailedFlightResults.isEmpty {
                // Only show skeleton when actually loading AND no results yet
                VStack {
                    Spacer()
                    ForEach(0..<4, id: \.self) { _ in
                        DetailedFlightCardSkeleton()
                            .padding(.bottom, 5)
                    }
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color("scroll")) // Add scroll background to skeleton section
            } else if !viewModel.isLoadingDetailedFlights && viewModel.detailedFlightResults.isEmpty {
                // Show error/no results only when not loading and no results
                VStack {
                    Spacer()
                    if let error = viewModel.detailedFlightError {
                        Text("Error: \(error)")
                            .foregroundColor(.red)
                            .padding()
                    } else {
                        Text("No flights found for these dates")
                            .foregroundColor(.gray)
                            .padding()
                    }
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color("scroll")) // Add scroll background to error section
            } else {
                VStack(spacing: 0) {
                    // If we have a selected flight, show the FlightDetailCard for it
                    if let selectedId = viewModel.selectedFlightId,
                       let selectedFlight = viewModel.detailedFlightResults.first(where: { $0.id == selectedId }) {
                        
                        ScrollView {
                            VStack(spacing: 0) {
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
                        .background(Color("scroll")) // Add scroll background to selected flight details
                    }
                    // Otherwise show the list of flights
                    else {
                        ScrollView {
                            VStack(spacing: 16) {
                                ForEach(filteredResults, id: \.id) { result in
                                    // Use a custom wrapper for multi-city or the existing one for regular flights
                                    if isMultiCity {
                                        ModernMultiCityFlightCardWrapper(
                                            result: result,
                                            viewModel: viewModel,
                                            onTap: {
                                                viewModel.selectedFlightId = result.id
                                            }
                                        )
                                        .padding(.horizontal)
                                    } else {
                                        DetailedFlightCardWrapper(
                                            result: result,
                                            viewModel: viewModel,
                                            onTap: {
                                                viewModel.selectedFlightId = result.id
                                            }
                                        )
                                        .padding(.horizontal)
                                    }
                                }
                                
                                // Add spacer to fill remaining space with scroll background
                                Spacer(minLength: 0)
                            }
                            .padding(.vertical)
                            .frame(maxWidth: .infinity)
                            .frame(minHeight: UIScreen.main.bounds.height - 200) // Ensure minimum height to fill screen
                        }
                        .background(Color("scroll")) // Add scroll background to flight list
                        
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
                            .background(Color("scroll")) // Add scroll background to loading section
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $showingFilterSheet) {
            FlightFilterSheet(viewModel: viewModel)
        }
        .onAppear {
            print("ModifiedDetailedFlightListView onAppear - detailedFlightResults count: \(viewModel.detailedFlightResults.count)")
            
            // Initialize dates array from the API date strings
            viewModel.initializeDatesFromStrings()
            
            // Force immediate update of filtered results
            updateFilteredResults()
        }
        .onReceive(viewModel.$detailedFlightResults) { newResults in
            print("Received new results: \(newResults.count) flights")
            
            // Force immediate UI update
            DispatchQueue.main.async {
                updateFilteredResults()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color("scroll")) // Main background
    }
    
    // FIXED: Consolidated function to update filtered results
    private func updateFilteredResults() {
        print("Updating filtered results - Source count: \(viewModel.detailedFlightResults.count), Current filter: \(selectedFilter)")
        
        // Always update filteredResults first, regardless of filter
        filteredResults = viewModel.detailedFlightResults
        
        // Then apply the current filter
        applyLocalFilters()
        
        print("Updated filtered results - Final count: \(filteredResults.count)")
    }
    

    // FIXED: Updated local filtering function to show tagged flights first, then sorted remaining flights
    private func applyLocalFilters() {
        print("Applying local filters. Total results: \(viewModel.detailedFlightResults.count), Selected filter: \(selectedFilter)")
        
        let sourceResults = viewModel.detailedFlightResults
        
        switch selectedFilter {
        case .all:
            filteredResults = sourceResults
            
        case .best:
            // Show best tagged flights first, then remaining flights in original order
            let bestResults = sourceResults.filter { $0.isBest }
            let otherResults = sourceResults.filter { !$0.isBest }
            filteredResults = bestResults + otherResults
            
        case .cheapest:
            // Show cheapest tagged flights first, then remaining flights sorted by price (ascending)
            let cheapestResults = sourceResults.filter { $0.isCheapest }
            let otherResults = sourceResults.filter { !$0.isCheapest }.sorted { $0.minPrice < $1.minPrice }
            filteredResults = cheapestResults + otherResults
            
        case .fastest:
            // Show fastest tagged flights first, then remaining flights sorted by duration (ascending)
            let fastestResults = sourceResults.filter { $0.isFastest }
            let otherResults = sourceResults.filter { !$0.isFastest }.sorted { $0.totalDuration < $1.totalDuration }
            filteredResults = fastestResults + otherResults
            
        case .direct:
            // Show direct flights first, then connecting flights (sorted by price for better user experience)
            let directFlights = sourceResults.filter { flight in
                flight.legs.allSatisfy { $0.stopCount == 0 }
            }.sorted { $0.minPrice < $1.minPrice }
            
            let connectingFlights = sourceResults.filter { flight in
                !flight.legs.allSatisfy { $0.stopCount == 0 }
            }.sorted { $0.minPrice < $1.minPrice }
            
            filteredResults = directFlights + connectingFlights
        }
        
        print("Local filtering complete. Filtered results count: \(filteredResults.count)")
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
            airlineLogo: segment.airlineLogo, // Add this line
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
                    airlineLogo: segment.airlineLogo, // Added airline logo
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
                    
                    // Flight leg header
                    HStack {
                        Text("Flight \(index + 1)")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.blue)
                        Spacer()
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, index > 0 ? 8 : 0)
                    .padding(.bottom, 4)
                    
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
                        .background(Color.blue)
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
                    filterRequest.sortBy = "best"
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
            
            // Debug log to see what filters are being applied
            printAppliedFilters(filterRequest)
            
            // Apply the filter
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


