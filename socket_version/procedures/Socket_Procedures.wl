// ═══════════════════════════════════════════════════════════════
// PROCÉDURES SOCKET - COMMUNICATION TEMPS RÉEL (VERSION CORRIGÉE)
// ═══════════════════════════════════════════════════════════════
// 
// Ces procédures gèrent la communication socket entre les instances
// de l'application sur RDS (Remote Desktop Services)
// 
// VERSION : 2.0.1 - Corrections syntaxe WinDev
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

// Construire le message JSON manuellement
sJSON est une chaîne
sJSON = "{"
sJSON += [" "action":""] + sAction + [" ","]
sJSON += [" "user":""] + gsUtilisateurActuel + [" ","]
sJSON += [" "timestamp":""] + DateHeureSys() + [" "]

// Ajouter les données si présentes
SI stDonnees <> Null ALORS
	sJSON += [," "data":{"]
	
	// Si c'est un entier simple (idLigne)
	SI TypeVar(stDonnees) = wlEntier ALORS
		sJSON += [" "idLigne":"] + stDonnees
	SINON
		// Sinon, essayer de sérialiser
		sDonnees est une chaîne = ChaîneConstruit([" "idLigne":%1], stDonnees)
		sJSON += sDonnees
	FIN
	
	sJSON += "}"
FIN

sJSON += "}"

Trace("📤 Envoi JSON : " + sJSON)

// Envoyer selon le rôle
SI gbEstServeur = Vrai ALORS
	// ═══════════════════════════════════════════════════════════
	// MODE SERVEUR : Broadcaster à tous les clients connectés
	// ═══════════════════════════════════════════════════════════
	POUR TOUT sNomClient DE gtabClientsConnectes
		SI SocketEcrit(sNomClient, sJSON) = Faux ALORS
			// Client déconnecté, le retirer de la liste
			nIndice est un entier = TableauCherche(gtabClientsConnectes, asLigne, sNomClient)
			SI nIndice > 0 ALORS
				Supprime(gtabClientsConnectes, nIndice)
			FIN
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

// Lire les messages du client en mode callback
SocketChangeModeTransmission(sNomClient, SocketSansMarqueurFin)
SocketLit(sNomClient, Vrai, Socket_MessageClient, sNomClient)

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

Trace("📨 Message brut de client : " + sMessage)

// Parser le message JSON manuellement
sAction est une chaîne = ExtraitChaîne(sMessage, 2, [" "action":""], [" ","])
sUser est une chaîne = ExtraitChaîne(sMessage, 2, [" "user":""], [" ","])
sIDLigne est une chaîne = ExtraitChaîne(sMessage, 2, [" "idLigne":"], "}")
nIDLigne est un entier = Val(sIDLigne)

Trace("📨 Message de " + sUser + " : " + sAction + " (ligne " + nIDLigne + ")")

// ═══════════════════════════════════════════════════════════════
// BROADCASTER À TOUS LES AUTRES CLIENTS
// ═══════════════════════════════════════════════════════════════
POUR TOUT sAutreClient DE gtabClientsConnectes
	SI sAutreClient <> sNomClient ALORS
		SI SocketEcrit(sAutreClient, sMessage) = Faux ALORS
			// Client déconnecté, le retirer de la liste
			nIndice est un entier = TableauCherche(gtabClientsConnectes, asLigne, sAutreClient)
			SI nIndice > 0 ALORS
				Supprime(gtabClientsConnectes, nIndice)
			FIN
			SocketFerme(sAutreClient)
		FIN
	FIN
FIN

// ═══════════════════════════════════════════════════════════════
// TRAITER LE MESSAGE LOCALEMENT AUSSI
// (Le serveur est aussi un utilisateur)
// ═══════════════════════════════════════════════════════════════
Socket_TraiterMessage(sAction, sUser, nIDLigne)


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

Trace("📨 Message brut du serveur : " + sMessage)

// Parser le message JSON manuellement
sAction est une chaîne = ExtraitChaîne(sMessage, 2, [" "action":""], [" ","])
sUser est une chaîne = ExtraitChaîne(sMessage, 2, [" "user":""], [" ","])
sIDLigne est une chaîne = ExtraitChaîne(sMessage, 2, [" "idLigne":"], "}")
nIDLigne est un entier = Val(sIDLigne)

Trace("📨 Message du serveur : " + sAction + " de " + sUser + " (ligne " + nIDLigne + ")")

// Traiter le message
Socket_TraiterMessage(sAction, sUser, nIDLigne)


// ═══════════════════════════════════════════════════════════════
// PROCÉDURE : TRAITER UN MESSAGE REÇU
// ═══════════════════════════════════════════════════════════════
// 
// Traite un message reçu via socket selon son type d'action
// 
// Paramètres :
//   - sAction : Type d'action
//   - sUser : Nom de l'utilisateur émetteur
//   - nIDLigne : ID de la ligne concernée (0 si non applicable)
// 
// ═══════════════════════════════════════════════════════════════

PROCÉDURE Socket_TraiterMessage(sAction est une chaîne, sUser est une chaîne, nIDLigne est un entier = 0)

// ═══════════════════════════════════════════════════════════════
// IGNORER SES PROPRES MESSAGES
// ═══════════════════════════════════════════════════════════════
SI sUser = gsUtilisateurActuel ALORS
	RETOUR
FIN

// ═══════════════════════════════════════════════════════════════
// TRAITER SELON L'ACTION
// ═══════════════════════════════════════════════════════════════
SELON sAction
	CAS "connect"
		// ───────────────────────────────────────────────────────
		// Un utilisateur s'est connecté
		// ───────────────────────────────────────────────────────
		ToastAffiche("👤 " + sUser + " s'est connecté", toastCourt, cvBas, chCentre)
		
	CAS "disconnect"
		// ───────────────────────────────────────────────────────
		// Un utilisateur s'est déconnecté
		// ───────────────────────────────────────────────────────
		ToastAffiche("👤 " + sUser + " s'est déconnecté", toastCourt, cvBas, chCentre)
		
	CAS "lock"
		// ───────────────────────────────────────────────────────
		// Une ligne a été verrouillée par un autre utilisateur
		// ───────────────────────────────────────────────────────
		Socket_TraiterVerrouillage(nIDLigne, sUser)
		
	CAS "unlock"
		// ───────────────────────────────────────────────────────
		// Une ligne a été déverrouillée par un autre utilisateur
		// ───────────────────────────────────────────────────────
		Socket_TraiterDeverrouillage(nIDLigne)
		
	CAS "update"
		// ───────────────────────────────────────────────────────
		// Une ligne a été modifiée par un autre utilisateur
		// ───────────────────────────────────────────────────────
		Socket_TraiterMiseAJour(nIDLigne, sUser)
		
	AUTRE CAS
		// ───────────────────────────────────────────────────────
		// Action inconnue
		// ───────────────────────────────────────────────────────
		Trace("⚠️ Action socket inconnue : " + sAction)
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
		TableAffiche(TABLE_Prod_TL21, taLigneAffichée, i)
		
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
		TableAffiche(TABLE_Prod_TL21, taLigneAffichée, i)
		
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
