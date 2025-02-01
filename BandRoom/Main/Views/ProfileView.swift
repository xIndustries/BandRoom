import SwiftUI

struct ProfileView: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("Profile View")
                .font(.title)
                .bold()

            // ✅ Reset Button for UserDefaults
            Button(action: {
                UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
                UserDefaults.standard.synchronize()
                print("✅ UserDefaults Reset Successfully")
            }) {
                Text("Reset Progress")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.red)
                    .cornerRadius(12)
                    .padding(.horizontal, 20)
            }
        }
        .padding()
    }
}

#Preview {
    ProfileView()
}
