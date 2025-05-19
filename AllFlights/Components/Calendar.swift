import SwiftUI

struct APIResponse: Codable {
    let results: [FlightPrice]
}

struct FlightPrice: Codable {
    let date: TimeInterval  // Unix timestamp
    let price: Int
    let price_category: String
}

struct LanguageData: Codable {
    var months: MonthNames
    var days: DayNames
    
    struct MonthNames: Codable {
        var full: [String]
        var short: [String]
    }
    
    struct DayNames: Codable {
        var full: [String]
        var short: [String]
        var min: [String]
    }
}

struct DateSelection {
    var selectedDates: [Date] = []
    var selectionState: SelectionState = .none
    
    enum SelectionState {
        case none
        case firstDateSelected
        case rangeSelected
    }
}

struct CalendarFormatting {
    private static let dateCache = NSCache<NSString, NSString>()
    private static let timeCache = NSCache<NSString, NSString>()
    
    static let monthFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM"
        return formatter
    }()
    
    static let yearFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy"
        return formatter
    }()
    
    static let fullDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy"
        return formatter
    }()
    
    static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter
    }()
    
    static func monthString(for date: Date, languageData: LanguageData?, calendar: Calendar) -> String {
        if let languageData = languageData {
            let monthIndex = calendar.component(.month, from: date) - 1
            if monthIndex >= 0 && monthIndex < languageData.months.short.count {
                return languageData.months.short[monthIndex]
            }
        }
        return monthFormatter.string(from: date)
    }
    
    static func yearString(for date: Date) -> String {
        return yearFormatter.string(from: date)
    }
    
    static func formattedDate(_ date: Date?) -> String {
        guard let date = date else { return "MMM DD, YYYY" }
        
        let cacheKey = "\(date.timeIntervalSince1970)" as NSString
        if let cachedResult = dateCache.object(forKey: cacheKey) {
            return cachedResult as String
        }
        
        let result = fullDateFormatter.string(from: date)
        dateCache.setObject(result as NSString, forKey: cacheKey)
        return result
    }
    
    static func formattedTime(_ date: Date) -> String {
        let cacheKey = "\(date.timeIntervalSince1970)" as NSString
        if let cachedResult = timeCache.object(forKey: cacheKey) {
            return cachedResult as String
        }
        
        let result = timeFormatter.string(from: date)
        timeCache.setObject(result as NSString, forKey: cacheKey)
        return result
    }
}

// MARK: - CalendarView
struct CalendarView: View {
    @Binding var fromiatacode: String
    @Binding var toiatacode: String
    @Binding var parentSelectedDates: [Date]
   
    @State private var priceData: [Date: (Int, String)] = [:]
    private let calendar = Calendar.current
    
    // MARK: - Language Properties
    @State private var languages: [String: LanguageData] = [:]
    @State private var selectedLanguage: String = "English"
    @State private var showLanguagePicker = false
    
    // MARK: - State
    @State private var dateSelection = DateSelection()
    @State private var currentMonth = Date()
    @State private var showingMonths = 12
    
    // Time selection
    @State private var timeSelection: Bool = false // Changed to false to match the screenshot
    @State private var departureTime = Date()
    @State private var showDepartureTimePicker: Bool = false
    @State private var returnTime = Date()
    @State private var showReturnTimePicker: Bool = false
    
    // Single or range selection
    @State private var singleDate: Bool = true
    
    // Controls whether to show the return date selector
    @State private var showReturnDateSelector: Bool = false
    
