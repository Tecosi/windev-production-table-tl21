PROCÉDURE HSurveille_Callback(NomFichier, Action)
// ───────────────────────────────────────────────────────────────────────────────
// Callback appelé par HSurveille quand un autre utilisateur modifie la base
// ───────────────────────────────────────────────────────────────────────────────

// ✅ IGNORER SI C'EST MOI-MÊME QUI AI FAIT LA MODIFICATION
SI gbModificationParMoiMeme = Vrai ALORS
	RETOUR
FIN

// ✅ SI UN UTILISATEUR EST EN TRAIN DE SAISIR
SI gbSaisieEnCours = Vrai ALORS
	// ✅ MÉMORISER SA POSITION ET SON CONTENU
	MemoriserPositionSaisie()
	
	// ✅ RAFRAÎCHIR LA TABLE (pour voir les changements de l'autre utilisateur)
	nPositionActuelle est un entier = TableSelect(TABLE_Prod_TL21)
	nIDActuelPos est un entier = 0
	SI nPositionActuelle > 0 ALORS
		nIDActuelPos = TABLE_Prod_TL21.COL_ID[nPositionActuelle]
	FIN
	
	TableAffiche(TABLE_Prod_TL21, taRéExécuteRequete)
	TableTrie(TABLE_Prod_TL21, "+COL_Ordre")
	
	// ✅ RESTAURER LA POSITION ET LE CONTENU
	RestaurationPositionSaisie()
	
	// Pas de toast pour ne pas déranger l'utilisateur en saisie
	RETOUR
FIN

// ✅ SI PERSONNE N'EST EN TRAIN DE SAISIR
// Marquer qu'une actualisation est nécessaire
gbActualisationEnAttente = Vrai
gnNombreModifications++

// Afficher un toast discret
ToastAffiche("📝 Modification détectée (" + gnNombreModifications + ")", toastCourt, cvBas, chCentre)
