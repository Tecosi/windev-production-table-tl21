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
