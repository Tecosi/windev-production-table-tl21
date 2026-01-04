PROCÉDURE VerrouillerLignePourSaisie()
// ───────────────────────────────────────────────────────────────────────────────
// Verrouille l'enregistrement pour édition exclusive
// ───────────────────────────────────────────────────────────────────────────────

// ✅ INDIQUER QU'UNE SAISIE EST EN COURS
gbSaisieEnCours = Vrai

// Vérifier qu'une ligne est sélectionnée
SI TABLE_Prod_TL21 <= 0 ALORS
	RETOUR
FIN

// Récupérer l'ID de la ligne sélectionnée
nIDActuel est un entier = TABLE_Prod_TL21.COL_ID

// Lire l'enregistrement dans la base
SI HLitRecherchePremier(Prod_TL21, IDProd_TL21, nIDActuel) = Faux ALORS
	RETOUR
FIN

// ═══════════════════════════════════════════════════════════════
// VÉRIFIER SI LA LIGNE EST DISPONIBLE
// ═══════════════════════════════════════════════════════════════
SI Prod_TL21.Modifie_par <> "" ET Prod_TL21.Modifie_par <> gsUtilisateurActuel ALORS
	// Ligne déjà verrouillée par un autre utilisateur
	ToastAffiche("⚠️ Ligne en cours d'édition par " + Prod_TL21.Modifie_par, toastCourt, cvBas, chCentre)
	gbSaisieEnCours = Faux
	RETOUR
FIN

// ═══════════════════════════════════════════════════════════════
// VERROUILLER L'ENREGISTREMENT (HFSQL)
// ═══════════════════════════════════════════════════════════════
SI HBloqueNumEnr(Prod_TL21, hNumEnrEnCours) = Faux ALORS
	ToastAffiche("⚠️ Impossible de verrouiller l'enregistrement", toastCourt, cvBas, chCentre)
	gbSaisieEnCours = Faux
	RETOUR
FIN

// Mémoriser l'ID de la ligne verrouillée
gnIDLigneEnCoursDeModification = nIDActuel

// ═══════════════════════════════════════════════════════════════
// DÉFINIR LE CHAMP Modifie_par (VERROUILLAGE APPLICATION)
// ═══════════════════════════════════════════════════════════════
gbModificationParMoiMeme = Vrai

Prod_TL21.Modifie_par = gsUtilisateurActuel
HModifie(Prod_TL21)

gbModificationParMoiMeme = Faux

// Pas de toast pour ne pas déranger l'utilisateur
