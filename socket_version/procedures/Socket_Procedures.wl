// ═══════════════════════════════════════════════════════════════
// PROCÉDURES SOCKET - COMMUNICATION TEMPS RÉEL
// ═══════════════════════════════════════════════════════════════
// 
// Ces procédures gèrent la communication socket entre les instances
// de l'application sur RDS (Remote Desktop Services)
// 
// ═══════════════════════════════════════════════════════════════


// ═══════════════════════════════════════════════════════════════
// PROCÉDURE : ENVOYER UN MESSAGE VIA SOCKET
// ═══════════════════════════════════════════════════════════════
// 
// Envoie un message JSON à tous les autres utilisateurs
// 
// Paramètres :
//   - sAction : Type d'action (connect, disconnect, lock, unlock, update)
//   - stDonnees : Données associées à l'action (optionnel)
// 
// ═══════════════════════════════════════════════════════════════

PROCÉDURE Socket_Envoyer(sAction est une chaîne, stDonnees = Null)

// Vérifier que le socket est actif
SI gbSocketActif = Faux ALORS
	RETOUR
FIN

// Construire le message JSON
stMessage est un JSON
stMessage.action = sAction
stMessage.user = gsUtilisateurActuel
stMessage.timestamp = DateHeureSys()
stMessage.data = stDonnees

// Sérialiser en JSON
sJSON est une chaîne = VariantVersJSON(stMessage)

// Envoyer selon le rôle
SI gbEstServeur = Vrai ALORS
	// ═══════════════════════════════════════════════════════════
	// MODE SERVEUR : Broadcaster à tous les clients connectés
	// ═══════════════════════════════════════════════════════════
	POUR TOUT sNomClient DE gtabClientsConnectes
		SI SocketEcrit(sNomClient, sJSON) = Faux ALORS
			// Client déconnecté, le retirer de la liste
			Supprime(gtabClientsConnectes, IndiceCherche(gtabClientsConnectes, sNomClient))
			SocketFerme(sNomClient)
		FIN
	FIN
SINON
	// ═══════════════════════════════════════════════════════════
	// MODE CLIENT : Envoyer au serveur
	// ═══════════════════════════════════════════════════════════
	SI SocketEcrit(gsNomSocketClient, sJSON) = Faux ALORS
		// Erreur d'envoi
		Trace("❌ Erreur d'envoi socket : " + ErreurInfo())
		gbSocketActif = Faux
	FIN
FIN


// ═══════════════════════════════════════════════════════════════
// CALLBACK : NOUVELLE CONNEXION CLIENT (Serveur uniquement)
// ═══════════════════════════════════════════════════════════════
// 
// Appelée automatiquement quand un nouveau client se connecte
// 
// Paramètres :
//   - sNomSocket : Nom du socket serveur
// 
// ═══════════════════════════════════════════════════════════════

PROCÉDURE Socket_NouvelleConnexion(sNomSocket est une chaîne)

// Accepter la connexion
sNomClient est une chaîne = SocketAccepte(sNomSocket)

SI sNomClient = "" ALORS
	Trace("❌ Impossible d'accepter la connexion : " + ErreurInfo())
	RETOUR
FIN

// Ajouter à la liste des clients connectés
Ajoute(gtabClientsConnectes, sNomClient)

// Lire les messages du client en mode non bloquant
SocketLit(sNomClient, Vrai, Socket_MessageClient)

Trace("✅ Nouveau client connecté : " + sNomClient + " (Total : " + Dimension(gtabClientsConnectes) + ")")


// ═══════════════════════════════════════════════════════════════
// CALLBACK : MESSAGE REÇU D'UN CLIENT (Serveur uniquement)
// ═══════════════════════════════════════════════════════════════
// 
// Appelée automatiquement quand un client envoie un message
// 
// Paramètres :
//   - sNomClient : Nom du socket client
//   - sMessage : Message JSON reçu
// 
// ═══════════════════════════════════════════════════════════════

PROCÉDURE Socket_MessageClient(sNomClient est une chaîne, sMessage est une chaîne)

// Vérifier que le message n'est pas vide
SI sMessage = "" ALORS
	RETOUR
FIN

// Désérialiser le message JSON
stMessage est un JSON
SI PAS JSONVersVariant(stMessage, sMessage) ALORS
	Trace("❌ Erreur de désérialisation JSON : " + sMessage)
	RETOUR
FIN

Trace("📨 Message de " + stMessage.user + " : " + stMessage.action)

