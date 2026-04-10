import SwiftUI

struct IncidentDetailCard<Content: View>: View {
    let icon: String
    let iconColor: Color
    let title: String
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(iconColor)
                Text(title)
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.ncText)
            }

            content()
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.ncCard)
                .shadow(color: .black.opacity(0.08), radius: 12, y: 4)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.white.opacity(0.06), lineWidth: 1)
        )
    }
}

struct IncidentWorkflowStepRow: View {
    let title: String
    let subtitle: String?
    let isCompleted: Bool
    let isFirst: Bool
    var isLast: Bool = false

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            VStack(spacing: 0) {
                if !isFirst {
                    Rectangle()
                        .fill(isCompleted ? Color.ncPrimary.opacity(0.4) : Color.white.opacity(0.1))
                        .frame(width: 2, height: 12)
                }

                ZStack {
                    if isCompleted {
                        Circle()
                            .fill(Color.ncPrimary)
                            .frame(width: 20, height: 20)
                        Image(systemName: "checkmark")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(.white)
                    } else {
                        Circle()
                            .stroke(Color.white.opacity(0.2), style: StrokeStyle(lineWidth: 1.5, dash: [3]))
                            .frame(width: 20, height: 20)
                    }
                }

                if !isLast {
                    Rectangle()
                        .fill(isCompleted ? Color.ncPrimary.opacity(0.4) : Color.white.opacity(0.1))
                        .frame(width: 2, height: 12)
                }
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 14, weight: isCompleted ? .semibold : .regular, design: .rounded))
                    .foregroundStyle(isCompleted ? Color.ncText : Color.ncTextSec)

                if let subtitle {
                    Text(subtitle)
                        .font(.system(size: 11, weight: .regular))
                        .foregroundStyle(Color.ncTextSec)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding(.vertical, 2)

            Spacer()
        }
    }
}
