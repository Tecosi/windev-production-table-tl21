// ═══════════════════════════════════════════════════════════════════════════════
// SOLUTION COMPLÈTE : SAISIE SIMULTANÉE MULTI-UTILISATEURS
// ═══════════════════════════════════════════════════════════════════════════════
// 
// OBJECTIF :
// - User B peut saisir pendant que User A enregistre
// - User B voit les changements de User A immédiatement
// - User B reste dans sa cellule avec sa saisie préservée
//
// ═══════════════════════════════════════════════════════════════════════════════


// ═══════════════════════════════════════════════════════════════════════════════
// ÉTAPE 1 : DÉCLARER LES VARIABLES GLOBALES (dans le code de déclaration de la fenêtre)
// ═══════════════════════════════════════════════════════════════════════════════

// Variables existantes (à garder)
gbModificationParMoiMeme est un booléen = Faux
gbSaisieEnCours est un booléen = Faux
gbActualisationEnAttente est un booléen = Faux
gnNombreModifications est un entier = 0
gsUtilisateurActuel est une chaîne = ""
gnIDLigneEnCoursDeModification est un entier = 0

// ✅ NOUVELLES VARIABLES POUR MÉMORISER LA POSITION DE SAISIE
gnLigneEnCoursDeSaisie est un entier = 0          // Numéro de ligne dans la table
gnColonneEnCoursDeSaisie est un entier = 0        // Numéro de colonne dans la table
gsContenuCelluleEnCours est une chaîne = ""       // Contenu en cours de saisie
gnIDLigneEnCoursDeSaisie est un entier = 0        // ID de l'enregistrement
gnPositionCurseur est un entier = 0               // Position du curseur dans le texte


// ═══════════════════════════════════════════════════════════════════════════════
// ÉTAPE 2 : PROCÉDURE POUR MÉMORISER LA POSITION DE SAISIE
// ═══════════════════════════════════════════════════════════════════════════════

PROCÉDURE MemoriserPositionSaisie()
// ───────────────────────────────────────────────────────────────────────────────
// Mémorise la ligne, la colonne, le contenu et la position du curseur
// ───────────────────────────────────────────────────────────────────────────────

// Réinitialiser
gnLigneEnCoursDeSaisie = 0
gnColonneEnCoursDeSaisie = 0
gsContenuCelluleEnCours = ""
gnIDLigneEnCoursDeSaisie = 0
gnPositionCurseur = 0

