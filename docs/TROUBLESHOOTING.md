# 🔧 Résolution de Problèmes

Ce guide vous aide à résoudre les problèmes courants rencontrés lors de l'utilisation de l'application WinDev Production Table TL21.

---

## 📋 Table des Matières

1. [Problèmes de Saisie](#problèmes-de-saisie)
2. [Problèmes de Verrouillage](#problèmes-de-verrouillage)
3. [Problèmes de Synchronisation](#problèmes-de-synchronisation)
4. [Problèmes de Performance](#problèmes-de-performance)
5. [Erreurs Courantes](#erreurs-courantes)

---

## 🖊️ Problèmes de Saisie

### Problème : La saisie est perdue lors du rafraîchissement

**Symptômes :**
- User B saisit du texte
- User A enregistre une modification
- User B perd sa saisie

**Causes possibles :**
1. `gbSaisieEnCours` n'est pas défini correctement
2. Les procédures `MemoriserPositionSaisie()` et `RestaurationPositionSaisie()` ne sont pas appelées
3. Le callback HSurveille n'est pas correctement implémenté

**Solutions :**

#### Solution 1 : Vérifier gbSaisieEnCours

```wlangage
// Dans l'événement "Entrée dans COL_xxx"
VerrouillerLignePourSaisie()  // Cette procédure définit gbSaisieEnCours = Vrai

// Dans l'événement "Sortie de COL_xxx"
gbSaisieEnCours = Faux
```

#### Solution 2 : Vérifier le callback HSurveille

```wlangage
PROCÉDURE HSurveille_Callback(NomFichier, Action)
	SI gbModificationParMoiMeme = Vrai ALORS RETOUR
	
	SI gbSaisieEnCours = Vrai ALORS
		MemoriserPositionSaisie()
		TableAffiche(TABLE_Prod_TL21, taRéExécuteRequete)
		RestaurationPositionSaisie()
		RETOUR
	FIN
	
	gbActualisationEnAttente = Vrai
FIN
```

#### Solution 3 : Activer les logs

```wlangage
// Ajouter des logs pour déboguer
Trace("gbSaisieEnCours = " + gbSaisieEnCours)
Trace("gnColonneEnCoursDeSaisie = " + gnColonneEnCoursDeSaisie)
Trace("gsContenuCelluleEnCours = " + gsContenuCelluleEnCours)
```

---

### Problème : Le curseur n'est pas au bon endroit après restauration

**Symptômes :**
- Le contenu est restauré
- Mais le curseur est à la fin du texte

**Cause :**
- Limitation technique de WinDev : pas de fonction pour restaurer la position exacte du curseur

**Solution :**
- Accepter cette limitation
- Le curseur sera toujours placé à la fin du texte après restauration

---

## 🔒 Problèmes de Verrouillage

### Problème : "Ligne en cours d'édition par [utilisateur]" alors que personne n'édite

**Symptômes :**
- Message d'avertissement affiché
- Impossible d'éditer la ligne
- Aucun utilisateur n'est réellement en train d'éditer

**Causes possibles :**
1. Verrou HFSQL non libéré
2. Champ `Modifie_par` non réinitialisé
3. Crash de l'application sans libération du verrou

**Solutions :**

#### Solution 1 : Libérer manuellement le verrou

```wlangage
// Exécuter ce code pour libérer tous les verrous
POUR TOUT Prod_TL21
	SI Prod_TL21.Modifie_par <> "" ALORS
		Prod_TL21.Modifie_par = ""
		HModifie(Prod_TL21)
	FIN
FIN
ToastAffiche("✅ Tous les verrous ont été libérés", toastCourt, cvBas, chCentre)
```

#### Solution 2 : Ajouter un timeout automatique

```wlangage
// Ajouter un champ DateHeureVerrou dans la table
// Libérer automatiquement les verrous de plus de 30 minutes

POUR TOUT Prod_TL21
	SI Prod_TL21.Modifie_par <> "" ALORS
		nMinutesEcoulees est un entier = DateHeureDifférence(Prod_TL21.DateHeureVerrou, DateHeureSys())
		SI nMinutesEcoulees > 30 ALORS
			Prod_TL21.Modifie_par = ""
			HModifie(Prod_TL21)
		FIN
	FIN
FIN
```

#### Solution 3 : Forcer le déverrouillage

```wlangage
// Dans VerrouillerLignePourSaisie(), forcer le déverrouillage
SI Prod_TL21.Modifie_par <> "" ET Prod_TL21.Modifie_par <> gsUtilisateurActuel ALORS
	// Demander confirmation
	SI OuiNon("La ligne est verrouillée par " + Prod_TL21.Modifie_par + ". Forcer le déverrouillage ?") = Oui ALORS
		Prod_TL21.Modifie_par = ""
		HModifie(Prod_TL21)
		// Continuer le verrouillage
	SINON
		gbSaisieEnCours = Faux
		RETOUR
	FIN
FIN
```

---

### Problème : HDébloqueNumEnr ne fonctionne pas

**Symptômes :**
- Erreur lors de l'appel à `HDébloqueNumEnr()`
- Verrou HFSQL non libéré

**Causes possibles :**
1. Mauvais paramètre passé à `HDébloqueNumEnr()`
2. Enregistrement déjà débloqué
3. Connexion HFSQL perdue

**Solutions :**

#### Solution 1 : Vérifier les paramètres

```wlangage
// Correct
HDébloqueNumEnr(Prod_TL21, hNumEnrEnCours)

// Incorrect
HDébloqueNumEnr(Prod_TL21, nID)  // ❌ Ne pas utiliser l'ID
```

#### Solution 2 : Vérifier si l'enregistrement est verrouillé

```wlangage
SI HBloqueNumEnr(Prod_TL21, hNumEnrEnCours) = Vrai ALORS
	// Enregistrement verrouillé, on peut le débloquer
	HDébloqueNumEnr(Prod_TL21, hNumEnrEnCours)
FIN
```

---

## 🔄 Problèmes de Synchronisation

### Problème : HSurveille ne se déclenche pas

**Symptômes :**
- User A enregistre une modification
- User B ne voit pas les changements

**Causes possibles :**
1. HSurveille non activé
2. Callback non défini
3. Base de données non en mode Client/Server

**Solutions :**

#### Solution 1 : Activer HSurveille

```wlangage
// Dans l'événement "Initialisation" de la fenêtre
HSurveille(Prod_TL21, HSurveille_Callback, hFichierModifié)
```

#### Solution 2 : Vérifier le callback

```wlangage
PROCÉDURE HSurveille_Callback(NomFichier, Action)
	Trace("HSurveille déclenché : " + NomFichier + " - " + Action)
	// ... reste du code
FIN
```

#### Solution 3 : Vérifier le mode HFSQL

```wlangage
// HSurveille fonctionne uniquement en mode Client/Server
// Vérifier la connexion
SI HConnexion("MaConnexion", "utilisateur", "motdepasse", "serveur:4900", "MaBase") = Faux ALORS
	Erreur("Impossible de se connecter à HFSQL Client/Server")
FIN
```

---

### Problème : Boucle infinie de HSurveille

**Symptômes :**
- HSurveille se déclenche en boucle
- Performance dégradée
- Application qui freeze

**Cause :**
- `gbModificationParMoiMeme` n'est pas utilisé correctement

**Solution :**

```wlangage
// TOUJOURS encapsuler les modifications
gbModificationParMoiMeme = Vrai
HModifie(Prod_TL21)
gbModificationParMoiMeme = Faux

// Dans le callback
PROCÉDURE HSurveille_Callback(NomFichier, Action)
	SI gbModificationParMoiMeme = Vrai ALORS
		RETOUR  // ✅ Ignorer ses propres modifications
	FIN
	// ... reste du code
FIN
```

---

## ⚡ Problèmes de Performance

### Problème : La table est lente à rafraîchir

**Symptômes :**
- `TableAffiche()` prend plusieurs secondes
- Interface qui freeze

**Causes possibles :**
1. Trop d'enregistrements
2. Requête non optimisée
3. Pas d'index sur les champs

**Solutions :**

#### Solution 1 : Ajouter des index

```wlangage
// Dans l'analyse, ajouter des index sur :
// - IDProd_TL21 (clé primaire)
// - Ordre
// - Modifie_par
```

#### Solution 2 : Limiter le nombre d'enregistrements

```wlangage
// Filtrer par date
HFiltre(Prod_TL21, "Date >= '" + DateSys() - 30 + "'")
TableAffiche(TABLE_Prod_TL21, taRéExécuteRequete)
```

#### Solution 3 : Rafraîchissement partiel

```wlangage
// Au lieu de rafraîchir toute la table
TableAffiche(TABLE_Prod_TL21, taRéExécuteRequete)

// Rafraîchir uniquement la ligne modifiée
TableAfficheLigne(TABLE_Prod_TL21, nNumLigne)
```

---

### Problème : Trop de toasts affichés

**Symptômes :**
- Toasts qui s'accumulent
- Interface encombrée

**Solution :**

```wlangage
// Limiter les toasts dans HSurveille_Callback
SI gbSaisieEnCours = Vrai ALORS
	// Pas de toast pendant la saisie
	RETOUR
FIN

// Afficher un toast seulement toutes les 5 modifications
SI gnNombreModifications MODULO 5 = 0 ALORS
	ToastAffiche("📝 " + gnNombreModifications + " modifications détectées", toastCourt, cvBas, chCentre)
FIN
```

---

## ❌ Erreurs Courantes

### Erreur : "Variable gbModificationParMoiMeme non déclarée"

**Solution :**
Déclarer la variable dans le code de déclaration de la fenêtre :

```wlangage
gbModificationParMoiMeme est un booléen = Faux
```

---

### Erreur : "Enregistrement introuvable"

**Cause :**
L'ID de l'enregistrement n'existe plus dans la base.

**Solution :**

```wlangage
SI HLitRecherchePremier(Prod_TL21, IDProd_TL21, nID) = Faux ALORS
	ToastAffiche("⚠️ Enregistrement supprimé par un autre utilisateur", toastCourt, cvBas, chCentre)
	TableAffiche(TABLE_Prod_TL21, taRéExécuteRequete)
	RETOUR
FIN
```

---

### Erreur : "Impossible de verrouiller l'enregistrement"

**Cause :**
L'enregistrement est déjà verrouillé par un autre utilisateur.

**Solution :**

```wlangage
SI HBloqueNumEnr(Prod_TL21, hNumEnrEnCours) = Faux ALORS
	ToastAffiche("⚠️ Ligne déjà verrouillée", toastCourt, cvBas, chCentre)
	gbSaisieEnCours = Faux
	RETOUR
FIN
```

---

### Erreur : "TableSelectOccurrence retourne 0"

**Cause :**
Aucune colonne n'est sélectionnée.

**Solution :**

```wlangage
gnColonneEnCoursDeSaisie = TableSelectOccurrence(TABLE_Prod_TL21, tscColonne)
SI gnColonneEnCoursDeSaisie = 0 ALORS
	// Pas de colonne sélectionnée, abandonner
	RETOUR
FIN
```

---

## 🧪 Tests et Débogage

### Activer les Logs

```wlangage
// Dans chaque procédure, ajouter des traces
PROCÉDURE VerrouillerLignePourSaisie()
	Trace("=== VerrouillerLignePourSaisie ===")
	Trace("gbSaisieEnCours = " + gbSaisieEnCours)
	Trace("nIDActuel = " + nIDActuel)
	// ... reste du code
FIN
```

### Tester en Mode Mono-Utilisateur

Avant de tester en multi-utilisateurs, vérifier que tout fonctionne en mono-utilisateur :

1. Ouvrir la fenêtre
2. Entrer dans une cellule
3. Modifier le contenu
4. Sortir de la cellule
5. Vérifier que l'enregistrement est sauvegardé

### Tester en Mode Multi-Utilisateurs

1. Ouvrir 2 instances de l'application (2 ordinateurs ou 2 sessions)
2. User A entre dans une cellule de la ligne 1
3. User B entre dans une cellule de la ligne 2
4. User B commence à saisir
5. User A sort de sa ligne (enregistrement)
6. Vérifier que User B reste dans sa cellule avec sa saisie

---

## 📞 Support

Si vous ne trouvez pas de solution à votre problème :

1. Consultez la [documentation](../README.md)
2. Vérifiez le [CHANGELOG](../CHANGELOG.md)
3. Ouvrez une [issue](https://github.com/VOTRE_USERNAME/windev-production-table-tl21/issues)

---

**Dernière mise à jour :** 2025-01-04
