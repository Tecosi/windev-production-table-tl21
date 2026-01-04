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
