import SwiftUI

struct MainTabBarView: View {
    @State private var selectedTab: Tab = .home
    
    enum Tab {
        case home, lesson, trophy, profile
    }
    
    var body: some View {
        ZStack {
            // Display the selected view
            switch selectedTab {
            case .home:
                HomeView()
            case .lesson:
                LessonView()
            case .trophy:
                TrophyView()
            case .profile:
                ProfileView()
            }
            
            VStack {
                Spacer()
                
                HStack {
                    TabBarButton(image: "house", isSelected: selectedTab == .home) {
                        selectedTab = .home
                    }
                    Spacer()
                    TabBarButton(image: "book", isSelected: selectedTab == .lesson) {
                        selectedTab = .lesson
                    }
                    Spacer()
                    TabBarButton(image: "trophy", isSelected: selectedTab == .trophy) {
                        selectedTab = .trophy
                    }
                    Spacer()
                    TabBarButton(image: "person", isSelected: selectedTab == .profile) {
                        selectedTab = .profile
                    }
                }
                .padding(.horizontal, 17)
                .frame(height: 80)
                .background(Color.black.opacity(0.9))
                .clipShape(Capsule())
                .padding(.horizontal, 16)
                .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 4)
            }
            .ignoresSafeArea(.keyboard, edges: .bottom)
        }
    }
}

struct TabBarButton: View {
    let image: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: image)
                .font(.system(size: 24, weight: .medium))
                .foregroundColor(isSelected ? .black : .gray)
                .frame(width: 50, height: 50)
                .background(isSelected ? Color.white : Color.clear)
                .clipShape(Circle())
                .scaleEffect(isSelected ? 1.2 : 1.0)
                .animation(.spring(response: 0.3, dampingFraction: 0.5), value: isSelected)
        }
    }
}

struct MainTabBarView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabBarView()
    }
}