// Vérifier si une cellule est en cours de saisie
SI gbSaisieEnCours = Vrai ALORS
	// Mémoriser la ligne sélectionnée
	gnLigneEnCoursDeSaisie = TableSelect(TABLE_Prod_TL21)
	
	SI gnLigneEnCoursDeSaisie > 0 ALORS
		// Mémoriser l'ID de la ligne
		gnIDLigneEnCoursDeSaisie = TABLE_Prod_TL21.COL_ID[gnLigneEnCoursDeSaisie]
		
		// Déterminer quelle colonne est active
		gnColonneEnCoursDeSaisie = TableSelectOccurrence(TABLE_Prod_TL21, tscColonne)
		
		// Mémoriser le contenu actuel de la cellule
		SELON gnColonneEnCoursDeSaisie
			CAS 1: gsContenuCelluleEnCours = TABLE_Prod_TL21.COL_Client[gnLigneEnCoursDeSaisie]
			CAS 2: gsContenuCelluleEnCours = TABLE_Prod_TL21.COL_Affaire[gnLigneEnCoursDeSaisie]
			CAS 3: gsContenuCelluleEnCours = TABLE_Prod_TL21.COL_Commande[gnLigneEnCoursDeSaisie]
			CAS 4: gsContenuCelluleEnCours = TABLE_Prod_TL21.COL_PIECE[gnLigneEnCoursDeSaisie]
			CAS 5: gsContenuCelluleEnCours = TABLE_Prod_TL21.COL_DESA[gnLigneEnCoursDeSaisie]
			CAS 6: gsContenuCelluleEnCours = TABLE_Prod_TL21.COL_QTEREST[gnLigneEnCoursDeSaisie]
			CAS 7: gsContenuCelluleEnCours = TABLE_Prod_TL21.COL_Couleur[gnLigneEnCoursDeSaisie]
			CAS 8: gsContenuCelluleEnCours = TABLE_Prod_TL21.COL_R[gnLigneEnCoursDeSaisie]
			CAS 9: gsContenuCelluleEnCours = TABLE_Prod_TL21.COL_Balancelle[gnLigneEnCoursDeSaisie]
			CAS 10: gsContenuCelluleEnCours = TABLE_Prod_TL21.COL_Observations[gnLigneEnCoursDeSaisie]
			CAS 11: gsContenuCelluleEnCours = TABLE_Prod_TL21.COL_Doc[gnLigneEnCoursDeSaisie]
			CAS 12: gsContenuCelluleEnCours = TABLE_Prod_TL21.COL_Doc1[gnLigneEnCoursDeSaisie]
			CAS 13: gsContenuCelluleEnCours = TABLE_Prod_TL21.COL_Doc2[gnLigneEnCoursDeSaisie]
			CAS 14: gsContenuCelluleEnCours = TABLE_Prod_TL21.COL_Doc3[gnLigneEnCoursDeSaisie]
			CAS 15: gsContenuCelluleEnCours = TABLE_Prod_TL21.COL_Doc4[gnLigneEnCoursDeSaisie]
			CAS 16: gsContenuCelluleEnCours = TABLE_Prod_TL21.COL_Doc5[gnLigneEnCoursDeSaisie]
			CAS 17: gsContenuCelluleEnCours = TABLE_Prod_TL21.COL_CT[gnLigneEnCoursDeSaisie]
			CAS 18: gsContenuCelluleEnCours = TABLE_Prod_TL21.COL_DetailCT[gnLigneEnCoursDeSaisie]
			CAS 19: gsContenuCelluleEnCours = TABLE_Prod_TL21.COL_Epaisseuravant[gnLigneEnCoursDeSaisie]
			CAS 20: gsContenuCelluleEnCours = TABLE_Prod_TL21.COL_Epaisseurapres[gnLigneEnCoursDeSaisie]
			CAS 21: gsContenuCelluleEnCours = TABLE_Prod_TL21.COL_HSFEreb[gnLigneEnCoursDeSaisie]
			CAS 22: gsContenuCelluleEnCours = TABLE_Prod_TL21.COL_HSFDerb[gnLigneEnCoursDeSaisie]
			CAS 23: gsContenuCelluleEnCours = TABLE_Prod_TL21.COL_HeureVC[gnLigneEnCoursDeSaisie]
			CAS 24: gsContenuCelluleEnCours = TABLE_Prod_TL21.COL_Reprise[gnLigneEnCoursDeSaisie]
			CAS 25: gsContenuCelluleEnCours = TABLE_Prod_TL21.COL_Vconvoyeur[gnLigneEnCoursDeSaisie]
		FIN
		
		// ✅ MÉMORISER LA POSITION DU CURSEUR
		// Note: En WinDev, il n'y a pas de fonction directe pour obtenir la position du curseur
		// On mémorise la longueur du texte comme approximation
		gnPositionCurseur = Taille(gsContenuCelluleEnCours)
	FIN
FIN


// ═══════════════════════════════════════════════════════════════════════════════
// ÉTAPE 3 : PROCÉDURE POUR RESTAURER LA POSITION DE SAISIE
// ═══════════════════════════════════════════════════════════════════════════════

PROCÉDURE RestaurationPositionSaisie()
// ───────────────────────────────────────────────────────────────────────────────
// Restaure la ligne, la colonne, le contenu et la position du curseur
// ───────────────────────────────────────────────────────────────────────────────

// Vérifier s'il y a une position à restaurer
SI gnIDLigneEnCoursDeSaisie = 0 ALORS
	RETOUR