    // MARK: - Computed Properties
    var selectedDates: [Date] {
        dateSelection.selectedDates
    }
    
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - Body
    var body: some View {
        VStack(spacing: 0) {
            // New header view that matches the screenshot
            calendarHeaderView
            
            // Weekday header
            weekdayHeaderView
                .background(Color.white)
            
            // Main calendar content
            ScrollView {
                VStack(spacing: 0) {
                    // Display multiple months
                    ForEach(0..<showingMonths, id: \.self) { monthOffset in
                        if let date = calendar.date(byAdding: .month, value: monthOffset, to: currentMonth) {
                            monthSectionView(for: date)
                        }
                    }
                }
                .padding(.bottom, 80) // Add padding at bottom to account for fixed Continue button
            }
            
            // Bottom Continue button (always visible)
            ContinueButtonView(
                tripType: showReturnDateSelector ? "Round Trip" : "One Way",
                price: getLowestPrice(),
                onContinue: {
                    parentSelectedDates = dateSelection.selectedDates
                    dismiss()
                }
            )
            .background(Color.white)
            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: -2)
        }
        .onAppear {
            loadLanguageData()
            
            // Initialize dateSelection with parentSelectedDates
            if !parentSelectedDates.isEmpty {
                dateSelection.selectedDates = parentSelectedDates
                
                // Update selection state based on number of dates
                if parentSelectedDates.count == 1 {
                    dateSelection.selectionState = .firstDateSelected
                } else if parentSelectedDates.count > 1 {
                    dateSelection.selectionState = .rangeSelected
                    showReturnDateSelector = true
                }
            }
            
            // Fetch prices for the current month
            fetchMonthlyPrices(for: currentMonth)
        }
    }
    
    // MARK: - Calendar Header View
    private var calendarHeaderView: some View {
        VStack(spacing: 0) {
            HStack {
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "xmark")
                        .font(.headline)
                        .padding()
                }
                
                Text("Dates")
                    .font(.headline)
                
                Spacer()
                
                Button("Anytime") {
                    // Handle anytime selection
                }
                .foregroundColor(.blue)
                .padding()
            }
            .padding(.horizontal)
            
            HStack(spacing: 15) {
                if dateSelection.selectedDates.isEmpty {
                    // No dates selected yet - show placeholders
                    // Departure date selector
                    VStack(alignment: .leading) {
                        Text("Departure")
                            .font(.subheadline)
                            .foregroundColor(.primary)
                            .padding(.horizontal)
                            .padding(.top, 8)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.orange, lineWidth: 2)
                    )
                    .padding(.leading)
                    
                    // Return date selector or Add Return button
                    if showReturnDateSelector {
                        VStack(alignment: .leading) {
                            Text("Return")
                                .font(.subheadline)
                                .foregroundColor(.primary)
                                .padding(.horizontal)
                                .padding(.top, 8)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                        .padding(.trailing)
                    } else {
                        Button(action: {
                            showReturnDateSelector = true
                            singleDate = false
                        }) {
                            Text("Add Return")
                                .font(.subheadline)
                                .foregroundColor(.blue)
                                .padding(.vertical, 10)
                                .padding(.horizontal)
                                .frame(maxWidth: .infinity)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                )
                        }
                        .padding(.trailing)
                    }
                } else {
                    // Show selected dates with X button
                    if let departureDate = dateSelection.selectedDates.first {
                        // Departure date display
                        HStack {
                            let dateFormatter = DateFormatter()
//                            dateFormatter.dateFormat = "EEE, d MMM"
                            
                            Text(dateFormatter.string(from: departureDate))
                                .font(.subheadline)
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            Button(action: {
                                // Clear this date
                                if dateSelection.selectedDates.count > 1 {
                                    dateSelection.selectedDates.removeFirst()
                                    dateSelection.selectionState = .firstDateSelected
                                } else {
                                    dateSelection.selectedDates = []
                                    dateSelection.selectionState = .none
                                }
                            }) {
                                Image(systemName: "xmark")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                .background(Color.white)
                        )
                        .padding(.leading)
                    }
                    
                    // Return date if available
                    if dateSelection.selectedDates.count > 1, let returnDate = dateSelection.selectedDates.last {
                        HStack {
                            let dateFormatter = DateFormatter()
//                            dateFormatter.dateFormat = "EEE, d MMM"
                            
                            Text(dateFormatter.string(from: returnDate))
                                .font(.subheadline)
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            Button(action: {
                                // Clear this date
                                dateSelection.selectedDates.removeLast()
                                dateSelection.selectionState = .firstDateSelected
                            }) {
                                Image(systemName: "xmark")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                .background(Color.white)
                        )
                        .padding(.trailing)
                    } else if showReturnDateSelector {
                        // Empty return date selector
                        VStack(alignment: .leading) {
                            Text("Return")
                                .font(.subheadline)
                                .foregroundColor(.primary)
                                .padding(.horizontal)
                                .padding(.top, 8)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                        .padding(.trailing)
                    } else {
                        // Add Return button
                        Button(action: {
                            showReturnDateSelector = true
                            singleDate = false
                        }) {
                            Text("Add Return")
                                .font(.subheadline)
                                .foregroundColor(.blue)
                                .padding(.vertical, 10)
                                .padding(.horizontal)
                                .frame(maxWidth: .infinity)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                )
                        }
                        .padding(.trailing)
                    }
                }
            }
            .padding(.bottom)
        }
        .background(Color.white)
    }
    
    // MARK: - Weekday Header View
    private var weekdayHeaderView: some View {
        HStack(spacing: 0) {
            ForEach(["S", "M", "T", "W", "T", "F", "S"], id: \.self) { day in
                Text(day)
                    .font(.subheadline)
                    .frame(maxWidth: .infinity)
                    .foregroundColor(.black)
            }
        }
        .padding(.vertical, 10)
        .background(Color.white)
        .overlay(
            Rectangle()
                .frame(height: 1)
                .foregroundColor(Color.gray.opacity(0.3)),
            alignment: .bottom
        )
    }
    
    // MARK: - Month Section View
    private func monthSectionView(for date: Date) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            // Month header
            HStack {
                Text("\(CalendarFormatting.monthString(for: date, languageData: languages[selectedLanguage], calendar: calendar)) , \(CalendarFormatting.yearString(for: date))")
                    .font(.headline)
                    .padding(.leading)
                    .padding(.top, 10)
                
                Spacer()
                
                Button("Select Month") {
                    // Handle month selection
                }
                .foregroundColor(.blue)
                .font(.subheadline)
                .padding(.trailing)
                .padding(.top, 10)
            }
            
            // Calendar grid
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 0), count: 7), spacing: 15) {
                let days = getDaysInMonth(for: date)
                
                ForEach(days, id: \.self) { day in
                    if let dayDate = day {
                        DayViewWithPrice(
                            date: dayDate,
                            isSelected: isDateSelected(dayDate),
                            calendar: calendar,
                            priceData: priceData,
                            isInRange: isDateInRange(dayDate),
                            isRangeSelection: dateSelection.selectedDates.count > 1
                        )
                        .onTapGesture {
                            if !isPastDate(dayDate) {
                                handleDateSelection(dayDate)
                                fetchMonthlyPrices(for: dayDate)
                            }
                        }
                        .contentShape(Rectangle()) // Makes the entire cell tappable
                    } else {
                        // Empty cell
                        Color.clear
                            .frame(height: 50)
                    }
                }
            }
            .padding(.bottom, 20)
        }
    }
    
    // MARK: - Day View with Price
    struct DayViewWithPrice: View {
        let date: Date
        let isSelected: Bool
        let calendar: Calendar
        let priceData: [Date: (Int, String)]
        
        // Check if this date is in a selected range (for highlighting dates between selections)
        let isInRange: Bool
        
        // Add a property to check if there are multiple dates selected (range selection)
        let isRangeSelection: Bool
        
        private var day: Int {
            calendar.component(.day, from: date)
        }
        
        private var price: Int? {
            let normalizedDate = calendar.startOfDay(for: date)
            return priceData[normalizedDate]?.0
        }
        
        private var priceCategory: String? {
            let normalizedDate = calendar.startOfDay(for: date)
            return priceData[normalizedDate]?.1
        }
        
        private var isPastDate: Bool {
            let today = calendar.startOfDay(for: Date())
            return calendar.compare(date, to: today, toGranularity: .day) == .orderedAscending
        }
        
        var body: some View {
            VStack(spacing: 5) {
                // Day number
                Text("\(day)")
                    .font(.system(size: 16))
                    .fontWeight(isSelected ? .bold : .regular)
                    .foregroundColor(
                        isPastDate ? Color.gray.opacity(0.5) :
                            (isSelected ? Color(hex: "#0044AB") : .black)
                    )
                    .frame(width: 36, height: 36)
                    .background(
                        RoundedRectangle(cornerRadius: 5)
                            .fill(isSelected ? Color.clear : Color.clear)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(
                                isPastDate ? Color.clear :
                                (isSelected ? Color(hex: "#0044AB") : Color.clear),
                                lineWidth: 1
                            )
                    )
                    .background(
                        // Only apply the background highlight if NOT in range selection mode
                        RoundedRectangle(cornerRadius: 5)
                            .fill(isInRange && !isSelected && !isPastDate && isRangeSelection ?
                                  Color.blue.opacity(0.2) : Color.clear)
                    )
                
                // Price
                if let price = price, !isPastDate {
                    Text("$\(price)")
                        .font(.system(size: 12))
                        .foregroundColor(getPriceColor(for: priceCategory ?? "normal"))
                } else {
                    // Empty text to maintain spacing
                    Text("")
                        .font(.system(size: 12))
                }
            }
            .frame(height: 50)
            .opacity(isPastDate ? 0.5 : 1.0)
        }
        
        private func getPriceColor(for category: String) -> Color {
            switch category.lowercased() {
            case "cheap":
                return .green
            case "expensive":
                return .red
            case "normal":
                return .gray
            default:
                return .primary
            }
        }
    }
    
    // Get the lowest price for the selected trip
    private func getLowestPrice() -> Int {
        if dateSelection.selectedDates.isEmpty {
            // If no dates selected, find the lowest price in the priceData
            if let minPrice = priceData.values.map({ $0.0 }).min() {
                return minPrice
            }
            return 198 // Default price if no data available
        } else if dateSelection.selectedDates.count == 1, let selectedDate = dateSelection.selectedDates.first {
            // If only one date is selected, get its price if available
            let normalizedDate = calendar.startOfDay(for: selectedDate)
            if let price = priceData[normalizedDate]?.0 {
                return price
            }
            return 198 // Default price if price for the selected date is not available
        } else if dateSelection.selectedDates.count >= 2 {
            // If two dates are selected (round trip), calculate total price
            // Here you might want to sum prices or implement your own pricing logic
            var totalPrice = 0
            for date in dateSelection.selectedDates {
                let normalizedDate = calendar.startOfDay(for: date)
                if let price = priceData[normalizedDate]?.0 {
                    totalPrice += price
                }
            }
            return totalPrice > 0 ? totalPrice : 198
        }
        
        return 198 // Default price
    }
    
    // MARK: - Continue Button View
    struct ContinueButtonView: View {
        let tripType: String
        let price: Int
        let onContinue: () -> Void
        
        var body: some View {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(tripType)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    Text("from $\(price)")
                        .font(.headline)
                        .foregroundColor(.black)
                }
                
                Spacer()
                
                Button(action: onContinue) {
                    Text("Continue")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(width: 120, height: 44)
                        .background(Color(hex: "#0044AB"))
                        .cornerRadius(8)
                }
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.white)
        }
    }
    
    // MARK: - Helper Methods
    private func isDateSelected(_ date: Date) -> Bool {
        dateSelection.selectedDates.contains { calendar.isDate($0, inSameDayAs: date) }
    }
    
    private func isPastDate(_ date: Date) -> Bool {
        let today = calendar.startOfDay(for: Date())
        return calendar.compare(date, to: today, toGranularity: .day) == .orderedAscending
    }
    
    private func isDateInRange(_ date: Date) -> Bool {
        // If we have two dates selected, check if this date is between them
        if dateSelection.selectedDates.count >= 2,
           let firstDate = dateSelection.selectedDates.first,
           let lastDate = dateSelection.selectedDates.last {
            
            let normalizedDate = calendar.startOfDay(for: date)
            let normalizedFirst = calendar.startOfDay(for: firstDate)
            let normalizedLast = calendar.startOfDay(for: lastDate)
            
            return normalizedDate >= normalizedFirst && normalizedDate <= normalizedLast
        }
        return false
    }
    
    private func handleDateSelection(_ date: Date) {
        if singleDate && !showReturnDateSelector {
            // Single date mode
            dateSelection.selectedDates = [date]
            dateSelection.selectionState = .firstDateSelected
        } else {
            // Two date selection mode
            switch dateSelection.selectionState {
            case .none:
                dateSelection.selectedDates = [date]
                dateSelection.selectionState = .firstDateSelected
                
            case .firstDateSelected:
                if calendar.isDate(date, inSameDayAs: dateSelection.selectedDates[0]) {
                    return // Same date, do nothing
                }
                
                let startDate = min(date, dateSelection.selectedDates[0])
                let endDate = max(date, dateSelection.selectedDates[0])
                dateSelection.selectedDates = [startDate, endDate]
                dateSelection.selectionState = .rangeSelected
                
            case .rangeSelected:
                // Start over with new date
                dateSelection.selectedDates = [date]
                dateSelection.selectionState = .firstDateSelected
            }
        }
    }
    
    private func getDaysInMonth(for date: Date) -> [Date?] {
        let monthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: date))!
        let daysInMonth = calendar.range(of: .day, in: .month, for: monthStart)?.count ?? 30
        
        // Get the weekday of the first day (1 = Sunday, 2 = Monday, etc.)
        let firstWeekday = calendar.component(.weekday, from: monthStart)
        
        // Create array with empty slots for days before the 1st of the month
        var days = Array(repeating: nil as Date?, count: firstWeekday - 1)
        
        // Add all days in the month
        for day in 1...daysInMonth {
            if let dayDate = calendar.date(byAdding: .day, value: day - 1, to: monthStart) {
                days.append(dayDate)
            }
        }
        
        return days
    }
    
    private func fetchMonthlyPrices(for selectedDate: Date) {
        guard let origin = fromiatacode.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let destination = toiatacode.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else { return }
        
        let calendar = Calendar.current
        let firstOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: selectedDate))!
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        let formattedDate = dateFormatter.string(from: firstOfMonth)

        let urlString = "https://staging.plane.lascade.com/api/price/?currency=INR&country=IN"
        guard let url = URL(string: urlString) else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let payload: [String: Any] = [
            "origin": origin,
            "destination": destination,
            "departure": formattedDate,
            "round_trip": true
        ]

        guard let httpBody = try? JSONSerialization.data(withJSONObject: payload) else { return }
        request.httpBody = httpBody

        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else { return }
            do {
                let decoded = try JSONDecoder().decode(APIResponse.self, from: data)
                DispatchQueue.main.async {
                    var newPriceData: [Date: (Int, String)] = [:]
                    for item in decoded.results {
                        let date = Date(timeIntervalSince1970: item.date)
                        let normalizedDate = calendar.startOfDay(for: date)
                        newPriceData[normalizedDate] = (item.price, item.price_category)
                    }
                    self.priceData = newPriceData
                }
            } catch {
                print("Failed to decode API response:", error)
            }
        }.resume()
    }
    
    private func loadLanguageData() {
        guard let fileURL = Bundle.main.url(forResource: "calendar_localizations", withExtension: "json"),
              let jsonData = try? Data(contentsOf: fileURL) else {
            print("Failed to load language data file")
            return
        }
        
        do {
            let decoder = JSONDecoder()
            languages = try decoder.decode([String: LanguageData].self, from: jsonData)
            
            if languages.keys.contains("English") {
                selectedLanguage = "English"
            } else {
                selectedLanguage = languages.keys.sorted().first ?? selectedLanguage
            }
        } catch {
            print("Error decoding language data: \(error)")
        }
    }
}



struct CalendarView_Previews: PreviewProvider {
    static var previews: some View {
        struct PreviewWrapper: View {
            @State private var dates: [Date] = []
            @State private var fromIataCode: String = "COK"
            @State private var toIataCode: String = "DXB"

            var body: some View {
                CalendarView(fromiatacode: $fromIataCode, toiatacode: $toIataCode, parentSelectedDates: $dates)
            }
        }
        
        return PreviewWrapper()
    }
}
