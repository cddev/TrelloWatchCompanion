import Foundation
import Security

// Nom unique pour identifier le service dans le Keychain
// !! REMPLACEZ PAR VOTRE IDENTIFIANT D'APP UNIQUE !!
private let keychainServiceName = "com.votredomaine.votreapp.trello"
private let keychainAccountName = "trelloCredentials"

struct KeychainHelper {

    // Sauvegarde les credentials dans le Keychain
    static func saveCredentials(_ credentials: TrelloCredentials) throws {
        // Encoder les credentials en Data
        guard let data = try? JSONEncoder().encode(credentials) else {
            print("KeychainError: Failed to encode credentials")
            throw KeychainError.encodingError
        }

        // Préparer la requête pour le Keychain
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keychainServiceName,
            kSecAttrAccount as String: keychainAccountName,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly // Bonne pratique de sécurité
        ]

        // Supprimer l'ancien item s'il existe
        SecItemDelete(query as CFDictionary)

        // Ajouter le nouvel item
        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else {
            print("KeychainError: Failed to save item. Status: \(status)")
            throw KeychainError.saveError(status)
        }
        print("Credentials saved to Keychain successfully.")
    }

    // Charge les credentials depuis le Keychain
    static func loadCredentials() throws -> TrelloCredentials? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keychainServiceName,
            kSecAttrAccount as String: keychainAccountName,
            kSecReturnData as String: kCFBooleanTrue!, // On veut récupérer les data
            kSecMatchLimit as String: kSecMatchLimitOne // On ne s'attend qu'à un seul résultat
        ]

        var dataTypeRef: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)

        if status == errSecSuccess {
            guard let retrievedData = dataTypeRef as? Data else {
                print("KeychainError: Failed to cast retrieved data.")
                throw KeychainError.unexpectedData
            }
            // Décoder les Data en TrelloCredentials
            guard let credentials = try? JSONDecoder().decode(TrelloCredentials.self, from: retrievedData) else {
                print("KeychainError: Failed to decode credentials from data.")
                throw KeychainError.decodingError
            }
            print("Credentials loaded from Keychain successfully.")
            return credentials
        } else if status == errSecItemNotFound {
            print("Keychain: No credentials found for the specified account.")
            return nil // Normal, l'item n'existe pas encore
        } else {
            print("KeychainError: Failed to load item. Status: \(status)")
            throw KeychainError.loadError(status)
        }
    }

    // Supprime les credentials du Keychain
    static func deleteCredentials() throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keychainServiceName,
            kSecAttrAccount as String: keychainAccountName
        ]

        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
             print("KeychainError: Failed to delete item. Status: \(status)")
            throw KeychainError.deleteError(status)
        }
         print("Credentials deleted from Keychain (or did not exist).")
    }
}