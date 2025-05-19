import SwiftUI

struct HomeView: View {
    @State private var isSearchExpanded = true
    @State private var navigateToAccount = false
    @Namespace private var animation
    @GestureState private var dragOffset: CGFloat = 0

    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                Color("AppPrimaryColor")
                    .frame(height: UIScreen.main.bounds.height * 0.3)
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    // Sticky header
                    headerView
                        .zIndex(1)

                    ScrollView {
                        VStack(spacing: 0) {
                            // ✅ GeometryReader must be inside the scrollable VStack
                            GeometryReader { geo in
                                Color.clear
                                    .preference(
                                        key: ScrollOffsetPreferenceKey.self,
                                        value: geo.frame(in: .named("scroll")).minY
                                    )
                            }
                            .frame(height: 0)

                            // Search Section
                            ZStack {
                                if isSearchExpanded {
                                    SearchInput()
                                        .matchedGeometryEffect(id: "searchBox", in: animation)
                                        .transition(.opacity.combined(with: .move(edge: .top)))
                                        .gesture(dragGesture)
                                } else {
                                    CollapsibleSearchInput(isExpanded: $isSearchExpanded)
                                        .matchedGeometryEffect(id: "searchBox", in: animation)
                                        .transition(.opacity.combined(with: .move(edge: .top)))
                                }
                            }
                            .animation(.spring(response: 0.4, dampingFraction: 0.8), value: isSearchExpanded)
                            .padding(.bottom, 10)

                            // Scrollable content
                            VStack(spacing: 16) {
                                recentSearchSection
                                CheapFlights()
                                FeatureCards()
                                LoginNotifier()
                                ratingPrompt
                                BottomSignature()
                            }
                        }
                    }
                    .coordinateSpace(name: "scroll")
                    .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
                        print("Scroll offset value: \(value)") // ✅ Debug scroll value
                        let threshold: CGFloat = -40
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                            isSearchExpanded = value > threshold
                        }
                    }
                }
            }
            .navigationDestination(isPresented: $navigateToAccount) {
                AccountView()
            }
        }
        .scrollIndicators(.hidden)
    }

    // MARK: - Drag Gesture for collapsing SearchInput
    var dragGesture: some Gesture {
        DragGesture(minimumDistance: 10, coordinateSpace: .global)
            .updating($dragOffset) { value, state, _ in
                state = value.translation.height
            }
            .onEnded { value in
                if value.translation.height < -20 {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                        isSearchExpanded = false
                    }
                }
            }
    }

    // MARK: - Header View
    var headerView: some View {
        HStack {
            Image("logoHome")
                .resizable()
                .frame(width: 25, height: 25)
                .cornerRadius(6)
                .padding(.trailing, 4)

            Text("All Flights")
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(.white)

            Spacer()

            Image("homeProfile")
                .resizable()
                .frame(width: 30, height: 30)
                .cornerRadius(6)
                .padding(.trailing, 4)
                .onTapGesture {
                    navigateToAccount = true
                }
        }
        .padding(.horizontal, 25)
        .padding(.top, 20)
        .padding(.bottom, 10)
        .background(Color("AppPrimaryColor").ignoresSafeArea(edges: .top))
    }

    // MARK: - Recent Search Section
    var recentSearchSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Recent Search")
                    .font(.system(size: 18))
                    .foregroundColor(.black)
                    .fontWeight(.semibold)
                Spacer()
                Text("Clear All")
                    .foregroundColor(Color("ThridColor"))
                    .font(.system(size: 14))
                    .fontWeight(.bold)
            }
            .padding(.horizontal)

            RecentSearch()
        }
    }

    // MARK: - Rating Prompt
    var ratingPrompt: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color("gradientBlueLeft"), Color("gradientBlueRight")]),
                startPoint: .leading,
                endPoint: .trailing
            )
            HStack {
                Image("starImg")
                Spacer()
                VStack(alignment: .leading) {
                    Text("How do you feel?")
                        .font(.system(size: 22))
                        .fontWeight(.bold)
                    Text("Rate us On Appstore")
                        .font(.system(size: 14))
                        .fontWeight(.semibold)
                }
                Spacer()
                Button(action: {}) {
                    Text("Rate Us")
                        .font(.system(size: 14))
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding(.vertical, 10)
                        .padding(.horizontal, 20)
                        .background(Color("buttonBlue"))
                        .cornerRadius(10)
                }
            }
            .padding()
        }
    }
}

// MARK: - Scroll Offset Preference Key
struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

// MARK: - Preview
#Preview {
    HomeView()
}
