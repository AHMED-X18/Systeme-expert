# SYSTÈME EXPERT DE GESTION PORTUAIRE
*Expert System for Maritime Port Management*

## 📋 INFORMATIONS DU PROJET

**Équipe de développement :**
- AGHETSEH NGOH PETENSEBEN
- AHMED JALIL TADIDA
- AKOULOUZE JAMALI AMINA
- AKOULOUZE MANY EVA
- ARREYNTOW KERONE ENOW
- ATCHINE OUDAM HANNIEL
- ATSA NANGOU BRIDGET
- DANWE KAGOU MANUELLA
- ESSONO SANDRINE FLORA
- FOFACK ALEMDJOU HENRI

**Technologies utilisées :** Prolog (Programming in Logic)  
**Domaine :** Intelligence Artificielle - Systèmes Experts

---

## 🎯 PRÉSENTATION DU PROJET

Ce projet implémente un **système expert complet** pour la gestion automatisée d'un port maritime moderne. Le système utilise la logique de Prolog pour orchestrer l'ensemble des opérations portuaires, depuis l'arrivée des navires jusqu'à la sortie des marchandises du terminal.

### Architecture Modulaire

Le système est structuré en **six modules interconnectés**, chacun gérant une phase critique des opérations portuaires :

1. **Planification de l'arrivée des navires**
2. **Déchargement des conteneurs**
3. **Transfert et empilage dans la cour**
4. **Traitement administratif et douanier**
5. **Chargement pour le transport et transbordement**
6. **Transport terrestre et sortie du port**

---

## 🔧 FONCTIONNALITÉS DÉTAILLÉES PAR MODULE

### MODULE 1 : Planification de l'Arrivée des Navires
*Commande de démarrage : `demarrer_systeme`*

