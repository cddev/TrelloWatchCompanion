import Foundation
import WatchConnectivity
import UserNotifications // Importer pour demander l'autorisation si besoin

class WatchSessionManager: NSObject, WCSessionDelegate, ObservableObject {
    static let shared = WatchSessionManager()
    @Published var credentials: TrelloCredentials?

    // **!!! ATTENTION: Utiliser Keychain est préférable même sur watchOS si possible !!!**
    // Pour la simplicité de l'exemple, on utilise UserDefaults, mais ce n'est PAS sécurisé pour des tokens.
    // Une meilleure approche serait de ne PAS stocker le token sur la montre et le demander à l'iPhone
    // à chaque lancement via sendMessage, ou utiliser le Keychain partagé via App Group.
    private let credentialsKey = "trelloCredentials_watch" // Clé différente pour éviter conflit

    private var session: WCSession?

    private override init() {
        super.init()
        if WCSession.isSupported() {
            session = WCSession.default
            session?.delegate = self
            session?.activate()
            loadCredentials() // Charger au démarrage
            print("WatchSessionManager: WCSession activation requested on Watch.")
        } else {
            print("WatchSessionManager: WCSession not supported on Watch.")
        }
    }

    // MARK: - WCSessionDelegate Methods

    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        DispatchQueue.main.async { // Mettre à jour l'UI/état sur le thread principal
            if let error = error {
                print("WatchSessionManager: WCSession activation failed: \(error.localizedDescription)")
                // Gérer l'erreur si nécessaire
            } else {
                print("WatchSessionManager: WCSession activation completed with state: \(activationState.rawValue)")
                // On peut demander les données à l'iPhone ici si on ne les a pas encore
                // self.requestCredentialsFromPhoneIfNeeded()
            }
        }
    }

    // --- Réception de Messages ---
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        print("Watch received message with reply handler: \(message)")
        DispatchQueue.main.async {
            if let key = message["apiKey"] as? String, let token = message["apiToken"] as? String {
                let receivedCredentials = TrelloCredentials(apiKey: key, apiToken: token)

                // Comparer avant de sauvegarder/notifier pour éviter travail inutile
                if self.credentials?.apiKey != key || self.credentials?.apiToken != token {
                    self.credentials = receivedCredentials
                    self.saveCredentials(receivedCredentials) // Sauvegarde (non sécurisée ici)
                    print("WatchSessionManager: Credentials updated and saved.")
                    // Notifier l'UI que les credentials ont changé
                    NotificationCenter.default.post(name: .credentialsUpdated, object: nil)
                    // Envoyer une réponse de succès à l'iPhone
                    replyHandler(["status": "success", "message": "Credentials received by watch."])
                } else {
                     print("WatchSessionManager: Received identical credentials, no update needed.")
                     replyHandler(["status": "no_change", "message": "Credentials already up-to-date."])
                }

            } else {
                print("WatchSessionManager: Received message does not contain valid credentials.")
                 replyHandler(["status": "error", "message": "Invalid credentials format received."])
            }
        }
    }

     // Gérer aussi les messages sans replyHandler au cas où l'iPhone utilise cette méthode
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
         print("Watch received message WITHOUT reply handler: \(message)")
         DispatchQueue.main.async {
             if let key = message["apiKey"] as? String, let token = message["apiToken"] as? String {
                 let receivedCredentials = TrelloCredentials(apiKey: key, apiToken: token)
                 if self.credentials?.apiKey != key || self.credentials?.apiToken != token {
                    self.credentials = receivedCredentials
                    self.saveCredentials(receivedCredentials)
                    print("WatchSessionManager: Credentials updated and saved (no reply).")
                    NotificationCenter.default.post(name: .credentialsUpdated, object: nil)
                 } else {
                     print("WatchSessionManager: Received identical credentials (no reply).")
                 }
             } else {
                 print("WatchSessionManager: Received invalid message format (no reply).")
             }
         }
     }


    // --- Persistance (Simplifié avec UserDefaults - NON SÉCURISÉ) ---
    private func saveCredentials(_ creds: TrelloCredentials?) {
        do {
            if let creds = creds {
                let data = try JSONEncoder().encode(creds)
                UserDefaults.standard.set(data, forKey: credentialsKey)
                print("Watch Credentials saved to UserDefaults (Insecure).")
            } else {
                UserDefaults.standard.removeObject(forKey: credentialsKey)
                 print("Watch Credentials removed from UserDefaults.")
            }
        } catch {
             print("WatchSessionManager: Failed to encode/save credentials to UserDefaults: \(error)")
        }
    }

    private func loadCredentials() {
        if let data = UserDefaults.standard.data(forKey: credentialsKey) {
            do {
                let savedCreds = try JSONDecoder().decode(TrelloCredentials.self, from: data)
                self.credentials = savedCreds
                print("Watch Credentials loaded from UserDefaults (Insecure).")
            } catch {
                 print("WatchSessionManager: Failed to decode credentials from UserDefaults: \(error)")
                 // Supprimer les données corrompues potentiellement
                 UserDefaults.standard.removeObject(forKey: credentialsKey)
                 self.credentials = nil
            }
        } else {
            print("WatchSessionManager: No credentials found in UserDefaults.")
            self.credentials = nil
        }
    }

     // Fonction pour effacer explicitement (utile pour déconnexion)
     func clearCredentials() {
         self.credentials = nil
         saveCredentials(nil)
         print("WatchSessionManager: Credentials cleared.")
         // Notifier l'UI pour qu'elle réagisse
         NotificationCenter.default.post(name: .credentialsUpdated, object: nil)
     }
}