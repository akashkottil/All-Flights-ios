import Foundation
import Combine
import Alamofire



class ExploreViewModel: ObservableObject {
    private static var cachedDestinations: [ExploreDestination]? = nil
    @Published var destinations: [ExploreDestination] = []
    @Published var isLoading = false
    @Published var errorMessage: String? = nil
    @Published var showingCities = false
    @Published var selectedCountryName: String? = nil
    @Published var fromLocation = "Kochi"  // Default to Kochi
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
    
    @Published var fromIataCode: String = "COK"
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
    
    @Published var showNoResultsModal = false
    @Published var isInitialEmptyResult = false
    
    func handleTryDifferentSearch() {
        print("🔄 User requested different search from modal")
        showNoResultsModal = false
        isInitialEmptyResult = false
        
        // Navigate back to search form
        if isDirectSearch {
            clearSearchFormAndReturnToExplore()
        } else {
            goBackToFlightResults()
        }
    }

    func handleClearFilters() {
        print("🧹 User requested clear filters from modal")
        showNoResultsModal = false
        isInitialEmptyResult = false
        
        // Reset filters and try search again
        _currentFilterRequest = nil
        resetFilterSheetState()
        
        // Retry the search with no filters
        if !selectedOriginCode.isEmpty && !selectedDestinationCode.isEmpty && !selectedDepartureDatee.isEmpty {
            searchFlightsForDatesWithPagination(
                origin: selectedOriginCode,
                destination: selectedDestinationCode,
                returnDate: selectedReturnDatee,
                departureDate: selectedDepartureDatee,
                isDirectSearch: isDirectSearch
            )
        }
    }
    
    func resetFilterSheetStateForNewSearch() {
        filterSheetState = FilterSheetState()
        print("🧹 Filter sheet state reset for new search")
    }
    
    func handleFlightResults(_ results: [FlightResult]) {
            // Filter out invalid results before setting
            let validResults = results.filter { result in
                // Ensure we have valid data
                !result.outbound.origin.iata.isEmpty &&
                !result.outbound.destination.iata.isEmpty &&
                result.price > 0 &&
                result.outbound.departure != nil
            }
            
            DispatchQueue.main.async {
                self.flightResults = validResults
                self.isLoadingFlights = false
                
                if validResults.isEmpty {
                    self.errorMessage = "No flights found for this route"
                } else {
                    self.errorMessage = nil
                }
            }
        }
    
    // Add this method to ExploreViewModel
    func resetFilterSheetState() {
        filterSheetState = FilterSheetState()
        print("🧹 Filter sheet state reset to defaults")
    }
    
    func getFilterPreviewCount(filterRequest: FlightFilterRequest) -> AnyPublisher<Int, Error> {
        guard let searchId = currentSearchId else {
            return Fail(error: NSError(domain: "ExploreViewModel", code: 1, userInfo: [NSLocalizedDescriptionKey: "No search ID available"]))
                .eraseToAnyPublisher()
        }
        
        print("🔍 Getting filter preview count for searchId: \(searchId)")
        
        return service.pollFlightResultsPaginated(
            searchId: searchId,
            page: 1,
            limit: 1, // We only need the count, not the actual results
            filterRequest: filterRequest
        )
        .map { response in
            print("📊 Preview count response: \(response.count) flights")
            return response.count
        }
        .eraseToAnyPublisher()
    }
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

        // IMPORTANT: Reset filters
        _currentFilterRequest = nil
        resetFilterSheetState()
            
        // Reset navigation states
        showingCities = false
        selectedCountryName = nil
        selectedCity = nil
            
        // Reset location states to default - FIXED to always show COK Kochi
        toLocation = "Anywhere"
        toIataCode = ""
        fromLocation = "Kochi"  // Always reset to Kochi
        fromIataCode = "COK"    // Always reset to COK
            
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
            
        // Set loading state if destinations will be cleared
        if !preserveCountries {
            destinations = []
        }
        if destinations.isEmpty {
            isLoading = true
            print("🔄 Setting loading state during reset (destinations empty)")
        }
            
