procédure EnregistrerLigneModifiee()

// ═══════════════════════════════════════════════════════════════
// VÉRIFIER QU'UNE LIGNE EST SÉLECTIONNÉE
// ═══════════════════════════════════════════════════════════════
si TABLE_Prod_TL21 <= 0 alors retour

// ═══════════════════════════════════════════════════════════════
// MÉMORISER LA POSITION ET L'ID AVANT MODIFICATION
// ═══════════════════════════════════════════════════════════════
nPositionActuelle est un entier = TableSelect(TABLE_Prod_TL21)
nIDActuel est un entier = TABLE_Prod_TL21.COL_ID

// ═══════════════════════════════════════════════════════════════
// ENCAPSULER LA MODIFICATION POUR HSurveille
// ═══════════════════════════════════════════════════════════════
gbModificationParMoiMeme = Vrai

// ═══════════════════════════════════════════════════════════════
// LIRE L'ENREGISTREMENT DANS LA BASE
// ═══════════════════════════════════════════════════════════════
si HLitRecherchePremier(Prod_TL21, IDProd_TL21, nIDActuel) = Faux alors
	gbModificationParMoiMeme = Faux
	Erreur("❌ Enregistrement introuvable", "ID : " + nIDActuel)
	retour
fin

// ═══════════════════════════════════════════════════════════════
// METTRE À JOUR TOUS LES CHAMPS DEPUIS LA TABLE
// ═══════════════════════════════════════════════════════════════

// ───────────────────────────────────────────────────────────────
// Champs de base
// ───────────────────────────────────────────────────────────────
Prod_TL21.Date = TABLE_Prod_TL21.COL_Date
Prod_TL21.Ordre = TABLE_Prod_TL21.COL_Ordre
Prod_TL21.Client = TABLE_Prod_TL21.COL_Client
Prod_TL21.Affaire = TABLE_Prod_TL21.COL_Affaire
Prod_TL21.Commande = TABLE_Prod_TL21.COL_Commande

// ───────────────────────────────────────────────────────────────
// Champs techniques
// ───────────────────────────────────────────────────────────────
Prod_TL21.PIECE = TABLE_Prod_TL21.COL_PIECE
Prod_TL21.DESA = TABLE_Prod_TL21.COL_DESA
Prod_TL21.QTEREST = TABLE_Prod_TL21.COL_QTEREST

// ───────────────────────────────────────────────────────────────
// ✅ AJOUT : Champs couleur et paramètres
// ───────────────────────────────────────────────────────────────
Prod_TL21.Couleur = TABLE_Prod_TL21.COL_Couleur
Prod_TL21.FLAG = TABLE_Prod_TL21.COL_Param
Prod_TL21.R = TABLE_Prod_TL21.COL_R

// ───────────────────────────────────────────────────────────────
// ✅ AJOUT : Balancelle
// ───────────────────────────────────────────────────────────────
Prod_TL21.Balancelle = TABLE_Prod_TL21.COL_Balancelle

// ───────────────────────────────────────────────────────────────
// ✅ AJOUT : Observations
// ───────────────────────────────────────────────────────────────
Prod_TL21.Observations = TABLE_Prod_TL21.COL_Observations

// ───────────────────────────────────────────────────────────────
// ✅ AJOUT : Documents (Doc, Doc1, Doc2, Doc3, Doc4, Doc5)
// ───────────────────────────────────────────────────────────────
Prod_TL21.Doc = TABLE_Prod_TL21.COL_Doc
Prod_TL21.Doc1 = TABLE_Prod_TL21.COL_Doc1
Prod_TL21.Doc2 = TABLE_Prod_TL21.COL_Doc2
Prod_TL21.Doc3 = TABLE_Prod_TL21.COL_Doc3
Prod_TL21.Doc4 = TABLE_Prod_TL21.COL_Doc4
Prod_TL21.Doc5 = TABLE_Prod_TL21.COL_Doc5

// ───────────────────────────────────────────────────────────────
// ✅ AJOUT : Contrôle technique
// ───────────────────────────────────────────────────────────────
Prod_TL21.CT = TABLE_Prod_TL21.COL_CT
Prod_TL21.DetailCT = TABLE_Prod_TL21.COL_DetailCT

// ───────────────────────────────────────────────────────────────
// ✅ AJOUT : Mesures d'épaisseur
// ───────────────────────────────────────────────────────────────
Prod_TL21.Epaisseuravant = TABLE_Prod_TL21.COL_Epaisseuravant
Prod_TL21.Epaisseurapres = TABLE_Prod_TL21.COL_Epaisseurapres

// ───────────────────────────────────────────────────────────────
// ✅ AJOUT : Heures de travail
// ───────────────────────────────────────────────────────────────
Prod_TL21.HSFEreb = TABLE_Prod_TL21.COL_HSFEreb
Prod_TL21.HSFDerb = TABLE_Prod_TL21.COL_HSFDerb
Prod_TL21.HeureVC = TABLE_Prod_TL21.COL_HeureVC

// ───────────────────────────────────────────────────────────────
// ✅ AJOUT : Reprise et vitesse convoyeur
// ───────────────────────────────────────────────────────────────
Prod_TL21.Reprise = TABLE_Prod_TL21.COL_Reprise
Prod_TL21.Vconvoyeur = TABLE_Prod_TL21.COL_Vconvoyeur

// ───────────────────────────────────────────────────────────────
// Champ système (toujours mis à jour)
// ───────────────────────────────────────────────────────────────
Prod_TL21.Modifie_par = gsUtilisateurActuel

// ═══════════════════════════════════════════════════════════════
// ENREGISTRER DANS LA BASE
// ═══════════════════════════════════════════════════════════════
si HModifie(Prod_TL21) = Faux alors
	gbModificationParMoiMeme = Faux
	Erreur("❌ Erreur d'enregistrement", HErreurInfo())
	retour
fin

// ═══════════════════════════════════════════════════════════════
// RAFRAÎCHIR LA TABLE POUR AFFICHER LA NOUVELLE VALEUR
// ═══════════════════════════════════════════════════════════════
TableAffiche(TABLE_Prod_TL21, taRéExécuteRequete)
TableTrie(TABLE_Prod_TL21, "+COL_Ordre")

// ═══════════════════════════════════════════════════════════════
// RESTAURER LA POSITION SUR LA MÊME LIGNE (par ID)
// ═══════════════════════════════════════════════════════════════
si nIDActuel > 0 alors
	pour i = 1 à TableOccurrence(TABLE_Prod_TL21)
		si TABLE_Prod_TL21.COL_ID[i] = nIDActuel alors
			TableSelectPlus(TABLE_Prod_TL21, i)
			
			HExécuteRequête(REQ_SansNom_Julien_TL211, hRequêteDéfaut, SAI_DatePrevi)
			TableAffiche(TABLE_Prod_TL21, taRéExécuteRequete)

			// ✅ FORCER LE RAFRAÎCHISSEMENT DE LA LIGNE
			TableAffiche(TABLE_Prod_TL21, i)

			sortir
		fin
	fin
fin

// ═══════════════════════════════════════════════════════════════
// LIBÉRER L'ENCAPSULATION APRÈS LE RAFRAÎCHISSEMENT
// ═══════════════════════════════════════════════════════════════
gbModificationParMoiMeme = Faux

// ═══════════════════════════════════════════════════════════════
// CONFIRMATION VISUELLE
// ═══════════════════════════════════════════════════════════════
ToastAffiche("✓ Enregistré", toastCourt, cvBas, chCentre)
