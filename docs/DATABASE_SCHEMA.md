# 🗄️ Schéma de Base de Données

## Table : Prod_TL21

### Description

Table principale de gestion de production contenant les informations sur les commandes, les pièces, les documents et les mesures techniques.

---

## 📊 Structure de la Table

### Vue d'Ensemble

| Propriété | Valeur |
|-----------|--------|
| **Nom** | Prod_TL21 |
| **Type** | HFSQL (Classic ou Client/Server) |
| **Nombre de champs** | 29 |
| **Clé primaire** | IDProd_TL21 |
| **Index** | IDProd_TL21, Ordre |

---

## 📝 Liste Complète des Champs

### 1. Identifiants et Ordre

| Champ | Type | Taille | Description | Contraintes |
|-------|------|--------|-------------|-------------|
| `IDProd_TL21` | Entier | 4 octets | Identifiant unique auto-incrémenté | Clé primaire, Non nul, Auto-incrémenté |
| `Ordre` | Entier | 4 octets | Ordre d'affichage dans la table | Non nul, Défaut: 0 |

### 2. Informations Client et Commande

| Champ | Type | Taille | Description | Contraintes |
|-------|------|--------|-------------|-------------|
| `Client` | Chaîne | 255 | Nom du client | Nullable |
| `Affaire` | Chaîne | 100 | Numéro d'affaire | Nullable |
| `Commande` | Chaîne | 100 | Numéro de commande | Nullable |

### 3. Détails Techniques

| Champ | Type | Taille | Description | Contraintes |
|-------|------|--------|-------------|-------------|
| `PIECE` | Chaîne | 100 | Référence de la pièce | Nullable |
| `DESA` | Chaîne | 100 | Désignation | Nullable |
| `QTEREST` | Entier | 4 octets | Quantité restante | Nullable, Défaut: 0 |
| `Couleur` | Chaîne | 50 | Couleur de la pièce | Nullable |
| `R` | Chaîne | 50 | Référence R | Nullable |
| `Balancelle` | Chaîne | 50 | Numéro de balancelle | Nullable |
| `Observations` | Texte | Illimité | Observations et remarques | Nullable |

### 4. Documents (6 champs)

| Champ | Type | Taille | Description | Contraintes |
|-------|------|--------|-------------|-------------|
| `Doc` | Chaîne | 255 | Document principal | Nullable |
| `Doc1` | Chaîne | 255 | Document 1 | Nullable |
| `Doc2` | Chaîne | 255 | Document 2 | Nullable |
| `Doc3` | Chaîne | 255 | Document 3 | Nullable |
| `Doc4` | Chaîne | 255 | Document 4 | Nullable |
| `Doc5` | Chaîne | 255 | Document 5 | Nullable |

### 5. Contrôle Technique

| Champ | Type | Taille | Description | Contraintes |
|-------|------|--------|-------------|-------------|
| `CT` | Chaîne | 50 | Contrôle technique | Nullable |
| `DetailCT` | Texte | Illimité | Détail du contrôle technique | Nullable |

### 6. Mesures d'Épaisseur

| Champ | Type | Taille | Description | Contraintes |
|-------|------|--------|-------------|-------------|
| `Epaisseuravant` | Réel | 8 octets | Épaisseur avant traitement (mm) | Nullable, Défaut: 0.0 |
| `Epaisseurapres` | Réel | 8 octets | Épaisseur après traitement (mm) | Nullable, Défaut: 0.0 |

### 7. Heures de Travail

| Champ | Type | Taille | Description | Contraintes |
|-------|------|--------|-------------|-------------|
| `HSFEreb` | Réel | 8 octets | Heures SF Éreb | Nullable, Défaut: 0.0 |
| `HSFDerb` | Réel | 8 octets | Heures SF Derb | Nullable, Défaut: 0.0 |
| `HeureVC` | Réel | 8 octets | Heures VC | Nullable, Défaut: 0.0 |

### 8. Autres Informations

