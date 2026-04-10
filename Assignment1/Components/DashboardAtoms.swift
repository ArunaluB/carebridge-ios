import SwiftUI

struct DashboardStatChipView: View {
    let icon: String
    let value: String
    let label: String
    let color: Color

    var body: some View {
        VStack(spacing: 10) {
            ZStack {
                Circle().fill(color.opacity(0.14)).frame(width: 42, height: 42)
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(color)
            }

            Text(value)
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundStyle(Color.ncText)

            Text(label)
                .font(.system(size: 10, weight: .medium))
                .foregroundStyle(Color.ncTextSec)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 18)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.ncCard)
                .shadow(color: .black.opacity(0.07), radius: 12, x: 0, y: 4)
        )
        .accessibilityLabel("\(label): \(value)")
    }
}

struct DashboardQuickActionButton: View {
    let icon: String
    let label: String
    let color: Color
    let badge: String?
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                ZStack(alignment: .topTrailing) {
                    ZStack {
                        Circle()
                            .fill(color.opacity(0.14))
                            .frame(width: 42, height: 42)
                        Image(systemName: icon)
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(color)
                    }

                    if let badge {
                        Text(badge)
                            .font(.system(size: 8, weight: .bold))
                            .foregroundStyle(.white)
                            .frame(minWidth: 16, minHeight: 16)
                            .background(Capsule().fill(Color(hex: "FF6B6B")))
                            .offset(x: 6, y: -4)
                    }
                }

                Text(label)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(Color.ncTextSec)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.ncCard)
                    .shadow(color: .black.opacity(0.05), radius: 8, y: 3)
            )
        }
        .buttonStyle(ScalePressButtonStyle())
        .accessibilityLabel("\(label)\(badge.map { ". \($0)" } ?? "")")
    }
}

struct DashboardMiniStatView: View {
    let icon: String
    let count: Int
    let label: String
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(color)
            Text("\(count)")
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundStyle(Color.ncText)
            Text(label)
                .font(.system(size: 8, weight: .medium))
                .foregroundStyle(Color.ncTextSec)
        }
        .frame(maxWidth: .infinity)
        .accessibilityLabel("\(label): \(count)")
    }
}
