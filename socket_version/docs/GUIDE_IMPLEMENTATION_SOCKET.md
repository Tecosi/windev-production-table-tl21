# 📘 Guide d'Implémentation - Solution Socket

Ce guide vous accompagne étape par étape pour implémenter la solution socket dans votre application WinDev.

---

## 📋 Prérequis

- **WinDev 28** ou supérieur
- **Application existante** avec table de production
- **Environnement RDS** (Remote Desktop Services)
- **Procédures existantes** : `EnregistrerLigneModifiee()` et `VerrouillerLignePourSaisie()`

---

## 🎯 Vue d'Ensemble

La migration vers les sockets se fait en **5 étapes** :

1. ✅ Ajouter les variables globales socket
2. ✅ Ajouter les procédures socket
3. ✅ Modifier l'initialisation et la fermeture
4. ✅ Modifier les événements de la table
5. ✅ Tester

**Temps estimé :** 30-45 minutes

---

## 📝 Étape 1 : Ajouter les Variables Globales

### **1.1 Ouvrir le Code de Déclaration**

1. Ouvrir votre fenêtre dans WinDev
2. Clic droit sur la fenêtre → **Code**
3. Sélectionner **Déclarations globales de la fenêtre**

### **1.2 Ajouter les Variables Socket**

Ajouter ce code **en haut** des déclarations :

```wlangage
// ═══════════════════════════════════════════════════════════════
// VARIABLES SOCKET (NOUVELLES)
// ═══════════════════════════════════════════════════════════════

gbEstServeur est un booléen = Faux                // Indique si cette instance est le serveur
gsNomSocketServeur est une chaîne = "ServeurProd_TL21"  // Nom du socket serveur
gsNomSocketClient est une chaîne = "ClientProd_TL21"    // Nom du socket client
gnPortSocket est un entier = 5000                 // Port du serveur (localhost)
gtabClientsConnectes est un tableau de chaînes    // Liste des clients (serveur uniquement)
gbSocketActif est un booléen = Faux               // Indique si le socket est actif
```

### **1.3 Garder les Variables Existantes**

**Ne pas supprimer** les variables existantes :

```wlangage
// Variables existantes (À GARDER)
gbModificationParMoiMeme est un booléen = Faux
gbSaisieEnCours est un booléen = Faux
gbActualisationEnAttente est un booléen = Faux
gnNombreModifications est un entier = 0
gsUtilisateurActuel est une chaîne = ""
gnIDLigneEnCoursDeModification est un entier = 0
```

✅ **Validation :** Compiler (F9) pour vérifier qu'il n'y a pas d'erreurs.

---

## 📝 Étape 2 : Ajouter les Procédures Socket

### **2.1 Créer les Procédures Locales**

1. Dans l'explorateur de projet, clic droit sur votre fenêtre
2. **Nouveau** → **Procédure locale**
3. Nom : `Socket_Envoyer`

### **2.2 Copier le Code des Procédures**

Ouvrir le fichier `procedures/Socket_Procedures.wl` et copier **tout le contenu** dans les procédures locales de la fenêtre.

Le fichier contient **8 procédures** :

| Procédure | Description |
|-----------|-------------|
| `Socket_Envoyer` | Envoie un message via socket |
| `Socket_NouvelleConnexion` | Callback nouvelle connexion (serveur) |
| `Socket_MessageClient` | Callback message client (serveur) |
| `Socket_MessageRecu` | Callback message serveur (client) |
| `Socket_TraiterMessage` | Traite un message reçu |
| `Socket_TraiterVerrouillage` | Traite un verrouillage distant |
| `Socket_TraiterDeverrouillage` | Traite un déverrouillage distant |
| `Socket_TraiterMiseAJour` | Traite une mise à jour distante |

### **2.3 Vérifier les Procédures Existantes**

Vérifier que vous avez déjà ces procédures (existantes) :

- ✅ `EnregistrerLigneModifiee()`
- ✅ `VerrouillerLignePourSaisie()`

Si elles n'existent pas, copier depuis `procedures/EnregistrerLigneModifiee.wl` et `procedures/VerrouillerLignePourSaisie.wl`.

✅ **Validation :** Compiler (F9) pour vérifier qu'il n'y a pas d'erreurs.

---

## 📝 Étape 3 : Modifier l'Initialisation et la Fermeture

### **3.1 Modifier l'Événement "Initialisation"**

1. Ouvrir le code de la fenêtre
2. Sélectionner l'événement **"Initialisation de FEN_xxx"**
3. **Remplacer tout le code** par le contenu de `events/fenetre_initialisation.wl`

**Ce code fait :**
- Récupère le nom de l'utilisateur
- Essaie de créer le serveur socket (1ère instance)
- Ou se connecte comme client (instances suivantes)
- Charge les données de la table

### **3.2 Modifier l'Événement "Fermeture"**