| Champ | Type | Taille | Description | Contraintes |
|-------|------|--------|-------------|-------------|
| `Reprise` | Chaîne | 50 | Indicateur de reprise | Nullable |
| `Vconvoyeur` | Réel | 8 octets | Vitesse convoyeur (m/min) | Nullable, Défaut: 0.0 |

### 9. Gestion Multi-Utilisateurs

| Champ | Type | Taille | Description | Contraintes |
|-------|------|--------|-------------|-------------|
| `Modifie_par` | Chaîne | 100 | Nom de l'utilisateur en cours d'édition | Nullable, Défaut: "" |

---

## 🔑 Index et Clés

### Clé Primaire

```sql
PRIMARY KEY (IDProd_TL21)
```

### Index

```sql
INDEX idx_ordre ON Prod_TL21 (Ordre)
INDEX idx_modifie_par ON Prod_TL21 (Modifie_par)
```

---

## 📊 Mapping Table WinDev ↔ Base de Données

### Colonnes de la Table WinDev

| Colonne WinDev | Champ Base | Type Affichage | Éditable |
|----------------|------------|----------------|----------|
| `COL_ID` | `IDProd_TL21` | Texte | ❌ Non |
| `COL_Ordre` | `Ordre` | Numérique | ❌ Non |
| `COL_Client` | `Client` | Texte | ✅ Oui |
| `COL_Affaire` | `Affaire` | Texte | ✅ Oui |
| `COL_Commande` | `Commande` | Texte | ✅ Oui |
| `COL_PIECE` | `PIECE` | Texte | ✅ Oui |
| `COL_DESA` | `DESA` | Texte | ✅ Oui |
| `COL_QTEREST` | `QTEREST` | Numérique | ✅ Oui |
| `COL_Couleur` | `Couleur` | Texte | ✅ Oui |
| `COL_R` | `R` | Texte | ✅ Oui |
| `COL_Balancelle` | `Balancelle` | Texte | ✅ Oui |
| `COL_Observations` | `Observations` | Texte | ✅ Oui |
| `COL_Doc` | `Doc` | Texte | ✅ Oui |
| `COL_Doc1` | `Doc1` | Texte | ✅ Oui |
| `COL_Doc2` | `Doc2` | Texte | ✅ Oui |
| `COL_Doc3` | `Doc3` | Texte | ✅ Oui |
| `COL_Doc4` | `Doc4` | Texte | ✅ Oui |
| `COL_Doc5` | `Doc5` | Texte | ✅ Oui |
| `COL_CT` | `CT` | Texte | ✅ Oui |
| `COL_DetailCT` | `DetailCT` | Texte | ✅ Oui |
| `COL_Epaisseuravant` | `Epaisseuravant` | Numérique | ✅ Oui |
| `COL_Epaisseurapres` | `Epaisseurapres` | Numérique | ✅ Oui |
| `COL_HSFEreb` | `HSFEreb` | Numérique | ✅ Oui |
| `COL_HSFDerb` | `HSFDerb` | Numérique | ✅ Oui |
| `COL_HeureVC` | `HeureVC` | Numérique | ✅ Oui |
| `COL_Reprise` | `Reprise` | Texte | ✅ Oui |
| `COL_Vconvoyeur` | `Vconvoyeur` | Numérique | ✅ Oui |
| `COL_Modifie_par` | `Modifie_par` | Texte | ❌ Non |

**Total : 28 colonnes (dont 26 éditables)**

---

## 🔄 Requêtes Courantes

### 1. Sélection de Toutes les Lignes (Triées par Ordre)

```wlangage
// WinDev
POUR TOUT Prod_TL21 AVEC "Ordre"
	// Traitement
FIN
```

```sql
-- SQL équivalent
SELECT * FROM Prod_TL21 ORDER BY Ordre ASC;
```

### 2. Recherche par ID

