// ═══════════════════════════════════════════════════════════════
// VARIABLES GLOBALES DE LA FENÊTRE
// ═══════════════════════════════════════════════════════════════
// 
// À déclarer dans : Code de déclaration de la fenêtre
// 
// ═══════════════════════════════════════════════════════════════

// ───────────────────────────────────────────────────────────────
// Variables de gestion des modifications
// ───────────────────────────────────────────────────────────────
gbModificationParMoiMeme est un booléen = Faux    // Flag pour encapsuler les modifications
gbSaisieEnCours est un booléen = Faux             // Indique si l'utilisateur est en train de saisir
gbActualisationEnAttente est un booléen = Faux    // Indique qu'un rafraîchissement est en attente
gnNombreModifications est un entier = 0           // Compteur de modifications détectées

// ───────────────────────────────────────────────────────────────
// Variables d'identification utilisateur
// ───────────────────────────────────────────────────────────────
gsUtilisateurActuel est une chaîne = ""           // Nom de l'utilisateur actuel

// ───────────────────────────────────────────────────────────────
// Variables de verrouillage
// ───────────────────────────────────────────────────────────────
gnIDLigneEnCoursDeModification est un entier = 0  // ID de la ligne verrouillée (HFSQL)

// ───────────────────────────────────────────────────────────────
// Variables de mémorisation de position (pour restauration)
// ───────────────────────────────────────────────────────────────
gnLigneEnCoursDeSaisie est un entier = 0          // Numéro de ligne dans la table
gnColonneEnCoursDeSaisie est un entier = 0        // Numéro de colonne dans la table
gsContenuCelluleEnCours est une chaîne = ""       // Contenu en cours de saisie
gnIDLigneEnCoursDeSaisie est un entier = 0        // ID de l'enregistrement en cours de saisie
gnPositionCurseur est un entier = 0               // Position du curseur dans le texte (approximation)

// ═══════════════════════════════════════════════════════════════
// INITIALISATION
// ═══════════════════════════════════════════════════════════════
// 
// Dans l'événement "Initialisation" de la fenêtre, ajouter :
// 
// // Récupérer le nom de l'utilisateur
// gsUtilisateurActuel = HInfoUtilisateur()
// // OU
// gsUtilisateurActuel = Environnement("USERNAME")
// // OU
// gsUtilisateurActuel = "Nom_Utilisateur_Fixe"
// 
// // Activer HSurveille
// HSurveille(Prod_TL21, HSurveille_Callback, hFichierModifié)
// 
// ═══════════════════════════════════════════════════════════════
