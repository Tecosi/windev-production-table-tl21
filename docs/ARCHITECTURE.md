# 🏗️ Architecture Technique

## Vue d'Ensemble

L'application WinDev Production Table TL21 est conçue pour gérer l'édition simultanée multi-utilisateurs d'une table de production avec synchronisation temps réel.

---

## 📊 Diagramme d'Architecture Globale

```
┌─────────────────────────────────────────────────────────────────────┐
│                         COUCHE PRÉSENTATION                          │
│                                                                      │
│  ┌──────────────────────────────────────────────────────────────┐  │
│  │              TABLE_Prod_TL21 (26 colonnes)                   │  │
│  │                                                               │  │
│  │  ┌─────────┐  ┌─────────┐  ┌─────────┐  ┌─────────┐        │  │
│  │  │ COL_    │  │ COL_    │  │ COL_    │  │ COL_    │  ...   │  │
│  │  │ Client  │  │ Affaire │  │ Commande│  │ PIECE   │        │  │
│  │  └─────────┘  └─────────┘  └─────────┘  └─────────┘        │  │
│  │                                                               │  │
│  │  Événements:                                                 │  │
│  │  • Entrée dans colonne → VerrouillerLignePourSaisie()       │  │
│  │  • Sortie de colonne → gbSaisieEnCours = Faux               │  │
│  │  • Sortie de ligne → EnregistrerLigneModifiee()             │  │
│  └──────────────────────────────────────────────────────────────┘  │
│                                                                      │
│  ┌──────────────────────────────────────────────────────────────┐  │
│  │                   Boutons de Contrôle                        │  │
│  │                                                               │  │
│  │  [BTN_UP]  [BTN_DOWN]  [BTN_Ajout]                          │  │
│  └──────────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────────┘
                                  │
                                  ▼
┌─────────────────────────────────────────────────────────────────────┐
│                         COUCHE MÉTIER                                │
│                                                                      │
│  ┌──────────────────────────────────────────────────────────────┐  │
│  │                    Procédures Métier                         │  │
│  │                                                               │  │
│  │  • EnregistrerLigneModifiee()                                │  │
│  │  • VerrouillerLignePourSaisie()                              │  │
│  │  • MemoriserPositionSaisie()                                 │  │
│  │  • RestaurationPositionSaisie()                              │  │
│  └──────────────────────────────────────────────────────────────┘  │
│                                                                      │
│  ┌──────────────────────────────────────────────────────────────┐  │
│  │                  Variables Globales                          │  │
│  │                                                               │  │
│  │  • gbModificationParMoiMeme                                  │  │
│  │  • gbSaisieEnCours                                           │  │
│  │  • gbActualisationEnAttente                                  │  │
│  │  • gnNombreModifications                                     │  │
│  │  • gsUtilisateurActuel                                       │  │
│  │  • gnIDLigneEnCoursDeModification                            │  │
│  │  • gnLigneEnCoursDeSaisie                                    │  │
│  │  • gnColonneEnCoursDeSaisie                                  │  │
│  │  • gsContenuCelluleEnCours                                   │  │
│  │  • gnIDLigneEnCoursDeSaisie                                  │  │
│  └──────────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────────┘
                                  │
                                  ▼
┌─────────────────────────────────────────────────────────────────────┐
│                    COUCHE SYNCHRONISATION                            │
│                                                                      │
│  ┌──────────────────────────────────────────────────────────────┐  │
│  │                   HSurveille_Callback()                      │  │
│  │                                                               │  │
│  │  SI gbModificationParMoiMeme ALORS RETOUR                    │  │
│  │                                                               │  │
│  │  SI gbSaisieEnCours ALORS                                    │  │
│  │    → MemoriserPositionSaisie()                               │  │
│  │    → TableAffiche(taRéExécuteRequete)                        │  │
│  │    → RestaurationPositionSaisie()                            │  │
│  │  SINON                                                        │  │
│  │    → gbActualisationEnAttente = Vrai                         │  │
│  │  FIN                                                          │  │
│  └──────────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────────┘
                                  │
                                  ▼
┌─────────────────────────────────────────────────────────────────────┐
│                       COUCHE DONNÉES                                 │
│                                                                      │
│  ┌──────────────────────────────────────────────────────────────┐  │
│  │                    Base HFSQL                                │  │
│  │                                                               │  │
│  │  Table: Prod_TL21                                            │  │
│  │  • 29 champs                                                 │  │
│  │  • Clé primaire: IDProd_TL21                                 │  │
│  │  • Champ de verrouillage: Modifie_par                       │  │
│  │                                                               │  │
│  │  Fonctions HFSQL:                                            │  │
│  │  • HLitRecherchePremier()                                    │  │
│  │  • HModifie()                                                │  │
│  │  • HBloqueNumEnr()                                           │  │
│  │  • HDébloqueNumEnr()                                         │  │
│  │  • HSurveille()                                              │  │
│  └──────────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────────┘
```

