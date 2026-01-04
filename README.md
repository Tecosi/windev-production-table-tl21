# 🚀 WinDev Production Table TL21

Application de gestion de production multi-utilisateurs avec synchronisation temps réel pour WinDev.

## 📋 Description

Cette application WinDev permet de gérer une table de production (`TABLE_Prod_TL21`) avec les fonctionnalités suivantes :

- ✅ **Édition multi-utilisateurs simultanée** avec verrouillage des enregistrements
- ✅ **Synchronisation temps réel** via HSurveille
- ✅ **Préservation de la saisie** lors des rafraîchissements
- ✅ **Gestion des conflits** d'édition entre utilisateurs
- ✅ **Réorganisation des lignes** avec boutons UP/DOWN
- ✅ **Ajout de nouvelles lignes** avec numérotation automatique

## 🎯 Problème Résolu

### Avant
Quand **User A** enregistrait une modification, **User B** perdait le focus de sa cellule et sa saisie en cours était perdue.

### Après
**User B** reste dans sa cellule, voit les changements de **User A** en temps réel, et sa saisie est préservée.

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    TABLE_Prod_TL21                          │
│  (26 colonnes éditables + gestion multi-utilisateurs)       │
└─────────────────────────────────────────────────────────────┘
                            │
        ┌───────────────────┼───────────────────┐
        │                   │                   │
        ▼                   ▼                   ▼
┌──────────────┐   ┌──────────────┐   ┌──────────────┐
│   User A     │   │   User B     │   │   User C     │
│              │   │              │   │              │
│ Édite ligne 1│   │ Édite ligne 2│   │ Édite ligne 3│
└──────────────┘   └──────────────┘   └──────────────┘
        │                   │                   │
        └───────────────────┼───────────────────┘
                            │
                            ▼
                    ┌──────────────┐
                    │  HSurveille  │
                    │ (Sync temps  │
                    │    réel)     │
                    └──────────────┘
                            │
                            ▼
                    ┌──────────────┐
                    │ Base HFSQL   │
                    │  Prod_TL21   │
                    └──────────────┘
