import Foundation

// Définition des erreurs déjà dans Models.swift partagé

class TrelloAPIService {
    private let baseURL = URL(string: "https://api.trello.com/1")!
    private var apiKey: String?
    private var apiToken: String?

    // Méthode pour injecter/mettre à jour les credentials de manière sécurisée
    // Appelée par les ViewModels après réception via WatchConnectivity
    func setCredentials(key: String?, token: String?) {
        // Validation simple
        guard let key = key, !key.isEmpty, let token = token, !token.isEmpty else {
            print("TrelloAPIService: Attempted to set invalid credentials.")
            self.apiKey = nil
            self.apiToken = nil
            return
        }
        self.apiKey = key
        self.apiToken = token
        print("TrelloAPIService: Credentials set.")
    }

    private func makeURL(path: String, queryItems: [URLQueryItem] = []) throws -> URL {
        // Vérifier si les credentials sont présents AVANT de construire l'URL
        guard let key = apiKey, let token = apiToken else {
            print("TrelloAPIService: Missing credentials for API call.")
            throw TrelloError.authenticationRequired // Erreur spécifique
        }

        var components = URLComponents(url: baseURL.appendingPathComponent(path), resolvingAgainstBaseURL: false)

        // Cloner les items pour ajouter clé/token sans modifier l'original
        var allQueryItems = queryItems
        allQueryItems.append(URLQueryItem(name: "key", value: key))
        allQueryItems.append(URLQueryItem(name: "token", value: token))
        components?.queryItems = allQueryItems

        guard let url = components?.url else {
            throw TrelloError.invalidURL
        }
        // print("Requesting URL: \(url.absoluteString)") // Debug
        return url
    }

    // Fonction générique pour exécuter les requêtes GET et décoder la réponse
    private func performRequest<T: Decodable>(url: URL, method: String = "GET", body: Data? = nil) async throws -> T {
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.httpBody = body // Ajouter le corps pour PUT/POST si nécessaire

        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw TrelloError.invalidResponse
            }

             // print("Status Code: \(httpResponse.statusCode)") // Debug

            // Gérer les erreurs Trello spécifiques
            if httpResponse.statusCode == 401 {
                 // 401 signifie souvent un token invalide ou des permissions manquantes
                 print("TrelloAPIService: Received 401 Unauthorized. Check API Key/Token and permissions.")
                 throw TrelloError.invalidCredentials
            }
             if httpResponse.statusCode == 404 {
                 print("TrelloAPIService: Received 404 Not Found.")
                 // Convertir en message d'erreur plus clair si possible
                 let errorMessage = String(data: data, encoding: .utf8) ?? "Resource not found"
                 throw TrelloError.apiError(message: errorMessage)
             }

            // Gérer les autres erreurs serveur/client
            if !(200...299).contains(httpResponse.statusCode) {
                 let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown API Error"
                 print("TrelloAPIService: API Error \(httpResponse.statusCode): \(errorMessage)")
                 throw TrelloError.apiError(message: "Error \(httpResponse.statusCode): \(errorMessage)")
            }

             // Si le statut est OK, essayer de décoder
            do {
                let decoder = JSONDecoder()
                let decodedObject = try decoder.decode(T.self, from: data)
                return decodedObject
            } catch {
                print("TrelloAPIService: Decoding Error: \(error)")
                print("Data received: \(String(data: data, encoding: .utf8) ?? "Unable to decode data")")
                throw TrelloError.decodingError(error)
            }
        } catch let error as TrelloError {
             // Relancer les erreurs Trello spécifiques déjà identifiées
             throw error
        } catch {
            // Gérer les erreurs réseau URLSession (offline, timeout, etc.)
            print("TrelloAPIService: Network Error: \(error)")
            throw TrelloError.networkError(error)
        }
    }

    // Fonction spécifique pour les requêtes PUT qui ne renvoient pas forcément de contenu JSON
    private func performUpdateRequest(url: URL) async throws {
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"

        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse else {
                throw TrelloError.invalidResponse
            }
            // print("Update Request Status Code: \(httpResponse.statusCode)") // Debug

             if httpResponse.statusCode == 401 {
                 print("TrelloAPIService: Received 401 Unauthorized on PUT. Check API Key/Token and permissions.")
                 throw TrelloError.invalidCredentials
             }
             if httpResponse.statusCode == 404 {
                 print("TrelloAPIService: Received 404 Not Found on PUT.")
                 let errorMessage = String(data: data, encoding: .utf8) ?? "Resource not found"
                 throw TrelloError.apiError(message: errorMessage)
             }

            if !(200...299).contains(httpResponse.statusCode) {
                let errorMessage = String(data: data, encoding: .utf8) ?? "Update failed"
                print("TrelloAPIService: Update API Error \(httpResponse.statusCode): \(errorMessage)")
                throw TrelloError.apiError(message: "Error \(httpResponse.statusCode): \(errorMessage)")
            }
            // Si 2xx, l'opération a réussi, pas besoin de retourner de données.
        } catch let error as TrelloError {
            throw error
        } catch {
            print("TrelloAPIService: Network Error during update: \(error)")
            throw TrelloError.networkError(error)
        }
    }


    // --- API Endpoints ---

    func fetchBoards() async throws -> [TrelloBoardSimple] {
        let url = try makeURL(path: "/members/me/boards", queryItems: [
            URLQueryItem(name: "filter", value: "open"),
            URLQueryItem(name: "fields", value: "id,name")
        ])
        return try await performRequest(url: url)
    }

    func fetchBoardDetails(boardId: String) async throws -> TrelloBoardDetail {
        let url = try makeURL(path: "/boards/\(boardId)", queryItems: [
            URLQueryItem(name: "lists", value: "open"), // Récupérer les listes ouvertes
            URLQueryItem(name: "cards", value: "open"), // Récupérer les cartes ouvertes
            URLQueryItem(name: "list_fields", value: "id,name"), // Champs pour les listes
            URLQueryItem(name: "card_fields", value: "id,name,idList") // Champs pour les cartes
            // Ajouter 'pos' si nécessaire pour trier listes/cartes
        ])
        // Tri des listes et cartes si 'pos' est récupéré (non implémenté ici)
        var boardDetails: TrelloBoardDetail = try await performRequest(url: url)
        // boardDetails.lists.sort { $0.pos < $1.pos } // Exemple si 'pos' est ajouté
        // boardDetails.cards.sort { $0.pos < $1.pos } // Exemple si 'pos' est ajouté
        return boardDetails
    }

     func moveCard(cardId: String, toListId: String, position: String = "bottom") async throws {
        let url = try makeURL(path: "/cards/\(cardId)", queryItems: [
            URLQueryItem(name: "idList", value: toListId),
            URLQueryItem(name: "pos", value: position) // Ou "top"
        ])
        try await performUpdateRequest(url: url) // Utiliser la méthode PUT simple
    }
}