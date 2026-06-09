import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 1
    @State private var locationService = LocationService()
    @State private var signService = SignService()
    @State private var supabaseService = SupabaseService()

    var body: some View {
        TabView(selection: $selectedTab) {
            MySignsView()
                .tabItem {
                    Label("My Signs", systemImage: "signpost.right.and.left")
                }
                .tag(0)

            ARSignView()
                .tabItem {
                    Label("AR", systemImage: "camera.viewfinder")
                }
                .tag(1)

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape")
                }
                .tag(2)
        }
        .environment(locationService)
        .environment(signService)
        .environment(supabaseService)
        .onAppear {
            locationService.start()
        }
    }
}

#Preview {
    ContentView()
}
