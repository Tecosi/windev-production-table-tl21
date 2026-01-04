# 🎯 GUIDE D'IMPLÉMENTATION : SAISIE SIMULTANÉE MULTI-UTILISATEURS

## 📋 Table des Matières

1. [Vue d'ensemble](#vue-densemble)
2. [Étape 1 : Déclarer les variables globales](#étape-1--déclarer-les-variables-globales)
3. [Étape 2 : Ajouter les procédures locales](#étape-2--ajouter-les-procédures-locales)
4. [Étape 3 : Modifier la procédure HSurveille](#étape-3--modifier-la-procédure-hsurveille)
5. [Étape 4 : Modifier les événements de la table](#étape-4--modifier-les-événements-de-la-table)
6. [Étape 5 : Modifier les événements des colonnes](#étape-5--modifier-les-événements-des-colonnes)
7. [Résumé des modifications](#résumé-des-modifications)
8. [Test de la solution](#test-de-la-solution)

---

## 🎯 Vue d'ensemble

### Problème à Résoudre

Quand **User A** enregistre une ligne pendant que **User B** est en train de saisir :
- ❌ **Avant** : User B perd le focus et sa saisie est perdue
- ✅ **Après** : User B reste dans sa cellule, voit les changements de User A, et sa saisie est préservée

### Solution Implémentée

1. **Mémorisation** : Avant le rafraîchissement, on mémorise la ligne, la colonne et le contenu en cours de saisie
2. **Rafraîchissement** : La table est rafraîchie pour afficher les changements de User A
3. **Restauration** : User B est replacé dans sa cellule avec son contenu restauré

---

## 📝 Étape 1 : Déclarer les Variables Globales

### Où ?

Dans le **code de déclaration de la fenêtre** :
1. Ouvrez la fenêtre dans l'éditeur
2. Appuyez sur **F2** (ou clic droit → Code)
3. Sélectionnez **"Déclarations globales de [NomFenêtre]"**

### Code à Ajouter

```wlangage
// ═══════════════════════════════════════════════════════════════
// VARIABLES GLOBALES DE LA FENÊTRE
// ═══════════════════════════════════════════════════════════════

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
```

---

## 🔧 Étape 2 : Ajouter les Procédures Locales

### Où ?

Dans les **procédures locales de la fenêtre** :
1. Dans l'éditeur de code, dans le volet de gauche
2. Faites un **clic droit** sur le nom de la fenêtre
3. Sélectionnez **"Nouvelle procédure locale"**

### Procédure 1 : MemoriserPositionSaisie

Créez une nouvelle procédure locale nommée **`MemoriserPositionSaisie`** et copiez ce code :

```wlangage
PROCÉDURE MemoriserPositionSaisie()
// ───────────────────────────────────────────────────────────────
// Mémorise la ligne, la colonne, le contenu et la position du curseur
// ───────────────────────────────────────────────────────────────

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
		
		// Mémoriser la longueur du texte (approximation de la position du curseur)
		gnPositionCurseur = Taille(gsContenuCelluleEnCours)
	FIN
FIN
```

### Procédure 2 : RestaurationPositionSaisie

Créez une nouvelle procédure locale nommée **`RestaurationPositionSaisie`** et copiez ce code :

```wlangage
PROCÉDURE RestaurationPositionSaisie()
// ───────────────────────────────────────────────────────────────
// Restaure la ligne, la colonne, le contenu et la position du curseur
// ───────────────────────────────────────────────────────────────

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
```

---

## 🔄 Étape 3 : Modifier la Procédure HSurveille

### Où ?

Dans la procédure **`HSurveille_Callback`** (ou le nom que vous avez donné à votre callback HSurveille).

### Code à Remplacer

**Remplacez TOUT le code** de la procédure par :

```wlangage
PROCÉDURE HSurveille_Callback(NomFichier, Action)
// ───────────────────────────────────────────────────────────────
// Callback appelé par HSurveille quand un autre utilisateur modifie la base
// ───────────────────────────────────────────────────────────────

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
```

---

## 📊 Étape 4 : Modifier les Événements de la Table

### Événement : "Sortie de saisie d'une ligne de TABLE_Prod_TL21"

**Où ?**
1. Clic droit sur **TABLE_Prod_TL21** → **Code**
2. Sélectionnez **"Sortie de saisie d'une ligne de TABLE_Prod_TL21"**

**Code à Mettre :**

```wlangage
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
```

---

## 📝 Étape 5 : Modifier les Événements des Colonnes

### Pour CHAQUE Colonne Éditable (26 colonnes)

Liste des colonnes :
- COL_Client
- COL_Affaire
- COL_Commande
- COL_PIECE
- COL_DESA
- COL_QTEREST
- COL_Couleur
- COL_R
- COL_Balancelle
- COL_Observations
- COL_Doc
- COL_Doc1
- COL_Doc2
- COL_Doc3
- COL_Doc4
- COL_Doc5
- COL_CT
- COL_DetailCT
- COL_Epaisseuravant
- COL_Epaisseurapres
- COL_HSFEreb
- COL_HSFDerb
- COL_HeureVC
- COL_Reprise
- COL_Vconvoyeur

### Événement : "Entrée dans COL_xxx"

**Où ?**
1. Clic droit sur la colonne (ex: **COL_Client**) → **Code**
2. Sélectionnez **"Entrée dans COL_Client"**

**Code à Mettre :**

```wlangage
// ═══════════════════════════════════════════════════════════════
// ÉVÉNEMENT : ENTRÉE DANS COL_Client
// ═══════════════════════════════════════════════════════════════

// ✅ VERROUILLER LA LIGNE
VerrouillerLignePourSaisie()
```

### Événement : "Sortie de COL_xxx"

**Où ?**
1. Clic droit sur la colonne (ex: **COL_Client**) → **Code**
2. Sélectionnez **"Sortie de COL_Client"**

**Code à Mettre :**

```wlangage
// ═══════════════════════════════════════════════════════════════
// ÉVÉNEMENT : SORTIE DE COL_Client
// ═══════════════════════════════════════════════════════════════

// ✅ INDIQUER QUE LA SAISIE EST TERMINÉE
gbSaisieEnCours = Faux
```

**⚠️ Important :** Répétez cette opération pour **TOUTES les 26 colonnes éditables** !

---

## 📊 Résumé des Modifications

| Emplacement | Action | Code |
|-------------|--------|------|
| **Déclarations globales** | Ajouter | 5 nouvelles variables globales |
| **Procédures locales** | Créer | `MemoriserPositionSaisie()` |
| **Procédures locales** | Créer | `RestaurationPositionSaisie()` |
| **HSurveille_Callback** | Remplacer | Nouveau code avec mémorisation/restauration |
| **Sortie de saisie d'une ligne** | Remplacer | Enregistrement + Libération + Actualisation |
| **Entrée dans COL_xxx** (×26) | Ajouter | `VerrouillerLignePourSaisie()` |
| **Sortie de COL_xxx** (×26) | Ajouter | `gbSaisieEnCours = Faux` |

---

## 🧪 Test de la Solution

### Scénario de Test

1. **User A** ouvre la fenêtre et entre dans une cellule de la ligne 1
2. **User B** ouvre la fenêtre et entre dans une cellule de la ligne 2
3. **User B** commence à saisir "TEST" dans COL_Client
4. **User A** sort de sa ligne (enregistrement)
5. **Vérification** : User B doit :
   - ✅ Rester dans COL_Client de la ligne 2
   - ✅ Voir "TEST" toujours affiché
   - ✅ Voir les changements de User A dans la ligne 1

### Résultat Attendu

| Utilisateur | Avant | Après |
|-------------|-------|-------|
| **User A** | Modifie ligne 1 | ✅ Changements enregistrés |
| **User B** | Saisit "TEST" ligne 2 | ✅ Reste dans sa cellule avec "TEST" |

---

## 🎯 Points Clés

### ✅ Ce Qui Fonctionne Maintenant

1. **User B peut saisir pendant que User A enregistre**
2. **User B voit les changements de User A immédiatement**
3. **User B reste dans sa cellule avec sa saisie préservée**
4. **Pas de toast pendant la saisie** (pour ne pas déranger)
5. **Actualisation différée** si personne n'est en saisie

### ⚠️ Limitations

1. **Position du curseur** : WinDev ne permet pas de restaurer la position exacte du curseur dans le texte (limitation technique)
2. **Contenu restauré** : Le contenu est restauré à la fin du texte

---

## 📞 Support

Si vous rencontrez des problèmes :
1. Vérifiez que **toutes les variables globales** sont déclarées
2. Vérifiez que **les deux procédures** sont créées
3. Vérifiez que **les 26 colonnes** ont bien les événements Entrée/Sortie
4. Testez avec **deux utilisateurs simultanés**

---

**Bon courage pour l'implémentation ! 🚀**
