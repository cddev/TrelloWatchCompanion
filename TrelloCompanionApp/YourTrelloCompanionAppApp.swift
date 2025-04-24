import SwiftUI

@main
struct YourTrelloCompanionAppApp: App { // <-- RENOMMEZ ICI
    // Initialiser le session manager tôt pour qu'il commence à s'activer
    init() {
        _ = PhoneSessionManager.shared
    }

    var body: some Scene {
        WindowGroup {
            ContentView() // Ceci est le ContentView de l'app iOS
        }
    }
}