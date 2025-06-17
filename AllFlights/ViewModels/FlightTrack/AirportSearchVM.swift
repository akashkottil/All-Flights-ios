// ViewModels/AirportSearchViewModel.swift
import Foundation
import Combine

@MainActor
class AirportSearchViewModel: ObservableObject {
    @Published var searchText = ""
    @Published var airports: [FlightTrackAirport] = []
    @Published var airlines: [FlightTrackAirline] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var searchEntityType: SearchEntityType = .unknown
    
    // Tracked tab specific properties
    @Published var selectedSearchType: TrackedSearchType?
    @Published var flightNumber = ""
    @Published var arrivalAirportText = ""
    @Published var arrivalAirports: [FlightTrackAirport] = []
    @Published var selectedDate: String?
    
    private var cancellables = Set<AnyCancellable>()
    private let networkManager = FlightTrackNetworkManager.shared
    
    init() {
        // Debounce search to avoid too many API calls
        $searchText
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] searchText in
                if !searchText.isEmpty && searchText.count >= 2 {
                    Task {
                        // Check if we should do mixed search or just airport search
                        if self?.shouldPerformMixedSearch == true {
                            await self?.performMixedSearch(query: searchText)
                        } else {
                            await self?.searchAirportsOnly(query: searchText)
                        }
                    }
                } else {
                    self?.clearSearchResults()
                }
            }
            .store(in: &cancellables)
        
        // Debounce arrival airport search for tracked tab
        $arrivalAirportText
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] searchText in
                if !searchText.isEmpty && searchText.count >= 2 {
                    Task {
                        await self?.searchArrivalAirports(query: searchText)
                    }
                } else {
                    self?.arrivalAirports = []
                }
            }
            .store(in: &cancellables)
    }
    
    // Add property to control search type
    var shouldPerformMixedSearch = false
    
    func searchAirportsOnly(query: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let response = try await networkManager.searchAirports(query: query)
            airports = response.results
            airlines = [] // Clear airlines for airport-only search
        } catch {
            errorMessage = error.localizedDescription
            airports = []
            airlines = []
        }
        
        isLoading = false
    }
    
    func performMixedSearch(query: String) async {
        isLoading = true
        errorMessage = nil
        
        // Perform both searches in parallel but handle errors independently
        async let airportResults = networkManager.searchAirports(query: query)
        async let airlineResults = networkManager.searchAirlines(query: query)
        
        var airportResponse: FlightTrackAirportResponse?
        var airlineResponse: AirlineResponse?
        
        // Handle airport search
        do {
            airportResponse = try await airportResults
        } catch {
            print("Airport search failed: \(error)")
        }
        
        // Handle airline search
        do {
            airlineResponse = try await airlineResults
        } catch {
            print("Airline search failed: \(error)")
        }
        
        // Update results
        airports = airportResponse?.results ?? []
        airlines = airlineResponse?.results ?? []
        
        // Set error message only if both searches failed
        if airports.isEmpty && airlines.isEmpty {
            errorMessage = "No results found"
        }
        
        // Determine the primary search type based on results
        determineSearchEntityType()
        
        isLoading = false
    }
    
    func searchArrivalAirports(query: String) async {
        do {
            let response = try await networkManager.searchAirports(query: query)
            arrivalAirports = response.results
        } catch {
            print("Error searching arrival airports: \(error)")
            arrivalAirports = []
        }
    }
    
    private func determineSearchEntityType() {
        // Logic to determine if user is searching for airport or airline
        // Check if search text looks like airline code (2-3 letters) or airport code (3 letters)
        let searchUpper = searchText.uppercased()
        
        if searchUpper.count == 2 || (searchUpper.count == 3 && !airlines.isEmpty) {
            searchEntityType = .airline
        } else if searchUpper.count == 3 || !airports.isEmpty {
            searchEntityType = .airport
        } else {
            searchEntityType = .unknown
        }
    }
    
    func selectAirline(_ airline: FlightTrackAirline) {
        selectedSearchType = .flight
        let airlineCode = airline.iataCode ?? airline.icaoCode ?? "??"
        searchText = "\(airlineCode) - \(airline.name)"
    }
    
    func selectAirport(_ airport: FlightTrackAirport) {
        selectedSearchType = .airport
        searchText = "\(airport.iataCode) - \(airport.city)"
    }
    
    func selectArrivalAirport(_ airport: FlightTrackAirport) {
        arrivalAirportText = "\(airport.iataCode) - \(airport.city)"
        arrivalAirports = []
    }
    
    func clearSearch() {
        searchText = ""
        clearSearchResults()
    }
    
    func clearSearchResults() {
        airports = []
        airlines = []
        errorMessage = nil
        searchEntityType = .unknown
    }
    
    func resetTrackedSearch() {
        selectedSearchType = nil
        flightNumber = ""
        arrivalAirportText = ""
        arrivalAirports = []
        selectedDate = nil
        clearSearch()
    }
}

