import SwiftUI

struct MainTabBarView: View {
    @State private var selectedTab: Tab = .home
    
    enum Tab {
        case home, lesson, trophy, profile
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Display the selected view
                switch selectedTab {
                case .home:
                    HomeView()
                case .lesson:
                    LessonView(lessonNumber: 1, onComplete: markLessonCompleted) // ✅ Pass the completion function
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
                    .padding(.horizontal, 11)
                    .frame(height: 70)
                    .background(Color(red: 0.0, green: 0.098, blue: 0.125))
                    .clipShape(Capsule())
                    .padding(.horizontal, 16)
                    .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 4)
                }
                .ignoresSafeArea(.keyboard, edges: .bottom)
            }
        }
    }

    // ✅ Lesson completion function
    private func markLessonCompleted(lessonNumber: Int) {
        print("✅ Lesson \(lessonNumber) completed!")
        UserDefaults.standard.set(lessonNumber, forKey: "currentLessonIndex") // ✅ Save progress
    }
}

// ✅ Updated `TabBarButton` with filled and non-filled icons
struct TabBarButton: View {
    let image: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: isSelected ? "\(image).fill" : image) // ✅ Toggle filled version
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(isSelected ? Color.white : Color.gray)
                .frame(width: 50, height: 50)
                .scaleEffect(isSelected ? 1.4 : 1.0)
                .animation(.spring(response: 0.3, dampingFraction: 0.5), value: isSelected)
        }
    }
}

// ✅ Preview
struct MainTabBarView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabBarView()
    }
}
