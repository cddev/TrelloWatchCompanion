import Foundation
import Combine // Ou utiliser async/await directement dans les vues

@MainActor
class BoardDetailViewModel: ObservableObject {
    @Published var boardDetail: TrelloBoardDetail?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showMoveCardSheet = false // Contrôle l'affichage de la sheet
    @Published var cardToMove: TrelloCard? // La carte sélectionnée pour le déplacement

    // Propriété calculée pour faciliter l'affichage par colonne dans la TabView
    var cardsByList: [String: [TrelloCard]] {
        guard let cards = boardDetail?.cards else { return [:] }
        // Grouper les cartes par leur idList
        return Dictionary(grouping: cards, by: { $0.idList })
    }

    // Propriété calculée pour obtenir les listes de destination possibles
    var availableListsForMoving: [TrelloList] {
        // Exclure la liste actuelle de la carte à déplacer
        guard let currentListId = cardToMove?.idList, let allLists = boardDetail?.lists else { return [] }
        return allLists.filter { $0.id != currentListId }
    }

    private let boardId: String
    // Utiliser l'instance partagée ou injectée de l'API Service qui contient déjà les credentials
    private let apiService: TrelloAPIService

    // Initialiseur qui reçoit l'ID du tableau et le service API configuré
    init(boardId: String, apiService: TrelloAPIService) {
        self.boardId = boardId
        self.apiService = apiService
    }

    // Charger les détails du tableau (listes et cartes)
    func loadBoardDetails() {
        isLoading = true
        errorMessage = nil

        Task {
            do {
                let details = try await apiService.fetchBoardDetails(boardId: boardId)
                // Mettre à jour la propriété publiée, ce qui rafraîchira l'UI
                self.boardDetail = details
            } catch let error as TrelloError {
                // Gérer les erreurs spécifiques Trello
                handleTrelloError(error)
            } catch {
                 // Gérer les autres erreurs
                 self.errorMessage = "Erreur inconnue: \(error.localizedDescription)"
                 print("BoardDetailViewModel: Unknown error loading board details: \(error)")
            }
            // Fin du chargement
            isLoading = false
        }
    }

    // Méthode appelée lorsqu'on tape sur une carte pour initier le déplacement
    func selectCardForMove(_ card: TrelloCard) {
        self.cardToMove = card
        self.showMoveCardSheet = true // Déclenche l'affichage de la sheet
    }

     // Méthode appelée depuis MoveCardView lorsqu'une destination est choisie
     func moveSelectedCard(toList destinationList: TrelloList) {
        guard let card = cardToMove else {
            print("BoardDetailViewModel: Attempted to move card but none selected.")
            return
        }

         // Sauvegarder l'ID de la liste originale pour pouvoir annuler si l'API échoue
         let originalListId = card.idList

        // 1. Mise à jour Optimiste de l'UI : Modifie l'état local immédiatement
        // Ceci rend l'application plus réactive.
        updateLocalCardList(cardId: card.id, newlistId: destinationList.id)

        // 2. Cacher la feuille de sélection et réinitialiser la carte sélectionnée
        self.showMoveCardSheet = false
        self.cardToMove = nil

        // 3. Appel API Asynchrone pour effectuer le déplacement sur Trello
        Task {
            do {
                try await apiService.moveCard(cardId: card.id, toListId: destinationList.id)
                print("BoardDetailViewModel: Card \(card.id) moved successfully via API to list \(destinationList.id)")
                // Si succès, l'UI est déjà à jour (grâce à la màj optimiste).
                // On pourrait déclencher un rechargement complet si on voulait être certain
                // d'avoir l'état le plus récent (ex: position exacte dans la liste).
                // loadBoardDetails() // Optionnel

            } catch {
                // 4. Annuler la mise à jour optimiste si l'appel API échoue
                print("BoardDetailViewModel: Failed to move card via API: \(error)")
                // Remettre la carte dans sa liste d'origine dans l'UI locale
                updateLocalCardList(cardId: card.id, newlistId: originalListId)
                // Afficher un message d'erreur à l'utilisateur
                 if let trelloError = error as? TrelloError {
                     handleTrelloError(trelloError, context: "move card")
                 } else {
                      self.errorMessage = "Échec du déplacement: Erreur réseau/inconnue."
                 }

            }
        }
    }

    // Méthode privée pour mettre à jour l'état local de la carte (pour la màj optimiste et l'annulation)
    private func updateLocalCardList(cardId: String, newlistId: String) {
         // S'assurer que boardDetail existe
         guard boardDetail != nil else { return }
         // Trouver l'index de la carte à modifier dans notre tableau local
         if let cardIndex = boardDetail!.cards.firstIndex(where: { $0.id == cardId }) {
             // Modifier directement l'idList de la carte dans notre modèle local
             boardDetail!.cards[cardIndex].idList = newlistId
             // Forcer SwiftUI à redessiner car un élément interne d'un objet publié a changé.
             // objectWillChange.send() est implicitement appelé quand on modifie boardDetail.
             print("BoardDetailViewModel: Updated local card \(cardId) to list \(newlistId)")
         } else {
              print("BoardDetailViewModel: Could not find card \(cardId) locally to update its list.")
         }
     }

     // Helper pour gérer les erreurs Trello (peut être étendu)
     private func handleTrelloError(_ error: TrelloError, context: String? = nil) {
         let prefix = context.map { "\($0): " } ?? ""
          switch error {
          case .authenticationRequired, .invalidCredentials:
              self.errorMessage = "\(prefix)Auth échouée."
              // Idéalement, propager cette erreur pour déconnecter l'utilisateur
          case .apiError(let message):
               self.errorMessage = "\(prefix)\(message)"
          case .networkError:
               self.errorMessage = "\(prefix)Erreur réseau."
          case .decodingError:
               self.errorMessage = "\(prefix)Données Trello invalides."
          default:
               self.errorMessage = "\(prefix)Erreur interne."
          }
          print("BoardDetailViewModel: Trello error handled: \(error)")
     }
}