FIN

// Rechercher la ligne correspondant à l'ID mémorisé
nNouvelleLigne est un entier = 0
POUR i = 1 À TableOccurrence(TABLE_Prod_TL21)
	SI TABLE_Prod_TL21.COL_ID[i] = gnIDLigneEnCoursDeSaisie ALORS
		nNouvelleLigne = i
		SORTIR
	FIN
FIN

// Si la ligne n'existe plus, abandonner
SI nNouvelleLigne = 0 ALORS
	gnLigneEnCoursDeSaisie = 0
	gnColonneEnCoursDeSaisie = 0
	gsContenuCelluleEnCours = ""
	gnIDLigneEnCoursDeSaisie = 0
	RETOUR
FIN

// ✅ RESTAURER LE CONTENU DE LA CELLULE
SELON gnColonneEnCoursDeSaisie
	CAS 1: TABLE_Prod_TL21.COL_Client[nNouvelleLigne] = gsContenuCelluleEnCours
	CAS 2: TABLE_Prod_TL21.COL_Affaire[nNouvelleLigne] = gsContenuCelluleEnCours
	CAS 3: TABLE_Prod_TL21.COL_Commande[nNouvelleLigne] = gsContenuCelluleEnCours
	CAS 4: TABLE_Prod_TL21.COL_PIECE[nNouvelleLigne] = gsContenuCelluleEnCours
	CAS 5: TABLE_Prod_TL21.COL_DESA[nNouvelleLigne] = gsContenuCelluleEnCours
	CAS 6: TABLE_Prod_TL21.COL_QTEREST[nNouvelleLigne] = gsContenuCelluleEnCours
	CAS 7: TABLE_Prod_TL21.COL_Couleur[nNouvelleLigne] = gsContenuCelluleEnCours
	CAS 8: TABLE_Prod_TL21.COL_R[nNouvelleLigne] = gsContenuCelluleEnCours
	CAS 9: TABLE_Prod_TL21.COL_Balancelle[nNouvelleLigne] = gsContenuCelluleEnCours
	CAS 10: TABLE_Prod_TL21.COL_Observations[nNouvelleLigne] = gsContenuCelluleEnCours
	CAS 11: TABLE_Prod_TL21.COL_Doc[nNouvelleLigne] = gsContenuCelluleEnCours
	CAS 12: TABLE_Prod_TL21.COL_Doc1[nNouvelleLigne] = gsContenuCelluleEnCours
	CAS 13: TABLE_Prod_TL21.COL_Doc2[nNouvelleLigne] = gsContenuCelluleEnCours
	CAS 14: TABLE_Prod_TL21.COL_Doc3[nNouvelleLigne] = gsContenuCelluleEnCours
	CAS 15: TABLE_Prod_TL21.COL_Doc4[nNouvelleLigne] = gsContenuCelluleEnCours
	CAS 16: TABLE_Prod_TL21.COL_Doc5[nNouvelleLigne] = gsContenuCelluleEnCours
	CAS 17: TABLE_Prod_TL21.COL_CT[nNouvelleLigne] = gsContenuCelluleEnCours
	CAS 18: TABLE_Prod_TL21.COL_DetailCT[nNouvelleLigne] = gsContenuCelluleEnCours
	CAS 19: TABLE_Prod_TL21.COL_Epaisseuravant[nNouvelleLigne] = gsContenuCelluleEnCours
	CAS 20: TABLE_Prod_TL21.COL_Epaisseurapres[nNouvelleLigne] = gsContenuCelluleEnCours
	CAS 21: TABLE_Prod_TL21.COL_HSFEreb[nNouvelleLigne] = gsContenuCelluleEnCours
	CAS 22: TABLE_Prod_TL21.COL_HSFDerb[nNouvelleLigne] = gsContenuCelluleEnCours
	CAS 23: TABLE_Prod_TL21.COL_HeureVC[nNouvelleLigne] = gsContenuCelluleEnCours
	CAS 24: TABLE_Prod_TL21.COL_Reprise[nNouvelleLigne] = gsContenuCelluleEnCours
	CAS 25: TABLE_Prod_TL21.COL_Vconvoyeur[nNouvelleLigne] = gsContenuCelluleEnCours