---

## 🔄 Flux de Données

### 1. Entrée dans une Cellule

```
User clique sur cellule
         │
         ▼
Événement "Entrée dans COL_xxx"
         │
         ▼
VerrouillerLignePourSaisie()
         │
         ├─→ gbSaisieEnCours = Vrai
         │
         ├─→ HLitRecherchePremier(Prod_TL21, IDProd_TL21, nID)
         │
         ├─→ SI Modifie_par = "" OU Modifie_par = gsUtilisateurActuel
         │   │
         │   ├─→ HBloqueNumEnr(Prod_TL21, hNumEnrEnCours)
         │   │
         │   ├─→ gbModificationParMoiMeme = Vrai
         │   │
         │   ├─→ Prod_TL21.Modifie_par = gsUtilisateurActuel
         │   │
         │   ├─→ HModifie(Prod_TL21)
         │   │
         │   └─→ gbModificationParMoiMeme = Faux
         │
         └─→ SINON
             │
             └─→ ToastAffiche("⚠️ Ligne en cours d'édition par [utilisateur]")
```

### 2. Sortie d'une Cellule

```
User quitte cellule
         │
         ▼
Événement "Sortie de COL_xxx"
         │
         └─→ gbSaisieEnCours = Faux
```

### 3. Sortie d'une Ligne (Enregistrement)

```
User quitte ligne
         │
         ▼
Événement "Sortie de saisie d'une ligne"
         │
         ├─→ EnregistrerLigneModifiee()
         │   │
         │   ├─→ HLitRecherchePremier(Prod_TL21, IDProd_TL21, nID)
         │   │
         │   ├─→ gbModificationParMoiMeme = Vrai
         │   │
         │   ├─→ Prod_TL21.Client = TABLE_Prod_TL21.COL_Client
         │   │   Prod_TL21.Affaire = TABLE_Prod_TL21.COL_Affaire
         │   │   ... (29 champs)
         │   │
         │   ├─→ HModifie(Prod_TL21)
         │   │
         │   └─→ gbModificationParMoiMeme = Faux
         │
         ├─→ HDébloqueNumEnr(Prod_TL21, hNumEnrEnCours)
         │
         ├─→ Prod_TL21.Modifie_par = ""
         │
         └─→ SI gbActualisationEnAttente ALORS
             │
             ├─→ TableAffiche(TABLE_Prod_TL21, taRéExécuteRequete)
             │
             └─→ gbActualisationEnAttente = Faux
```

### 4. Synchronisation HSurveille

