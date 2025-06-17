// ViewModels/AirportSearchViewModel.swift
import Foundation
import Combine

@MainActor
class AirportSearchViewModel: ObservableObject {
    @Published var searchText = ""
    @Published var airports: [FlightTrackAirport] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
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
                        await self?.searchAirports(query: searchText)
                    }
                } else {
                    self?.airports = []
                }
            }
            .store(in: &cancellables)
    }
    
    func searchAirports(query: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let response = try await networkManager.searchAirports(query: query)
            airports = response.results
        } catch {
            errorMessage = error.localizedDescription
            airports = []
        }
        
        isLoading = false
    }
    
    func clearSearch() {
        searchText = ""
        airports = []
        errorMessage = nil
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
            throw FlightTrackNetworkError.serverError(httpResponse.statusCode)
        }
        
        do {
            let airportResponse = try JSONDecoder().decode(FlightTrackAirportResponse.self, from: data)
            return airportResponse
        } catch {
            print("Decoding error: \(error)")
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