1. Sélectionner l'événement **"Fermeture de FEN_xxx"**
2. **Remplacer tout le code** par le contenu de `events/fenetre_fermeture.wl`

**Ce code fait :**
- Notifie les autres utilisateurs de la déconnexion
- Ferme proprement les connexions socket
- Libère les ressources

✅ **Validation :** Compiler (F9) et tester le lancement de l'application.

**Résultat attendu :**
- Toast : "🟢 Serveur socket démarré" (1ère instance)
- Toast : "🔵 Connecté au serveur socket" (instances suivantes)

---

## 📝 Étape 4 : Modifier les Événements de la Table

### **4.1 Modifier "Entrée dans COL_xxx"**

Pour **chaque colonne éditable** (26 colonnes) :

1. Ouvrir le code de la colonne
2. Sélectionner l'événement **"Entrée dans COL_xxx"**
3. **Remplacer tout le code** par :

```wlangage
// Verrouiller localement
VerrouillerLignePourSaisie()

// Notifier les autres utilisateurs via socket
nIDLigne est un entier = TABLE_Prod_TL21.COL_ID
Socket_Envoyer("lock", {idLigne: nIDLigne})
```

**Liste des 26 colonnes à modifier :**

| Colonnes | Nombre |
|----------|--------|
| COL_Client, COL_Affaire, COL_Commande | 3 |
| COL_PIECE, COL_DESA, COL_QTEREST | 3 |
| COL_Couleur, COL_R, COL_Balancelle | 3 |
| COL_Observations | 1 |
| COL_Doc, COL_Doc1, COL_Doc2, COL_Doc3, COL_Doc4, COL_Doc5 | 6 |
| COL_CT, COL_DetailCT | 2 |
| COL_Epaisseuravant, COL_Epaisseurapres | 2 |
| COL_HSFEreb, COL_HSFDerb, COL_HeureVC | 3 |
| COL_Reprise, COL_Vconvoyeur | 2 |
| **TOTAL** | **26** |

**Astuce :** Utiliser la fonction **Rechercher/Remplacer** (Ctrl+H) pour remplacer rapidement dans toutes les colonnes.

### **4.2 Modifier "Sortie de COL_xxx"**

Pour les 26 colonnes, **garder le code existant** :

```wlangage
gbSaisieEnCours = Faux
```

Pas de modification nécessaire.

### **4.3 Modifier "Sortie de saisie d'une ligne"**

1. Ouvrir le code de la table `TABLE_Prod_TL21`
2. Sélectionner l'événement **"Sortie de saisie d'une ligne de TABLE_Prod_TL21"**
3. **Remplacer tout le code** par le contenu de `events/table_sortie_ligne_socket.wl`

**Ce code fait :**
- Enregistre la ligne
- Libère les verrous
- Notifie le déverrouillage via socket
- Notifie la mise à jour via socket
- Actualise si nécessaire

✅ **Validation :** Compiler (F9) pour vérifier qu'il n'y a pas d'erreurs.

---

## 📝 Étape 5 : Tester

### **5.1 Test Mono-Utilisateur**

1. **Lancer l'application**
   - ✅ Toast : "🟢 Serveur socket démarré"
   - ✅ Table chargée

2. **Entrer dans une cellule**
   - ✅ Pas d'erreur

3. **Modifier le contenu**
   - ✅ Saisie normale

4. **Sortir de la cellule**
   - ✅ Toast : "✓ Enregistré"
   - ✅ Données sauvegardées

### **5.2 Test Multi-Utilisateurs (2 Sessions RDS)**

#### **Session 1 (User A)**

1. **Lancer l'application**
   - ✅ Toast : "🟢 Serveur socket démarré"

#### **Session 2 (User B)**

2. **Lancer l'application**
   - ✅ Toast : "🔵 Connecté au serveur socket"
   - ✅ User A reçoit : "👤 User B s'est connecté"

#### **Test de Verrouillage**

3. **User A : Entrer dans une cellule ligne 1**
   - ✅ User B reçoit : "🔒 User A édite la ligne 1"
   - ✅ Colonne `Modifie_par` affiche "User A" chez User B

4. **User B : Vérifier que la ligne 1 est verrouillée**
   - ✅ Indicateur visuel présent

#### **Test de Saisie Simultanée**

5. **User B : Entrer dans une cellule ligne 2**
   - ✅ User A reçoit : "🔒 User B édite la ligne 2"

6. **User B : Commencer à taper "TEST"**
   - ✅ Saisie normale

7. **User A : Sortir de la ligne 1 (enregistrement)**
   - ✅ User A : Toast "✓ Enregistré"
   - ✅ User B : Toast "📝 Mise à jour en attente de User A (1)"
   - ✅ User B : **Reste dans sa cellule avec "TEST"** ✅✅✅

8. **User B : Sortir de la ligne 2**
   - ✅ Toast : "✓ Enregistré"
   - ✅ Toast : "📥 Données actualisées (1 modifications)"
   - ✅ User A reçoit : "📥 Mise à jour de User B"

