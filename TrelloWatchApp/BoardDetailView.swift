import SwiftUI

struct BoardDetailView: View {
    let boardId: String
    // Utiliser StateObject car cette vue crée et possède son ViewModel
    @StateObject private var viewModel: BoardDetailViewModel

    // Initialiseur pour injecter l'API Service configuré
    init(boardId: String, apiService: TrelloAPIService) {
        self.boardId = boardId
        // Initialiser le StateObject avec les dépendances nécessaires
        _viewModel = StateObject(wrappedValue: BoardDetailViewModel(boardId: boardId, apiService: apiService))
    }

    var body: some View {
        VStack {
            if viewModel.isLoading && viewModel.boardDetail == nil { // Afficher seulement au premier chargement
                ProgressView("Chargement...")
            } else if let errorMsg = viewModel.errorMessage {
                VStack {
                    Text("Erreur")
                        .font(.headline)
                        .foregroundColor(.red)
                    Text(errorMsg)
                        .font(.caption)
                        .multilineTextAlignment(.center)
                    Button("Réessayer") {
                        viewModel.loadBoardDetails()
                    }
                }
            } else if let board = viewModel.boardDetail {
                 // Utiliser TabView pour simuler les colonnes
                 if board.lists.isEmpty {
                      Text("Ce tableau n'a pas de colonnes.")
                 } else {
                     TabView {
                         ForEach(board.lists) { list in
                             // Utiliser une ScrollView au lieu d'une List pour éviter les listes imbriquées
                             ScrollView {
                                 VStack(alignment: .leading, spacing: 5) {
                                     // Liste des cartes dans cette colonne
                                     // Récupérer les cartes pour cette liste spécifique
                                     let cardsInList = viewModel.cardsByList[list.id] ?? []
                                     if cardsInList.isEmpty {
                                         Text("Aucune carte")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                            .padding(.vertical) // Un peu d'espace
                                     } else {
                                         ForEach(cardsInList) { card in
                                             Button(action: {
                                                 viewModel.selectCardForMove(card)
                                             }) {
                                                 // Améliorer l'affichage du bouton
                                                 Text(card.name)
                                                     .font(.footnote)
                                                     .frame(maxWidth: .infinity, alignment: .leading) // Prend toute la largeur
                                                     .padding(.vertical, 6)
                                                     .padding(.horizontal, 10)
                                                     .background(Color.gray.opacity(0.2)) // Fond léger
                                                     .cornerRadius(5)
                                             }
                                             .buttonStyle(.plain) // Style de bouton pour le fond et padding
                                         }
                                     }
                                     Spacer() // Pousse les cartes vers le haut si peu nombreuses
                                 }
                                 .padding(.horizontal) // Padding pour le contenu de la ScrollView
                             }
                             .navigationTitle(list.name) // Le titre change avec la colonne
                             .tag(list.id) // Identifier chaque page/onglet
                         }
                     }
                     .tabViewStyle(.page(indexDisplayMode: .automatic)) // Style page par page
                     // Le titre global du tableau peut être mis ailleurs si nécessaire,
                     // car la nav bar change avec la TabView.
                     // .navigationTitle(board.name) // Titre global moins utile ici

                 }
            } else {
                // Cas où il n'y a ni chargement ni erreur, mais pas de données
                Text("Impossible de charger les détails.")
            }
        }
        .onAppear {
            // Charger les détails si ce n'est pas déjà fait
            if viewModel.boardDetail == nil && !viewModel.isLoading {
                viewModel.loadBoardDetails()
            }
        }
        // La sheet est présentée au niveau de la vue qui contient la TabView
        .sheet(isPresented: $viewModel.showMoveCardSheet) {
            // Feuille modale pour déplacer la carte
            if let card = viewModel.cardToMove {
                // S'assurer que la sheet a sa propre NavigationView pour la barre de titre/bouton
                NavigationView {
                    MoveCardView(
                        cardToMove: card,
                        availableLists: viewModel.availableListsForMoving,
                        onMoveSelected: { destinationList in
                            viewModel.moveSelectedCard(toList: destinationList)
                            // La fermeture est gérée par le ViewModel via showMoveCardSheet = false
                        }
                    )
                }
            }
        }
    }
}