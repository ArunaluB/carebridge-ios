import SwiftUI

struct AttendanceSummaryChipView: View {
    let value: String
    let label: String
    let color: Color
    let icon: String

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(color)
            Text(value)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundStyle(Color.ncText)
            Text(label)
                .font(.system(size: 9, weight: .medium))
                .foregroundStyle(Color.ncTextSec)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
    }
}

struct AttendanceFormField: View {
    let title: String
    let placeholder: String
    @Binding var text: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .foregroundStyle(Color.ncTextSec)
                .textCase(.uppercase)
                .tracking(0.5)

            TextField(placeholder, text: $text)
                .font(.system(size: 14))
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.white.opacity(0.06))
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.white.opacity(0.08), lineWidth: 1)
                        )
                )
        }
    }
}

struct AttendanceConfirmButton: View {
    let title: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(color)
                )
        }
        .accessibilityLabel(title)
    }
}