```wlangage
// WinDev
HLitRecherchePremier(Prod_TL21, IDProd_TL21, nID)
SI HTrouve(Prod_TL21) ALORS
	// Enregistrement trouvé
FIN
```

```sql
-- SQL équivalent
SELECT * FROM Prod_TL21 WHERE IDProd_TL21 = :nID;
```

### 3. Vérification de Verrouillage

```wlangage
// WinDev
HLitRecherchePremier(Prod_TL21, IDProd_TL21, nID)
SI Prod_TL21.Modifie_par = "" OU Prod_TL21.Modifie_par = gsUtilisateurActuel ALORS
	// Ligne disponible
SINON
	// Ligne verrouillée par un autre utilisateur
FIN
```

```sql
-- SQL équivalent
SELECT * FROM Prod_TL21 
WHERE IDProd_TL21 = :nID 
AND (Modifie_par = '' OR Modifie_par = :gsUtilisateurActuel);
```

### 4. Mise à Jour d'une Ligne

```wlangage
// WinDev
HLitRecherchePremier(Prod_TL21, IDProd_TL21, nID)
SI HTrouve(Prod_TL21) ALORS
	Prod_TL21.Client = "Nouveau Client"
	Prod_TL21.Affaire = "AFF-2025-001"
	HModifie(Prod_TL21)
FIN
```

```sql
-- SQL équivalent
UPDATE Prod_TL21 
SET Client = 'Nouveau Client', 
    Affaire = 'AFF-2025-001'
WHERE IDProd_TL21 = :nID;
```

### 5. Ajout d'une Nouvelle Ligne

```wlangage
// WinDev
Prod_TL21.Ordre = nNouvelOrdre
Prod_TL21.Client = "Client XYZ"
Prod_TL21.Affaire = "AFF-2025-002"
// ... autres champs
HAjoute(Prod_TL21)
```

```sql
-- SQL équivalent
INSERT INTO Prod_TL21 (Ordre, Client, Affaire, ...)
VALUES (:nNouvelOrdre, 'Client XYZ', 'AFF-2025-002', ...);
```

### 6. Réorganisation (Changement d'Ordre)

```wlangage
// WinDev - Monter une ligne
HLitRecherchePremier(Prod_TL21, IDProd_TL21, nID)
SI HTrouve(Prod_TL21) ALORS
	nOrdreActuel est un entier = Prod_TL21.Ordre
	Prod_TL21.Ordre = nOrdreActuel - 1
	HModifie(Prod_TL21)
FIN
```

```sql
-- SQL équivalent
UPDATE Prod_TL21 
SET Ordre = Ordre - 1
WHERE IDProd_TL21 = :nID;
```

---

## 🔐 Règles de Gestion

### Verrouillage

1. **Verrouillage automatique** : Quand un utilisateur entre dans une cellule, `Modifie_par` est défini avec son nom
2. **Libération automatique** : Quand l'utilisateur quitte la ligne, `Modifie_par` est remis à ""
3. **Vérification** : Avant de verrouiller, vérifier que `Modifie_par` est vide ou contient le nom de l'utilisateur actuel

### Ordre

1. **Numérotation** : L'ordre commence à 1 et s'incrémente de 1
2. **Réorganisation** : Lors d'un déplacement, tous les ordres sont recalculés
3. **Ajout** : Une nouvelle ligne prend l'ordre maximum + 1

### Valeurs par Défaut

1. **Numériques** : 0 ou 0.0
2. **Chaînes** : "" (chaîne vide)
3. **Textes** : "" (chaîne vide)

---

## 📈 Statistiques

### Taille Estimée

| Élément | Valeur |
|---------|--------|
| **Taille par enregistrement** | ~2 Ko |
| **Nombre d'enregistrements** | Variable (production) |
| **Taille totale estimée** | 2 Ko × nombre d'enregistrements |

### Performance

| Opération | Temps Estimé |
|-----------|--------------|
| **Lecture** | < 10ms |
| **Écriture** | < 50ms |
| **Recherche par ID** | < 5ms |
| **Tri par Ordre** | < 20ms |