// ═══════════════════════════════════════════════════════════════
// BROADCASTER À TOUS LES AUTRES CLIENTS
// ═══════════════════════════════════════════════════════════════
POUR TOUT sAutreClient DE gtabClientsConnectes
	SI sAutreClient <> sNomClient ALORS
		SI SocketEcrit(sAutreClient, sMessage) = Faux ALORS
			// Client déconnecté, le retirer de la liste
			Supprime(gtabClientsConnectes, IndiceCherche(gtabClientsConnectes, sAutreClient))
			SocketFerme(sAutreClient)
		FIN
	FIN
FIN

// ═══════════════════════════════════════════════════════════════
// TRAITER LE MESSAGE LOCALEMENT AUSSI
// (Le serveur est aussi un utilisateur)
// ═══════════════════════════════════════════════════════════════
Socket_TraiterMessage(stMessage)


// ═══════════════════════════════════════════════════════════════
// CALLBACK : MESSAGE REÇU DU SERVEUR (Client uniquement)
// ═══════════════════════════════════════════════════════════════
// 
// Appelée automatiquement quand le serveur envoie un message
// 
// Paramètres :
//   - sNomSocket : Nom du socket client
//   - sMessage : Message JSON reçu
// 
// ═══════════════════════════════════════════════════════════════

PROCÉDURE Socket_MessageRecu(sNomSocket est une chaîne, sMessage est une chaîne)

// Vérifier que le message n'est pas vide
SI sMessage = "" ALORS
	RETOUR
FIN

// Désérialiser le message JSON
stMessage est un JSON
SI PAS JSONVersVariant(stMessage, sMessage) ALORS
	Trace("❌ Erreur de désérialisation JSON : " + sMessage)
	RETOUR
FIN

Trace("📨 Message du serveur : " + stMessage.action + " de " + stMessage.user)

// Traiter le message
Socket_TraiterMessage(stMessage)


// ═══════════════════════════════════════════════════════════════
// PROCÉDURE : TRAITER UN MESSAGE REÇU
// ═══════════════════════════════════════════════════════════════
// 
// Traite un message reçu via socket selon son type d'action
// 
// Paramètres :
//   - stMessage : Message JSON désérialisé
// 
// ═══════════════════════════════════════════════════════════════

PROCÉDURE Socket_TraiterMessage(stMessage est un JSON)

// ═══════════════════════════════════════════════════════════════
// IGNORER SES PROPRES MESSAGES
// ═══════════════════════════════════════════════════════════════
SI stMessage.user = gsUtilisateurActuel ALORS
	RETOUR
FIN

// ═══════════════════════════════════════════════════════════════
// TRAITER SELON L'ACTION
// ═══════════════════════════════════════════════════════════════
SELON stMessage.action
	CAS "connect"
		// ───────────────────────────────────────────────────────
		// Un utilisateur s'est connecté
		// ───────────────────────────────────────────────────────
		ToastAffiche("👤 " + stMessage.user + " s'est connecté", toastCourt, cvBas, chCentre)
		
	CAS "disconnect"
		// ───────────────────────────────────────────────────────
		// Un utilisateur s'est déconnecté
		// ───────────────────────────────────────────────────────
		ToastAffiche("👤 " + stMessage.user + " s'est déconnecté", toastCourt, cvBas, chCentre)
		
	CAS "lock"
		// ───────────────────────────────────────────────────────
		// Une ligne a été verrouillée par un autre utilisateur
		// ───────────────────────────────────────────────────────
		Socket_TraiterVerrouillage(stMessage.data.idLigne, stMessage.user)
		
	CAS "unlock"
		// ───────────────────────────────────────────────────────
		// Une ligne a été déverrouillée par un autre utilisateur
		// ───────────────────────────────────────────────────────
		Socket_TraiterDeverrouillage(stMessage.data.idLigne)
		
	CAS "update"
		// ───────────────────────────────────────────────────────
		// Une ligne a été modifiée par un autre utilisateur
		// ───────────────────────────────────────────────────────
		Socket_TraiterMiseAJour(stMessage.data.idLigne, stMessage.user)
		
	AUTRE CAS
		// ───────────────────────────────────────────────────────
		// Action inconnue
		// ───────────────────────────────────────────────────────
		Trace("⚠️ Action socket inconnue : " + stMessage.action)
FIN


