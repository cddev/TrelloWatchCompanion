import Foundation
import Combine // Ou utiliser async/await directement dans les vues

@MainActor // Assure que les @Published sont mis à jour sur le thread principal
class BoardListViewModel: ObservableObject {
    @Published var boards: [TrelloBoardSimple] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var needsAuthentication = false // Indique si on attend les credentials

    // Garder une instance unique du service API pour partager les credentials
     let apiService: TrelloAPIService

    // Utiliser un injecteur de dépendance est une bonne pratique
    init(apiService: TrelloAPIService = TrelloAPIService()) {
        self.apiService = apiService
        // Vérifier l'état initial des credentials via le service
        if apiService.apiKey == nil || apiService.apiToken == nil {
            needsAuthentication = true
        }
    }

    // Méthode pour charger les tableaux, nécessite les credentials
    func loadBoards(credentials: TrelloCredentials?) {
        guard let creds = credentials else {
            // Si les credentials ne sont pas fournis (ou sont effacés), marquer comme nécessitant l'auth
            needsAuthentication = true
            errorMessage = "Authentification requise via l'iPhone."
            self.boards = [] // Vider la liste existante
            apiService.setCredentials(key: nil, token: nil) // Effacer dans le service aussi
            return
        }

        // Si on reçoit des credentials valides
        needsAuthentication = false
        isLoading = true
        errorMessage = nil
        // Mettre à jour l'API Service avec les credentials reçus
        apiService.setCredentials(key: creds.apiKey, token: creds.apiToken)

        Task {
            do {
                let fetchedBoards = try await apiService.fetchBoards()
                self.boards = fetchedBoards
                // Si succès, s'assurer qu'il n'y a pas de message d'erreur résiduel
                 self.errorMessage = nil
            } catch let error as TrelloError {
                 // Gérer les erreurs spécifiques Trello
                 handleTrelloError(error)
            } catch {
                // Gérer les autres erreurs
                self.errorMessage = "Erreur inconnue: \(error.localizedDescription)"
                print("BoardListViewModel: Unknown error loading boards: \(error)")
            }
            // Fin du chargement dans tous les cas (succès ou erreur)
            isLoading = false
        }
    }

    // Helper pour gérer les erreurs Trello de manière centralisée
    private func handleTrelloError(_ error: TrelloError) {
         switch error {
         case .authenticationRequired, .invalidCredentials:
             self.errorMessage = "Authentification échouée. Vérifiez sur l'iPhone."
             self.needsAuthentication = true // Marquer qu'on a besoin d'auth
             self.boards = [] // Vider la liste
             apiService.setCredentials(key: nil, token: nil) // Effacer creds dans le service
         case .apiError(let message):
              self.errorMessage = "Erreur Trello: \(message)"
         case .networkError:
              self.errorMessage = "Erreur réseau. Vérifiez la connexion."
         case .invalidURL, .invalidResponse:
              self.errorMessage = "Erreur interne de l'application." // Erreur de programmation
         case .decodingError:
              self.errorMessage = "Erreur de données Trello." // L'API a peut-être changé
         }
         print("BoardListViewModel: Trello error handled: \(error)")
    }
}