// HapticManager.swift
// NurseryConnect
// Centralized haptic feedback for all app interactions

import UIKit

struct HapticManager {
    
    static func impact(_ style: UIImpactFeedbackGenerator.FeedbackStyle = .medium) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }
    
    static func notification(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(type)
    }
    
    static func selection() {
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()
    }
    
    // Convenience methods
    static func lightTap() {
        impact(.light)
    }
    
    static func mediumTap() {
        impact(.medium)
    }
    
    static func heavyTap() {
        impact(.heavy)
    }
    
    static func success() {
        notification(.success)
    }
    
    static func warning() {
        notification(.warning)
    }
    
    static func error() {
        notification(.error)
    }
}
