// View+Extensions.swift
// NurseryConnect
// SwiftUI View extensions for glassmorphism, neumorphism, and animations

import SwiftUI

// MARK: - Glassmorphism Modifier
struct GlassMorphismModifier: ViewModifier {
    var cornerRadius: CGFloat
    var opacity: CGFloat
    
    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(.ultraThinMaterial)
                    .opacity(opacity)
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.3),
                                Color.white.opacity(0.1)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
    }
}

// MARK: - Neumorphism Modifier
struct NeumorphismModifier: ViewModifier {
    @Environment(\.colorScheme) var colorScheme
    var cornerRadius: CGFloat
    var isPressed: Bool
    
    func body(content: Content) -> some View {
        content
            .background(
                Group {
                    if colorScheme == .dark {
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .fill(Color.ncBackgroundDark)
                            .shadow(color: Color.black.opacity(0.5), radius: isPressed ? 2 : 8, x: isPressed ? 2 : 6, y: isPressed ? 2 : 6)
                            .shadow(color: Color(hex: "2A2B4A").opacity(0.5), radius: isPressed ? 2 : 8, x: isPressed ? -2 : -6, y: isPressed ? -2 : -6)
                    } else {
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .fill(Color.ncBackgroundLight)
                            .shadow(color: Color.black.opacity(0.12), radius: isPressed ? 2 : 8, x: isPressed ? 2 : 6, y: isPressed ? 2 : 6)
                            .shadow(color: Color.white.opacity(0.9), radius: isPressed ? 2 : 8, x: isPressed ? -2 : -6, y: isPressed ? -2 : -6)
                    }
                }
            )
    }
}

// MARK: - Animated Appear Modifier
struct AnimatedAppearModifier: ViewModifier {
    @State private var isVisible = false
    var delay: Double
    var offsetY: CGFloat
    
    func body(content: Content) -> some View {
        content
            .opacity(isVisible ? 1 : 0)
            .offset(y: isVisible ? 0 : offsetY)
            .onAppear {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(delay)) {
                    isVisible = true
                }
            }
    }
}

// MARK: - Slide In From Edge
struct SlideInModifier: ViewModifier {
    @State private var isVisible = false
    var delay: Double
    var edge: Edge
    
    var offset: CGSize {
        switch edge {
        case .leading: return CGSize(width: -50, height: 0)
        case .trailing: return CGSize(width: 50, height: 0)
        case .top: return CGSize(width: 0, height: -30)
        case .bottom: return CGSize(width: 0, height: 30)
        }
    }
    
    func body(content: Content) -> some View {
        content
            .opacity(isVisible ? 1 : 0)
            .offset(isVisible ? .zero : offset)
            .onAppear {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.75).delay(delay)) {
                    isVisible = true
                }
            }
    }
}

// MARK: - Pulse Animation
struct PulseModifier: ViewModifier {
    @State private var isPulsing = false
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(isPulsing ? 1.05 : 1.0)
            .animation(
                .easeInOut(duration: 1.2)
                .repeatForever(autoreverses: true),
                value: isPulsing
            )
            .onAppear { isPulsing = true }
    }
}

// MARK: - Shimmer Effect
struct ShimmerModifier: ViewModifier {
    @State private var phase: CGFloat = 0
    
    func body(content: Content) -> some View {
        content
            .overlay(
                GeometryReader { geometry in
                    LinearGradient(
                        colors: [
                            Color.clear,
                            Color.white.opacity(0.4),
                            Color.clear
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .frame(width: geometry.size.width * 2)
                    .offset(x: phase * geometry.size.width * 2 - geometry.size.width)
                }
            )
            .mask(content)
            .onAppear {
                withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                    phase = 1
                }
            }
    }
}

// MARK: - Card Style Modifier
struct CardStyleModifier: ViewModifier {
    @Environment(\.colorScheme) var colorScheme
    var cornerRadius: CGFloat
    var hasShadow: Bool
    
    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(colorScheme == .dark ? Color(hex: "242540") : .white)
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(colorScheme == .dark ? Color.white.opacity(0.05) : Color.clear, lineWidth: 1)
            )
            .if(hasShadow) { view in
                view.shadow(color: Color.black.opacity(colorScheme == .dark ? 0.3 : 0.08), radius: 12, x: 0, y: 4)
            }
    }
}

// MARK: - View Extensions
extension View {
    func glassMorphism(cornerRadius: CGFloat = 20, opacity: CGFloat = 0.8) -> some View {
        modifier(GlassMorphismModifier(cornerRadius: cornerRadius, opacity: opacity))
    }
    
    func neumorphic(cornerRadius: CGFloat = 16, isPressed: Bool = false) -> some View {
        modifier(NeumorphismModifier(cornerRadius: cornerRadius, isPressed: isPressed))
    }
    
    func animatedAppear(delay: Double = 0, offsetY: CGFloat = 20) -> some View {
        modifier(AnimatedAppearModifier(delay: delay, offsetY: offsetY))
    }
    
    func slideIn(delay: Double = 0, from edge: Edge = .bottom) -> some View {
        modifier(SlideInModifier(delay: delay, edge: edge))
    }
    
    func pulse() -> some View {
        modifier(PulseModifier())
    }
    
    func shimmer() -> some View {
        modifier(ShimmerModifier())
    }
    
    func cardStyle(cornerRadius: CGFloat = 16, hasShadow: Bool = true) -> some View {
        modifier(CardStyleModifier(cornerRadius: cornerRadius, hasShadow: hasShadow))
    }
    
    // Conditional modifier
    @ViewBuilder
    func `if`<Transform: View>(_ condition: Bool, transform: (Self) -> Transform) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
    
    // Adaptive background
    func adaptiveBackground() -> some View {
        self.background(Color.ncBackground)
    }
}

// MARK: - Adaptive Colors
extension Color {
    static var ncBackground: Color {
        Color(UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor(Color.ncBackgroundDark)
                : UIColor(Color.ncBackgroundLight)
        })
    }
    
    static var ncText: Color {
        Color(UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor.white
                : UIColor(Color.ncTextPrimary)
        })
    }
    
    static var ncTextSec: Color {
        Color(UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor(white: 0.7, alpha: 1)
                : UIColor(Color.ncTextSecondary)
        })
    }
    
    static var ncCard: Color {
        Color(UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor(Color(hex: "242540"))
                : UIColor.white
        })
    }
}

// MARK: - Number Counting Animation
struct CountingNumberModifier: AnimatableModifier {
    var number: Double
    
    var animatableData: Double {
        get { number }
        set { number = newValue }
    }
    
    func body(content: Content) -> some View {
        Text("\(Int(number))")
            .font(.ncMono(28))
            .fontWeight(.bold)
    }
}
