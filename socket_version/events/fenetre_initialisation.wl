// ═══════════════════════════════════════════════════════════════
// ÉVÉNEMENT : INITIALISATION DE LA FENÊTRE
// ═══════════════════════════════════════════════════════════════
// 
// Ce code initialise la connexion socket et charge les données
// 
// ═══════════════════════════════════════════════════════════════

// ═══════════════════════════════════════════════════════════════
// ÉTAPE 1 : RÉCUPÉRER LE NOM DE L'UTILISATEUR
// ═══════════════════════════════════════════════════════════════

gsUtilisateurActuel = Environnement("USERNAME")

// Alternative si Environnement ne fonctionne pas :
// gsUtilisateurActuel = HInfoUtilisateur()
// gsUtilisateurActuel = "Utilisateur_" + NumériqueVersChaîne(Hasard(1000, 9999))

Trace("👤 Utilisateur : " + gsUtilisateurActuel)


// ═══════════════════════════════════════════════════════════════
// ÉTAPE 2 : INITIALISER LA CONNEXION SOCKET
// ═══════════════════════════════════════════════════════════════

// ───────────────────────────────────────────────────────────────
// ESSAYER DE CRÉER LE SERVEUR SOCKET
// ───────────────────────────────────────────────────────────────
SI SocketCrée(gsNomSocketServeur, gnPortSocket, Faux) = Vrai ALORS
	// ✅ CETTE INSTANCE DEVIENT LE SERVEUR
	// ───────────────────────────────────────────────────────────
	gbEstServeur = Vrai
	gbSocketActif = Vrai
	
	// Initialiser le tableau des clients
	TableauSupprimeTout(gtabClientsConnectes)
	
	// Attendre les connexions en mode non bloquant
	SI SocketAttendConnexion(gsNomSocketServeur, Socket_NouvelleConnexion) = Vrai ALORS
		ToastAffiche("🟢 Serveur socket démarré (Port " + gnPortSocket + ")", toastCourt, cvBas, chCentre)
		Trace("✅ Serveur socket créé sur le port " + gnPortSocket)
	SINON
		Erreur("Impossible d'attendre les connexions", ErreurInfo())
		gbSocketActif = Faux
	FIN
	
SINON
	// ───────────────────────────────────────────────────────────
	// LE SERVEUR EXISTE DÉJÀ, SE CONNECTER COMME CLIENT
	// ───────────────────────────────────────────────────────────
	gbEstServeur = Faux
	
	// Attendre un peu que le serveur soit prêt
	Temporisation(100)
	
	// Se connecter au serveur local (127.0.0.1)
	SI SocketConnecte(gsNomSocketClient, gnPortSocket, "127.0.0.1") = Vrai ALORS
		gbSocketActif = Vrai
		
		// Lire les messages du serveur en mode non bloquant
		SI SocketLit(gsNomSocketClient, Vrai, Socket_MessageRecu) = Vrai ALORS
			// Envoyer un message de connexion au serveur
			Socket_Envoyer("connect", {user: gsUtilisateurActuel})
			
			ToastAffiche("🔵 Connecté au serveur socket", toastCourt, cvBas, chCentre)
			Trace("✅ Client socket connecté au serveur")
		SINON
			Erreur("Impossible de lire les messages du serveur", ErreurInfo())
			gbSocketActif = Faux
		FIN
	SINON
		// Connexion échouée
		Erreur("Impossible de se connecter au serveur socket", ErreurInfo(), "Le serveur socket n'est peut-être pas démarré.")
		gbSocketActif = Faux
	FIN
FIN


// ═══════════════════════════════════════════════════════════════
// ÉTAPE 3 : CHARGER LES DONNÉES DE LA TABLE
// ═══════════════════════════════════════════════════════════════

// Exécuter la requête et afficher les données
TableAffiche(TABLE_Prod_TL21, taRéExécuteRequete)
TableTrie(TABLE_Prod_TL21, "+COL_Ordre")

Trace("✅ Table chargée : " + TableOccurrence(TABLE_Prod_TL21) + " lignes")


// ═══════════════════════════════════════════════════════════════
// ÉTAPE 4 : AFFICHER UN RÉSUMÉ
// ═══════════════════════════════════════════════════════════════

sResume est une chaîne
SI gbEstServeur = Vrai ALORS
	sResume = "Mode : SERVEUR 🟢"
SINON
	sResume = "Mode : CLIENT 🔵"
FIN
sResume += RC + "Utilisateur : " + gsUtilisateurActuel
sResume += RC + "Lignes chargées : " + TableOccurrence(TABLE_Prod_TL21)

Trace(sResume)


// ═══════════════════════════════════════════════════════════════
// NOTES
// ═══════════════════════════════════════════════════════════════
// 
// Sur RDS :
// - La 1ère instance qui se lance devient le serveur
// - Les instances suivantes deviennent des clients
// - Tous communiquent via localhost (127.0.0.1:5000)
// - Pas de configuration réseau nécessaire
// 
// Si le serveur se ferme :
// - Les clients perdent la connexion
// - La prochaine instance à se lancer deviendra serveur
// - Les clients existants doivent se reconnecter
// 
// ═══════════════════════════════════════════════════════════════
