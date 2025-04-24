import SwiftUI

struct MoveCardView: View {
    @Environment(\.dismiss) var dismiss // Pour fermer la feuille
    let cardToMove: TrelloCard
    let availableLists: [TrelloList]
    let onMoveSelected: (TrelloList) -> Void // Callback pour déclencher le déplacement

    var body: some View {
        // Pas besoin de NavigationView ici car elle est fournie par le .sheet dans BoardDetailView
        VStack(alignment: .leading) {
            Text("Déplacer:")
                .font(.caption)
                .foregroundColor(.secondary)
            Text(cardToMove.name)
                .font(.headline)
                .padding(.bottom, 5) // Réduit l'espace

            if availableLists.isEmpty {
                Text("Aucune autre colonne disponible.")
                    .foregroundColor(.secondary)
                    .padding(.vertical)
            } else {
                // Utiliser une List pour la sélection de destination
                List {
                    ForEach(availableLists) { list in
                        Button(list.name) {
                            onMoveSelected(list) // Appeler le callback
                            // La fermeture est gérée par le ViewModel parent
                        }
                    }
                }
                .listStyle(.carousel) // Style adapté à la montre
            }
        }
        .navigationTitle("Vers...") // Titre de la barre de la sheet
        .navigationBarTitleDisplayMode(.inline)
        .toolbar { // Bouton pour fermer manuellement
            ToolbarItem(placement: .cancellationAction) {
                Button("Annuler") {
                    dismiss()
                }
            }
        }
    }
}