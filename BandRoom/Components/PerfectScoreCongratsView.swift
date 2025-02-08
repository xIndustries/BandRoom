import SwiftUI

struct PerfectScoreCongratsView: View {
    var onDismiss: () -> Void

    var body: some View {
        VStack(spacing: 10) {
            Text("🎯 Perfect Score! 🎉")
                .font(.title3)
                .bold()
                .foregroundColor(.white)

            Text("You answered every question correctly!")
                .font(.headline)
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)

            Button(action: onDismiss) {
                Text("Awesome!")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(width: 180)
                    .background(Color.green)
                    .cornerRadius(10)
            }
        }
        .padding()
        .frame(width: 320, height: 180)
        .background(Color.blue)
        .cornerRadius(20)
        .shadow(radius: 10)
    }
}

// ✅ Preview
#Preview {
    PerfectScoreCongratsView(onDismiss: {})
}
