import Foundation

// Modèle simplifié pour la liste des tableaux
struct TrelloBoardSimple: Identifiable, Codable, Hashable {
    let id: String
    let name: String
}

// Modèles pour la vue détaillée du tableau
struct TrelloBoardDetail: Codable {
    let id: String
    let name: String
    var lists: [TrelloList] // var si on modifie localement
    var cards: [TrelloCard] // var si on modifie localement
}

struct TrelloList: Identifiable, Codable, Hashable {
    let id: String
    let name: String
    // Ajoutez 'pos' si vous voulez les trier
}

struct TrelloCard: Identifiable, Codable, Hashable {
    let id: String
    let name: String
    var idList: String // var car elle change lors du déplacement
     // Ajoutez d'autres champs si nécessaire (ex: pos)
}

// Pour stocker les credentials (utilisé par KeychainHelper et les SessionManagers)
struct TrelloCredentials: Codable {
    let apiKey: String
    let apiToken: String
}

// Erreurs possibles du Keychain (utilisé par KeychainHelper)
enum KeychainError: Error, LocalizedError {
    case encodingError
    case saveError(OSStatus)
    case loadError(OSStatus)
    case deleteError(OSStatus)
    case unexpectedData
    case decodingError

    var errorDescription: String? {
        switch self {
        case .encodingError: return "Impossible d'encoder les données pour le Keychain."
        case .saveError(let status): return "Impossible de sauvegarder dans le Keychain (Code: \(status))."
        case .loadError(let status): return "Impossible de charger depuis le Keychain (Code: \(status))."
        case .deleteError(let status): return "Impossible de supprimer du Keychain (Code: \(status))."
        case .unexpectedData: return "Données inattendues reçues du Keychain."
        case .decodingError: return "Impossible de décoder les données du Keychain."
        }
    }
}

// Erreurs spécifiques à l'API Trello (utilisé par TrelloAPIService)
enum TrelloError: Error {
    case invalidURL
    case networkError(Error)
    case invalidResponse
    case apiError(message: String)
    case decodingError(Error)
    case authenticationRequired
    case invalidCredentials
}

// Notification pour la mise à jour des credentials (utilisé par WatchSessionManager Watch)
extension Notification.Name {
    static let credentialsUpdated = Notification.Name("credentialsUpdated")
}