```
User A enregistre modification
         │
         ▼
HSurveille détecte changement
         │
         ▼
HSurveille_Callback() appelé chez User B
         │
         ├─→ SI gbModificationParMoiMeme = Vrai
         │   │
         │   └─→ RETOUR (ignorer)
         │
         └─→ SI gbSaisieEnCours = Vrai
             │
             ├─→ MemoriserPositionSaisie()
             │   │
             │   ├─→ gnLigneEnCoursDeSaisie = TableSelect(TABLE_Prod_TL21)
             │   │
             │   ├─→ gnIDLigneEnCoursDeSaisie = TABLE_Prod_TL21.COL_ID
             │   │
             │   ├─→ gnColonneEnCoursDeSaisie = TableSelectOccurrence(..., tscColonne)
             │   │
             │   └─→ gsContenuCelluleEnCours = TABLE_Prod_TL21.COL_xxx
             │
             ├─→ TableAffiche(TABLE_Prod_TL21, taRéExécuteRequete)
             │
             └─→ RestaurationPositionSaisie()
                 │
                 ├─→ Rechercher ligne par ID
                 │
                 ├─→ TABLE_Prod_TL21.COL_xxx[nLigne] = gsContenuCelluleEnCours
                 │
                 ├─→ TableSelectPlus(TABLE_Prod_TL21, nLigne, nColonne)
                 │
                 └─→ gbSaisieEnCours = Vrai
```

---

## 🔐 Mécanisme de Verrouillage

### Double Niveau de Verrouillage

L'application utilise un **double niveau de verrouillage** pour assurer l'intégrité des données :

#### 1. Verrouillage HFSQL (Niveau Base de Données)

```wlangage
HBloqueNumEnr(Prod_TL21, hNumEnrEnCours)
```

**Avantages :**
- ✅ Empêche les modifications concurrentes au niveau de la base
- ✅ Protège contre les conflits d'écriture

**Libération :**
```wlangage
HDébloqueNumEnr(Prod_TL21, hNumEnrEnCours)
```

#### 2. Verrouillage Application (Niveau Interface)

```wlangage
Prod_TL21.Modifie_par = gsUtilisateurActuel
```

**Avantages :**
- ✅ Indicateur visuel pour les autres utilisateurs
- ✅ Permet de savoir qui édite la ligne
- ✅ Peut être affiché dans l'interface

**Libération :**
```wlangage
Prod_TL21.Modifie_par = ""
```

### Tableau Comparatif

| Aspect | Verrouillage HFSQL | Verrouillage Application |
|--------|-------------------|-------------------------|
| **Niveau** | Base de données | Interface utilisateur |
| **Protection** | Conflits d'écriture | Indication visuelle |
| **Visibilité** | Interne | Visible par tous |
| **Libération** | Automatique ou manuelle | Manuelle uniquement |
| **Utilisation** | Technique | UX/UI |

---

## 🧩 Composants Principaux

### 1. Variables Globales

| Variable | Type | Description | Utilisation |
|----------|------|-------------|-------------|
| `gbModificationParMoiMeme` | Booléen | Indique si la modification vient de l'utilisateur actuel | Empêche HSurveille de se déclencher sur ses propres modifications |
| `gbSaisieEnCours` | Booléen | Indique si l'utilisateur est en train de saisir | Empêche le rafraîchissement pendant la saisie |
| `gbActualisationEnAttente` | Booléen | Indique qu'un rafraîchissement est en attente | Applique le rafraîchissement après la saisie |
| `gnNombreModifications` | Entier | Compteur de modifications détectées | Affichage dans les toasts |
| `gsUtilisateurActuel` | Chaîne | Nom de l'utilisateur actuel | Verrouillage et identification |
| `gnIDLigneEnCoursDeModification` | Entier | ID de la ligne verrouillée | Libération du verrou HFSQL |
| `gnLigneEnCoursDeSaisie` | Entier | Numéro de ligne en cours de saisie | Restauration de position |
| `gnColonneEnCoursDeSaisie` | Entier | Numéro de colonne en cours de saisie | Restauration de position |
| `gsContenuCelluleEnCours` | Chaîne | Contenu de la cellule en cours | Restauration du contenu |
| `gnIDLigneEnCoursDeSaisie` | Entier | ID de la ligne en cours de saisie | Recherche après rafraîchissement |

### 2. Procédures

#### EnregistrerLigneModifiee()

**Rôle :** Sauvegarde tous les champs de la ligne modifiée dans la base de données.

**Paramètres :** Aucun (utilise la ligne sélectionnée dans la table)

**Retour :** Aucun

**Encapsulation :** Oui (`gbModificationParMoiMeme = Vrai`)

