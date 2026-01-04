# 🔌 Solution Socket pour WinDev Production Table TL21

## 📋 Vue d'Ensemble

Cette solution remplace **HSurveille** par des **sockets TCP** pour la synchronisation temps réel multi-utilisateurs sur **RDS (Remote Desktop Services)**.

---

## ✨ Avantages par Rapport à HSurveille

| Critère | HSurveille | Sockets |
|---------|-----------|---------|
| **Latence** | 1-5 secondes | < 50ms |
| **Méthode** | Polling périodique | Push instantané |
| **Ressources** | Requêtes HFSQL continues | Communication mémoire |
| **Configuration** | HFSQL Client/Server requis | Aucune |
| **Complexité** | Moyenne | Simple |
| **Messages** | "Fichier modifié" | Personnalisés (JSON) |
| **Débogage** | Difficile | Facile (Trace) |
| **Contrôle** | Limité | Total |

---

## 🏗️ Architecture

### **Sur RDS (Remote Desktop Services)**

```
┌─────────────────────────────────────────────────────────────┐
│                    SERVEUR RDS                               │
│                                                              │
│  ┌────────────────────────────────────────────────────┐    │
│  │         SERVEUR SOCKET (Port 5000)                 │    │
│  │  - Démarre avec la 1ère instance                   │    │
│  │  - Écoute sur localhost:5000                       │    │
│  │  - Broadcast les messages à tous les clients      │    │
│  └────────────────────────────────────────────────────┘    │
│                            │                                 │
│         ┌──────────────────┼──────────────────┐            │
│         │                  │                  │             │
│         ▼                  ▼                  ▼             │
│  ┌───────────┐      ┌───────────┐      ┌───────────┐      │
│  │ Session 1 │      │ Session 2 │      │ Session 3 │      │
│  │  User A   │      │  User B   │      │  User C   │      │
│  │ (Serveur) │      │ (Client)  │      │ (Client)  │      │
│  └───────────┘      └───────────┘      └───────────┘      │
│                                                              │
│  Tous connectés à localhost:5000                            │
└─────────────────────────────────────────────────────────────┘
```

### **Principe de Fonctionnement**

1. **La 1ère instance** qui se lance crée le serveur socket (port 5000)
2. **Les instances suivantes** se connectent comme clients
3. **Communication** via localhost (127.0.0.1) - ultra-rapide
4. **Messages JSON** pour transmettre les actions (lock, unlock, update)

---

## 📦 Structure des Fichiers

```
socket_solution/
├── variables/
│   └── global_variables_socket.wl      # Variables globales (socket + existantes)
│
├── procedures/
│   ├── Socket_Procedures.wl            # Toutes les procédures socket
│   ├── EnregistrerLigneModifiee.wl     # Procédure d'enregistrement (existante)
│   └── VerrouillerLignePourSaisie.wl   # Procédure de verrouillage (existante)
│
├── events/
│   ├── fenetre_initialisation.wl       # Initialisation socket + données
│   ├── fenetre_fermeture.wl            # Fermeture propre du socket
│   ├── table_entree_colonne_socket.wl  # Entrée colonne + notification
│   ├── table_sortie_ligne_socket.wl    # Sortie ligne + notification
│   └── table_sortie_colonne_socket.wl  # Sortie colonne (inchangé)
│
└── docs/
    ├── README_SOCKET.md                # Ce fichier
    ├── GUIDE_IMPLEMENTATION_SOCKET.md  # Guide d'implémentation
    └── PROTOCOLE_MESSAGES.md           # Documentation du protocole JSON
```

---

## 🚀 Installation Rapide

### **Étape 1 : Ajouter les Variables Globales**

Dans le **code de déclaration de la fenêtre**, ajouter :

```wlangage
// Variables socket (nouvelles)
gbEstServeur est un booléen = Faux
gsNomSocketServeur est une chaîne = "ServeurProd_TL21"
gsNomSocketClient est une chaîne = "ClientProd_TL21"
gnPortSocket est un entier = 5000
gtabClientsConnectes est un tableau de chaînes
gbSocketActif est un booléen = Faux

// Variables existantes (à garder)
gbModificationParMoiMeme est un booléen = Faux
gbSaisieEnCours est un booléen = Faux
gbActualisationEnAttente est un booléen = Faux
gnNombreModifications est un entier = 0
gsUtilisateurActuel est une chaîne = ""
gnIDLigneEnCoursDeModification est un entier = 0
```

### **Étape 2 : Ajouter les Procédures Socket**

Copier tout le contenu de `procedures/Socket_Procedures.wl` dans les **procédures locales** de la fenêtre.

### **Étape 3 : Modifier l'Événement "Initialisation"**

Remplacer le code de l'événement **"Initialisation"** de la fenêtre par le contenu de `events/fenetre_initialisation.wl`.

### **Étape 4 : Modifier l'Événement "Fermeture"**

Remplacer le code de l'événement **"Fermeture"** de la fenêtre par le contenu de `events/fenetre_fermeture.wl`.

### **Étape 5 : Modifier les Événements de la Table**

#### **Entrée dans COL_xxx (26 colonnes)**
Remplacer par le contenu de `events/table_entree_colonne_socket.wl`

