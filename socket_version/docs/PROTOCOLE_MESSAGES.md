# 📨 Protocole de Messages Socket

Ce document décrit le protocole de communication JSON utilisé pour la synchronisation temps réel entre les instances de l'application.

---

## 📋 Format Général

Tous les messages sont au format **JSON** et suivent cette structure :

```json
{
  "action": "string",
  "user": "string",
  "timestamp": "string",
  "data": {
    ...
  }
}
```

### **Champs Obligatoires**

| Champ | Type | Description |
|-------|------|-------------|
| `action` | string | Type d'action (voir ci-dessous) |
| `user` | string | Nom de l'utilisateur émetteur |
| `timestamp` | string | Date et heure du message (format WinDev) |
| `data` | object | Données associées à l'action (optionnel) |

---

## 📬 Types de Messages

### **1. Connexion (`connect`)**

Envoyé par un client quand il se connecte au serveur.

#### **Émetteur**
Client (nouvelle instance)

#### **Récepteurs**
Tous les autres clients + serveur

#### **Format**

```json
{
  "action": "connect",
  "user": "UserB",
  "timestamp": "20250104120000",
  "data": {
    "user": "UserB"
  }
}
```

#### **Traitement**

```wlangage
CAS "connect"
	ToastAffiche("👤 " + stMessage.user + " s'est connecté", toastCourt, cvBas, chCentre)
```

#### **Exemple de Flux**

```
User B (Client) → Serveur : {"action": "connect", "user": "UserB", ...}
Serveur → User A : {"action": "connect", "user": "UserB", ...}
User A affiche : "👤 UserB s'est connecté"
```

---

### **2. Déconnexion (`disconnect`)**

Envoyé par un client quand il se déconnecte du serveur.

