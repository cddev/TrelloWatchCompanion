import Foundation
import WatchConnectivity

class PhoneSessionManager: NSObject, WCSessionDelegate, ObservableObject {
    static let shared = PhoneSessionManager()
    private var session: WCSession?

    @Published var activationState: WCSessionActivationState = .notActivated
    @Published var isWatchAppInstalled: Bool = false
    @Published var isReachable: Bool = false // Très important pour savoir si on peut envoyer un message *maintenant*

    private override init() {
        super.init()
        if WCSession.isSupported() {
            session = WCSession.default
            session?.delegate = self
            session?.activate()
            print("PhoneSessionManager: WCSession activation requested.")
        } else {
             print("PhoneSessionManager: WCSession not supported on this device.")
        }
    }

    // MARK: - WCSessionDelegate Methods

    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        DispatchQueue.main.async {
            self.activationState = activationState
            if let error = error {
                print("PhoneSessionManager: WCSession activation failed: \(error.localizedDescription)")
            } else {
                print("PhoneSessionManager: WCSession activation completed: \(activationState.rawValue)")
                self.isWatchAppInstalled = session.isWatchAppInstalled
                self.isReachable = session.isReachable
                 print("PhoneSessionManager: Watch App Installed: \(self.isWatchAppInstalled), Reachable: \(self.isReachable)")
            }
        }
    }

    // --- Méthodes nécessaires pour iOS ---
    func sessionDidBecomeInactive(_ session: WCSession) {
        print("PhoneSessionManager: Session did become inactive.")
        DispatchQueue.main.async {
             self.isReachable = session.isReachable // Mettre à jour l'état
        }
    }

    func sessionDidDeactivate(_ session: WCSession) {
        print("PhoneSessionManager: Session did deactivate. Reactivating...")
        DispatchQueue.main.async {
             self.activationState = .notActivated
             self.isReachable = false
        }
        // Réactiver la session est une bonne pratique
        session.activate()
    }

    // --- Surveillance de l'état ---
    func sessionWatchStateDidChange(_ session: WCSession) {
         DispatchQueue.main.async {
              print("PhoneSessionManager: Watch state changed.")
              self.isWatchAppInstalled = session.isWatchAppInstalled
              self.isReachable = session.isReachable
              print("PhoneSessionManager: Watch App Installed: \(self.isWatchAppInstalled), Reachable: \(self.isReachable)")
         }
    }

     func sessionReachabilityDidChange(_ session: WCSession) {
         DispatchQueue.main.async {
              print("PhoneSessionManager: Reachability changed.")
              self.isReachable = session.isReachable
              print("PhoneSessionManager: Reachable: \(self.isReachable)")
         }
     }


    // MARK: - Sending Data

    func sendCredentialsToWatch(apiKey: String, apiToken: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let session = session else {
            completion(.failure(WCError(.sessionNotSupported)))
            return
        }

        guard activationState == .activated else {
             completion(.failure(WCError(.sessionNotActivated)))
             return
        }

        guard isWatchAppInstalled else {
             completion(.failure(WCError(.watchAppNotInstalled)))
             return
        }

        let messageData = ["apiKey": apiKey, "apiToken": apiToken]

        session.sendMessage(messageData, replyHandler: { reply in
            // La montre a reçu et a répondu (optionnel)
            print("PhoneSessionManager: Message sent successfully and received reply: \(reply)")
            completion(.success(()))
        }, errorHandler: { error in
            // Erreur lors de l'envoi
            print("PhoneSessionManager: Error sending message: \(error.localizedDescription)")
            // Wrapper l'erreur pour plus de clarté
            completion(.failure(WCError(.sendMessageFailed(error))))
        })
    }
}