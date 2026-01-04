// ═══════════════════════════════════════════════════════════════
// ÉVÉNEMENT : SORTIE DE SAISIE D'UNE LIGNE DE TABLE_Prod_TL21
// ═══════════════════════════════════════════════════════════════

// ═══════════════════════════════════════════════════════════════
// ✅ ENREGISTRER LA LIGNE MODIFIÉE
// ═══════════════════════════════════════════════════════════════
EnregistrerLigneModifiee()

// ═══════════════════════════════════════════════════════════════
// ✅ LIBÉRER LE VERROU HFSQL
// ═══════════════════════════════════════════════════════════════
SI gnIDLigneEnCoursDeModification <> 0 ALORS
	HDébloqueNumEnr(Prod_TL21, hNumEnrEnCours)
	gnIDLigneEnCoursDeModification = 0
FIN

// ═══════════════════════════════════════════════════════════════
// ✅ LIBÉRER LE CHAMP Modifie_par
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
// ✅ ACTUALISER SI NÉCESSAIRE
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
	
	ToastAffiche("📥 Données actualisées", toastCourt, cvBas, chCentre)
FIN