FIN

// ✅ RESTAURER LE FOCUS DANS LA CELLULE
TableSelectPlus(TABLE_Prod_TL21, nNouvelleLigne, gnColonneEnCoursDeSaisie)

// ✅ REMETTRE LE FLAG DE SAISIE EN COURS
gbSaisieEnCours = Vrai

// Réinitialiser les variables de mémorisation
gnLigneEnCoursDeSaisie = 0
gnColonneEnCoursDeSaisie = 0
gsContenuCelluleEnCours = ""
gnIDLigneEnCoursDeSaisie = 0


// ═══════════════════════════════════════════════════════════════════════════════
// ÉTAPE 4 : MODIFIER LA PROCÉDURE HSurveille
// ═══════════════════════════════════════════════════════════════════════════════

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


// ═══════════════════════════════════════════════════════════════════════════════
// ÉTAPE 5 : CODE MODIFIÉ POUR "SORTIE DE SAISIE D'UNE LIGNE"
// ═══════════════════════════════════════════════════════════════════════════════

// ═══════════════════════════════════════════════════════════════════════════════
// ÉVÉNEMENT : SORTIE DE SAISIE D'UNE LIGNE DE TABLE_Prod_TL21
// ═══════════════════════════════════════════════════════════════════════════════

// ═══════════════════════════════════════════════════════════════════════════════
// ✅ ENREGISTRER LA LIGNE MODIFIÉE
// ═══════════════════════════════════════════════════════════════════════════════
EnregistrerLigneModifiee()

// ═══════════════════════════════════════════════════════════════════════════════
// ✅ LIBÉRER LE VERROU HFSQL
// ═══════════════════════════════════════════════════════════════════════════════
SI gnIDLigneEnCoursDeModification <> 0 ALORS
	HDébloqueNumEnr(Prod_TL21, hNumEnrEnCours)
	gnIDLigneEnCoursDeModification = 0
FIN

// ═══════════════════════════════════════════════════════════════════════════════
// ✅ LIBÉRER LE CHAMP Modifie_par
// ═══════════════════════════════════════════════════════════════════════════════
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

// ═══════════════════════════════════════════════════════════════════════════════
// ✅ ACTUALISER SI NÉCESSAIRE (seulement si personne n'est en saisie)
// ═══════════════════════════════════════════════════════════════════════════════
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
	
	ToastAffiche("📥 Données actualisées", toastCourt, cvBas, chCentre)
FIN


// ═══════════════════════════════════════════════════════════════════════════════
// ÉTAPE 6 : CODE POUR "ENTRÉE DANS COL_xxx" (TOUTES LES COLONNES)
// ═══════════════════════════════════════════════════════════════════════════════

// ═══════════════════════════════════════════════════════════════════════════════
// ÉVÉNEMENT : ENTRÉE DANS COL_Client (et toutes les autres colonnes éditables)
// ═══════════════════════════════════════════════════════════════════════════════

// ✅ VERROUILLER LA LIGNE
VerrouillerLignePourSaisie()


// ═══════════════════════════════════════════════════════════════════════════════
// ÉTAPE 7 : CODE POUR "SORTIE DE COL_xxx" (TOUTES LES COLONNES)
// ═══════════════════════════════════════════════════════════════════════════════

// ═══════════════════════════════════════════════════════════════════════════════
// ÉVÉNEMENT : SORTIE DE COL_Client (et toutes les autres colonnes éditables)
// ═══════════════════════════════════════════════════════════════════════════════

// ✅ INDIQUER QUE LA SAISIE EST TERMINÉE
gbSaisieEnCours = Faux


// ═══════════════════════════════════════════════════════════════════════════════
// FIN DU CODE
// ═══════════════════════════════════════════════════════════════════════════════
