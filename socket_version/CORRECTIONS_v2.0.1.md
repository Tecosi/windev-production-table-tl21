# 🔧 Corrections Version 2.0.1

## 📋 Erreurs Corrigées

### **1. TableAfficheLigne → TableAffiche**

**Erreur :**
```wlangage
TableAfficheLigne(TABLE_Prod_TL21, i)  // ❌ Fonction inconnue
```

**Correction :**
```wlangage
TableAffiche(TABLE_Prod_TL21, taLigneAffichée, i)  // ✅ Syntaxe correcte
```

**Fichiers modifiés :**
- `Socket_TraiterVerrouillage()`
- `Socket_TraiterDeverrouillage()`

---

### **2. JSONVersVariant → Parsing Manuel**

**Erreur :**
```wlangage
SI JSONVersVariant(stMessage, sMessage) ALORS  // ❌ Syntaxe incorrecte
```

**Correction :**
```wlangage
// Parser manuellement avec ExtraitChaîne
sAction est une chaîne = ExtraitChaîne(sMessage, 2, [" "action":""], [" ","])
sUser est une chaîne = ExtraitChaîne(sMessage, 2, [" "user":""], [" ","])
sIDLigne est une chaîne = ExtraitChaîne(sMessage, 2, [" "idLigne":"], "}")
nIDLigne est un entier = Val(sIDLigne)
```

**Fichiers modifiés :**
- `Socket_MessageClient()`
- `Socket_MessageRecu()`

---

### **3. IndiceCherche → TableauCherche**

**Erreur :**
```wlangage
nIndice = IndiceCherche(gtabClientsConnectes, sNomClient)  // ❌ Fonction inconnue
```

**Correction :**
```wlangage
nIndice est un entier = TableauCherche(gtabClientsConnectes, asLigne, sNomClient)
```

**Fichiers modifiés :**
- `Socket_Envoyer()`
- `Socket_MessageClient()`

---

### **4. SocketLit avec Callback**

**Erreur :**
```wlangage
SocketLit(sNomClient, Vrai, Socket_MessageClient)  // ❌ Callback sans paramètre
```

**Correction :**
```wlangage
SocketChangeModeTransmission(sNomClient, SocketSansMarqueurFin)
SocketLit(sNomClient, Vrai, Socket_MessageClient, sNomClient)
```

**Fichiers modifiés :**
- `Socket_NouvelleConnexion()`

---

### **5. Construction JSON Manuelle**

**Erreur :**
```wlangage
stMessage est un JSON
stMessage.action = "lock"
stMessage.data = {idLigne: 123}  // ❌ Syntaxe JSON complexe
sJSON = VariantVersJSON(stMessage)
```

**Correction :**
```wlangage
// Construire le JSON manuellement
sJSON est une chaîne
sJSON = "{"
sJSON += [" "action":""] + sAction + [" ","]
sJSON += [" "user":""] + gsUtilisateurActuel + [" ","]
sJSON += [" "timestamp":""] + DateHeureSys() + [" "]

SI stDonnees <> Null ALORS
	sJSON += [," "data":{"]
	sJSON += [" "idLigne":"] + stDonnees
	sJSON += "}"
FIN

sJSON += "}"
```

**Fichiers modifiés :**
- `Socket_Envoyer()`

---

### **6. Appel Socket_Envoyer Simplifié**

**Erreur :**
```wlangage
Socket_Envoyer("lock", {idLigne: nIDLigne})  // ❌ Syntaxe JSON complexe
```

**Correction :**
```wlangage
Socket_Envoyer("lock", nIDLigne)  // ✅ Passer l'ID directement
```

**Fichiers modifiés :**
- `table_entree_colonne_socket.wl`
- `table_sortie_ligne_socket.wl`

---

### **7. Socket_TraiterMessage avec Paramètres Simples**

**Erreur :**
```wlangage
PROCÉDURE Socket_TraiterMessage(stMessage est un JSON)  // ❌ Type JSON complexe
```

**Correction :**
```wlangage
PROCÉDURE Socket_TraiterMessage(sAction est une chaîne, sUser est une chaîne, nIDLigne est un entier = 0)
```

**Fichiers modifiés :**
- `Socket_TraiterMessage()`
- `Socket_MessageClient()`
- `Socket_MessageRecu()`

---

## ✅ Résumé des Corrections

| Erreur | Solution | Fichiers |
|--------|----------|----------|
| `TableAfficheLigne` | `TableAffiche(..., taLigneAffichée, i)` | Socket_Procedures.wl |
| `JSONVersVariant` | Parsing manuel avec `ExtraitChaîne` | Socket_Procedures.wl |
| `IndiceCherche` | `TableauCherche(..., asLigne, ...)` | Socket_Procedures.wl |
| Callback socket | `SocketChangeModeTransmission` + paramètre | Socket_Procedures.wl |
| Construction JSON | Construction manuelle de chaîne | Socket_Procedures.wl |
| Appel simplifié | Passer l'ID directement | Events/*.wl |
| Paramètres simples | Types de base au lieu de JSON | Socket_Procedures.wl |

---

## 🧪 Tests Recommandés

Après avoir appliqué les corrections :

1. **Compiler** (F9) pour vérifier qu'il n'y a plus d'erreurs
2. **Tester mono-utilisateur** : Lancer 1 instance
3. **Tester multi-utilisateurs** : Lancer 2 instances sur RDS
4. **Vérifier les logs** : Menu Code → Trace du débogueur

---

## 📝 Compatibilité

Ces corrections sont compatibles avec :
- ✅ WinDev 28
- ✅ WinDev 27
- ✅ WinDev 26 (probablement)

---

## 🔄 Différences avec v2.0.0

| Élément | v2.0.0 | v2.0.1 |
|---------|--------|--------|
| **JSON** | Type JSON natif | Construction manuelle |
| **Parsing** | JSONVersVariant | ExtraitChaîne |
| **Tableaux** | IndiceCherche | TableauCherche |
| **Affichage** | TableAfficheLigne | TableAffiche |
| **Callbacks** | Sans paramètre | Avec paramètre |

---

## 📞 Support

Si vous rencontrez d'autres erreurs :

1. **Copier le message d'erreur complet**
2. **Indiquer le numéro de ligne**
3. **Préciser votre version de WinDev**
4. **Ouvrir une issue** : https://github.com/Tecosi/windev-production-table-tl21/issues

---

**Version :** 2.0.1  
**Date :** 2025-01-04  
**Auteur :** Tecosi
