import SwiftUI
import Foundation
import Combine
// MARK: - Models
struct Country: Codable, Identifiable, Hashable {
    let id = UUID()
    let name: String
    let code: String
    let flag: String?
    
    private enum CodingKeys: String, CodingKey {
        case name, code, flag
    }
}

struct Currency: Codable, Identifiable, Hashable {
    let id = UUID()
    let name: String
    let code: String
    let symbol: String?
    let flag: String?
    
    private enum CodingKeys: String, CodingKey {
        case name, code, symbol, flag
    }
}

struct CountriesResponse: Codable {
    let results: [Country]
    let count: Int
    let next: String?
    let previous: String?
}

struct CurrenciesResponse: Codable {
    let results: [Currency]
    let count: Int
    let next: String?
    let previous: String?
}

// MARK: - API Service
class APIService: ObservableObject {
    private let baseURL = "https://staging.plane.lascade.com/api"
    
    func fetchCountries(search: String = "", page: Int = 1, limit: Int = 50) async throws -> CountriesResponse {
        var components = URLComponents(string: "\(baseURL)/countries/")!
        var queryItems: [URLQueryItem] = [
            URLQueryItem(name: "page", value: String(page)),
            URLQueryItem(name: "limit", value: String(limit))
        ]
        
        if !search.isEmpty {
            queryItems.append(URLQueryItem(name: "search", value: search))
        }
        
        components.queryItems = queryItems
        
        let (data, _) = try await URLSession.shared.data(from: components.url!)
        return try JSONDecoder().decode(CountriesResponse.self, from: data)
    }
    
    func fetchCurrencies(search: String = "", page: Int = 1, limit: Int = 50) async throws -> CurrenciesResponse {
        var components = URLComponents(string: "\(baseURL)/currencies/")!
        var queryItems: [URLQueryItem] = [
            URLQueryItem(name: "page", value: String(page)),
            URLQueryItem(name: "limit", value: String(limit))
        ]
        
        if !search.isEmpty {
            queryItems.append(URLQueryItem(name: "search", value: search))
        }
        
        components.queryItems = queryItems
        
        let (data, _) = try await URLSession.shared.data(from: components.url!)
        return try JSONDecoder().decode(CurrenciesResponse.self, from: data)
    }
}

// MARK: - ViewModels
class CountryViewModel: ObservableObject {
    @Published var countries: [Country] = []
    @Published var isLoading = false
    @Published var searchText = ""
    @Published var selectedCountry: Country?
    
    private let apiService = APIService()
    private var searchTask: Task<Void, Never>?
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        Task {
            await loadCountries()
        }
        
        // Setup search debouncing
        $searchText
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            .sink { [weak self] _ in
                Task {
                    await self?.searchCountries()
                }
            }
            .store(in: &cancellables)
    }
    
    func loadCountries() async {
        await MainActor.run {
            isLoading = true
        }
        
        do {
            let response = try await apiService.fetchCountries()
            await MainActor.run {
                self.countries = response.results
                self.isLoading = false
            }
        } catch {
            print("Error loading countries: \(error)")
            await MainActor.run {
                self.isLoading = false
            }
        }
    }
    
    func searchCountries() async {
        searchTask?.cancel()
        searchTask = Task {
            await MainActor.run {
                isLoading = true
            }
            
            do {
                let response = try await apiService.fetchCountries(search: searchText)
                if !Task.isCancelled {
                    await MainActor.run {
                        self.countries = response.results
                        self.isLoading = false
                    }
                }
            } catch {
                if !Task.isCancelled {
                    print("Error searching countries: \(error)")
                    await MainActor.run {
                        self.isLoading = false
                    }
                }
            }
        }
    }
}

class CurrencyViewModel: ObservableObject {
    @Published var currencies: [Currency] = []
    @Published var isLoading = false
    @Published var searchText = ""
    @Published var selectedCurrency: Currency?
    
    private let apiService = APIService()
    private var searchTask: Task<Void, Never>?
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        Task {
            await loadCurrencies()
        }
        
        // Setup search debouncing
        $searchText
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            .sink { [weak self] _ in
                Task {
                    await self?.searchCurrencies()
                }
            }
            .store(in: &cancellables)
    }
    
    func loadCurrencies() async {
        await MainActor.run {
            isLoading = true
        }
        
        do {
            let response = try await apiService.fetchCurrencies()
            await MainActor.run {
                self.currencies = response.results
                self.isLoading = false
            }
        } catch {
            print("Error loading currencies: \(error)")
            await MainActor.run {
                self.isLoading = false
            }
        }
    }
    
    func searchCurrencies() async {
        searchTask?.cancel()
        searchTask = Task {
            await MainActor.run {
                isLoading = true
            }
            
            do {
                let response = try await apiService.fetchCurrencies(search: searchText)
                if !Task.isCancelled {
                    await MainActor.run {
                        self.currencies = response.results
                        self.isLoading = false
                    }
                }
            } catch {
                if !Task.isCancelled {
                    print("Error searching currencies: \(error)")
                    await MainActor.run {
                        self.isLoading = false
                    }
                }
            }
        }
    }
}

