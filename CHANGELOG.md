# Changelog

Tous les changements notables de ce projet seront documentés dans ce fichier.

Le format est basé sur [Keep a Changelog](https://keepachangelog.com/fr/1.0.0/),
et ce projet adhère au [Semantic Versioning](https://semver.org/lang/fr/).

---

## [1.0.0] - 2025-01-04

### ✨ Ajouté

#### Fonctionnalités Principales
- **Gestion multi-utilisateurs** avec verrouillage des enregistrements
- **Synchronisation temps réel** via HSurveille
- **Préservation de la saisie** lors des rafraîchissements
- **Mémorisation et restauration** de la position du curseur
- **Actualisation différée** pour ne pas interrompre la saisie

#### Procédures
- `EnregistrerLigneModifiee()` - Sauvegarde complète d'une ligne avec 29 champs
- `VerrouillerLignePourSaisie()` - Verrouillage double niveau (HFSQL + application)
- `MemoriserPositionSaisie()` - Mémorisation de la position avant rafraîchissement
- `RestaurationPositionSaisie()` - Restauration de la position après rafraîchissement

#### Variables Globales
- `gbModificationParMoiMeme` - Flag d'encapsulation pour HSurveille
- `gbSaisieEnCours` - Indicateur de saisie en cours
- `gbActualisationEnAttente` - Flag d'actualisation différée
- `gnNombreModifications` - Compteur de modifications
- `gsUtilisateurActuel` - Nom de l'utilisateur actuel
- `gnIDLigneEnCoursDeModification` - ID de la ligne verrouillée
- `gnLigneEnCoursDeSaisie` - Numéro de ligne mémorisée
- `gnColonneEnCoursDeSaisie` - Numéro de colonne mémorisée
- `gsContenuCelluleEnCours` - Contenu de la cellule mémorisée
- `gnIDLigneEnCoursDeSaisie` - ID de l'enregistrement mémorisé

#### Événements
- **Entrée dans colonne** - Verrouillage automatique
- **Sortie de colonne** - Désactivation du flag de saisie
- **Sortie de ligne** - Enregistrement et libération des verrous
- **HSurveille_Callback** - Gestion intelligente des rafraîchissements

#### Documentation
- Guide d'implémentation complet
- Architecture technique détaillée
- Schéma de base de données
- README avec instructions d'installation
- Exemples de code

### 🔧 Modifié

#### Gestion des Modifications
- **Avant** : User B perdait le focus et sa saisie lors d'un enregistrement de User A
- **Après** : User B reste dans sa cellule avec sa saisie préservée

#### Synchronisation
- **Avant** : Rafraîchissement immédiat interrompant la saisie
- **Après** : Rafraîchissement différé ou avec restauration de position

#### Verrouillage
- **Avant** : Verrouillage HFSQL uniquement
- **Après** : Double verrouillage (HFSQL + champ `Modifie_par`)

### 🐛 Corrigé

- **Perte de saisie** lors du rafraîchissement de la table
- **Éjection du focus** quand HSurveille se déclenche
- **Boucle infinie** de HSurveille sur ses propres modifications
- **Conflits d'édition** entre utilisateurs simultanés

### 📊 Statistiques

- **29 champs** dans la table Prod_TL21
- **26 colonnes éditables** dans la table WinDev
- **4 procédures** principales
- **10 variables globales**
- **4 événements** de table/colonnes

---

## [Unreleased]

### 🚀 Prévu

#### Fonctionnalités Futures
- Migration vers application web (React + Node.js + MySQL)
- API REST pour accès externe
- Interface d'administration
- Historique des modifications
- Notifications push pour les modifications
- Mode hors ligne avec synchronisation

#### Améliorations
- Restauration exacte de la position du curseur (si WinDev le permet)
- Gestion des conflits d'édition avec fusion intelligente
- Indicateur visuel de verrouillage dans la table
- Timeout automatique des verrous
- Logs d'audit des modifications

#### Optimisations
- Cache local pour réduire les requêtes
- Rafraîchissement partiel (uniquement les lignes modifiées)
- Compression des données pour HSurveille
- Pool de connexions pour HFSQL

---

## Notes de Version

### Version 1.0.0 - Première Release Stable

Cette première version stable résout le problème principal de perte de saisie en mode multi-utilisateurs. La solution implémente un système de mémorisation/restauration de position et une gestion intelligente des rafraîchissements.

**Compatibilité :**
- WinDev 28 ou supérieur
- HFSQL Classic ou Client/Server
- Windows 10/11

**Migration depuis version antérieure :**
- Ajouter les 10 variables globales
- Ajouter les 4 procédures
- Modifier les événements de la table et des 26 colonnes
- Tester en environnement de développement avant production

**Limitations connues :**
- Position du curseur restaurée à la fin du texte (limitation WinDev)
- Pas de gestion de timeout automatique des verrous

---

## Contributeurs

- Développement initial : 2025-01-04
- Documentation : 2025-01-04
- Tests multi-utilisateurs : 2025-01-04

---

**Légende :**
- ✨ Ajouté : Nouvelles fonctionnalités
- 🔧 Modifié : Changements dans les fonctionnalités existantes
- 🐛 Corrigé : Corrections de bugs
- 🚀 Prévu : Fonctionnalités futures
- 📊 Statistiques : Métriques du projet
