// ═══════════════════════════════════════════════════════════════
// ÉVÉNEMENT : SORTIE DE SAISIE D'UNE LIGNE (VERSION SOCKET CORRIGÉE)
// ═══════════════════════════════════════════════════════════════
// 
// VERSION : 2.0.1 - Corrections syntaxe WinDev
// ═══════════════════════════════════════════════════════════════

// Récupérer l'ID de la ligne avant l'enregistrement
nIDLigne est un entier = TABLE_Prod_TL21.COL_ID


// ═══════════════════════════════════════════════════════════════
// ÉTAPE 1 : ENREGISTRER LA LIGNE MODIFIÉE
// ═══════════════════════════════════════════════════════════════

EnregistrerLigneModifiee()


// ═══════════════════════════════════════════════════════════════
// ÉTAPE 2 : LIBÉRER LE VERROU HFSQL
// ═══════════════════════════════════════════════════════════════

SI gnIDLigneEnCoursDeModification <> 0 ALORS
	HDébloqueNumEnr(Prod_TL21, hNumEnrEnCours)
	gnIDLigneEnCoursDeModification = 0
FIN


// ═══════════════════════════════════════════════════════════════
// ÉTAPE 3 : LIBÉRER LE CHAMP Modifie_par
// ═══════════════════════════════════════════════════════════════

gbSaisieEnCours = Faux

SI TABLE_Prod_TL21 > 0 ALORS
	nIDActuel est un entier = TABLE_Prod_TL21.COL_ID
	
	SI HLitRecherchePremier(Prod_TL21, IDProd_TL21, nIDActuel) ALORS
		SI Prod_TL21.Modifie_par = gsUtilisateurActuel ALORS
			gbModificationParMoiMeme = Vrai
			Prod_TL21.Modifie_par = ""
			HModifie(Prod_TL21)
			gbModificationParMoiMeme = Faux
			gnNombreModifications = 0
		FIN
	FIN
FIN


// ═══════════════════════════════════════════════════════════════
// ÉTAPE 4 : NOTIFIER LE DÉVERROUILLAGE VIA SOCKET
// ═══════════════════════════════════════════════════════════════

Socket_Envoyer("unlock", nIDLigne)

Trace("🔓 Déverrouillage de la ligne " + nIDLigne + " notifié")


// ═══════════════════════════════════════════════════════════════
// ÉTAPE 5 : NOTIFIER LA MISE À JOUR VIA SOCKET
// ═══════════════════════════════════════════════════════════════

Socket_Envoyer("update", nIDLigne)

Trace("📝 Mise à jour de la ligne " + nIDLigne + " notifiée")


// ═══════════════════════════════════════════════════════════════
// ÉTAPE 6 : ACTUALISER SI NÉCESSAIRE
// ═══════════════════════════════════════════════════════════════

SI gbActualisationEnAttente = Vrai ALORS
	gbActualisationEnAttente = Faux
	
	nPositionActuelle est un entier = TableSelect(TABLE_Prod_TL21)
	nIDActuelPos est un entier = 0
	SI nPositionActuelle > 0 ALORS
		nIDActuelPos = TABLE_Prod_TL21.COL_ID[nPositionActuelle]
	FIN
	
	TableAffiche(TABLE_Prod_TL21, taRéExécuteRequete)
	TableTrie(TABLE_Prod_TL21, "+COL_Ordre")
	
	SI nIDActuelPos > 0 ALORS
		POUR i = 1 À TableOccurrence(TABLE_Prod_TL21)
			SI TABLE_Prod_TL21.COL_ID[i] = nIDActuelPos ALORS
				TableSelectPlus(TABLE_Prod_TL21, i)
				SORTIR
			FIN
		FIN
	FIN
	
	ToastAffiche("📥 Données actualisées (" + gnNombreModifications + " modifications)", toastCourt, cvBas, chCentre)
	gnNombreModifications = 0
FIN


// ═══════════════════════════════════════════════════════════════
// NOTES
// ═══════════════════════════════════════════════════════════════
// 
// Séquence :
// 1. User A sort de la ligne (enregistrement)
// 2. EnregistrerLigneModifiee() sauvegarde dans HFSQL
// 3. Socket_Envoyer("unlock", nIDLigne) notifie le déverrouillage
// 4. Socket_Envoyer("update", nIDLigne) notifie la mise à jour
// 5. User B reçoit les messages et rafraîchit sa table
// 
// Avantages :
// - Notification instantanée (< 50ms)
// - Pas de polling HFSQL
// - Contrôle total sur les messages
// 
// ═══════════════════════════════════════════════════════════════