**Champs sauvegardés :** 29 champs (voir DATABASE_SCHEMA.md)

#### VerrouillerLignePourSaisie()

**Rôle :** Verrouille l'enregistrement pour édition exclusive.

**Paramètres :** Aucun (utilise la ligne sélectionnée dans la table)

**Retour :** Aucun

**Actions :**
1. Active `gbSaisieEnCours`
2. Lit l'enregistrement
3. Vérifie si disponible
4. Bloque avec `HBloqueNumEnr()`
5. Définit `Modifie_par`
6. Affiche un toast si déjà verrouillé

#### MemoriserPositionSaisie()

**Rôle :** Mémorise la position et le contenu avant rafraîchissement.

**Paramètres :** Aucun

**Retour :** Aucun

**Mémorise :**
- Numéro de ligne
- Numéro de colonne
- ID de l'enregistrement
- Contenu de la cellule

#### RestaurationPositionSaisie()

**Rôle :** Restaure la position et le contenu après rafraîchissement.

**Paramètres :** Aucun

**Retour :** Aucun

**Restaure :**
- Recherche la ligne par ID
- Restaure le contenu de la cellule
- Replace le focus dans la cellule
- Réactive `gbSaisieEnCours`

### 3. Événements

#### Entrée dans COL_xxx

**Déclencheur :** User clique dans une cellule

**Action :** Appelle `VerrouillerLignePourSaisie()`

**Fréquence :** À chaque entrée dans une cellule éditable (26 colonnes)

#### Sortie de COL_xxx

**Déclencheur :** User quitte une cellule

**Action :** Désactive `gbSaisieEnCours`

**Fréquence :** À chaque sortie d'une cellule éditable (26 colonnes)

#### Sortie de saisie d'une ligne

**Déclencheur :** User quitte une ligne

**Actions :**
1. Enregistre la ligne
2. Libère le verrou HFSQL
3. Libère le champ `Modifie_par`
4. Applique l'actualisation en attente si nécessaire

**Fréquence :** Une fois par ligne éditée

---

## 🎯 Patterns de Conception Utilisés

### 1. Flag Pattern (Encapsulation)

**Problème :** HSurveille se déclenche sur les propres modifications de l'utilisateur.

**Solution :** Utiliser un flag `gbModificationParMoiMeme` pour encapsuler les modifications.

```wlangage
gbModificationParMoiMeme = Vrai
// Modification
gbModificationParMoiMeme = Faux
```

### 2. Deferred Update Pattern (Actualisation Différée)

**Problème :** Le rafraîchissement interrompt la saisie de l'utilisateur.

**Solution :** Différer l'actualisation jusqu'à la fin de la saisie.

```wlangage
SI gbSaisieEnCours = Vrai ALORS
    gbActualisationEnAttente = Vrai
SINON
    TableAffiche(...)
FIN
```

### 3. Memento Pattern (Mémorisation/Restauration)

**Problème :** Le rafraîchissement fait perdre la position et le contenu.

**Solution :** Mémoriser l'état avant rafraîchissement et le restaurer après.

```wlangage
MemoriserPositionSaisie()
TableAffiche(...)
RestaurationPositionSaisie()
```

### 4. Observer Pattern (HSurveille)

**Problème :** Les utilisateurs ne voient pas les modifications des autres.

**Solution :** HSurveille notifie tous les utilisateurs des changements.

```wlangage
HSurveille(Prod_TL21, HSurveille_Callback)
```

---

## 🔄 Cycle de Vie d'une Modification