// MARK: - Currency Selection Sheet
struct CurrencySelectionSheet: View {
    @StateObject private var viewModel = CurrencyViewModel()
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedCurrency: Currency?
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.black)
                    }
                    
                    Spacer()
                    
                    Text("Currency")
                        .font(.system(size: 18, weight: .semibold))
                    
                    Spacer()
                    
                    // Invisible button for spacing
                    Button(action: {}) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .medium))
                    }
                    .opacity(0)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 15)
                
                Divider()
                
                VStack(spacing: 0) {
                    // Search Bar
                    HStack {
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.gray)
                                .font(.system(size: 16))
                            
                            TextField("Search Currency", text: $viewModel.searchText)
                                .font(.system(size: 16))
                            
                            if !viewModel.searchText.isEmpty {
                                Button(action: {
                                    viewModel.searchText = ""
                                }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.gray)
                                        .font(.system(size: 16))
                                }
                            }
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 10)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    .padding(.bottom, 15)
                    
                    // Currency List
                    if viewModel.isLoading {
                        Spacer()
                        ProgressView()
                            .scaleEffect(1.2)
                        Spacer()
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 0) {
                                ForEach(viewModel.currencies) { currency in
                                    CurrencyRow(
                                        currency: currency,
                                        isSelected: selectedCurrency?.code == currency.code
                                    ) {
                                        selectedCurrency = currency
                                        dismiss()
                                    }
                                    
                                    if currency != viewModel.currencies.last {
                                        Divider()
                                            .padding(.leading, 60)
                                    }
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                    }
                }
            }
            .navigationBarHidden(true)
        }
    }
}

struct CurrencyRow: View {
    let currency: Currency
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                // Flag or placeholder
                if let flag = currency.flag {
                    Text(flag)
                        .font(.system(size: 24))
                        .frame(width: 32, height: 24)
                } else {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color(.systemGray4))
                        .frame(width: 32, height: 24)
                        .overlay(
                            Text(currency.code.prefix(2))
                                .font(.system(size: 10, weight: .medium))
                                .foregroundColor(.white)
                        )
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(currency.code)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.black)
                    
                    Text(currency.name)
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                // Checkbox
                Image(systemName: isSelected ? "checkmark.square.fill" : "square")
                    .font(.system(size: 20))
                    .foregroundColor(isSelected ? .blue : .gray)
            }
            .padding(.vertical, 12)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Region Selection Sheet
struct RegionSelectionSheet: View {
    @StateObject private var viewModel = CountryViewModel()
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedCountry: Country?
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.black)
                    }
                    
                    Spacer()
                    
                    Text("Region")
                        .font(.system(size: 18, weight: .semibold))
                    
                    Spacer()
                    
                    // Invisible button for spacing
                    Button(action: {}) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .medium))
                    }
                    .opacity(0)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 15)
                
                Divider()
                
                VStack(spacing: 0) {
                    // Search Bar
                    HStack {
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.gray)
                                .font(.system(size: 16))
                            
                            TextField("Search Region", text: $viewModel.searchText)
                                .font(.system(size: 16))
                            
                            if !viewModel.searchText.isEmpty {
                                Button(action: {
                                    viewModel.searchText = ""
                                }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.gray)
                                        .font(.system(size: 16))
                                }
                            }
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 10)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    .padding(.bottom, 15)
                    
                    // Country List
                    if viewModel.isLoading {
                        Spacer()
                        ProgressView()
                            .scaleEffect(1.2)
                        Spacer()
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 0) {
                                ForEach(viewModel.countries) { country in
                                    CountryRow(
                                        country: country,
                                        isSelected: selectedCountry?.code == country.code
                                    ) {
                                        selectedCountry = country
                                        dismiss()
                                    }
                                    
                                    if country != viewModel.countries.last {
                                        Divider()
                                            .padding(.leading, 60)
                                    }
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                    }
                }
            }
            .navigationBarHidden(true)
        }
    }
}

