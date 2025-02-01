
import SwiftUI

struct TrophyView: View {
    var body: some View {
        VStack {
            Text("Trophy View")
            
            Image("note_c") // ✅ No need to include ".png" extension
                .resizable()
                .scaledToFit()
                .frame(width: 200, height: 200) // ✅ Adjust size if needed
        }
    }
}

#Preview {
    TrophyView()
}
