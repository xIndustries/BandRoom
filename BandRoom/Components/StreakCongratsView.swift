import SwiftUI

struct StreakCongratsView: View {
    var body: some View {
        VStack(spacing: 10) {
            Text("🔥 5 Streaks! Congrats! 🎉")
                .font(.largeTitle)
                .bold()
                .foregroundColor(.white)
            
            Text("Keep up the great work!")
                .font(.headline)
                .foregroundColor(.white.opacity(0.9))
        }
        .padding()
        .frame(width: 300, height: 150)
        .background(Color.blue)
        .cornerRadius(20)
        .shadow(radius: 10)
    }
}

// ✅ Preview
#Preview {
    StreakCongratsView()
}