struct CountryRow: View {
    let country: Country
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                // Flag or placeholder
                if let flag = country.flag {
                    Text(flag)
                        .font(.system(size: 24))
                        .frame(width: 32, height: 24)
                } else {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color(.systemGray4))
                        .frame(width: 32, height: 24)
                        .overlay(
                            Text(country.code.prefix(2))
                                .font(.system(size: 10, weight: .medium))
                                .foregroundColor(.white)
                        )
                }
                
                Text(country.name)
                    .font(.system(size: 16))
                    .foregroundColor(.black)
                
                Spacer()
                
                // Checkbox
                Image(systemName: isSelected ? "checkmark.square.fill" : "square")
                    .font(.system(size: 20))
                    .foregroundColor(isSelected ? .blue : .gray)
            }
            .padding(.vertical, 12)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Updated AccountView
struct AccountView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var showingCurrencySheet = false
    @State private var showingRegionSheet = false
    @State private var selectedCurrency: Currency?
    @State private var selectedCountry: Country?
    
    // Legal items data for reusability
    private let legalItems = [
        "Request a feature",
        "Contact us",
        "About us",
        "Rate our app"
    ]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack {
                    // Header
                    HStack {
                        Button(action: {
                            dismiss()
                        }) {
                            Image("BackIcon")
                        }
                        Spacer()
                        Text("Account")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .padding(.trailing, 30)
                        Spacer()
                    }
                    
                    Divider()
                    
                    VStack(alignment: .leading, spacing: 15) {
                        // Login section
                        VStack(alignment: .leading) {
                            Text("Ready for Takeoff? ")
                                .font(.system(size: 22))
                                .fontWeight(.bold)
                            Text("Log In Now")
                                .font(.system(size: 22))
                                .fontWeight(.bold)
                        }
                        
                        Text("Access your profile, manage settings, and view personalized features.")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                        Button(action: {}) {
                            Text("Login")
                                .font(.system(size: 14))
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .padding(.vertical, 10)
                                .padding(.horizontal, 20)
                                .background(Color("buttonBlue"))
                                .cornerRadius(10)
                        }
                        
                        // App Settings section
                        SectionTitle(text: "App Settings")
                        
                        SettingCard(
                            title: "Region",
                            subtitle: selectedCountry?.name ?? "India",
                            icon: Image("flag"),
                            action: {
                                showingRegionSheet = true
                            }
                        )
                        
                        SettingCard(
                            title: "Currency",
                            subtitle: selectedCurrency?.name ?? "Rupee",
                            action: {
                                showingCurrencySheet = true
                            }
                        )
                        
                        SettingCard(
                            title: "Display",
                            subtitle: "Light mode",
                            action: {}
                        )
                        
                        // Legal and Info section
                        SectionTitle(text: "Legal and Info")
                        
                        VStack(spacing: 10) {
                            ForEach(legalItems, id: \.self) { item in
                                LegalInfoItem(title: item, action: {})
                                
                                if item != legalItems.last {
                                    Divider()
                                }
                            }
                        }
                        .padding(.vertical, 10)
                        .padding(.horizontal, 20)
                        .background(Color.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.gray, lineWidth: 1)
                        )
                        .cornerRadius(10)
                    }
                    .padding(.top, 20)
                }
                .padding()
            }
            .scrollIndicators(.hidden)
            .navigationBarBackButtonHidden(true)
            .sheet(isPresented: $showingCurrencySheet) {
                CurrencySelectionSheet(selectedCurrency: $selectedCurrency)
            }
            .sheet(isPresented: $showingRegionSheet) {
                RegionSelectionSheet(selectedCountry: $selectedCountry)
            }
        }
    }
}

// MARK: - Original Reusable Components (unchanged)
struct SectionTitle: View {
    let text: String
    
    var body: some View {
        Text(text)
            .font(.system(size: 18))
            .fontWeight(.bold)
            .padding(.vertical, 5)
    }
}

struct SettingCard: View {
    let title: String
    let subtitle: String
    var icon: Image? = nil
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading) {
                    Text(title)
                        .font(.system(size: 16))
                        .fontWeight(.semibold)
                    
                    HStack {
                        icon
                            .frame(width: 16, height: 12)
                        Text(subtitle)
                            .font(.system(size: 14))
                            .fontWeight(.medium)
                            .foregroundColor(.gray)
                    }
                    Spacer()
                }
                Spacer()
                Image("RightArrow")
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 20)
            .background(Color.white)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.gray, lineWidth: 1)
            )
            .cornerRadius(10)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct LegalInfoItem: View {
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading) {
                    Text(title)
                        .font(.system(size: 16))
                        .fontWeight(.semibold)
                    Spacer()
                }
                Spacer()
                Image("RightArrow")
                    
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Preview
#Preview {
    AccountView()
}