#### **Test de Déconnexion**

9. **User B : Fermer l'application**
   - ✅ User A reçoit : "👤 User B s'est déconnecté"

---

## 🎯 Récapitulatif des Modifications

| Élément | Action | Fichier Source |
|---------|--------|----------------|
| **Variables globales** | Ajouter 6 variables | `variables/global_variables_socket.wl` |
| **Procédures** | Ajouter 8 procédures | `procedures/Socket_Procedures.wl` |
| **Initialisation** | Remplacer le code | `events/fenetre_initialisation.wl` |
| **Fermeture** | Remplacer le code | `events/fenetre_fermeture.wl` |
| **Entrée COL_xxx** (×26) | Remplacer le code | `events/table_entree_colonne_socket.wl` |
| **Sortie COL_xxx** (×26) | Garder le code | (inchangé) |
| **Sortie ligne** | Remplacer le code | `events/table_sortie_ligne_socket.wl` |

---

## 🔧 Configuration Avancée

### **Changer le Port Socket**

Par défaut : **5000**

Pour changer :

```wlangage
gnPortSocket est un entier = 6000  // Nouveau port
```

### **Activer les Logs Détaillés**

Les logs sont déjà activés via `Trace()`.

Pour les voir :
- Menu **Code** → **Trace du débogueur**
- Ou fichier `Trace_<Date>.txt` dans le répertoire de l'application

### **Désactiver les Toasts**

Pour réduire les notifications :

```wlangage
// Dans Socket_TraiterMessage(), commenter les ToastAffiche()
// ToastAffiche("👤 " + stMessage.user + " s'est connecté", toastCourt, cvBas, chCentre)
```

---

## ❌ Erreurs Courantes

### **Erreur : "Impossible de créer le serveur socket"**

**Cause :** Le port 5000 est déjà utilisé.

**Solution :**
1. Vérifier qu'aucune autre application n'utilise le port 5000
2. Ou changer `gnPortSocket`

### **Erreur : "Impossible de se connecter au serveur socket"**

**Cause :** Le serveur n'est pas démarré.

**Solution :**
1. Lancer au moins une instance (qui deviendra serveur)
2. Puis lancer les autres instances (qui deviendront clients)

### **Erreur : "Variable gbSocketActif non déclarée"**

**Cause :** Variables globales non ajoutées.

**Solution :**
Retourner à l'**Étape 1** et ajouter les variables globales.

### **Erreur : "Procédure Socket_Envoyer inconnue"**

**Cause :** Procédures socket non ajoutées.

**Solution :**
Retourner à l'**Étape 2** et ajouter les procédures.

---

## 📊 Checklist de Validation

Avant de déployer en production, vérifier :

- [ ] ✅ Variables globales ajoutées (6 variables)
- [ ] ✅ Procédures socket ajoutées (8 procédures)
- [ ] ✅ Initialisation modifiée
- [ ] ✅ Fermeture modifiée
- [ ] ✅ Entrée colonnes modifiée (26 colonnes)
- [ ] ✅ Sortie ligne modifiée
- [ ] ✅ Test mono-utilisateur OK
- [ ] ✅ Test multi-utilisateurs OK (2+ sessions)
- [ ] ✅ Test verrouillage OK
- [ ] ✅ Test saisie simultanée OK
- [ ] ✅ Test déconnexion OK
- [ ] ✅ Pas d'erreurs de compilation
- [ ] ✅ Logs activés pour débogage

---

## 🚀 Déploiement

### **Sur RDS**

1. Compiler l'application en mode **Release**
2. Déployer l'exécutable sur le serveur RDS
3. Tester avec 2-3 utilisateurs réels
4. Monitorer les logs pendant 1-2 jours
5. Déployer pour tous les utilisateurs

### **Recommandations**

- ✅ Garder une instance ouverte en permanence (serveur)
- ✅ Documenter le port utilisé (5000)
- ✅ Former les utilisateurs aux nouveaux indicateurs visuels
- ✅ Monitorer les performances

---

## 📞 Support

- **Documentation** : `README_SOCKET.md`
- **Protocole** : `PROTOCOLE_MESSAGES.md`
- **Dépannage** : `TROUBLESHOOTING_SOCKET.md`
- **Issues** : https://github.com/Tecosi/windev-production-table-tl21/issues

---

## 🎉 Félicitations !

Vous avez maintenant une application WinDev avec **synchronisation temps réel via sockets** ! 🚀

**Avantages obtenus :**
- ✅ Latence < 50ms (vs 1-5 secondes avec HSurveille)
- ✅ Notifications instantanées
- ✅ Pas de configuration réseau
- ✅ Contrôle total sur les messages
- ✅ Débogage facile

---

**Version :** 2.0.0 (Socket)  
**Date :** 2025-01-04  
**Auteur :** Tecosi
