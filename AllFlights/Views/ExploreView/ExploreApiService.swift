import Alamofire
import Foundation
import Combine


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
    
    // Replace the existing pollFlightResultsPaginated method in ExploreAPIService

    func pollFlightResultsPaginated(searchId: String, page: Int = 1, limit: Int = 20, filterRequest: FlightFilterRequest? = nil) -> AnyPublisher<FlightPollResponse, Error> {
        let baseURL = "https://staging.plane.lascade.com/api/poll/"
        
        // Build query parameters
        let parameters: [String: String] = [
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
        
        // Build request body from filter request
        var requestDict: [String: Any] = [:]
        
        if let filterRequest = filterRequest {
            print("🔧 Building filter request body:")
            
            // Only add fields that have meaningful values
            if let durationMax = filterRequest.durationMax, durationMax > 0 {
                requestDict["duration_max"] = durationMax
                print("   Duration max: \(durationMax) minutes")
            }
            
            if let stopCountMax = filterRequest.stopCountMax {
                requestDict["stop_count_max"] = stopCountMax
                print("   Stop count max: \(stopCountMax)")
            }
            
            if let ranges = filterRequest.arrivalDepartureRanges, !ranges.isEmpty {
                var rangesArray: [[String: Any]] = []
                
                for range in ranges {
                    var rangeDict: [String: Any] = [:]
                    
                    if let arrival = range.arrival {
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
                    
                    if let departure = range.departure {
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
                    
                    if !rangeDict.isEmpty {
                        rangesArray.append(rangeDict)
                    }
                }
                
                if !rangesArray.isEmpty {
                    requestDict["arrival_departure_ranges"] = rangesArray
                    print("   Time ranges: \(rangesArray.count) ranges")
                }
            }
            
            // Only add non-empty arrays
            if let exclude = filterRequest.iataCodesExclude, !exclude.isEmpty {
                requestDict["iata_codes_exclude"] = exclude
                print("   Exclude airlines: \(exclude)")
            }
            
            if let include = filterRequest.iataCodesInclude, !include.isEmpty {
                requestDict["iata_codes_include"] = include
                print("   Include airlines: \(include)")
            }
            
            // Only add sorting if it's specified AND it's a valid value
            if let sortBy = filterRequest.sortBy, !sortBy.isEmpty {
                // Only use valid sort values
                let validSortValues = ["price", "duration", "departure", "arrival"]
                if validSortValues.contains(sortBy) {
                    requestDict["sort_by"] = sortBy
                    print("   Sort by: \(sortBy)")
                    
                    // Add sort_order if needed
                    if let sortOrder = filterRequest.sortOrder, !sortOrder.isEmpty {
                        requestDict["sort_order"] = sortOrder
                        print("   Sort order: \(sortOrder)")
                    } else {
                        // Default sort order is ascending
                        requestDict["sort_order"] = "asc"
                        print("   Sort order: asc (default)")
                    }
                } else {
                    print("   ⚠️ Invalid sort value ignored: \(sortBy)")
                }
            }
            
            // Only add non-empty arrays
            if let agencyExclude = filterRequest.agencyExclude, !agencyExclude.isEmpty {
                requestDict["agency_exclude"] = agencyExclude
                print("   Exclude agencies: \(agencyExclude)")
            }
            
            if let agencyInclude = filterRequest.agencyInclude, !agencyInclude.isEmpty {
                requestDict["agency_include"] = agencyInclude
                print("   Include agencies: \(agencyInclude)")
            }
            
            // Only add price constraints if they're meaningful
            if let priceMin = filterRequest.priceMin, priceMin > 0 {
                requestDict["price_min"] = priceMin
                print("   Price min: ₹\(priceMin)")
            }
            
            if let priceMax = filterRequest.priceMax, priceMax > 0 {
                requestDict["price_max"] = priceMax
                print("   Price max: ₹\(priceMax)")
            }
        }
        
        // Add body to request
        do {
               // Always use the requestDict, which will be empty if no filters
               request.httpBody = try JSONSerialization.data(withJSONObject: requestDict)
               
               if requestDict.isEmpty {
                   print("🔧 Empty filter request body (no filters applied)")
               } else if let requestBody = String(data: request.httpBody ?? Data(), encoding: .utf8) {
                   print("🔧 Final API request body: \(requestBody)")
               }
           } catch {
               print("❌ Error encoding filter request: \(error)")
               return Fail(error: error).eraseToAnyPublisher()
           }
        
        print("🚀 Making API call to poll endpoint")
        print("   Search ID: \(searchId)")
        print("   Page: \(page)")
        print("   Limit: \(limit)")
        
        // Return a publisher that will emit results
        return Future<FlightPollResponse, Error> { promise in
            AF.request(request)
                .validate()
                .responseData { [weak self] response in
                    // Log response details
                    print("📡 Poll API Response:")
                    print("   Status Code: \(response.response?.statusCode ?? 0)")
                    
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
                            
                            print("✅ Poll response decoded successfully:")
                            print("   Results: \(pollResponse.results.count)")
                            print("   Total: \(pollResponse.count)")
                            print("   Cached: \(pollResponse.cache)")
                            print("   Has Next: \(pollResponse.next != nil)")
                            
                            promise(.success(pollResponse))
                        } catch {
                            print("❌ Poll response decoding error: \(error)")
                            if let responseStr = String(data: data, encoding: .utf8) {
                                print("   Response data: \(responseStr.prefix(500))")
                            }
                            promise(.failure(error))
                        }
                    case .failure(let error):
                        print("❌ Poll API request failed: \(error)")
                        if let data = response.data, let responseStr = String(data: data, encoding: .utf8) {
                            print("   Error response: \(responseStr.prefix(500))")
                        }
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