#### **Émetteur**
Client (fermeture de l'application)

#### **Récepteurs**
Tous les autres clients + serveur

#### **Format**

```json
{
  "action": "disconnect",
  "user": "UserB",
  "timestamp": "20250104120500",
  "data": {
    "user": "UserB"
  }
}
```

#### **Traitement**

```wlangage
CAS "disconnect"
	ToastAffiche("👤 " + stMessage.user + " s'est déconnecté", toastCourt, cvBas, chCentre)
```

#### **Exemple de Flux**

```
User B (Client) → Serveur : {"action": "disconnect", "user": "UserB", ...}
Serveur → User A : {"action": "disconnect", "user": "UserB", ...}
User A affiche : "👤 UserB s'est déconnecté"
```

---

### **3. Verrouillage (`lock`)**

Envoyé quand un utilisateur entre dans une cellule (verrouillage d'une ligne).

#### **Émetteur**
Utilisateur qui entre dans une cellule

#### **Récepteurs**
Tous les autres utilisateurs

#### **Format**

```json
{
  "action": "lock",
  "user": "UserA",
  "timestamp": "20250104120100",
  "data": {
    "idLigne": 123
  }
}
```

#### **Traitement**

```wlangage
CAS "lock"
	Socket_TraiterVerrouillage(stMessage.data.idLigne, stMessage.user)
	
PROCÉDURE Socket_TraiterVerrouillage(nIDLigne, sUtilisateur)
	// Trouver la ligne dans la table
	POUR i = 1 À TableOccurrence(TABLE_Prod_TL21)
		SI TABLE_Prod_TL21.COL_ID[i] = nIDLigne ALORS
			// Afficher l'indicateur
			TABLE_Prod_TL21.COL_Modifie_par[i] = sUtilisateur
			TableAfficheLigne(TABLE_Prod_TL21, i)
			ToastAffiche("🔒 " + sUtilisateur + " édite la ligne " + i, toastCourt, cvBas, chCentre)
			SORTIR
		FIN
	FIN
```

#### **Exemple de Flux**

```
User A entre dans cellule ligne 1
User A → Serveur : {"action": "lock", "user": "UserA", "data": {"idLigne": 123}}
Serveur → User B : {"action": "lock", "user": "UserA", "data": {"idLigne": 123}}
User B affiche : "🔒 UserA édite la ligne 1"
User B voit : COL_Modifie_par = "UserA"
```

---

### **4. Déverrouillage (`unlock`)**

Envoyé quand un utilisateur sort d'une ligne (libération du verrou).

#### **Émetteur**
Utilisateur qui sort de la ligne

#### **Récepteurs**
Tous les autres utilisateurs

#### **Format**

```json
{
  "action": "unlock",
  "user": "UserA",
  "timestamp": "20250104120200",
  "data": {
    "idLigne": 123
  }
}
```

#### **Traitement**

```wlangage
CAS "unlock"
	Socket_TraiterDeverrouillage(stMessage.data.idLigne)
	
PROCÉDURE Socket_TraiterDeverrouillage(nIDLigne)
	// Trouver la ligne dans la table
	POUR i = 1 À TableOccurrence(TABLE_Prod_TL21)
		SI TABLE_Prod_TL21.COL_ID[i] = nIDLigne ALORS
			// Effacer l'indicateur
			TABLE_Prod_TL21.COL_Modifie_par[i] = ""
			TableAfficheLigne(TABLE_Prod_TL21, i)
			SORTIR
		FIN
	FIN
```

#### **Exemple de Flux**

```
User A sort de la ligne 1
User A → Serveur : {"action": "unlock", "user": "UserA", "data": {"idLigne": 123}}
Serveur → User B : {"action": "unlock", "user": "UserA", "data": {"idLigne": 123}}
User B efface : COL_Modifie_par = ""
```

---

### **5. Mise à Jour (`update`)**

Envoyé quand un utilisateur enregistre une ligne modifiée.

#### **Émetteur**
Utilisateur qui enregistre

#### **Récepteurs**
Tous les autres utilisateurs

#### **Format**

```json
{
  "action": "update",
  "user": "UserA",
  "timestamp": "20250104120200",
  "data": {
    "idLigne": 123
  }
}
```

#### **Traitement**

```wlangage
CAS "update"
	Socket_TraiterMiseAJour(stMessage.data.idLigne, stMessage.user)
	
PROCÉDURE Socket_TraiterMiseAJour(nIDLigne, sUtilisateur)
	// Si l'utilisateur est en train de saisir, différer
	SI gbSaisieEnCours = Vrai ALORS
		gbActualisationEnAttente = Vrai
		gnNombreModifications++
		ToastAffiche("📝 Mise à jour en attente de " + sUtilisateur, toastCourt, cvBas, chCentre)
		RETOUR
	FIN
	
	// Sinon, rafraîchir immédiatement
	TableAffiche(TABLE_Prod_TL21, taRéExécuteRequete)
	ToastAffiche("📥 Mise à jour de " + sUtilisateur, toastCourt, cvBas, chCentre)
```

#### **Exemple de Flux**

```
User A enregistre la ligne 1
User A → Serveur : {"action": "update", "user": "UserA", "data": {"idLigne": 123}}
Serveur → User B : {"action": "update", "user": "UserA", "data": {"idLigne": 123}}

Cas 1 : User B n'est pas en train de saisir
→ User B rafraîchit immédiatement
→ User B affiche : "📥 Mise à jour de UserA"

Cas 2 : User B est en train de saisir
→ User B diffère le rafraîchissement
→ User B affiche : "📝 Mise à jour en attente de UserA (1)"
→ User B rafraîchira quand il sortira de sa ligne
```

---

## 🔄 Flux Complets

### **Scénario 1 : Connexion et Verrouillage**

```
1. User A lance l'application
   → Devient serveur
   → Toast : "🟢 Serveur socket démarré"

2. User B lance l'application
   → Devient client
   → Envoie : {"action": "connect", "user": "UserB"}
   → Toast : "🔵 Connecté au serveur socket"
   → User A reçoit : "👤 UserB s'est connecté"

3. User A entre dans cellule ligne 1
   → Envoie : {"action": "lock", "user": "UserA", "data": {"idLigne": 123}}
   → User B reçoit : "🔒 UserA édite la ligne 1"
   → User B voit : COL_Modifie_par = "UserA"
```

---

### **Scénario 2 : Saisie Simultanée**

```
1. User A entre dans ligne 1
   → Envoie : {"action": "lock", "user": "UserA", "data": {"idLigne": 123}}

2. User B entre dans ligne 2
   → Envoie : {"action": "lock", "user": "UserB", "data": {"idLigne": 456}}
   → User A reçoit : "🔒 UserB édite la ligne 2"

3. User B tape "TEST" dans sa cellule
   → gbSaisieEnCours = Vrai

4. User A sort de la ligne 1 (enregistrement)
   → Envoie : {"action": "unlock", "user": "UserA", "data": {"idLigne": 123}}
   → Envoie : {"action": "update", "user": "UserA", "data": {"idLigne": 123}}
   → User B reçoit les messages
   → User B diffère le rafraîchissement (gbSaisieEnCours = Vrai)
   → User B affiche : "📝 Mise à jour en attente de UserA (1)"
   → User B RESTE dans sa cellule avec "TEST" ✅

5. User B sort de la ligne 2 (enregistrement)
   → Envoie : {"action": "unlock", "user": "UserB", "data": {"idLigne": 456}}
   → Envoie : {"action": "update", "user": "UserB", "data": {"idLigne": 456}}
   → User B rafraîchit maintenant (gbActualisationEnAttente = Vrai)
   → User B affiche : "📥 Données actualisées (1 modifications)"
   → User A reçoit : "📥 Mise à jour de UserB"
```

---

### **Scénario 3 : Déconnexion**

```
1. User B ferme l'application
   → Envoie : {"action": "disconnect", "user": "UserB"}
   → Ferme le socket client
   → User A reçoit : "👤 UserB s'est déconnecté"

2. User A continue à travailler normalement
   → Reste serveur
```

---

## 🛠️ Implémentation Technique

### **Sérialisation JSON**

```wlangage
// Construire le message
stMessage est un JSON
stMessage.action = "lock"
stMessage.user = gsUtilisateurActuel
stMessage.timestamp = DateHeureSys()
stMessage.data = {idLigne: 123}

// Sérialiser
sJSON est une chaîne = VariantVersJSON(stMessage)
// Résultat : {"action":"lock","user":"UserA","timestamp":"20250104120000","data":{"idLigne":123}}
```

### **Désérialisation JSON**

```wlangage
// Recevoir le message JSON
sMessage est une chaîne = "{"action":"lock","user":"UserA",...}"

// Désérialiser
stMessage est un JSON
SI JSONVersVariant(stMessage, sMessage) ALORS
	// Accéder aux données
	sAction est une chaîne = stMessage.action
	sUser est une chaîne = stMessage.user
	nIDLigne est un entier = stMessage.data.idLigne
FIN
```

### **Envoi via Socket**

```wlangage
// Mode serveur : Broadcast à tous les clients
POUR TOUT sNomClient DE gtabClientsConnectes
	SocketEcrit(sNomClient, sJSON)
FIN

// Mode client : Envoyer au serveur
SocketEcrit(gsNomSocketClient, sJSON)
```

---

## 📊 Statistiques

### **Taille des Messages**

| Message | Taille Typique |
|---------|----------------|
| `connect` | ~80 octets |
| `disconnect` | ~80 octets |
| `lock` | ~90 octets |
| `unlock` | ~90 octets |
| `update` | ~90 octets |

### **Fréquence des Messages**

| Scénario | Messages/Minute |
|----------|-----------------|
| Utilisateur inactif | 0 |
| Utilisateur actif (édition) | 2-10 |
| 10 utilisateurs actifs | 20-100 |

### **Bande Passante**

Pour 10 utilisateurs actifs :
- **Messages** : ~100/minute
- **Données** : ~9 Ko/minute
- **Charge réseau** : Négligeable (localhost)

---

## 🔐 Sécurité

### **Sur RDS**

- ✅ Communication via **localhost** (127.0.0.1)
- ✅ Pas d'exposition réseau externe
- ✅ Isolation par session RDS
- ✅ Pas besoin de chiffrement (local)

### **Sur Réseau Local**

Si vous déployez sur un réseau local :

- ⚠️ Utiliser **SSL/TLS** pour chiffrer
- ⚠️ Authentifier les clients
- ⚠️ Valider les messages JSON
- ⚠️ Limiter le taux de messages (rate limiting)

---

## 🧪 Tests

### **Tester la Sérialisation**

```wlangage
// Test de sérialisation
stMessage est un JSON
stMessage.action = "lock"
stMessage.user = "UserA"
stMessage.timestamp = DateHeureSys()
stMessage.data = {idLigne: 123}

sJSON est une chaîne = VariantVersJSON(stMessage)
Trace("JSON : " + sJSON)

// Test de désérialisation
stMessage2 est un JSON
SI JSONVersVariant(stMessage2, sJSON) ALORS
	Trace("Action : " + stMessage2.action)
	Trace("User : " + stMessage2.user)
	Trace("ID Ligne : " + stMessage2.data.idLigne)
FIN
```

### **Tester l'Envoi/Réception**

```wlangage
// Dans Socket_Envoyer(), ajouter un log
Trace("📤 Envoi : " + sAction + " → " + VariantVersJSON(stDonnees))

// Dans Socket_MessageRecu(), ajouter un log
Trace("📥 Réception : " + stMessage.action + " de " + stMessage.user)
```

---

## 📞 Support

- **Documentation** : `README_SOCKET.md`
- **Guide** : `GUIDE_IMPLEMENTATION_SOCKET.md`
- **Dépannage** : `TROUBLESHOOTING_SOCKET.md`
- **Issues** : https://github.com/Tecosi/windev-production-table-tl21/issues

---

**Version :** 2.0.0 (Socket)  
**Date :** 2025-01-04  
**Auteur :** Tecosi
