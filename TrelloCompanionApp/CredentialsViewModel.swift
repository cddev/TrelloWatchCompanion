import Foundation
import Combine // Pour @Published et potentiellement les états WCSession
import SwiftUI // Pour Color

@MainActor // Pour que les mises à jour @Published se fassent sur le thread principal
class CredentialsViewModel: ObservableObject {
    @Published var apiKey: String = ""
    @Published var apiToken: String = ""
    @Published var statusMessage: String = ""
    @Published var statusColor: Color = .secondary // Pour l'UI
    @Published var isLoading: Bool = false

    // Référence au manager WatchConnectivity
    @ObservedObject var sessionManager = PhoneSessionManager.shared

    // Pour gérer les erreurs potentielles lors du chargement/sauvegarde
    @Published var keychainError: String?

    init() {
        loadCredentialsFromKeychain()
    }

    func loadCredentialsFromKeychain() {
        keychainError = nil
        do {
            if let loadedCreds = try KeychainHelper.loadCredentials() {
                self.apiKey = loadedCreds.apiKey
                self.apiToken = loadedCreds.apiToken
                statusMessage = "Identifiants chargés depuis le Keychain."
                statusColor = .green
            } else {
                 statusMessage = "Entrez votre clé API et Token Trello."
                 statusColor = .secondary
            }
        } catch let error as KeychainError {
            keychainError = error.localizedDescription
            statusMessage = "Erreur Keychain: \(error.localizedDescription)"
            statusColor = .red
        } catch {
             keychainError = error.localizedDescription
             statusMessage = "Erreur inconnue Keychain: \(error.localizedDescription)"
             statusColor = .red
        }
    }

    func saveAndSendCredentials() {
        // Validation simple
        guard !apiKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            statusMessage = "La clé API ne peut pas être vide."
            statusColor = .orange
            return
        }
        guard !apiToken.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            statusMessage = "Le Token API ne peut pas être vide."
             statusColor = .orange
            return
        }

        isLoading = true
        statusMessage = "Sauvegarde..."
        statusColor = .primary
        keychainError = nil

        let credentialsToSave = TrelloCredentials(apiKey: apiKey, apiToken: apiToken)

        Task { // Utiliser Task pour le travail asynchrone
            do {
                // 1. Sauvegarder dans le Keychain
                try KeychainHelper.saveCredentials(credentialsToSave)
                statusMessage = "Identifiants sauvegardés."
                statusColor = .green

                // 2. Envoyer à la montre
                statusMessage = "Envoi vers la montre..."
                sessionManager.sendCredentialsToWatch(apiKey: credentialsToSave.apiKey, apiToken: credentialsToSave.apiToken) { result in
                    // Remettre à jour l'UI sur le thread principal
                    DispatchQueue.main.async {
                         self.isLoading = false // Fin du chargement global
                         switch result {
                         case .success:
                             self.statusMessage = "Identifiants envoyés à la montre avec succès!"
                             self.statusColor = .green
                         case .failure(let error):
                             self.statusMessage = "Échec envoi: \(error.localizedDescription)"
                             self.statusColor = .red
                         }
                    }
                }

            } catch let error as KeychainError {
                 self.keychainError = error.localizedDescription
                 self.statusMessage = "Erreur Keychain: \(error.localizedDescription)"
                 self.statusColor = .red
                 self.isLoading = false
            } catch {
                 self.keychainError = error.localizedDescription
                 self.statusMessage = "Erreur inconnue Keychain: \(error.localizedDescription)"
                 self.statusColor = .red
                 self.isLoading = false
            }
        }
    }

    func clearCredentials() {
         isLoading = true
         statusMessage = "Suppression..."
         statusColor = .primary
         keychainError = nil
         Task {
             do {
                 try KeychainHelper.deleteCredentials()
                 self.apiKey = ""
                 self.apiToken = ""
                 self.statusMessage = "Identifiants supprimés. Envoyez un message vide à la montre si nécessaire."
                 self.statusColor = .orange // Indiquer qu'une action est peut-être requise
                 // Optionnel: envoyer des credentials vides à la montre pour la déconnexion
                 // sessionManager.sendCredentialsToWatch(apiKey: "", apiToken: "") { ... }

             } catch let error as KeychainError {
                 self.keychainError = error.localizedDescription
                 self.statusMessage = "Erreur Keychain: \(error.localizedDescription)"
                 self.statusColor = .red
             } catch {
                 self.keychainError = error.localizedDescription
                 self.statusMessage = "Erreur inconnue Keychain: \(error.localizedDescription)"
                 self.statusColor = .red
             }
             self.isLoading = false
         }
    }
}

// Wrapper simple pour les erreurs WatchConnectivity (juste pour l'exemple)
struct WCError: Error, LocalizedError {
    enum Code {
        case sessionNotSupported
        case sessionNotActivated
        case watchAppNotInstalled
        case sendMessageFailed(Error)
    }
    let code: Code

    init(_ code: Code) { self.code = code }

    var errorDescription: String? {
        switch code {
        case .sessionNotSupported: return "WatchConnectivity n'est pas supporté."
        case .sessionNotActivated: return "La session WatchConnectivity n'est pas active."
        case .watchAppNotInstalled: return "L'application Apple Watch n'est pas installée."
        case .sendMessageFailed(let err): return "Échec de l'envoi du message: \(err.localizedDescription)"
        }
    }
}