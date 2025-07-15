import SwiftUI

// This view contains the content and layout for the slide-out sidebar.
struct SidebarView: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    @Binding var isSidebarOpen: Bool
    
    var body: some View {
        HStack {
            // The content of the sidebar
            VStack(alignment: .leading, spacing: 30) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text("Bond")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    Text("Your Personal Assistant")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                .padding(.top, 50)
                
                // Menu Items
                VStack(alignment: .leading, spacing: 20) {
                    // NavigationLink to the JournalView
                    NavigationLink(destination: JournalView()) {
                        SidebarMenuItem(icon: "book.closed.fill", title: "Journal")
                    }
                    NavigationLink(destination: ReportsView()) {
                        SidebarMenuItem(icon: "book.closed.fill",title: "Reports")
                    }
                    
                    // Sign Out Button
                    SidebarMenuItem(icon: "arrow.left.square.fill", title: "Sign Out") {
                        authViewModel.disconnect()
                        withAnimation {
                            isSidebarOpen = false
                        }
                    }
                }
                
                Spacer()
            }
            .padding(.horizontal, 20)
            .frame(width: UIScreen.main.bounds.width * 0.60) // Sidebar takes up 75% of the screen width
            .background(Color.gray.opacity(0.2).ignoresSafeArea())
            
            // This spacer pushes the sidebar to the left edge
            Spacer()
        }
    }
}

// A reusable view for each item in the sidebar menu
struct SidebarMenuItem: View {
    let icon: String
    let title: String
    var action: (() -> Void)? = nil // Action is optional for NavigationLink
    
    var body: some View {
        // Use a Button for items with an action
        if let action = action {
            Button(action: action) {
                menuContent
            }
            .buttonStyle(PlainButtonStyle())
        } else {
            // Use just the content for NavigationLinks
            menuContent
        }
    }
    
    // The shared visual content for a menu item
    private var menuContent: some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.accentColor)
                .frame(width: 25)
            
            Text(title)
                .font(.body)
                .foregroundColor(.white)
            
            Spacer()
        }
        .padding(.vertical, 8)
    }
}