**Fonctionnalités principales :**
- **`afficher_etat_systeme`** : Visualise l'état complet du port (quais disponibles, navires en attente, conditions météorologiques)
- **`planifier_tous_arrivages(Date)`** : Optimise automatiquement la planification de tous les navires pour une date donnée
- **`planifier_arrivage(Navire, Date)`** : Planifie l'arrivée d'un navire spécifique en tenant compte des contraintes (tirant d'eau, disponibilité des quais, marées)
- **`traiter_priorite`** : Gère la priorité des navires selon des critères prédéfinis (urgence, type de cargo, accords commerciaux)
- **`afficher_journal`** : Consulte l'historique complet des arrivées avec horodatage
- **`verifier_systeme`** : Effectue un diagnostic complet de l'intégrité du système de planification

### MODULE 2 : Déchargement des Conteneurs
*Commande de démarrage : `demarrer_systeme`*

**Fonctionnalités principales :**
- **`afficher_etat_systeme`** : Affiche le statut des grues, navires amarrés et opérations en cours
- **`diagnostiquer_systeme`** : Détecte les anomalies dans les équipements de déchargement
- **`decharger_tous_conteneurs`** : Lance le déchargement automatisé de tous les conteneurs d'un navire
- **`decharger_conteneur_specifique(ID)`** : Décharge un conteneur particulier selon sa priorité
- **`amarrer_navire(Navire, Quai)`** : Gère l'amarrage sécurisé des navires
- **`ajouter_nouveau_navire(Details)`** : Enregistre un nouveau navire dans le système
- **`liberer_vehicule(ID)`** : Libère les équipements de manutention après utilisation
- **`afficher_journal_operations`** : Trace toutes les opérations de déchargement

### MODULE 3 : Transfert et Empilage dans la Cour
*Commande de démarrage : `demarrer` ou `start`*

**Fonctionnalités principales :**
- **`afficher_etat_cour`** : Visualise l'occupation des zones de stockage et la capacité disponible
- **`lister_conteneurs`** : Inventaire complet des conteneurs avec leur localisation exacte
- **`afficher_equipements`** : État des grues de cour, cavaliers et autres équipements
- **`executer_stockage_automatique`** : Optimise automatiquement le placement des conteneurs
- **`traiter_conteneur_specifique(ID)`** : Gère le stockage d'un conteneur selon ses caractéristiques
- **`ajouter_nouveau_conteneur(Details)`** : Enregistre un nouveau conteneur dans le système
- **`rechercher_position_optimale(Conteneur)`** : Trouve l'emplacement idéal selon les critères de rotation
- **`equilibrer_blocs`** : Redistribue les conteneurs pour optimiser l'espace
- **`rapport_complet`** : Génère un rapport détaillé de l'état de la cour

### MODULE 4 : Traitement Administratif et Douanier
*Commande de démarrage : `demarrer`*

**Fonctionnalités principales :**
- **`verifier_conteneur(ID)`** : Contrôle la conformité documentaire et réglementaire
- **`traiter_conteneur(ID)`** : Execute les procédures douanières complètes
- **`lister_conteneurs`** : Affiche les conteneurs avec leur statut administratif
- **`ajouter_donnees(Type, Details)`** : Enregistre de nouvelles informations douanières
- **`diagnostic_complet`** : Vérifie la cohérence de toutes les données administratives

### MODULE 5 : Chargement pour le Transport et Transbordement
*Commande de démarrage : `demarrer_systeme`*

**Fonctionnalités principales :**
- **`simuler_chargement(Navire)`** : Simule et optimise le plan de chargement
- **`afficher_etat_terminal`** : Visualise l'état des terminaux de chargement
- **`verifier_conteneur(ID)`** : Contrôle la préparation au chargement
- **`calculer_productivite`** : Mesure les performances des opérations de chargement

### MODULE 6 : Transport Terrestre et Sortie du Port
*Commande de démarrage : `demarrer`*

**Fonctionnalités principales :**
- **`marquer_conteneur_pret_transport(ID)`** : Valide la préparation pour l'évacuation
- **`assigner_transporteur(Conteneur, Transporteur)`** : Attribue un transporteur selon les critères optimaux
- **`ajouter_bon_livraison(Details)`** : Génère et valide les bons de livraison
- **`ajouter_lettre_voiture(Details)`** : Crée les documents de transport routier/ferroviaire
- **`ajouter_autorisation_sortie(Details)`** : Valide les autorisations réglementaires
- **`marquer_conteneur_charge(ID)`** : Confirme le chargement sur le véhicule de transport
- **`valider_controle_securite(ID)`** : Execute les contrôles de sécurité finaux
- **`assigner_porte_sortie(Conteneur, Porte)`** : Optimise l'attribution des portes de sortie
- **`marquer_conteneur_sortie(ID)`** : Finalise le processus de sortie du port

---

## 🏗️ ARCHITECTURE TECHNIQUE

### Composants Fondamentaux

Chaque module du système expert repose sur **trois composants essentiels** :

#### 1. **Base de Faits (Facts Base)**
Contient l'ensemble des données factuelles du domaine :
- États des équipements et infrastructures
- Informations sur les navires et conteneurs
- Données météorologiques et de marées
- Réglementations douanières et de sécurité

#### 2. **Base de Règles (Rules Base)**
Ensemble de règles logiques encodant l'expertise du domaine :
- Règles de priorité et d'optimisation
- Contraintes de sécurité et réglementaires
- Algorithmes de planification et d'allocation de ressources
- Procédures d'exception et de gestion d'erreurs

#### 3. **Moteur d'Inférence (Inference Engine)**
Mécanisme de raisonnement qui :
- Applique les règles aux faits pour déduire de nouvelles connaissances
- Gère le chaînage avant et arrière
- Résout les conflits entre règles
- Optimise les décisions selon les critères définis

---

## 🚀 INSTALLATION ET UTILISATION

### Prérequis
- SWI-Prolog (version 8.0 ou supérieure)
- Système d'exploitation compatible (Windows, Linux, macOS)

### Démarrage Rapide
1. Cloner le repository
2. Ouvrir SWI-Prolog
3. Charger le module souhaité 
4. Démarrer le système avec la commande appropriée


---

## 📊 AVANTAGES DU SYSTÈME

### Optimisation Opérationnelle
- **Réduction des temps d'attente** des navires grâce à la planification intelligente
- **Maximisation de l'utilisation** des équipements et infrastructures
- **Minimisation des coûts** opérationnels par l'optimisation des ressources

### Sécurité et Conformité
- **Respect automatique** des réglementations internationales
- **Traçabilité complète** de toutes les opérations
- **Gestion proactive** des risques et situations d'exception

### Évolutivité et Maintenance
- **Architecture modulaire** facilitant les mises à jour
- **Système de règles** facilement modifiable selon l'évolution des besoins
- **Interface standardisée** entre les modules

---

## 📈 PERSPECTIVES D'ÉVOLUTION

### Améliorations Techniques Envisagées
- **Intégration IoT** : Connexion avec les capteurs et équipements intelligents
- **Intelligence Artificielle Avancée** : Implémentation d'algorithmes d'apprentissage automatique
- **Interface Graphique** : Développement d'une interface utilisateur moderne
- **API REST** : Exposition des fonctionnalités via des services web

### Extensions Fonctionnelles
- **Module de Facturation Automatisée**
- **Système de Gestion de la Maintenance Prédictive**
- **Module de Reporting et Business Intelligence**
- **Intégration avec les Systèmes de Transport Multimodal**

---

## 📝 DOCUMENTATION TECHNIQUE

La documentation complète incluant :
- Diagrammes d'architecture détaillés
- Spécifications des règles métier
- Guide d'administration système
- Manuel utilisateur complet

Est disponible dans le **rapport PDF** joint au projet.

---

## ⚡ CONCLUSION

Ce système expert représente une **solution innovante et complète** pour la gestion automatisée des opérations portuaires. En exploitant la puissance du raisonnement logique de Prolog, il offre une approche intelligente et évolutive pour optimiser l'ensemble de la chaîne logistique portuaire.

L'architecture modulaire garantit une **maintenance aisée** et une **évolutivité optimale**, permettant d'adapter facilement le système aux spécificités de différents ports et aux évolutions réglementaires. 

Ce projet démontre le **potentiel considérable** des systèmes experts dans l'automatisation des processus complexes nécessitant une expertise métier approfondie, ouvrant la voie à une nouvelle génération de ports intelligents et connectés.

---

*Pour toute question technique ou demande de support, veuillez vous référer à la documentation complète ou contacter l'équipe de développement.*