```

## 📂 Structure du Dépôt

```
windev-production-table-tl21/
├── README.md                          # Ce fichier
├── docs/
│   ├── GUIDE_IMPLEMENTATION.md        # Guide d'implémentation complet
│   ├── ARCHITECTURE.md                # Architecture détaillée
│   ├── DATABASE_SCHEMA.md             # Schéma de la base de données
│   └── TROUBLESHOOTING.md             # Résolution de problèmes
├── procedures/
│   ├── EnregistrerLigneModifiee.wl    # Sauvegarde d'une ligne
│   ├── VerrouillerLignePourSaisie.wl  # Verrouillage d'enregistrement
│   ├── MemoriserPositionSaisie.wl     # Mémorisation de position
│   └── RestaurationPositionSaisie.wl  # Restauration de position
├── events/
│   ├── table_sortie_ligne.wl          # Événement sortie de ligne
│   ├── table_entree_colonne.wl        # Événement entrée colonne
│   ├── table_sortie_colonne.wl        # Événement sortie colonne
│   └── hsurveille_callback.wl         # Callback HSurveille
├── variables/
│   └── global_variables.wl            # Variables globales
├── examples/
│   └── complete_implementation.wl     # Exemple complet
└── CHANGELOG.md                       # Historique des modifications
```

## 🚀 Installation Rapide

### Prérequis

- WinDev 28 ou supérieur
- Base de données HFSQL (Classic ou Client/Server)
- Table `Prod_TL21` créée

### Étapes d'Installation

1. **Cloner le dépôt**
   ```bash
   git clone https://github.com/VOTRE_USERNAME/windev-production-table-tl21.git
   ```

2. **Copier les fichiers dans votre projet WinDev**

3. **Suivre le guide d'implémentation**
   - Voir [`docs/GUIDE_IMPLEMENTATION.md`](docs/GUIDE_IMPLEMENTATION.md)

4. **Tester avec plusieurs utilisateurs**

## 📖 Documentation

### Guides Principaux

- 📘 [**Guide d'Implémentation**](docs/GUIDE_IMPLEMENTATION.md) - Instructions étape par étape
- 🏗️ [**Architecture**](docs/ARCHITECTURE.md) - Architecture technique détaillée
- 🗄️ [**Schéma de Base de Données**](docs/DATABASE_SCHEMA.md) - Structure de la table Prod_TL21
- 🔧 [**Résolution de Problèmes**](docs/TROUBLESHOOTING.md) - Solutions aux problèmes courants

### Procédures

| Procédure | Description | Fichier |
|-----------|-------------|---------|
| `EnregistrerLigneModifiee()` | Sauvegarde une ligne modifiée avec ses 29 champs | [procedures/EnregistrerLigneModifiee.wl](procedures/EnregistrerLigneModifiee.wl) |
| `VerrouillerLignePourSaisie()` | Verrouille un enregistrement pour édition | [procedures/VerrouillerLignePourSaisie.wl](procedures/VerrouillerLignePourSaisie.wl) |
| `MemoriserPositionSaisie()` | Mémorise la position du curseur avant rafraîchissement | [procedures/MemoriserPositionSaisie.wl](procedures/MemoriserPositionSaisie.wl) |
| `RestaurationPositionSaisie()` | Restaure la position du curseur après rafraîchissement | [procedures/RestaurationPositionSaisie.wl](procedures/RestaurationPositionSaisie.wl) |

## 🎯 Fonctionnalités

### ✅ Gestion Multi-Utilisateurs

- **Verrouillage automatique** : Quand un utilisateur entre dans une cellule, l'enregistrement est verrouillé
- **Indicateur visuel** : Le champ `Modifie_par` affiche qui édite la ligne
- **Libération automatique** : Le verrou est libéré à la sortie de la ligne

### ✅ Synchronisation Temps Réel

- **HSurveille** : Détecte les modifications des autres utilisateurs
- **Rafraîchissement intelligent** : Ne rafraîchit pas si un utilisateur est en saisie
- **Actualisation différée** : Les modifications sont appliquées après la saisie

### ✅ Préservation de la Saisie

- **Mémorisation** : Position, colonne et contenu sont mémorisés avant rafraîchissement
- **Restauration** : L'utilisateur est replacé dans sa cellule avec son contenu intact
- **Pas d'interruption** : L'utilisateur peut continuer à saisir sans être dérangé

### ✅ Gestion des Colonnes

26 colonnes éditables :
- **Informations client** : Client, Affaire, Commande
- **Détails technique** : PIECE, DESA, QTEREST, Couleur, R, Balancelle
- **Documents** : Doc, Doc1, Doc2, Doc3, Doc4, Doc5
- **Mesures** : CT, DetailCT, Epaisseuravant, Epaisseurapres
- **Heures** : HSFEreb, HSFDerb, HeureVC
- **Autres** : Observations, Reprise, Vconvoyeur

## 🧪 Tests

### Scénario de Test Multi-Utilisateurs

1. **User A** ouvre la fenêtre et entre dans une cellule de la ligne 1
2. **User B** ouvre la fenêtre et entre dans une cellule de la ligne 2
3. **User B** commence à saisir "TEST" dans COL_Client
4. **User A** sort de sa ligne (enregistrement)
5. **Vérification** : User B doit :
   - ✅ Rester dans COL_Client de la ligne 2
   - ✅ Voir "TEST" toujours affiché
   - ✅ Voir les changements de User A dans la ligne 1

## ⚠️ Limitations Connues

1. **Position du curseur** : WinDev ne permet pas de restaurer la position exacte du curseur dans le texte (limitation technique)
2. **Contenu restauré** : Le curseur est placé à la fin du texte après restauration

## 🛠️ Technologies

- **Langage** : WLanguage (WinDev)
- **Base de données** : HFSQL (Classic ou Client/Server)
- **Synchronisation** : HSurveille
- **Verrouillage** : Double niveau (HFSQL + application)

## 📊 Schéma de Base de Données

La table `Prod_TL21` contient **29 champs** :

| Champ | Type | Description |
|-------|------|-------------|
| `IDProd_TL21` | Entier | Identifiant unique (clé primaire) |
| `Ordre` | Entier | Ordre d'affichage dans la table |
| `Client` | Chaîne | Nom du client |
| `Affaire` | Chaîne | Numéro d'affaire |
| `Commande` | Chaîne | Numéro de commande |
| ... | ... | *Voir [DATABASE_SCHEMA.md](docs/DATABASE_SCHEMA.md) pour la liste complète* |
| `Modifie_par` | Chaîne | Utilisateur en cours d'édition |

## 🤝 Contribution

Les contributions sont les bienvenues ! Pour contribuer :

1. Forkez le projet
2. Créez une branche (`git checkout -b feature/AmazingFeature`)
3. Committez vos changements (`git commit -m 'Add some AmazingFeature'`)
4. Poussez vers la branche (`git push origin feature/AmazingFeature`)
5. Ouvrez une Pull Request

## 📝 Changelog

Voir [CHANGELOG.md](CHANGELOG.md) pour l'historique des modifications.

## 📄 Licence

Ce projet est sous licence MIT. Voir le fichier `LICENSE` pour plus de détails.

## 👤 Auteur

Développé avec ❤️ pour la communauté WinDev

## 🙏 Remerciements

- Communauté WinDev pour le support
- PC SOFT pour WinDev et HFSQL

## 📞 Support

Pour toute question ou problème :
- 📖 Consultez la [documentation](docs/)
- 🐛 Ouvrez une [issue](https://github.com/VOTRE_USERNAME/windev-production-table-tl21/issues)
- 💬 Participez aux [discussions](https://github.com/VOTRE_USERNAME/windev-production-table-tl21/discussions)

---

**⭐ Si ce projet vous aide, n'hésitez pas à lui donner une étoile !**