#### **Sortie de saisie d'une ligne**
Remplacer par le contenu de `events/table_sortie_ligne_socket.wl`

#### **Sortie de COL_xxx (26 colonnes)**
Garder le code existant (inchangé)

---

## 🧪 Test

### **Test Mono-Utilisateur**

1. Lancer l'application
2. Vérifier le toast : "🟢 Serveur socket démarré"
3. Entrer dans une cellule
4. Modifier le contenu
5. Sortir de la cellule
6. Vérifier que l'enregistrement fonctionne

### **Test Multi-Utilisateurs**

1. **User A** : Lancer l'application (devient serveur)
   - Toast : "🟢 Serveur socket démarré"
   
2. **User B** : Lancer l'application (devient client)
   - Toast : "🔵 Connecté au serveur socket"
   - User A reçoit : "👤 User B s'est connecté"

3. **User A** : Entrer dans une cellule ligne 1
   - User B voit : "🔒 User A édite la ligne 1"
   - Colonne `Modifie_par` affiche "User A"

4. **User B** : Entrer dans une cellule ligne 2 et taper "TEST"

5. **User A** : Sortir de la ligne (enregistrement)
   - User B reçoit : "📥 Mise à jour de User A"
   - User B reste dans sa cellule avec "TEST" ✅

---

## 📨 Protocole de Messages

### **Format JSON**

```json
{
  "action": "lock|unlock|update|connect|disconnect",
  "user": "NomUtilisateur",
  "timestamp": "20250104120000",
  "data": {
    "idLigne": 123,
    ...
  }
}
```

### **Types de Messages**

| Action | Émetteur | Récepteur | Description |
|--------|----------|-----------|-------------|
| `connect` | Client | Tous | Connexion d'un utilisateur |
| `disconnect` | Client | Tous | Déconnexion d'un utilisateur |
| `lock` | User | Tous | Verrouillage d'une ligne |
| `unlock` | User | Tous | Déverrouillage d'une ligne |
| `update` | User | Tous | Mise à jour d'une ligne |

Voir `docs/PROTOCOLE_MESSAGES.md` pour plus de détails.

---

## ⚙️ Configuration

### **Changer le Port**

Par défaut, le serveur écoute sur le port **5000**. Pour changer :

```wlangage
gnPortSocket est un entier = 5000  // Changer ici
```

### **Activer les Logs**

Les logs sont activés via `Trace()`. Pour les voir :
- Menu **Code** → **Trace du débogueur**
- Ou fichier de trace WinDev

---

## 🔧 Dépannage

### **Problème : "Impossible de créer le serveur socket"**

**Cause :** Le port 5000 est déjà utilisé.

**Solution :**
1. Vérifier qu'aucune autre application n'utilise le port 5000
2. Ou changer le port dans `gnPortSocket`

### **Problème : "Impossible de se connecter au serveur socket"**

**Cause :** Le serveur n'est pas démarré ou le port est bloqué.

**Solution :**
1. Vérifier qu'au moins une instance est lancée (serveur)
2. Vérifier le firewall Windows (doit autoriser localhost)
3. Redémarrer toutes les instances

### **Problème : Les messages ne sont pas reçus**

**Cause :** Socket déconnecté ou erreur de sérialisation JSON.

**Solution :**
1. Vérifier les logs (Trace)
2. Vérifier que `gbSocketActif = Vrai`
3. Redémarrer les instances

Voir `docs/TROUBLESHOOTING_SOCKET.md` pour plus de solutions.

---

## 📊 Comparaison HSurveille vs Socket

### **Performance**

| Opération | HSurveille | Socket |
|-----------|-----------|--------|
| Verrouillage notifié | 1-5 sec | < 50ms |
| Mise à jour notifiée | 1-5 sec | < 50ms |
| Charge CPU | Moyenne (polling) | Faible (push) |
| Charge réseau | Moyenne | Très faible |

### **Fonctionnalités**

| Fonctionnalité | HSurveille | Socket |
|----------------|-----------|--------|
| Notification temps réel | ✅ | ✅ |
| Messages personnalisés | ❌ | ✅ |
| Indicateur utilisateur | ❌ | ✅ |
| Débogage facile | ❌ | ✅ |
| Configuration réseau | ⚠️ (HFSQL C/S) | ✅ (aucune) |

---

## 🎯 Recommandations

### **Pour RDS**

✅ **Utiliser la solution socket** (recommandé)
- Plus rapide
- Plus simple
- Pas de configuration

### **Pour Réseau Local**

✅ **Utiliser la solution socket** avec serveur dédié
- Créer une petite application serveur
- Toujours active
- Gère toutes les connexions

### **Pour Internet**

⚠️ **Utiliser une solution web** (React + Node.js + WebSocket)
- Plus adapté
- Sécurisé (HTTPS/WSS)
- Scalable

---

## 📞 Support

- **Documentation** : Voir `docs/`
- **Issues** : https://github.com/Tecosi/windev-production-table-tl21/issues
- **Guide** : `GUIDE_IMPLEMENTATION_SOCKET.md`

---

## 📝 Licence

MIT License - Voir `LICENSE`

---

**Version :** 2.0.0 (Socket)  
**Date :** 2025-01-04  
**Auteur :** Tecosi