// ═══════════════════════════════════════════════════════════════
// PROCÉDURE : TRAITER UN VERROUILLAGE DISTANT
// ═══════════════════════════════════════════════════════════════
// 
// Met à jour l'affichage quand un autre utilisateur verrouille une ligne
// 
// Paramètres :
//   - nIDLigne : ID de la ligne verrouillée
//   - sUtilisateur : Nom de l'utilisateur qui a verrouillé
// 
// ═══════════════════════════════════════════════════════════════

PROCÉDURE Socket_TraiterVerrouillage(nIDLigne est un entier, sUtilisateur est une chaîne)

// Trouver la ligne dans la table
POUR i = 1 À TableOccurrence(TABLE_Prod_TL21)
	SI TABLE_Prod_TL21.COL_ID[i] = nIDLigne ALORS
		// Mettre à jour l'indicateur visuel
		TABLE_Prod_TL21.COL_Modifie_par[i] = sUtilisateur
		
		// Rafraîchir l'affichage de cette ligne
		TableAfficheLigne(TABLE_Prod_TL21, i)
		
		// Toast discret
		ToastAffiche("🔒 " + sUtilisateur + " édite la ligne " + i, toastCourt, cvBas, chCentre)
		
		SORTIR
	FIN
FIN


// ═══════════════════════════════════════════════════════════════
// PROCÉDURE : TRAITER UN DÉVERROUILLAGE DISTANT
// ═══════════════════════════════════════════════════════════════
// 
// Met à jour l'affichage quand un autre utilisateur déverrouille une ligne
// 
// Paramètres :
//   - nIDLigne : ID de la ligne déverrouillée
// 
// ═══════════════════════════════════════════════════════════════

PROCÉDURE Socket_TraiterDeverrouillage(nIDLigne est un entier)

// Trouver la ligne dans la table
POUR i = 1 À TableOccurrence(TABLE_Prod_TL21)
	SI TABLE_Prod_TL21.COL_ID[i] = nIDLigne ALORS
		// Effacer l'indicateur visuel
		TABLE_Prod_TL21.COL_Modifie_par[i] = ""
		
		// Rafraîchir l'affichage de cette ligne
		TableAfficheLigne(TABLE_Prod_TL21, i)
		
		SORTIR
	FIN
FIN


// ═══════════════════════════════════════════════════════════════
// PROCÉDURE : TRAITER UNE MISE À JOUR DISTANTE
// ═══════════════════════════════════════════════════════════════
// 
// Rafraîchit la table quand un autre utilisateur modifie une ligne
// 
// Paramètres :
//   - nIDLigne : ID de la ligne modifiée
//   - sUtilisateur : Nom de l'utilisateur qui a modifié
// 
// ═══════════════════════════════════════════════════════════════

PROCÉDURE Socket_TraiterMiseAJour(nIDLigne est un entier, sUtilisateur est une chaîne)

// ═══════════════════════════════════════════════════════════════
// SI L'UTILISATEUR EST EN TRAIN DE SAISIR, DIFFÉRER
// ═══════════════════════════════════════════════════════════════
SI gbSaisieEnCours = Vrai ALORS
	gbActualisationEnAttente = Vrai
	gnNombreModifications++
	ToastAffiche("📝 Mise à jour en attente de " + sUtilisateur + " (" + gnNombreModifications + ")", toastCourt, cvBas, chCentre)
	RETOUR
FIN

// ═══════════════════════════════════════════════════════════════
// SINON, RAFRAÎCHIR IMMÉDIATEMENT
// ═══════════════════════════════════════════════════════════════

// Mémoriser la position actuelle
nPositionActuelle est un entier = TableSelect(TABLE_Prod_TL21)
nIDActuelPos est un entier = 0
SI nPositionActuelle > 0 ALORS
	nIDActuelPos = TABLE_Prod_TL21.COL_ID[nPositionActuelle]
FIN

// Rafraîchir la table
TableAffiche(TABLE_Prod_TL21, taRéExécuteRequete)
TableTrie(TABLE_Prod_TL21, "+COL_Ordre")

// Restaurer la position
SI nIDActuelPos > 0 ALORS
	POUR i = 1 À TableOccurrence(TABLE_Prod_TL21)
		SI TABLE_Prod_TL21.COL_ID[i] = nIDActuelPos ALORS
			TableSelectPlus(TABLE_Prod_TL21, i)
			SORTIR
		FIN
	FIN
FIN

// Toast de confirmation
ToastAffiche("📥 Mise à jour de " + sUtilisateur, toastCourt, cvBas, chCentre)
