// ═══════════════════════════════════════════════════════════════
// ÉVÉNEMENT : ENTRÉE DANS COL_xxx (VERSION SOCKET)
// ═══════════════════════════════════════════════════════════════
// 
// À appliquer sur les 26 colonnes éditables :
// - COL_Client, COL_Affaire, COL_Commande
// - COL_PIECE, COL_DESA, COL_QTEREST
// - COL_Couleur, COL_R, COL_Balancelle
// - COL_Observations
// - COL_Doc, COL_Doc1, COL_Doc2, COL_Doc3, COL_Doc4, COL_Doc5
// - COL_CT, COL_DetailCT
// - COL_Epaisseuravant, COL_Epaisseurapres
// - COL_HSFEreb, COL_HSFDerb, COL_HeureVC
// - COL_Reprise, COL_Vconvoyeur
// 
// ═══════════════════════════════════════════════════════════════

// ═══════════════════════════════════════════════════════════════
// ÉTAPE 1 : VERROUILLER LA LIGNE LOCALEMENT
// ═══════════════════════════════════════════════════════════════

// Appeler la procédure de verrouillage (existante)
VerrouillerLignePourSaisie()


// ═══════════════════════════════════════════════════════════════
// ÉTAPE 2 : NOTIFIER LES AUTRES UTILISATEURS VIA SOCKET
// ═══════════════════════════════════════════════════════════════

// Récupérer l'ID de la ligne
nIDLigne est un entier = TABLE_Prod_TL21.COL_ID

// Envoyer le message de verrouillage
Socket_Envoyer("lock", {idLigne: nIDLigne})

Trace("🔒 Verrouillage de la ligne " + nIDLigne + " notifié")


// ═══════════════════════════════════════════════════════════════
// NOTES
// ═══════════════════════════════════════════════════════════════
// 
// Séquence :
// 1. User A entre dans une cellule
// 2. VerrouillerLignePourSaisie() verrouille localement
// 3. Socket_Envoyer("lock") notifie les autres utilisateurs
// 4. User B reçoit le message et voit "Modifié par User A"
// 
// Avantages :
// - Notification instantanée (< 50ms)
// - Indicateur visuel pour tous les utilisateurs
// - Évite les conflits d'édition
// 
// ═══════════════════════════════════════════════════════════════