        print("✅ ExploreViewModel reset completed - fromLocation: \(fromLocation), fromIataCode: \(fromIataCode)")
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
        actualLoadedCount = 0
        isDataCached = false
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
                        limit: 30
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
                            // FIXED: Always check cache status first
                            self.totalFlightCount = pollResponse.count
                            self.isDataCached = pollResponse.cache
                            self.actualLoadedCount = pollResponse.results.count
                            self.detailedFlightResults = pollResponse.results
                            
                            // 🚨 ADD THIS NEW CONDITION CHECK FOR MULTI-CITY:
                            // CRITICAL: Check for initial empty results with cache = true for multi-city
                            if pollResponse.cache && pollResponse.count == 0 && self.isFirstLoad {
                                print("🚨 Multi-city initial empty result detected (cache: true, count: 0)")
                                self.isInitialEmptyResult = true
                                self.showNoResultsModal = true
                                self.hasMoreFlights = false
                                self.detailedFlightError = nil
                            }
                            // CRITICAL: Normal handling for multi-city
                            else if pollResponse.cache {
                                // Backend finished processing multi-city search
                                if pollResponse.count == 0 {
                                    if !self.isFirstLoad {
                                        self.detailedFlightError = "No flights found for your multi-city route"
                                    }
                                    self.hasMoreFlights = false
                                } else {
                                    self.detailedFlightError = nil
                                    self.hasMoreFlights = pollResponse.next != nil
                                }
                                print("✅ Multi-city search complete (cached): \(pollResponse.results.count)/\(pollResponse.count) flights, hasMore: \(self.hasMoreFlights)")
                            } else {
                                // Backend still processing multi-city
                                self.detailedFlightError = nil
                                self.hasMoreFlights = true
                                print("🔄 Multi-city search (processing): \(pollResponse.results.count)/\(pollResponse.count) flights, backend still processing")
                            }
                            
                            self.isLoadingDetailedFlights = false
                            // 🚨 ADD THIS: Mark first load complete
                            self.isFirstLoad = false
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
        
        // IMPORTANT: Reset filters for new search
        _currentFilterRequest = nil
        resetFilterSheetState()
        
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
            