```
┌─────────────────────────────────────────────────────────────────┐
│                        User A                                    │
└─────────────────────────────────────────────────────────────────┘
    │
    │ 1. Clique sur cellule
    ▼
┌─────────────────────────────────────────────────────────────────┐
│ Entrée dans COL_Client                                          │
│ → VerrouillerLignePourSaisie()                                  │
│   → gbSaisieEnCours = Vrai                                      │
│   → HBloqueNumEnr()                                             │
│   → Modifie_par = "User A"                                      │
└─────────────────────────────────────────────────────────────────┘
    │
    │ 2. Saisit "Nouveau Client"
    ▼
┌─────────────────────────────────────────────────────────────────┐
│ Sortie de COL_Client                                            │
│ → gbSaisieEnCours = Faux                                        │
└─────────────────────────────────────────────────────────────────┘
    │
    │ 3. Quitte la ligne
    ▼
┌─────────────────────────────────────────────────────────────────┐
│ Sortie de saisie d'une ligne                                    │
│ → EnregistrerLigneModifiee()                                    │
│   → gbModificationParMoiMeme = Vrai                             │
│   → Prod_TL21.Client = "Nouveau Client"                         │
│   → HModifie(Prod_TL21)                                         │
│   → gbModificationParMoiMeme = Faux                             │
│ → HDébloqueNumEnr()                                             │
│ → Modifie_par = ""                                              │
└─────────────────────────────────────────────────────────────────┘
    │
    │ 4. HSurveille détecte changement
    ▼
┌─────────────────────────────────────────────────────────────────┐
│                        User B                                    │
└─────────────────────────────────────────────────────────────────┘
    │
    │ 5. HSurveille_Callback() appelé
    ▼
┌─────────────────────────────────────────────────────────────────┐
│ HSurveille_Callback()                                           │
│ → SI gbModificationParMoiMeme = Faux                            │
│   → SI gbSaisieEnCours = Vrai                                   │
│     → MemoriserPositionSaisie()                                 │
│     → TableAffiche(taRéExécuteRequete)                          │
│     → RestaurationPositionSaisie()                              │
│   SINON                                                          │
│     → gbActualisationEnAttente = Vrai                           │
└─────────────────────────────────────────────────────────────────┘
    │
    │ 6. User B voit "Nouveau Client"
    ▼
┌─────────────────────────────────────────────────────────────────┐
│ Table rafraîchie avec nouvelles données                         │
│ User B reste dans sa cellule si en saisie                       │
└─────────────────────────────────────────────────────────────────┘
```

---

## 📈 Performance et Optimisation

### Optimisations Implémentées

1. **Actualisation conditionnelle** : Ne rafraîchit que si nécessaire
2. **Encapsulation des modifications** : Évite les callbacks inutiles
3. **Verrouillage ciblé** : Verrouille uniquement l'enregistrement en cours
4. **Mémorisation minimale** : Mémorise uniquement les données nécessaires

### Métriques de Performance

| Opération | Temps Estimé | Impact Utilisateur |
|-----------|--------------|-------------------|
| Verrouillage | < 50ms | Imperceptible |
| Enregistrement | < 100ms | Très faible |
| Rafraîchissement | < 200ms | Faible |
| Restauration | < 50ms | Imperceptible |

---

## 🔒 Sécurité

### Gestion des Conflits

1. **Verrouillage optimiste** : Vérifie avant de verrouiller
2. **Toast d'avertissement** : Informe si ligne déjà verrouillée
3. **Libération automatique** : Libère à la sortie de ligne
4. **Double vérification** : HFSQL + Application

### Intégrité des Données

1. **Transaction implicite** : HModifie() est atomique
2. **Encapsulation** : Évite les modifications concurrentes
3. **Validation** : Vérifie l'utilisateur avant libération

---

## 🧪 Tests et Validation

### Scénarios de Test

1. **Test mono-utilisateur** : Vérifier l'enregistrement basique
2. **Test bi-utilisateur** : Vérifier le verrouillage et la synchronisation
3. **Test multi-utilisateur** : Vérifier la scalabilité (3+ utilisateurs)
4. **Test de conflit** : Deux utilisateurs tentent d'éditer la même ligne
5. **Test de déconnexion** : Vérifier la libération des verrous

### Validation

- ✅ Pas de perte de données
- ✅ Pas d'interruption de saisie
- ✅ Synchronisation temps réel
- ✅ Indicateurs visuels corrects
- ✅ Performance acceptable

---

**Dernière mise à jour :** 2025-01-04