---

## 🔄 Migration et Export

### Export vers MySQL

```wlangage
// WinDev - Export vers MySQL
HExporteXML(Prod_TL21, "Prod_TL21_export.xml", hExpCréation)
```

### Structure MySQL Équivalente

```sql
CREATE TABLE Prod_TL21 (
    IDProd_TL21 INT AUTO_INCREMENT PRIMARY KEY,
    Ordre INT NOT NULL DEFAULT 0,
    Client VARCHAR(255),
    Affaire VARCHAR(100),
    Commande VARCHAR(100),
    PIECE VARCHAR(100),
    DESA VARCHAR(100),
    QTEREST INT DEFAULT 0,
    Couleur VARCHAR(50),
    R VARCHAR(50),
    Balancelle VARCHAR(50),
    Observations TEXT,
    Doc VARCHAR(255),
    Doc1 VARCHAR(255),
    Doc2 VARCHAR(255),
    Doc3 VARCHAR(255),
    Doc4 VARCHAR(255),
    Doc5 VARCHAR(255),
    CT VARCHAR(50),
    DetailCT TEXT,
    Epaisseuravant DECIMAL(10,2) DEFAULT 0.0,
    Epaisseurapres DECIMAL(10,2) DEFAULT 0.0,
    HSFEreb DECIMAL(10,2) DEFAULT 0.0,
    HSFDerb DECIMAL(10,2) DEFAULT 0.0,
    HeureVC DECIMAL(10,2) DEFAULT 0.0,
    Reprise VARCHAR(50),
    Vconvoyeur DECIMAL(10,2) DEFAULT 0.0,
    Modifie_par VARCHAR(100) DEFAULT '',
    INDEX idx_ordre (Ordre),
    INDEX idx_modifie_par (Modifie_par)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

---

## 🧪 Données de Test

### Exemple d'Enregistrement

```wlangage
// WinDev
Prod_TL21.IDProd_TL21 = 1
Prod_TL21.Ordre = 1
Prod_TL21.Client = "ACME Corporation"
Prod_TL21.Affaire = "AFF-2025-001"
Prod_TL21.Commande = "CMD-2025-123"
Prod_TL21.PIECE = "PCE-456"
Prod_TL21.DESA = "Pièce de test"
Prod_TL21.QTEREST = 100
Prod_TL21.Couleur = "Bleu"
Prod_TL21.R = "R-789"
Prod_TL21.Balancelle = "BAL-001"
Prod_TL21.Observations = "Observations de test"
Prod_TL21.Doc = "DOC-001.pdf"
Prod_TL21.Doc1 = "DOC-002.pdf"
Prod_TL21.Doc2 = ""
Prod_TL21.Doc3 = ""
Prod_TL21.Doc4 = ""
Prod_TL21.Doc5 = ""
Prod_TL21.CT = "OK"
Prod_TL21.DetailCT = "Contrôle réussi"
Prod_TL21.Epaisseuravant = 10.5
Prod_TL21.Epaisseurapres = 9.8
Prod_TL21.HSFEreb = 2.5
Prod_TL21.HSFDerb = 1.5
Prod_TL21.HeureVC = 3.0
Prod_TL21.Reprise = "Non"
Prod_TL21.Vconvoyeur = 15.0
Prod_TL21.Modifie_par = ""
HAjoute(Prod_TL21)
```

---

## 📝 Notes

1. **Champ Modifie_par** : Ce champ est géré automatiquement par l'application et ne doit pas être modifié manuellement
2. **Ordre** : L'ordre est recalculé automatiquement lors des opérations de réorganisation
3. **Documents** : Les champs Doc* contiennent des chemins de fichiers ou des noms de documents
4. **Mesures** : Les valeurs numériques sont en unités standard (mm pour épaisseur, heures pour temps, m/min pour vitesse)

---

**Dernière mise à jour :** 2025-01-04
