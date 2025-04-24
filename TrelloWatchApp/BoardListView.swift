import SwiftUI

struct BoardListView: View {
    @ObservedObject var viewModel: BoardListViewModel
    let credentials: TrelloCredentials // Passer les credentials valides

    var body: some View {
        // La NavigationView est déjà dans l'App principale de la montre
        VStack {
            if viewModel.isLoading {
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
                        viewModel.loadBoards(credentials: credentials)
                    }
                    .padding(.top)
                }
            } else if viewModel.boards.isEmpty && !viewModel.needsAuthentication { // Vérifier si on n'attend pas l'auth
                 Text("Aucun tableau Trello ouvert trouvé.")
                    .multilineTextAlignment(.center)
                 Button("Rafraîchir") {
                     viewModel.loadBoards(credentials: credentials)
                 }
                 .padding(.top)
            }
            else if viewModel.needsAuthentication {
                 // Ce cas est normalement géré par ContentView, mais sécurité
                 Text("Authentification requise sur l'iPhone.")
            }
            else {
                List {
                    ForEach(viewModel.boards) { board in
                        // Passer l'API Service déjà configuré avec les bons credentials
                        NavigationLink(destination: BoardDetailView(boardId: board.id, apiService: viewModel.apiService)) {
                            Text(board.name)
                        }
                    }
                }
                .listStyle(.carousel) // Style adapté à la montre
            }
        }
        .navigationTitle("Tableaux")
        .onAppear {
            // Charger seulement si pas déjà chargé ou si on veut rafraîchir
            // et si on a les credentials (vérifié par ContentView parent)
            if viewModel.boards.isEmpty && !viewModel.isLoading && !viewModel.needsAuthentication {
                viewModel.loadBoards(credentials: credentials)
            }
        }
    }
}