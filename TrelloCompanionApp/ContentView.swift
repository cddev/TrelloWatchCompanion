import SwiftUI
import WatchConnectivity // Importer pour utiliser les états

struct ContentView: View {
    @StateObject private var viewModel = CredentialsViewModel() // Utiliser StateObject

    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 15) {
                Text("Configuration Trello")
                    .font(.largeTitle)
                    .padding(.bottom)

                Text("Entrez votre clé API et votre Token générés depuis trello.com/app-key.")
                    .font(.caption)
                    .foregroundColor(.secondary)

                TextField("Clé API Trello", text: $viewModel.apiKey)
                    .textContentType(.password) // Empêche la suggestion, mais pas idéal
                    .keyboardType(.asciiCapable)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)

                // Utiliser SecureField pour masquer le token
                SecureField("Token API Trello", text: $viewModel.apiToken)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)

                // Indicateur de statut WatchConnectivity
                HStack {
                    Image(systemName: viewModel.sessionManager.isWatchAppInstalled ? (viewModel.sessionManager.isReachable ? "applewatch.watchface" : "applewatch") : "applewatch.slash")
                        .foregroundColor(viewModel.sessionManager.isWatchAppInstalled ? (viewModel.sessionManager.isReachable ? .green : .orange) : .red)
                    Text(watchStatusText())
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 5)


                // Affichage du statut et indicateur de chargement
                HStack {
                     Text(viewModel.statusMessage)
                         .font(.footnote)
                         .foregroundColor(viewModel.statusColor)
                     Spacer() // Pousse l'indicateur à droite
                     if viewModel.isLoading {
                         ProgressView()
                             .scaleEffect(0.8) // Taille plus petite
                     }
                }
                .frame(height: 30) // Hauteur fixe pour éviter les sauts d'UI


                Button {
                    viewModel.saveAndSendCredentials()
                } label: {
                    Text("Sauvegarder et Envoyer à la Montre")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .disabled(viewModel.isLoading || !viewModel.sessionManager.isWatchAppInstalled) // Désactiver si chargement ou montre non installée


                Button("Effacer les identifiants", role: .destructive) {
                    viewModel.clearCredentials()
                }
                .padding(.top)
                 .disabled(viewModel.isLoading)

                Spacer() // Pousse tout vers le haut

                 if let keychainError = viewModel.keychainError {
                     Text("Erreur Keychain: \(keychainError)")
                         .font(.caption)
                         .foregroundColor(.red)
                         .padding(.top)
                 }

            }
            .padding()
            .navigationTitle("Compagnon Trello")
             .navigationBarTitleDisplayMode(.inline) // Plus compact
        }
    }

     // Fonction helper pour le texte de statut de la montre
    func watchStatusText() -> String {
        if !viewModel.sessionManager.isWatchAppInstalled {
            return "App Watch non installée"
        } else if !viewModel.sessionManager.isReachable {
            return "Montre non joignable (activez Bluetooth/Wi-Fi)"
        } else {
            return "Montre connectée et joignable"
        }
    }
}

struct ContentView_Previews_iOS: PreviewProvider { // Renommez pour éviter conflit si watchOS a aussi un preview
    static var previews: some View {
        ContentView()
    }
}