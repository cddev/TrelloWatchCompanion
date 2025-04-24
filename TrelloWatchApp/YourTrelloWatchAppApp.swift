import SwiftUI

@main
struct YourTrelloWatchAppApp: App { // <-- RENOMMEZ ICI
     // Initialiser le manager pour qu'il commence à écouter
     init() {
         _ = WatchSessionManager.shared
     }

    var body: some Scene {
        WindowGroup {
            NavigationView { // La vue racine de la montre
                ContentView() // Ceci est le ContentView de l'app Watch
            }
        }
    }
}