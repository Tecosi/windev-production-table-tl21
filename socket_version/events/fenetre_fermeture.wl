// ═══════════════════════════════════════════════════════════════
// ÉVÉNEMENT : FERMETURE DE LA FENÊTRE
// ═══════════════════════════════════════════════════════════════
// 
// Ce code ferme proprement la connexion socket
// 
// ═══════════════════════════════════════════════════════════════

// Vérifier que le socket est actif
SI gbSocketActif = Faux ALORS
	RETOUR
FIN


// ═══════════════════════════════════════════════════════════════
// MODE SERVEUR : FERMER TOUTES LES CONNEXIONS
// ═══════════════════════════════════════════════════════════════

SI gbEstServeur = Vrai ALORS
	Trace("🔴 Fermeture du serveur socket...")
	
	// ───────────────────────────────────────────────────────────
	// Notifier tous les clients de la fermeture
	// ───────────────────────────────────────────────────────────
	Socket_Envoyer("server_shutdown", {message: "Le serveur se ferme"})
	
	// Attendre un peu pour que les messages soient envoyés
	Temporisation(100)
	
	// ───────────────────────────────────────────────────────────
	// Fermer toutes les connexions clients
	// ───────────────────────────────────────────────────────────
	POUR TOUT sNomClient DE gtabClientsConnectes
		SocketFerme(sNomClient)
		Trace("  ✓ Client fermé : " + sNomClient)
	FIN
	
	// Vider le tableau
	TableauSupprimeTout(gtabClientsConnectes)
	
	// ───────────────────────────────────────────────────────────
	// Fermer le serveur
	// ───────────────────────────────────────────────────────────
	SocketFerme(gsNomSocketServeur)
	
	ToastAffiche("🔴 Serveur socket arrêté", toastCourt, cvBas, chCentre)
	Trace("✅ Serveur socket fermé")
	
SINON
	// ═══════════════════════════════════════════════════════════
	// MODE CLIENT : DÉCONNECTER DU SERVEUR
	// ═══════════════════════════════════════════════════════════
	
	Trace("🔴 Déconnexion du serveur socket...")
	
	// ───────────────────────────────────────────────────────────
	// Notifier le serveur de la déconnexion
	// ───────────────────────────────────────────────────────────
	Socket_Envoyer("disconnect", {user: gsUtilisateurActuel})
	
	// Attendre un peu pour que le message soit envoyé
	Temporisation(100)
	
	// ───────────────────────────────────────────────────────────
	// Fermer la connexion client
	// ───────────────────────────────────────────────────────────
	SocketFerme(gsNomSocketClient)
	
	ToastAffiche("🔴 Déconnecté du serveur", toastCourt, cvBas, chCentre)
	Trace("✅ Client socket fermé")
FIN


// ═══════════════════════════════════════════════════════════════
// RÉINITIALISER LES VARIABLES
// ═══════════════════════════════════════════════════════════════

gbSocketActif = Faux
gbEstServeur = Faux


// ═══════════════════════════════════════════════════════════════
// NOTES
// ═══════════════════════════════════════════════════════════════
// 
// Fermeture propre :
// - Notifier les autres utilisateurs
// - Fermer toutes les connexions
// - Libérer les ressources
// 
// Si le serveur se ferme :
// - Les clients perdent la connexion
// - La prochaine instance à se lancer deviendra serveur
// 
// Recommandation :
// - Garder au moins une instance ouverte en permanence (serveur)
// - Ou créer une application serveur dédiée
// 
// ═══════════════════════════════════════════════════════════════
