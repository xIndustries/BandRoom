import SwiftUI

struct UserProfileView: View {
    @AppStorage("xp") private var xp: Int = 0 // ✅ XP Tracking

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "person.crop.circle.fill")
                    .resizable()
                    .frame(width: 50, height: 50)
                    .foregroundColor(.blue)

                VStack(alignment: .leading) {
                    Text("Welcome Back!")
                        .font(.headline)

                    Text("XP: \(xp)")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                Spacer()
            }

            // 🎯 XP Progress Bar
            ProgressView(value: Double(xp) / 100.0)
                .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                .frame(height: 8)
                .clipShape(Capsule())
                .background(Color.white.opacity(0.2))
                .padding(.top)
            
            Text("LEVEL UP at 100 XP!")
                .font(.subheadline)
                .foregroundColor(.gray)
                .padding(.top, 2)
        }
        .padding(.horizontal)
        .padding(.top, 20)
    }
}

// ✅ Preview
#Preview {
    UserProfileView()
}