// MARK: - Network Manager
class FlightTrackNetworkManager {
    static let shared = FlightTrackNetworkManager()
    private let baseURL = "https://staging.flight.lascade.com/api"
    private let authorization = "TheAllPowerfulKingOf7SeasAnd5LandsAkbarTheGreatCommandsTheAPIToWork"
    
    private init() {}
    
    func searchAirports(query: String) async throws -> FlightTrackAirportResponse {
        guard let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "\(baseURL)/v1/airports/?search=\(encodedQuery)") else {
            throw FlightTrackNetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "accept")
        request.addValue("v3Yue9c38cnNCoD19M9mWxOdXHWoAyofjsRmKOzzMq0rZ2cp4yH2irOOdjG4SMqs", forHTTPHeaderField: "X-CSRFToken")
        request.addValue(authorization, forHTTPHeaderField: "Authorization")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw FlightTrackNetworkError.invalidResponse
        }
        
        guard 200...299 ~= httpResponse.statusCode else {
            print("Airport search failed with status: \(httpResponse.statusCode)")
            throw FlightTrackNetworkError.serverError(httpResponse.statusCode)
        }
        
        do {
            let airportResponse = try JSONDecoder().decode(FlightTrackAirportResponse.self, from: data)
            print("Successfully decoded \(airportResponse.results.count) airports")
            return airportResponse
        } catch {
            print("Airport decoding error: \(error)")
            if let jsonString = String(data: data, encoding: .utf8) {
                print("Raw JSON response: \(jsonString)")
            }
            throw FlightTrackNetworkError.decodingError(error)
        }
    }
    
    func searchAirlines(query: String) async throws -> AirlineResponse {
        guard let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "\(baseURL)/v1/airlines/?search=\(encodedQuery)") else {
            throw FlightTrackNetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "accept")
        request.addValue("v3Yue9c38cnNCoD19M9mWxOdXHWoAyofjsRmKOzzMq0rZ2cp4yH2irOOdjG4SMqs", forHTTPHeaderField: "X-CSRFToken")
        request.addValue(authorization, forHTTPHeaderField: "Authorization")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw FlightTrackNetworkError.invalidResponse
        }
        
        guard 200...299 ~= httpResponse.statusCode else {
            print("Airline search failed with status: \(httpResponse.statusCode)")
            throw FlightTrackNetworkError.serverError(httpResponse.statusCode)
        }
        
        do {
            let airlineResponse = try JSONDecoder().decode(AirlineResponse.self, from: data)
            print("Successfully decoded \(airlineResponse.results.count) airlines")
            return airlineResponse
        } catch {
            print("Airline decoding error: \(error)")
            if let jsonString = String(data: data, encoding: .utf8) {
                print("Raw JSON response: \(jsonString)")
            }
            throw FlightTrackNetworkError.decodingError(error)
        }
    }
}

// MARK: - Network Errors
enum FlightTrackNetworkError: LocalizedError {
    case invalidURL
    case invalidResponse
    case serverError(Int)
    case decodingError(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid response"
        case .serverError(let code):
            return "Server error with code: \(code)"
        case .decodingError(let error):
            return "Decoding error: \(error.localizedDescription)"
        }
    }
}
