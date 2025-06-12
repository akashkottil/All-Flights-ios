// MARK: - Enhanced Shimmer Effect

import SwiftUICore
import SwiftUI
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
