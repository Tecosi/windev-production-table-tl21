// ═══════════════════════════════════════════════════════════════
// VARIABLES GLOBALES DE LA FENÊTRE - VERSION SOCKET
// ═══════════════════════════════════════════════════════════════
// 
// À déclarer dans : Code de déclaration de la fenêtre
// 
// ═══════════════════════════════════════════════════════════════

// ───────────────────────────────────────────────────────────────
// Variables de gestion des modifications (existantes)
// ───────────────────────────────────────────────────────────────
gbModificationParMoiMeme est un booléen = Faux    // Flag pour encapsuler les modifications
gbSaisieEnCours est un booléen = Faux             // Indique si l'utilisateur est en train de saisir
gbActualisationEnAttente est un booléen = Faux    // Indique qu'un rafraîchissement est en attente
gnNombreModifications est un entier = 0           // Compteur de modifications détectées

// ───────────────────────────────────────────────────────────────
// Variables d'identification utilisateur (existantes)
// ───────────────────────────────────────────────────────────────
gsUtilisateurActuel est une chaîne = ""           // Nom de l'utilisateur actuel

// ───────────────────────────────────────────────────────────────
// Variables de verrouillage (existantes)
// ───────────────────────────────────────────────────────────────
gnIDLigneEnCoursDeModification est un entier = 0  // ID de la ligne verrouillée (HFSQL)

// ───────────────────────────────────────────────────────────────
// ✅ NOUVELLES VARIABLES SOCKET
// ───────────────────────────────────────────────────────────────
gbEstServeur est un booléen = Faux                // Indique si cette instance est le serveur socket
gsNomSocketServeur est une chaîne = "ServeurProd_TL21"  // Nom du socket serveur
gsNomSocketClient est une chaîne = "ClientProd_TL21"    // Nom du socket client
gnPortSocket est un entier = 5000                 // Port du serveur socket (localhost)
gtabClientsConnectes est un tableau de chaînes    // Liste des sockets clients connectés (serveur uniquement)
gbSocketActif est un booléen = Faux               // Indique si le socket est actif et connecté

// ═══════════════════════════════════════════════════════════════
// NOTES D'IMPLÉMENTATION
// ═══════════════════════════════════════════════════════════════
// 
// Sur RDS (Remote Desktop Services) :
// - Tous les utilisateurs sont sur le même serveur
// - Communication via localhost (127.0.0.1)
// - La 1ère instance devient serveur
// - Les instances suivantes deviennent clients
// - Pas de configuration réseau nécessaire
// - Latence < 50ms
// 
// ═══════════════════════════════════════════════════════════════
