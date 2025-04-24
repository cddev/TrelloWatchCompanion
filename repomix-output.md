This file is a merged representation of a subset of the codebase, containing files not matching ignore patterns, combined into a single document by Repomix.
The content has been processed where empty lines have been removed, content has been formatted for parsing in markdown style, content has been compressed (code blocks are separated by ⋮---- delimiter).

# File Summary

## Purpose
This file contains a packed representation of the entire repository's contents.
It is designed to be easily consumable by AI systems for analysis, code review,
or other automated processes.

## File Format
The content is organized as follows:
1. This summary section
2. Repository information
3. Directory structure
4. Multiple file entries, each consisting of:
  a. A header with the file path (## File: path/to/file)
  b. The full contents of the file in a code block

## Usage Guidelines
- This file should be treated as read-only. Any changes should be made to the
  original repository files, not this packed version.
- When processing this file, use the file path to distinguish
  between different files in the repository.
- Be aware that this file may contain sensitive information. Handle it with
  the same level of security as you would the original repository.

## Notes
- Some files may have been excluded based on .gitignore rules and Repomix's configuration
- Binary files are not included in this packed representation. Please refer to the Repository Structure section for a complete list of file paths, including binary files
- Files matching these patterns are excluded: *.json
- Files matching patterns in .gitignore are excluded
- Files matching default ignore patterns are excluded
- Empty lines have been removed from all files
- Content has been formatted for parsing in markdown style
- Content has been compressed - code blocks are separated by ⋮---- delimiter
- Files are sorted by Git change count (files with more changes are at the bottom)

## Additional Info

# Directory Structure
```
.repomix/bundles.json
README.md
Shared/Models.swift
TrelloCompanionApp/ContentView.swift
TrelloCompanionApp/CredentialsViewModel.swift
TrelloCompanionApp/KeychainHelper.swift
TrelloCompanionApp/PhoneSessionManager.swift
TrelloCompanionApp/YourTrelloCompanionAppApp.swift
TrelloWatchApp/BoardDetailView.swift
TrelloWatchApp/BoardDetailViewModel.swift
TrelloWatchApp/BoardListView.swift
TrelloWatchApp/BoardListViewModel.swift
TrelloWatchApp/ContentView.swift
TrelloWatchApp/MoveCardView.swift
TrelloWatchApp/TrelloAPIService.swift
TrelloWatchApp/WatchSessionManager.swift
TrelloWatchApp/YourTrelloWatchAppApp.swift
```

# Files

## File: .repomix/bundles.json
```json
{
  "bundles": {}
}
```

## File: README.md
```markdown
# Trello Watch Companion App
https://drive.google.com/file/d/10uoUdQL4VoOJZLzmdQ2p1cIF8utW1cCb/view?usp=sharing, https://aistudio.google.com/app/prompts?state=%7B%22ids%22:%5B%221YA8XFPE_qSdMBWZAbV4CeEWry_QXjtZT%22%5D,%22action%22:%22open%22,%22userId%22:%22101478228369990562741%22,%22resourceKeys%22:%7B%7D%7D&usp=sharing
## Overview

This project demonstrates a basic implementation of a Trello client for watchOS (version 11 target assumed) paired with a companion iOS application. It allows users to authenticate with their Trello account via the iOS app, view their Trello boards and cards on their Apple Watch, and move cards between lists directly from the watch.

The implementation is based on the provided Trello REST API OpenAPI specification (`trelloopenapi.json`).

**Note:** This is a conceptual implementation focusing on core functionality and structure. It lacks robust error handling, advanced UI features, and comprehensive security measures beyond basic Keychain usage on iOS.

## Features

### iOS Companion App

*   Provides input fields for Trello API Key and API Token.
*   Securely stores the API Key and Token in the iOS Keychain.
*   Sends the credentials to the paired Apple Watch using WatchConnectivity.
*   Displays the status of the WatchConnectivity session (app installed, reachable).
*   Allows clearing stored credentials from the Keychain.

### watchOS App

*   Receives Trello credentials securely from the companion iOS app via WatchConnectivity.
*   Displays an authentication required message until credentials are received.
*   Fetches and displays a list of the user's open Trello boards.
*   Allows navigation into a selected board.
*   Displays the board's lists (columns) using a horizontal `TabView`.
*   Displays the cards within each list vertically.
*   Allows tapping on a card to initiate a move action.
*   Presents a modal sheet to select the destination list for the card.
*   Performs the card move via the Trello API.
*   Uses optimistic UI updates for smoother card moving experience (updates local state immediately, reverts on API failure).

## Prerequisites

*   **Xcode:** Version 15 or later recommended (for Swift 5.9+, watchOS 10/11 SDKs).
*   **Apple Developer Account:** Required for enabling App Groups and running on physical devices.
*   **Physical iPhone and Apple Watch:** Required for proper testing of WatchConnectivity features. Simulators have limitations.
*   **Trello Account:** You need a Trello account to interact with the API.
*   **Trello API Key and Token:**
    *   Generate these from the [Trello Developer Portal](https://trello.com/app-key).
    *   **API Key:** Identifies your application.
    *   **API Token:** Grants access on behalf of your Trello user account. Keep this secure!

## Configuration Steps

1.  **Download/Clone:** Obtain the project source code.
2.  **Open in Xcode:** Open the `.xcodeproj` file.
3.  **Bundle Identifiers:** Set unique Bundle Identifiers for both the iOS (`TrelloCompanionApp`) and watchOS (`TrelloWatchApp`) targets in the "Signing & Capabilities" tab. (e.g., `com.yourcompany.TrelloCompanionApp`, `com.yourcompany.TrelloCompanionApp.watchkitapp`).
4.  **Development Team:** Select your Apple Developer account team for both targets under "Signing & Capabilities".
5.  **App Group:**
    *   This is **highly recommended** if you plan to share data beyond basic WatchConnectivity messages (like using a shared Keychain group, which is more secure for watchOS credential storage than the current UserDefaults implementation).
    *   Go to "Signing & Capabilities" for **both** the iOS target and the watchOS App target (e.g., `TrelloWatchApp`).
    *   Click "+ Capability" and add "App Groups".
    *   Click the "+" button under App Groups and create a new group identifier (e.g., `group.com.yourcompany.TrelloCompanionApp`). **Use the same identifier for both targets.**
    *   Ensure the checkbox next to the created group is checked for both targets.
6.  **Keychain Service Name (iOS App):**
    *   Open `TrelloCompanionApp/KeychainHelper.swift`.
    *   Locate the constant `keychainServiceName`.
    *   **IMPORTANT:** Change the value `"com.votredomaine.votreapp.trello"` to a unique string, typically based on your iOS app's bundle identifier (e.g., `"com.yourcompany.TrelloCompanionApp.trello"`). This ensures your app's keychain items don't conflict with others.

## Build Instructions

1.  **Connect Devices:** Connect your physical iPhone to your Mac. Ensure your Apple Watch is paired with the iPhone and unlocked.
2.  **Select iOS Scheme:** In Xcode, select the scheme for the iOS companion app (e.g., `TrelloCompanionApp`).
3.  **Select iPhone Device:** Choose your connected iPhone as the run destination.
4.  **Build & Run (iOS):** Press `Cmd + R` or click the Run button. Install the app on your iPhone.
5.  **Select watchOS Scheme:** In Xcode, select the scheme for the watchOS app (e.g., `TrelloWatchApp`).
6.  **Select Watch Device:** Choose your paired Apple Watch as the run destination (it should appear under your iPhone).
7.  **Build & Run (watchOS):** Press `Cmd + R` or click the Run button. Xcode will build the watch app and install it via the paired iPhone.

## Usage Guide

1.  **Launch iOS App:** Open the Trello Companion app on your iPhone.
2.  **Enter Credentials:** Paste your generated Trello API Key and API Token into the respective fields.
3.  **Save & Send:** Tap the "Sauvegarder et Envoyer à la Montre" button.
    *   Observe the status messages. It should indicate saving to Keychain and attempting to send.
    *   The WatchConnectivity status indicator should ideally show the watch as reachable (green watch face icon).
    *   A success message should appear if the credentials were sent successfully.
4.  **Launch watchOS App:** Open the Trello app on your Apple Watch.
    *   Initially, it might show the "Authentification requise" message.
    *   Once it receives the credentials from the iPhone (this might take a few seconds, especially the first time), it should automatically transition to a loading state ("Chargement...").
    *   The list of your open Trello boards should appear.
5.  **Navigate (Watch):**
    *   Tap a board name to view its details.
    *   Swipe horizontally to switch between lists (columns).
    *   Scroll vertically to see cards within a list.
6.  **Move Card (Watch):**
    *   Tap on the name of a card you want to move.
    *   A modal sheet will appear titled "Vers...".
    *   Tap the name of the destination list.
    *   The sheet will dismiss, and the card should visually move to the new list in the UI (optimistic update). The API call happens in the background.

## Debugging Tips

*   **Console Logs:** Check the Xcode console output for BOTH the iOS and watchOS processes. Use `print` statements liberally in ViewModels, Session Managers, and API Services to track execution flow and variable values.
*   **WatchConnectivity:**
    *   **Activation:** Check logs in `PhoneSessionManager` and `WatchSessionManager` for successful activation (`activationDidCompleteWith`).
    *   **State:** Monitor `isWatchAppInstalled` and `isReachable` in the iOS app UI and logs. The watch must be unlocked and nearby for `isReachable` to be true. Bluetooth/Wi-Fi must be enabled.
    *   **Messaging:** Look for `sendMessage` logs on the phone and `didReceiveMessage` logs on the watch. Check for any errors passed to the `errorHandler` or `replyHandler`. Ensure the dictionary keys (`apiKey`, `apiToken`) match exactly.
    *   **First Connection:** Sometimes the first message send/receive after installation can be delayed. Try sending again if it doesn't work immediately. Ensure both apps have been run at least once.
*   **Authentication (Watch):**
    *   Verify credentials reception in `WatchSessionManager` logs.
    *   Check if `WatchSessionManager.shared.credentials` is non-nil in the watch `ContentView`.
    *   Ensure the `apiService.setCredentials` method is called correctly in `BoardListViewModel` when credentials change or the view appears.
    *   Look for `401 Unauthorized` errors (or `TrelloError.invalidCredentials`) in `TrelloAPIService` logs on the watch. Double-check the Key/Token entered on the iPhone.
*   **API Calls (Watch):**
    *   Examine `TrelloAPIService` logs for the constructed URL, HTTP status codes, and any specific error messages (`TrelloError.apiError`, `TrelloError.networkError`, `TrelloError.decodingError`).
    *   Common issues: Incorrect `boardId`/`cardId`/`listId`, network connectivity problems on the watch/iPhone, Trello API rate limits, or changes in the Trello API response format causing decoding errors.
*   **Keychain (iOS):**
    *   Check `KeychainHelper` logs for save/load/delete success or failure messages.
    *   Pay attention to `OSStatus` codes if errors occur (you can look these up online).
    *   Ensure the `keychainServiceName` is unique and correctly configured.
    *   On the Simulator, you can use "Device" -> "Erase All Content and Settings..." to reset the keychain if needed. On a device, deleting the app *should* remove its keychain items.
*   **App Group (If Sharing Data):** Double-check that the App Group identifier in "Signing & Capabilities" is **identical** for both the iOS and watchOS targets.
*   **SwiftUI:**
    *   Ensure `@StateObject` is used for ViewModels owned/created by a View, and `@ObservedObject` for ViewModels passed into a View.
    *   Verify that changes to `@Published` properties in ViewModels are happening on the main thread (use `@MainActor` on classes or specific functions).
    *   Use `print` statements inside view `body` properties (sparingly) or `.onChange` modifiers to track view updates.

## Known Limitations & Future Improvements

*   **watchOS Credential Storage:** Currently uses `UserDefaults` for simplicity, which is **not secure**. Should ideally use Keychain with App Group sharing or fetch credentials from iPhone on demand.
*   **Error Handling:** Basic error messages are shown. More user-friendly alerts, specific retry logic, and better state management during errors could be added.
*   **UI/UX:** The interface is functional but basic. Could be improved with better loading states, visual feedback on actions, custom styling, and potentially complications.
*   **Performance:** Loading all lists and cards for a board at once might be slow for large boards. Lazy loading or pagination could be implemented. The optimistic UI update helps perceived performance.
*   **Offline Support:** No offline caching or functionality. Requires active connection via the paired iPhone.
*   **Limited Functionality:** Only supports viewing open boards/lists/cards and moving cards. No creation, editing, deletion, searching, viewing closed items, attachments, comments, due dates, etc.
*   **Background Refresh:** The watch app doesn't currently fetch data in the background.

## Technology Stack

*   **SwiftUI:** For building the user interface for both iOS and watchOS.
*   **WatchConnectivity:** For communication between the iPhone and Apple Watch.
*   **Combine / async/await:** For handling asynchronous operations (API calls, WatchConnectivity).
*   **URLSession:** For making network requests to the Trello API.
*   **Security Framework (Keychain Services):** For secure storage of credentials on iOS.

## License

(Optional) Specify a license, e.g.:
MIT License
```

## File: Shared/Models.swift
```swift
// Modèle simplifié pour la liste des tableaux
struct TrelloBoardSimple: Identifiable, Codable, Hashable {
let id: String
let name: String
⋮----
// Modèles pour la vue détaillée du tableau
struct TrelloBoardDetail: Codable {
⋮----
var lists: [TrelloList] // var si on modifie localement
var cards: [TrelloCard] // var si on modifie localement
⋮----
struct TrelloList: Identifiable, Codable, Hashable {
⋮----
// Ajoutez 'pos' si vous voulez les trier
⋮----
struct TrelloCard: Identifiable, Codable, Hashable {
⋮----
var idList: String // var car elle change lors du déplacement
// Ajoutez d'autres champs si nécessaire (ex: pos)
⋮----
// Pour stocker les credentials (utilisé par KeychainHelper et les SessionManagers)
struct TrelloCredentials: Codable {
let apiKey: String
let apiToken: String
⋮----
// Erreurs possibles du Keychain (utilisé par KeychainHelper)
enum KeychainError: Error, LocalizedError {
⋮----
var errorDescription: String? {
⋮----
// Erreurs spécifiques à l'API Trello (utilisé par TrelloAPIService)
enum TrelloError: Error {
⋮----
// Notification pour la mise à jour des credentials (utilisé par WatchSessionManager Watch)
⋮----
static let credentialsUpdated = Notification.Name("credentialsUpdated")
```

## File: TrelloCompanionApp/ContentView.swift
```swift
import WatchConnectivity // Importer pour utiliser les états
struct ContentView: View {
@StateObject private var viewModel = CredentialsViewModel() // Utiliser StateObject
var body: some View {
⋮----
.textContentType(.password) // Empêche la suggestion, mais pas idéal
⋮----
// Utiliser SecureField pour masquer le token
⋮----
// Indicateur de statut WatchConnectivity
⋮----
// Affichage du statut et indicateur de chargement
⋮----
Spacer() // Pousse l'indicateur à droite
⋮----
.scaleEffect(0.8) // Taille plus petite
⋮----
.frame(height: 30) // Hauteur fixe pour éviter les sauts d'UI
⋮----
.disabled(viewModel.isLoading || !viewModel.sessionManager.isWatchAppInstalled) // Désactiver si chargement ou montre non installée
⋮----
Spacer() // Pousse tout vers le haut
⋮----
.navigationBarTitleDisplayMode(.inline) // Plus compact
⋮----
// Fonction helper pour le texte de statut de la montre
func watchStatusText() -> String {
⋮----
struct ContentView_Previews_iOS: PreviewProvider { // Renommez pour éviter conflit si watchOS a aussi un preview
static var previews: some View {
```

## File: TrelloCompanionApp/CredentialsViewModel.swift
```swift
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
⋮----
func loadCredentialsFromKeychain() {
⋮----
func saveAndSendCredentials() {
// Validation simple
⋮----
let credentialsToSave = TrelloCredentials(apiKey: apiKey, apiToken: apiToken)
Task { // Utiliser Task pour le travail asynchrone
⋮----
// 1. Sauvegarder dans le Keychain
⋮----
// 2. Envoyer à la montre
⋮----
// Remettre à jour l'UI sur le thread principal
⋮----
self.isLoading = false // Fin du chargement global
⋮----
func clearCredentials() {
⋮----
self.statusColor = .orange // Indiquer qu'une action est peut-être requise
// Optionnel: envoyer des credentials vides à la montre pour la déconnexion
// sessionManager.sendCredentialsToWatch(apiKey: "", apiToken: "") { ... }
⋮----
// Wrapper simple pour les erreurs WatchConnectivity (juste pour l'exemple)
struct WCError: Error, LocalizedError {
enum Code {
⋮----
let code: Code
init(_ code: Code) { self.code = code }
var errorDescription: String? {
```

## File: TrelloCompanionApp/KeychainHelper.swift
```swift
// Nom unique pour identifier le service dans le Keychain
// !! REMPLACEZ PAR VOTRE IDENTIFIANT D'APP UNIQUE !!
private let keychainServiceName = "com.votredomaine.votreapp.trello"
private let keychainAccountName = "trelloCredentials"
struct KeychainHelper {
// Sauvegarde les credentials dans le Keychain
static func saveCredentials(_ credentials: TrelloCredentials) throws {
// Encoder les credentials en Data
⋮----
// Préparer la requête pour le Keychain
let query: [String: Any] = [
⋮----
kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly // Bonne pratique de sécurité
⋮----
// Supprimer l'ancien item s'il existe
⋮----
// Ajouter le nouvel item
let status = SecItemAdd(query as CFDictionary, nil)
⋮----
// Charge les credentials depuis le Keychain
static func loadCredentials() throws -> TrelloCredentials? {
⋮----
kSecReturnData as String: kCFBooleanTrue!, // On veut récupérer les data
kSecMatchLimit as String: kSecMatchLimitOne // On ne s'attend qu'à un seul résultat
⋮----
var dataTypeRef: AnyObject?
let status = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)
⋮----
// Décoder les Data en TrelloCredentials
⋮----
return nil // Normal, l'item n'existe pas encore
⋮----
// Supprime les credentials du Keychain
static func deleteCredentials() throws {
⋮----
let status = SecItemDelete(query as CFDictionary)
```

## File: TrelloCompanionApp/PhoneSessionManager.swift
```swift
class PhoneSessionManager: NSObject, WCSessionDelegate, ObservableObject {
static let shared = PhoneSessionManager()
private var session: WCSession?
@Published var activationState: WCSessionActivationState = .notActivated
@Published var isWatchAppInstalled: Bool = false
@Published var isReachable: Bool = false // Très important pour savoir si on peut envoyer un message *maintenant*
private override init() {
⋮----
// MARK: - WCSessionDelegate Methods
func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
⋮----
// --- Méthodes nécessaires pour iOS ---
func sessionDidBecomeInactive(_ session: WCSession) {
⋮----
self.isReachable = session.isReachable // Mettre à jour l'état
⋮----
func sessionDidDeactivate(_ session: WCSession) {
⋮----
// Réactiver la session est une bonne pratique
⋮----
// --- Surveillance de l'état ---
func sessionWatchStateDidChange(_ session: WCSession) {
⋮----
func sessionReachabilityDidChange(_ session: WCSession) {
⋮----
// MARK: - Sending Data
func sendCredentialsToWatch(apiKey: String, apiToken: String, completion: @escaping (Result<Void, Error>) -> Void) {
⋮----
let messageData = ["apiKey": apiKey, "apiToken": apiToken]
⋮----
// La montre a reçu et a répondu (optionnel)
⋮----
// Erreur lors de l'envoi
⋮----
// Wrapper l'erreur pour plus de clarté
```

## File: TrelloCompanionApp/YourTrelloCompanionAppApp.swift
```swift
struct YourTrelloCompanionAppApp: App { // <-- RENOMMEZ ICI
// Initialiser le session manager tôt pour qu'il commence à s'activer
init() {
⋮----
var body: some Scene {
⋮----
ContentView() // Ceci est le ContentView de l'app iOS
```

## File: TrelloWatchApp/BoardDetailView.swift
```swift
struct BoardDetailView: View {
let boardId: String
// Utiliser StateObject car cette vue crée et possède son ViewModel
@StateObject private var viewModel: BoardDetailViewModel
// Initialiseur pour injecter l'API Service configuré
init(boardId: String, apiService: TrelloAPIService) {
⋮----
// Initialiser le StateObject avec les dépendances nécessaires
⋮----
var body: some View {
⋮----
if viewModel.isLoading && viewModel.boardDetail == nil { // Afficher seulement au premier chargement
⋮----
// Utiliser TabView pour simuler les colonnes
⋮----
// Utiliser une ScrollView au lieu d'une List pour éviter les listes imbriquées
⋮----
// Liste des cartes dans cette colonne
// Récupérer les cartes pour cette liste spécifique
let cardsInList = viewModel.cardsByList[list.id] ?? []
⋮----
.padding(.vertical) // Un peu d'espace
⋮----
// Améliorer l'affichage du bouton
⋮----
.frame(maxWidth: .infinity, alignment: .leading) // Prend toute la largeur
⋮----
.background(Color.gray.opacity(0.2)) // Fond léger
⋮----
.buttonStyle(.plain) // Style de bouton pour le fond et padding
⋮----
Spacer() // Pousse les cartes vers le haut si peu nombreuses
⋮----
.padding(.horizontal) // Padding pour le contenu de la ScrollView
⋮----
.navigationTitle(list.name) // Le titre change avec la colonne
.tag(list.id) // Identifier chaque page/onglet
⋮----
.tabViewStyle(.page(indexDisplayMode: .automatic)) // Style page par page
// Le titre global du tableau peut être mis ailleurs si nécessaire,
// car la nav bar change avec la TabView.
// .navigationTitle(board.name) // Titre global moins utile ici
⋮----
// Cas où il n'y a ni chargement ni erreur, mais pas de données
⋮----
// Charger les détails si ce n'est pas déjà fait
⋮----
// La sheet est présentée au niveau de la vue qui contient la TabView
⋮----
// Feuille modale pour déplacer la carte
⋮----
// S'assurer que la sheet a sa propre NavigationView pour la barre de titre/bouton
⋮----
// La fermeture est gérée par le ViewModel via showMoveCardSheet = false
```

## File: TrelloWatchApp/BoardDetailViewModel.swift
```swift
import Combine // Ou utiliser async/await directement dans les vues
⋮----
class BoardDetailViewModel: ObservableObject {
@Published var boardDetail: TrelloBoardDetail?
@Published var isLoading = false
@Published var errorMessage: String?
@Published var showMoveCardSheet = false // Contrôle l'affichage de la sheet
@Published var cardToMove: TrelloCard? // La carte sélectionnée pour le déplacement
// Propriété calculée pour faciliter l'affichage par colonne dans la TabView
var cardsByList: [String: [TrelloCard]] {
⋮----
// Grouper les cartes par leur idList
⋮----
// Propriété calculée pour obtenir les listes de destination possibles
var availableListsForMoving: [TrelloList] {
// Exclure la liste actuelle de la carte à déplacer
⋮----
private let boardId: String
// Utiliser l'instance partagée ou injectée de l'API Service qui contient déjà les credentials
private let apiService: TrelloAPIService
// Initialiseur qui reçoit l'ID du tableau et le service API configuré
init(boardId: String, apiService: TrelloAPIService) {
⋮----
// Charger les détails du tableau (listes et cartes)
func loadBoardDetails() {
⋮----
let details = try await apiService.fetchBoardDetails(boardId: boardId)
// Mettre à jour la propriété publiée, ce qui rafraîchira l'UI
⋮----
// Gérer les erreurs spécifiques Trello
⋮----
// Gérer les autres erreurs
⋮----
// Fin du chargement
⋮----
// Méthode appelée lorsqu'on tape sur une carte pour initier le déplacement
func selectCardForMove(_ card: TrelloCard) {
⋮----
self.showMoveCardSheet = true // Déclenche l'affichage de la sheet
⋮----
// Méthode appelée depuis MoveCardView lorsqu'une destination est choisie
func moveSelectedCard(toList destinationList: TrelloList) {
⋮----
// Sauvegarder l'ID de la liste originale pour pouvoir annuler si l'API échoue
let originalListId = card.idList
// 1. Mise à jour Optimiste de l'UI : Modifie l'état local immédiatement
// Ceci rend l'application plus réactive.
⋮----
// 2. Cacher la feuille de sélection et réinitialiser la carte sélectionnée
⋮----
// 3. Appel API Asynchrone pour effectuer le déplacement sur Trello
⋮----
// Si succès, l'UI est déjà à jour (grâce à la màj optimiste).
// On pourrait déclencher un rechargement complet si on voulait être certain
// d'avoir l'état le plus récent (ex: position exacte dans la liste).
// loadBoardDetails() // Optionnel
⋮----
// 4. Annuler la mise à jour optimiste si l'appel API échoue
⋮----
// Remettre la carte dans sa liste d'origine dans l'UI locale
⋮----
// Afficher un message d'erreur à l'utilisateur
⋮----
// Méthode privée pour mettre à jour l'état local de la carte (pour la màj optimiste et l'annulation)
private func updateLocalCardList(cardId: String, newlistId: String) {
// S'assurer que boardDetail existe
⋮----
// Trouver l'index de la carte à modifier dans notre tableau local
⋮----
// Modifier directement l'idList de la carte dans notre modèle local
⋮----
// Forcer SwiftUI à redessiner car un élément interne d'un objet publié a changé.
// objectWillChange.send() est implicitement appelé quand on modifie boardDetail.
⋮----
// Helper pour gérer les erreurs Trello (peut être étendu)
private func handleTrelloError(_ error: TrelloError, context: String? = nil) {
let prefix = context.map { "\($0): " } ?? ""
⋮----
// Idéalement, propager cette erreur pour déconnecter l'utilisateur
```

## File: TrelloWatchApp/BoardListView.swift
```swift
struct BoardListView: View {
@ObservedObject var viewModel: BoardListViewModel
let credentials: TrelloCredentials // Passer les credentials valides
var body: some View {
// La NavigationView est déjà dans l'App principale de la montre
⋮----
} else if viewModel.boards.isEmpty && !viewModel.needsAuthentication { // Vérifier si on n'attend pas l'auth
⋮----
// Ce cas est normalement géré par ContentView, mais sécurité
⋮----
// Passer l'API Service déjà configuré avec les bons credentials
⋮----
.listStyle(.carousel) // Style adapté à la montre
⋮----
// Charger seulement si pas déjà chargé ou si on veut rafraîchir
// et si on a les credentials (vérifié par ContentView parent)
```

## File: TrelloWatchApp/BoardListViewModel.swift
```swift
import Combine // Ou utiliser async/await directement dans les vues
@MainActor // Assure que les @Published sont mis à jour sur le thread principal
class BoardListViewModel: ObservableObject {
@Published var boards: [TrelloBoardSimple] = []
@Published var isLoading = false
@Published var errorMessage: String?
@Published var needsAuthentication = false // Indique si on attend les credentials
// Garder une instance unique du service API pour partager les credentials
let apiService: TrelloAPIService
// Utiliser un injecteur de dépendance est une bonne pratique
init(apiService: TrelloAPIService = TrelloAPIService()) {
⋮----
// Vérifier l'état initial des credentials via le service
⋮----
// Méthode pour charger les tableaux, nécessite les credentials
func loadBoards(credentials: TrelloCredentials?) {
⋮----
// Si les credentials ne sont pas fournis (ou sont effacés), marquer comme nécessitant l'auth
⋮----
self.boards = [] // Vider la liste existante
apiService.setCredentials(key: nil, token: nil) // Effacer dans le service aussi
⋮----
// Si on reçoit des credentials valides
⋮----
// Mettre à jour l'API Service avec les credentials reçus
⋮----
let fetchedBoards = try await apiService.fetchBoards()
⋮----
// Si succès, s'assurer qu'il n'y a pas de message d'erreur résiduel
⋮----
// Gérer les erreurs spécifiques Trello
⋮----
// Gérer les autres erreurs
⋮----
// Fin du chargement dans tous les cas (succès ou erreur)
⋮----
// Helper pour gérer les erreurs Trello de manière centralisée
private func handleTrelloError(_ error: TrelloError) {
⋮----
self.needsAuthentication = true // Marquer qu'on a besoin d'auth
self.boards = [] // Vider la liste
apiService.setCredentials(key: nil, token: nil) // Effacer creds dans le service
⋮----
self.errorMessage = "Erreur interne de l'application." // Erreur de programmation
⋮----
self.errorMessage = "Erreur de données Trello." // L'API a peut-être changé
```

## File: TrelloWatchApp/ContentView.swift
```swift
struct ContentView: View {
// Utiliser StateObject car cette vue "possède" le manager pour son cycle de vie ici
@StateObject private var watchManager = WatchSessionManager.shared
// Utiliser StateObject aussi pour le ViewModel racine
@StateObject private var boardListViewModel = BoardListViewModel()
var body: some View {
// Vérifie si les credentials existent via le manager partagé
⋮----
// Si oui, injecter les credentials dans le service API et montrer la liste des tableaux
⋮----
// S'assurer que le service API a les bons credentials au démarrage de la vue
⋮----
// Réagir si les credentials sont mis à jour depuis l'iPhone PENDANT que l'app est active
⋮----
boardListViewModel.loadBoards(credentials: creds) // Recharger les tableaux
⋮----
// Gérer le cas où les credentials sont effacés par l'iPhone
⋮----
boardListViewModel.boards = [] // Vider la liste
boardListViewModel.needsAuthentication = true // Mettre à jour l'état du VM
⋮----
// Si non, afficher un message invitant à configurer sur iPhone
⋮----
.navigationTitle("Trello") // Titre pour la vue d'attente
⋮----
struct ContentView_Previews_Watch: PreviewProvider { // Renommez pour éviter conflit
static var previews: some View {
// Pour le preview, simuler un état (ex: sans credentials)
⋮----
// Pour simuler avec credentials, il faudrait injecter un WatchManager préconfiguré
// .environmentObject(WatchSessionManager.preconfiguredManager())
```

## File: TrelloWatchApp/MoveCardView.swift
```swift
struct MoveCardView: View {
@Environment(\.dismiss) var dismiss // Pour fermer la feuille
let cardToMove: TrelloCard
let availableLists: [TrelloList]
let onMoveSelected: (TrelloList) -> Void // Callback pour déclencher le déplacement
var body: some View {
// Pas besoin de NavigationView ici car elle est fournie par le .sheet dans BoardDetailView
⋮----
.padding(.bottom, 5) // Réduit l'espace
⋮----
// Utiliser une List pour la sélection de destination
⋮----
onMoveSelected(list) // Appeler le callback
// La fermeture est gérée par le ViewModel parent
⋮----
.listStyle(.carousel) // Style adapté à la montre
⋮----
.navigationTitle("Vers...") // Titre de la barre de la sheet
⋮----
.toolbar { // Bouton pour fermer manuellement
```

## File: TrelloWatchApp/TrelloAPIService.swift
```swift
// Définition des erreurs déjà dans Models.swift partagé
class TrelloAPIService {
private let baseURL = URL(string: "https://api.trello.com/1")!
private var apiKey: String?
private var apiToken: String?
// Méthode pour injecter/mettre à jour les credentials de manière sécurisée
// Appelée par les ViewModels après réception via WatchConnectivity
func setCredentials(key: String?, token: String?) {
// Validation simple
⋮----
private func makeURL(path: String, queryItems: [URLQueryItem] = []) throws -> URL {
// Vérifier si les credentials sont présents AVANT de construire l'URL
⋮----
throw TrelloError.authenticationRequired // Erreur spécifique
⋮----
var components = URLComponents(url: baseURL.appendingPathComponent(path), resolvingAgainstBaseURL: false)
// Cloner les items pour ajouter clé/token sans modifier l'original
var allQueryItems = queryItems
⋮----
// print("Requesting URL: \(url.absoluteString)") // Debug
⋮----
// Fonction générique pour exécuter les requêtes GET et décoder la réponse
private func performRequest<T: Decodable>(url: URL, method: String = "GET", body: Data? = nil) async throws -> T {
var request = URLRequest(url: url)
⋮----
request.httpBody = body // Ajouter le corps pour PUT/POST si nécessaire
⋮----
// print("Status Code: \(httpResponse.statusCode)") // Debug
// Gérer les erreurs Trello spécifiques
⋮----
// 401 signifie souvent un token invalide ou des permissions manquantes
⋮----
// Convertir en message d'erreur plus clair si possible
let errorMessage = String(data: data, encoding: .utf8) ?? "Resource not found"
⋮----
// Gérer les autres erreurs serveur/client
⋮----
let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown API Error"
⋮----
// Si le statut est OK, essayer de décoder
⋮----
let decoder = JSONDecoder()
let decodedObject = try decoder.decode(T.self, from: data)
⋮----
// Relancer les erreurs Trello spécifiques déjà identifiées
⋮----
// Gérer les erreurs réseau URLSession (offline, timeout, etc.)
⋮----
// Fonction spécifique pour les requêtes PUT qui ne renvoient pas forcément de contenu JSON
private func performUpdateRequest(url: URL) async throws {
⋮----
// print("Update Request Status Code: \(httpResponse.statusCode)") // Debug
⋮----
let errorMessage = String(data: data, encoding: .utf8) ?? "Update failed"
⋮----
// Si 2xx, l'opération a réussi, pas besoin de retourner de données.
⋮----
// --- API Endpoints ---
func fetchBoards() async throws -> [TrelloBoardSimple] {
let url = try makeURL(path: "/members/me/boards", queryItems: [
⋮----
func fetchBoardDetails(boardId: String) async throws -> TrelloBoardDetail {
let url = try makeURL(path: "/boards/\(boardId)", queryItems: [
URLQueryItem(name: "lists", value: "open"), // Récupérer les listes ouvertes
URLQueryItem(name: "cards", value: "open"), // Récupérer les cartes ouvertes
URLQueryItem(name: "list_fields", value: "id,name"), // Champs pour les listes
URLQueryItem(name: "card_fields", value: "id,name,idList") // Champs pour les cartes
// Ajouter 'pos' si nécessaire pour trier listes/cartes
⋮----
// Tri des listes et cartes si 'pos' est récupéré (non implémenté ici)
var boardDetails: TrelloBoardDetail = try await performRequest(url: url)
// boardDetails.lists.sort { $0.pos < $1.pos } // Exemple si 'pos' est ajouté
// boardDetails.cards.sort { $0.pos < $1.pos } // Exemple si 'pos' est ajouté
⋮----
func moveCard(cardId: String, toListId: String, position: String = "bottom") async throws {
let url = try makeURL(path: "/cards/\(cardId)", queryItems: [
⋮----
URLQueryItem(name: "pos", value: position) // Ou "top"
⋮----
try await performUpdateRequest(url: url) // Utiliser la méthode PUT simple
```

## File: TrelloWatchApp/WatchSessionManager.swift
```swift
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
⋮----
loadCredentials() // Charger au démarrage
⋮----
// MARK: - WCSessionDelegate Methods
func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
DispatchQueue.main.async { // Mettre à jour l'UI/état sur le thread principal
⋮----
// Gérer l'erreur si nécessaire
⋮----
// On peut demander les données à l'iPhone ici si on ne les a pas encore
// self.requestCredentialsFromPhoneIfNeeded()
⋮----
// --- Réception de Messages ---
func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
⋮----
let receivedCredentials = TrelloCredentials(apiKey: key, apiToken: token)
// Comparer avant de sauvegarder/notifier pour éviter travail inutile
⋮----
self.saveCredentials(receivedCredentials) // Sauvegarde (non sécurisée ici)
⋮----
// Notifier l'UI que les credentials ont changé
⋮----
// Envoyer une réponse de succès à l'iPhone
⋮----
// Gérer aussi les messages sans replyHandler au cas où l'iPhone utilise cette méthode
func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
⋮----
// --- Persistance (Simplifié avec UserDefaults - NON SÉCURISÉ) ---
private func saveCredentials(_ creds: TrelloCredentials?) {
⋮----
let data = try JSONEncoder().encode(creds)
⋮----
private func loadCredentials() {
⋮----
let savedCreds = try JSONDecoder().decode(TrelloCredentials.self, from: data)
⋮----
// Supprimer les données corrompues potentiellement
⋮----
// Fonction pour effacer explicitement (utile pour déconnexion)
func clearCredentials() {
⋮----
// Notifier l'UI pour qu'elle réagisse
```

## File: TrelloWatchApp/YourTrelloWatchAppApp.swift
```swift
struct YourTrelloWatchAppApp: App { // <-- RENOMMEZ ICI
// Initialiser le manager pour qu'il commence à écouter
init() {
⋮----
var body: some Scene {
⋮----
NavigationView { // La vue racine de la montre
ContentView() // Ceci est le ContentView de l'app Watch
```
