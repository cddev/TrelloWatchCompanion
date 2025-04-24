import SwiftUI

struct ContentView: View {
    // Utiliser StateObject car cette vue "possède" le manager pour son cycle de vie ici
    @StateObject private var watchManager = WatchSessionManager.shared
    // Utiliser StateObject aussi pour le ViewModel racine
    @StateObject private var boardListViewModel = BoardListViewModel()

    var body: some View {
        // Vérifie si les credentials existent via le manager partagé
        if let credentials = watchManager.credentials {
             // Si oui, injecter les credentials dans le service API et montrer la liste des tableaux
            BoardListView(viewModel: boardListViewModel, credentials: credentials)
                .onAppear {
                    // S'assurer que le service API a les bons credentials au démarrage de la vue
                    boardListViewModel.apiService.setCredentials(key: credentials.apiKey, token: credentials.apiToken)
                }
                // Réagir si les credentials sont mis à jour depuis l'iPhone PENDANT que l'app est active
                .onReceive(NotificationCenter.default.publisher(for: .credentialsUpdated)) { _ in
                     print("Watch ContentView Received .credentialsUpdated notification")
                     if let creds = watchManager.credentials {
                         boardListViewModel.apiService.setCredentials(key: creds.apiKey, token: creds.apiToken)
                         boardListViewModel.loadBoards(credentials: creds) // Recharger les tableaux
                     } else {
                         // Gérer le cas où les credentials sont effacés par l'iPhone
                         print("Watch ContentView: Credentials seem to be cleared.")
                         boardListViewModel.boards = [] // Vider la liste
                         boardListViewModel.needsAuthentication = true // Mettre à jour l'état du VM
                     }
                 }

        } else {
            // Si non, afficher un message invitant à configurer sur iPhone
            VStack {
                Image(systemName: "lock.icloud")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 50, height: 50)
                Text("Authentification Trello requise.")
                    .padding(.top)
                Text("Veuillez configurer l'application sur votre iPhone.")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            .navigationTitle("Trello") // Titre pour la vue d'attente
        }
    }
}

struct ContentView_Previews_Watch: PreviewProvider { // Renommez pour éviter conflit
    static var previews: some View {
         // Pour le preview, simuler un état (ex: sans credentials)
         ContentView()
            // Pour simuler avec credentials, il faudrait injecter un WatchManager préconfiguré
            // .environmentObject(WatchSessionManager.preconfiguredManager())
    }
}