            return self.service.pollFlightResultsPaginated(
                searchId: searchResponse.searchId,
                page: 1,
                limit: 8,
                filterRequest: nil
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
                
                self.isLoadingDetailedFlights = false
            },
            receiveValue: { [weak self] pollResponse in
                guard let self = self else { return }
                
                // FIXED: Always check cache status first
                self.totalFlightCount = pollResponse.count
                self.isDataCached = pollResponse.cache
                self.actualLoadedCount = pollResponse.results.count
                self.detailedFlightResults = pollResponse.results
                self.detailedFlightError = nil
                
                // 🚨 ADD THIS NEW CONDITION CHECK FOR MODAL:
                // CRITICAL: Check for initial empty results with cache = true
                if pollResponse.cache && pollResponse.count == 0 && self.isFirstLoad {
                    // This is an initial empty result - show modal
                    print("🚨 Initial empty result detected (cache: true, count: 0)")
                    self.isInitialEmptyResult = true
                    self.showNoResultsModal = true
                    self.hasMoreFlights = false
                    self.detailedFlightError = nil // Clear error message since modal will handle it
                }
                // CRITICAL: Normal handling for other cache scenarios
                else if pollResponse.cache {
                    // Backend finished processing - final results
                    if pollResponse.count == 0 {
                        // This shouldn't happen if we caught it above, but just in case
                        if !self.isFirstLoad {
                            self.detailedFlightError = "No flights found for this route and date"
                        }
                        self.hasMoreFlights = false
                    } else {
                        self.hasMoreFlights = pollResponse.next != nil
                    }
                    print("✅ Initial search complete (cached): \(pollResponse.results.count)/\(pollResponse.count) flights, hasMore: \(self.hasMoreFlights)")
                } else {
                    // Backend still processing - continue loading
                    self.hasMoreFlights = true
                    print("🔄 Initial search (processing): \(pollResponse.results.count)/\(pollResponse.count) flights, backend still processing")
                    self.scheduleRetryAfterDelay()
                }
                
                // 🚨 ADD THIS: Mark that we've completed the first load
                self.isFirstLoad = false
            }
        )
        .store(in: &cancellables)
    }

    
    private func scheduleRetryAfterDelay() {
        // Only retry if backend is still processing (cache: false)
        print("🔄 Backend still processing data, scheduling retry...")
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
            guard let self = self,
                  let searchId = self.currentSearchId,
                  !self.isDataCached else {
                print("🛑 Retry cancelled - data cached or no search ID")
                return
            }
            
            print("🔄 Executing retry poll for more results")
            self.service.pollFlightResultsPaginated(
                searchId: searchId,
                page: self.currentPage,
                limit: 30,
                filterRequest: self._currentFilterRequest
            )
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { [weak self] pollResponse in
                    guard let self = self else { return }
                    
                    // Always update cache status
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
                    print("📊 Cache status: \(pollResponse.cache)")
                    
                    // 🚨 ADD THIS NEW CONDITION CHECK:
                    // CRITICAL: Check if this becomes an empty result during retry
                    if pollResponse.cache {
                        // Backend finished - check final state
                        if self.detailedFlightResults.isEmpty && pollResponse.count == 0 {
                            // Only show modal if this wasn't already handled as initial empty result
                            if !self.isInitialEmptyResult {
                                print("🚨 Empty result detected during retry (cache: true, count: 0)")
                                self.showNoResultsModal = true
                                self.detailedFlightError = nil // Clear error message since modal will handle it
                            }
                            self.hasMoreFlights = false
                        } else {
                            self.hasMoreFlights = pollResponse.next != nil
                            self.detailedFlightError = nil
                        }
                        print("✅ Backend finished after retry - hasMoreFlights: \(self.hasMoreFlights)")
                    } else {
                        // Still processing - schedule another retry
                        self.hasMoreFlights = true
                        self.scheduleRetryAfterDelay()
                        print("🔄 Backend still processing - scheduling another retry")
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
        isFirstLoad = true
        // Reset cache tracking for new filter
        isDataCached = false
        actualLoadedCount = 0
        
        service.pollFlightResultsPaginated(
            searchId: searchId,
            page: 1,
            limit: 8,
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
                
                // FIXED: Always check cache status first
                self.totalFlightCount = pollResponse.count
                self.isDataCached = pollResponse.cache
                self.actualLoadedCount = pollResponse.results.count
                self.detailedFlightResults = pollResponse.results
                
                // CRITICAL: Always check cache status for filters
                if pollResponse.cache {
                    // Backend finished processing filters - final results
                    if pollResponse.count == 0 {
                        self.detailedFlightError = "No flights found matching your filters"
                        self.hasMoreFlights = false
                    } else {
                        self.detailedFlightError = nil
                        self.hasMoreFlights = pollResponse.next != nil
                    }
                    print("✅ Filters applied (cached): \(pollResponse.results.count)/\(pollResponse.count) flights, hasMore: \(self.hasMoreFlights)")
                } else {
                    // Backend still processing filters
                    self.detailedFlightError = nil
                    self.hasMoreFlights = true
                    print("🔄 Filters applied (processing): \(pollResponse.results.count)/\(pollResponse.count) flights, backend still processing")
                }
                
                self.isLoadingDetailedFlights = false
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
        
        // FIXED: Check pagination rules based on cache status and next field
        if !shouldContinueLoadingMore() {
            print("🛑 Stopping pagination based on backend rules")
            hasMoreFlights = false
            return
        }
        
        print("📥 Loading more flights: page \(currentPage + 1)")
        isLoadingMoreFlights = true
        let nextPage = currentPage + 1
        
        service.pollFlightResultsPaginated(
            searchId: searchId,
            page: nextPage,
            limit: 30,
            filterRequest: _currentFilterRequest
        )
        .receive(on: DispatchQueue.main)
        .sink(
            receiveCompletion: { [weak self] completion in
                guard let self = self else { return }
                self.isLoadingMoreFlights = false
                
                if case .failure(let error) = completion {
                    print("❌ Load more flights failed: \(error.localizedDescription)")
                    // FIXED: Don't immediately stop pagination on error if backend is still processing
                    if self.isDataCached {
                        // If data is cached and we get an error, likely no more pages
                        self.hasMoreFlights = false
                    }
                }
            },
            receiveValue: { [weak self] pollResponse in
                guard let self = self else { return }
                
                // Always update cache status first
                self.totalFlightCount = pollResponse.count
                self.isDataCached = pollResponse.cache
                self.currentPage = nextPage
                
                // Filter out duplicates before appending
                let existingIds = Set(self.detailedFlightResults.map { $0.id })
                let newResults = pollResponse.results.filter { !existingIds.contains($0.id) }
                
                print("📥 Received \(pollResponse.results.count) flights, \(newResults.count) are unique")
                print("📊 Cache status: \(pollResponse.cache), Next available: \(pollResponse.next != nil)")
                
                // Append only unique results
                self.detailedFlightResults.append(contentsOf: newResults)
                self.actualLoadedCount = self.detailedFlightResults.count
                
                // CRITICAL: Always determine pagination based on cache status
                if pollResponse.cache {
                    // Backend finished processing - use next field for pagination
                    self.hasMoreFlights = pollResponse.next != nil
                    print("✅ Backend finished - hasMoreFlights based on next: \(self.hasMoreFlights)")
                } else {
                    // Backend still processing - continue loading
                    self.hasMoreFlights = true
                    print("🔄 Backend processing - continue loading")
                    
                    // Schedule another retry for more data
                    self.scheduleRetryAfterDelay()
                }
                
                self.isLoadingMoreFlights = false
            }
        )
        .store(in: &cancellables)
    }
    
    private func shouldContinueLoadingMore() -> Bool {
        // FIXED: If data is cached (cache: true), backend has finished processing all data
        // We should only continue if there are more pages available (next != null)
        if isDataCached {
            // Data is fully processed by backend, only continue if API says there are more pages
            let hasMorePages = hasMoreFlights // This should be set based on next != null from API
            print("✅ Data cached - checking pagination: hasMorePages=\(hasMorePages), loaded=\(actualLoadedCount)/\(totalFlightCount)")
            return hasMorePages
        }
        
        // FIXED: If data is not cached (cache: false), backend is still processing
        // We should continue loading to get more results as they become available
        print("🔄 Backend still processing data (cache: false) - continue loading")
        return true
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
            // Filter valid results
            let validResults = results.filter { result in
                !result.outbound.origin.iata.isEmpty &&
                !result.outbound.destination.iata.isEmpty &&
                result.price > 0 &&
                result.outbound.departure != nil
            }
            
            // Set anytime mode flag
            self.isAnytimeMode = true
            
            // Reset all detailed view flags to ensure they don't activate
            self.detailedFlightResults = []
            self.showingDetailedFlightList = false
            self.isLoadingDetailedFlights = false
            self.detailedFlightError = nil
            self.isDirectSearch = false
            
            // Set up the flight results display
            self.flightResults = validResults
            self.hasSearchedFlights = true
            self.isLoadingFlights = false
            
            // If we got results, update the to/from location display
            if let firstResult = validResults.first {
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
            if validResults.isEmpty {
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
        var directFlightsSelected: Bool = true      // ✅ Keep as true
        var oneStopSelected: Bool = true            // ✅ CHANGE: Set to true by default
        var multiStopSelected: Bool = true          // ✅ CHANGE: Set to true by default
        var priceRange: [Double] = [0.0, 2000.0]
        var departureTimes: [Double] = [0.0, 24.0]
        var arrivalTimes: [Double] = [0.0, 24.0]
        var durationRange: [Double] = [1.75, 8.5]
        var selectedAirlines: Set<String> = []
        
        // Add flag to track if this is first time opening filter sheet
        var isFirstTimeOpening: Bool = true         // ✅ ADD: Track first time opening
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
            // ✅ CRITICAL: For "All", respect current filter sheet state
            filterRequest = createCompleteFilterRequest() ?? FlightFilterRequest()
            currentFilterRequest = filterRequest
            
        case .best:
            filterRequest = FlightFilterRequest()
            // Merge with current filter sheet state
            if let completeRequest = createCompleteFilterRequest() {
                filterRequest = completeRequest
            }
            currentFilterRequest = filterRequest
            
        case .cheapest:
            filterRequest = FlightFilterRequest()
            filterRequest!.sortBy = "price"
            filterRequest!.sortOrder = "asc"
            // Merge with current filter sheet state
            if let completeRequest = createCompleteFilterRequest() {
                filterRequest!.stopCountMax = completeRequest.stopCountMax
                filterRequest!.iataCodesInclude = completeRequest.iataCodesInclude
                filterRequest!.priceMin = completeRequest.priceMin
                filterRequest!.priceMax = completeRequest.priceMax
                filterRequest!.durationMax = completeRequest.durationMax
                filterRequest!.arrivalDepartureRanges = completeRequest.arrivalDepartureRanges
            }
            currentFilterRequest = filterRequest
            
        case .fastest:
            filterRequest = FlightFilterRequest()
            filterRequest!.sortBy = "duration"
            filterRequest!.sortOrder = "asc"
            // Merge with current filter sheet state
            if let completeRequest = createCompleteFilterRequest() {
                filterRequest!.stopCountMax = completeRequest.stopCountMax
                filterRequest!.iataCodesInclude = completeRequest.iataCodesInclude
                filterRequest!.priceMin = completeRequest.priceMin
                filterRequest!.priceMax = completeRequest.priceMax
                filterRequest!.durationMax = completeRequest.durationMax
                filterRequest!.arrivalDepartureRanges = completeRequest.arrivalDepartureRanges
            }
            currentFilterRequest = filterRequest
            
        case .direct:
            filterRequest = FlightFilterRequest()
            filterRequest!.stopCountMax = 0
            // Merge with current filter sheet state (except stops)
            if let completeRequest = createCompleteFilterRequest() {
                filterRequest!.iataCodesInclude = completeRequest.iataCodesInclude
                filterRequest!.priceMin = completeRequest.priceMin
                filterRequest!.priceMax = completeRequest.priceMax
                filterRequest!.durationMax = completeRequest.durationMax
                filterRequest!.arrivalDepartureRanges = completeRequest.arrivalDepartureRanges
            }
            currentFilterRequest = filterRequest
        }
        
        // Always trigger a new search if we have origin/destination data
        if !self.selectedOriginCode.isEmpty && !self.selectedDestinationCode.isEmpty {
            // Apply the filter through polling
            if let request = filterRequest {
                applyPollFilters(filterRequest: request)
            }
        }
    }
    
    func applyPollFilters(filterRequest: FlightFilterRequest) {
            guard let searchId = currentSearchId else {
                print("⚠️ No search ID available for filter application")
                return
            }
            
            print("🔍 Applying filters via API - searchId: \(searchId)")
            print("🔍 Filter request: \(filterRequest)")
            
            // Store the filter request for future use
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
            
            // Clear existing results immediately to show loading state
            detailedFlightResults = []
            
            service.pollFlightResultsPaginated(
                searchId: searchId,
                page: 1,
                limit: 20, // Use larger limit for filtered results
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
                        
                        // Don't revert to old results on error, keep empty state
                        self.detailedFlightResults = []
                        self.totalFlightCount = 0
                        self.actualLoadedCount = 0
                    }
                },
                receiveValue: { [weak self] response in
                    guard let self = self else { return }
                    
                    print("✅ Filters applied successfully:")
                    print("   - Results count: \(response.results.count)")
                    print("   - Total available: \(response.count)")
                    print("   - Cached: \(response.cache)")
                    
                    // Apply client-side filtering for exact stop counts
                    let clientFilteredResults = self.applyClientSideStopFiltering(
                        results: response.results,
                        filterRequest: filterRequest
                    )
                    
                    // Update all tracking variables from API response
                    self.totalFlightCount = clientFilteredResults.count // Use client-filtered count
                    self.isDataCached = response.cache
                    self.actualLoadedCount = clientFilteredResults.count
                    self.hasMoreFlights = self.shouldContinueLoadingMore()
                    self.isLoadingDetailedFlights = false
                    self.detailedFlightError = nil
                    
                    // Update results with client-filtered data
                    self.detailedFlightResults = clientFilteredResults
                    
                    // Update the last poll response for airline data etc.
                    self.lastPollResponse = response
                    
                    print("📊 Filter application complete:")
                    print("   - API results: \(response.results.count)")
                    print("   - Client filtered: \(clientFilteredResults.count)")
                    print("   - Total count: \(self.totalFlightCount)")
                    print("   - Has more: \(self.hasMoreFlights)")
                    
                    // Force UI update
                    self.objectWillChange.send()
                }
            )
            .store(in: &cancellables)
        }
    
    private func applyClientSideStopFiltering(
        results: [FlightDetailResult],
        filterRequest: FlightFilterRequest
    ) -> [FlightDetailResult] {
        
        // Get the current stop filter selections from the filter sheet state
        let directSelected = filterSheetState.directFlightsSelected
        let oneStopSelected = filterSheetState.oneStopSelected
        let multiStopSelected = filterSheetState.multiStopSelected
        
        let selectedOptions = [
            (directSelected, "direct"),
            (oneStopSelected, "oneStop"),
            (multiStopSelected, "multiStop")
        ].filter { $0.0 }.map { $0.1 }
        
        print("🛑 Client-side filtering for stops: \(selectedOptions)")
        
        // If all options are selected or no options are selected, return all results
        if selectedOptions.count == 0 || selectedOptions.count == 3 {
            print("🛑 No stop filtering needed (all or none selected)")
            return results
        }
        
        let filteredResults = results.filter { flight in
            // Get the maximum stop count for this flight across all legs
            let maxStops = flight.legs.map { $0.stopCount }.max() ?? 0
            
            let isDirect = maxStops == 0
            let isOneStop = maxStops == 1
            let isMultiStop = maxStops >= 2
            
            // Check if this flight matches the selected criteria
            if selectedOptions.count == 1 {
                // Only one option selected - be exclusive
                if directSelected && !oneStopSelected && !multiStopSelected {
                    return isDirect
                } else if !directSelected && oneStopSelected && !multiStopSelected {
                    return isOneStop // Only 1-stop flights, exclude direct
                } else if !directSelected && !oneStopSelected && multiStopSelected {
                    return isMultiStop // Only 2+ stop flights, exclude direct and 1-stop
                }
            } else if selectedOptions.count == 2 {
                // Two options selected
                if directSelected && oneStopSelected && !multiStopSelected {
                    return isDirect || isOneStop
                } else if directSelected && !oneStopSelected && multiStopSelected {
                    return isDirect || isMultiStop
                } else if !directSelected && oneStopSelected && multiStopSelected {
                    return isOneStop || isMultiStop // Exclude direct flights
                }
            }
            
            // Default: include the flight
            return true
        }
        
        print("🛑 Client-side filtering result: \(results.count) → \(filteredResults.count) flights")
        
        return filteredResults
    }
    
    func createCompleteFilterRequest() -> FlightFilterRequest? {
        guard let currentFilter = _currentFilterRequest else { return nil }
        
        var filterRequest = FlightFilterRequest()
        
        // Copy all non-nil values from current filter
        filterRequest.durationMax = currentFilter.durationMax
        filterRequest.stopCountMax = currentFilter.stopCountMax
        filterRequest.arrivalDepartureRanges = currentFilter.arrivalDepartureRanges
        filterRequest.iataCodesExclude = currentFilter.iataCodesExclude
        filterRequest.iataCodesInclude = currentFilter.iataCodesInclude
        filterRequest.sortBy = currentFilter.sortBy
        filterRequest.sortOrder = currentFilter.sortOrder
        filterRequest.agencyExclude = currentFilter.agencyExclude
        filterRequest.agencyInclude = currentFilter.agencyInclude
        filterRequest.priceMin = currentFilter.priceMin
        filterRequest.priceMax = currentFilter.priceMax
        
        return filterRequest
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
    
    // In ExploreViewModel init() method, make sure these defaults are set
    init() {
        // Set default location values
        fromLocation = "Kochi"
        fromIataCode = "COK"
        toLocation = "Anywhere"
        toIataCode = ""
        
        setupAvailableMonths()
        
        // Initialize passenger data
        adultsCount = 1
        childrenCount = 0
        childrenAges = [0]
        selectedCabinClass = "Economy"
        
        // Rest of your existing init code...
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
                fetchFlightDetails(departure: fromIataCode, destination: city.location.iata)
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
        
        // Fetch flight details when a city is selected - use fromIataCode as departure
        fetchFlightDetails(departure: fromIataCode, destination: city.location.iata)
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
    
    func fetchFlightDetails(departure: String? = nil, destination: String) {
        isLoadingFlights = true
        errorMessage = nil
        hasSearchedFlights = true
        flightResults = [] // Clear previous results when starting a new search
        
        // Use fromIataCode as default departure if not provided
        let finalDeparture = departure ?? fromIataCode
        
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
        print("departure1111: \(finalDeparture)")
        
        service.fetchFlightDetails(
            origin: finalDeparture,
            destination: destination,
            departure: departureDate,
            roundTrip: isRoundTrip
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
                                fetchFlightDetails(departure: fromIataCode, destination: city.location.iata)
                            } else if !selectedDestinationCode.isEmpty {
                                fetchFlightDetails(departure: fromIataCode, destination: selectedDestinationCode)
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
                        fetchFlightDetails(departure: fromIataCode, destination: city.location.iata)
                    } else if !selectedDestinationCode.isEmpty {
                        fetchFlightDetails(departure: fromIataCode, destination: selectedDestinationCode)
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
                fetchFlightDetails(departure: fromIataCode, destination: city.location.iata)
            }
        }
    }
    
    func goBackToFlightResults() {
        print("goBackToFlightResults called")
        
        showNoResultsModal = false
        isInitialEmptyResult = false
        
        // Clear selected flight first
        selectedFlightId = nil
        
        // IMPORTANT: Reset filters when going back
        _currentFilterRequest = nil
        resetFilterSheetState()
        
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
            
            // FIXED: Automatically reload data when returning to flight results
            // Check if we need to reload flight results data
            if flightResults.isEmpty {
                print("🔄 Flight results empty, automatically reloading data for current month")
                
                // If we have a selected city, fetch flight details for current month
                if let city = selectedCity {
                    print("🔄 Fetching flight details for city: \(city.location.name)")
                    fetchFlightDetails(departure: fromIataCode, destination: city.location.iata)
                }
                // If we have destination code but no city, still fetch flight details
                else if !toIataCode.isEmpty {
                    print("🔄 Fetching flight details for destination: \(toIataCode)")
                    fetchFlightDetails(departure: fromIataCode, destination: toIataCode)
                }
                // If we have search context with dates, trigger search
                else if !fromIataCode.isEmpty && !toIataCode.isEmpty && !dates.isEmpty {
                    print("🔄 Re-triggering search with existing dates")
                    updateDatesAndRunSearch()
                }
                // Fallback: use current month selection to reload data
                else if !availableMonths.isEmpty && selectedMonthIndex < availableMonths.count {
                    print("🔄 Reloading data using current month selection: \(selectedMonthIndex)")
                    selectMonth(at: selectedMonthIndex)
                }
                else {
                    print("⚠️ Unable to determine reload strategy, staying on empty results")
                }
            } else {
                print("✅ Flight results already available (\(flightResults.count) flights)")
            }
        }
    }
    
    func clearSearchFormAndReturnToExplore() {
        showNoResultsModal = false
            isInitialEmptyResult = false
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
        
        // IMPORTANT: Reset filters completely
           _currentFilterRequest = nil
           resetFilterSheetState()
            
            // Clear search form data
            fromLocation = "Kochi" // Reset to default
            toLocation = "Anywhere" // Reset to anywhere
            fromIataCode = "COK" // Reset to default origin
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
