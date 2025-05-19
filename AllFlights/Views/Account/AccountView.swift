import SwiftUI

// MARK: - Reusable Components
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

// MARK: - Optimized AccountView
struct AccountView: View {
    @Environment(\.dismiss) private var dismiss
    
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
                            .fontWeight(.semibold)
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
                            subtitle: "India",
                            icon: Image("flag"),
                            action: {}
                        )
                        
                        SettingCard(
                            title: "Currency",
                            subtitle: "India",
                            action: {}
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
        }
    }
}

#Preview{
    AccountView()
}
