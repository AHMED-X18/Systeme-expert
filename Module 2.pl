% ===============================================================================
% SYSTÈME EXPERT - MODULE 2: DÉCHARGEMENT DES CONTENEURS
% Port Autonome de Kribi - Gestion Logistique Intelligente
% ===============================================================================

% Suppression des avertissements pour les prédicats dynamiques
:- dynamic(navire/3).
:- dynamic(conteneur/4).
:- dynamic(portique/3).
:- dynamic(scanner/2).
:- dynamic(tos/2).
:- dynamic(vehicule/2).
:- dynamic(operation_log/3).

% ===============================================================================
% BASE DE FAITS INITIALE
% ===============================================================================

% État des navires: navire(ID, Statut, NombreConteneurs)
navire(nav1, amarre, 3).
navire(nav2, en_attente, 5).

% État des conteneurs: conteneur(ID, Navire, Position, État)
conteneur(c1, nav1, cale_1, intact).
conteneur(c2, nav1, cale_2, endommage).
conteneur(c3, nav1, cale_3, intact).
conteneur(c4, nav2, cale_1, intact).
conteneur(c5, nav2, cale_2, intact).

% Équipements de levage: portique(ID, Statut, Capacité)
portique(p1, disponible, 50).
portique(p2, maintenance, 45).

% Systèmes de scanning: scanner(ID, Statut)
scanner(s1, actif).
scanner(s2, inactif).

% Terminal Operating System: tos(ID, Statut)
tos(tos1, actif).

% Véhicules de transport: vehicule(ID, Statut)
vehicule(v1, libre).
vehicule(v2, libre).
vehicule(v3, occupe).

% Journal des opérations: operation_log(Type, Conteneur, Timestamp)
operation_log(dechargement, c1, '2025-06-20 10:30').

% ===============================================================================
% RÈGLES MÉTIER DU SYSTÈME EXPERT
% ===============================================================================

% Règle principale: Vérification des conditions de déchargement
peut_decharger(Conteneur) :-
    conteneur(Conteneur, Navire, _, _),
    navire(Navire, amarre, _),
    portique(_, disponible, _),
    tos(_, actif),
    scanner(_, actif).

% Inspection automatisée des conteneurs
inspecter_conteneur(C) :-
    conteneur(C, _, _, Etat),
    (   Etat = endommage
    ->  format('⚠️  ALERTE: Conteneur ~w endommagé détecté!~n', [C]),
        format('   Action requise: Inspection manuelle et quarantaine~n')
    ;   format('✅ Conteneur ~w est intact - Inspection réussie~n', [C])
    ).

% Affectation intelligente des véhicules
affecter_vehicule(C) :-
    vehicule(V, libre),
    !,  % Coupe pour éviter les choix multiples
    retract(vehicule(V, libre)),
    assertz(vehicule(V, occupe)),
    format('🚛 Véhicule ~w assigné au conteneur ~w~n', [V, C]).

affecter_vehicule(C) :-
    format('❌ Aucun véhicule disponible pour le conteneur ~w~n', [C]).

% Enregistrement dans le Terminal Operating System
enregistrer_tos(C) :-
    tos(TOS, actif),
    !,
    get_time(Timestamp),
    assertz(operation_log(dechargement, C, Timestamp)),
    format('📊 Conteneur ~w enregistré dans le TOS (~w)~n', [C, TOS]).

enregistrer_tos(C) :-
    format('❌ TOS indisponible - Impossible d\'enregistrer le conteneur ~w~n', [C]).

% Processus complet de déchargement d'un conteneur
decharger_conteneur(C) :-
    peut_decharger(C),
    !,
    format('~n🏗️  DÉBUT DÉCHARGEMENT: Conteneur ~w~n', [C]),
    format('=======================================~n'),
    inspecter_conteneur(C),
    affecter_vehicule(C),
    enregistrer_tos(C),
    format('✅ Déchargement terminé pour le conteneur ~w~n', [C]),
    format('=======================================~n').

decharger_conteneur(C) :-
    format('❌ Impossible de décharger le conteneur ~w~n', [C]),
    format('   Vérifiez les conditions: navire amarré, équipements disponibles~n').

% Traitement de masse de tous les conteneurs éligibles
decharger_tous_conteneurs :-
    format('~n🚢 DÉMARRAGE DU DÉCHARGEMENT AUTOMATIQUE~n'),
    format('=========================================~n'),
    findall(C, peut_decharger(C), Conteneurs),
    (   Conteneurs = []
    ->  format('ℹ️  Aucun conteneur prêt pour le déchargement~n')
    ;   length(Conteneurs, Nb),
        format('📋 ~w conteneurs éligibles détectés~n', [Nb]),
        forall(member(C, Conteneurs), decharger_conteneur(C))
    ),
    format('🏁 DÉCHARGEMENT AUTOMATIQUE TERMINÉ~n'),
    format('=========================================~n').

% ===============================================================================
% PRÉDICATS D'INTERFACE ET DE GESTION
% ===============================================================================

% Affichage de l'état complet du système
afficher_etat_systeme :-
    format('~n📊 ÉTAT ACTUEL DU SYSTÈME PORTUAIRE~n'),
    format('===================================~n'),
    
    % Navires
    format('🚢 NAVIRES:~n'),
    forall(navire(N, S, Nb), 
           format('   • ~w: ~w (~w conteneurs)~n', [N, S, Nb])),
    
    % Conteneurs
    format('~n📦 CONTENEURS:~n'),
    forall(conteneur(C, N, P, E), 
           format('   • ~w: Navire ~w, ~w, État: ~w~n', [C, N, P, E])),
    
    % Équipements
    format('~n🏗️  PORTIQUES:~n'),
    forall(portique(P, S, Cap), 
           format('   • ~w: ~w (Capacité: ~w t/h)~n', [P, S, Cap])),
    
    % Scanners
    format('~n📡 SCANNERS:~n'),
    forall(scanner(S, St), 
           format('   • ~w: ~w~n', [S, St])),
    
    % TOS
    format('~n💻 TERMINAL OPERATING SYSTEM:~n'),
    forall(tos(T, St), 
           format('   • ~w: ~w~n', [T, St])),
    
    % Véhicules
    format('~n🚛 VÉHICULES:~n'),
    forall(vehicule(V, St), 
           format('   • ~w: ~w~n', [V, St])),
    
    format('~n===================================~n').

% Diagnostic du système
diagnostiquer_systeme :-
    format('~n🔍 DIAGNOSTIC DU SYSTÈME~n'),
    format('========================~n'),
    
    % Vérification des navires amarrés
    findall(N, navire(N, amarre, _), NaviresAmarres),
    length(NaviresAmarres, NbNavires),
    format('✓ Navires amarrés: ~w~n', [NbNavires]),
    
    % Vérification des équipements
    (   portique(_, disponible, _)
    ->  format('✓ Portique disponible~n')
    ;   format('❌ Aucun portique disponible~n')
    ),
    
    (   scanner(_, actif)
    ->  format('✓ Scanner actif~n')
    ;   format('❌ Aucun scanner actif~n')
    ),
    
    (   tos(_, actif)
    ->  format('✓ TOS opérationnel~n')
    ;   format('❌ TOS indisponible~n')
    ),
    
    % Véhicules disponibles
    findall(V, vehicule(V, libre), VehiculesLibres),
    length(VehiculesLibres, NbVehicules),
    format('✓ Véhicules disponibles: ~w~n', [NbVehicules]),
    
    % Conteneurs prêts
    findall(C, peut_decharger(C), ConteneursPrets),
    length(ConteneursPrets, NbPrets),
    format('✓ Conteneurs prêts pour déchargement: ~w~n', [NbPrets]),
    
    format('========================~n').

% Simulation d'arrivée d'un nouveau navire
ajouter_navire(ID, NbConteneurs) :-
    assertz(navire(ID, en_attente, NbConteneurs)),
    format('🚢 Nouveau navire ~w ajouté (en attente, ~w conteneurs)~n', [ID, NbConteneurs]).

% Simulation d'amarrage d'un navire
amarrer_navire(ID) :-
    retract(navire(ID, en_attente, Nb)),
    assertz(navire(ID, amarre, Nb)),
    format('⚓ Navire ~w amarré avec succès~n', [ID]).

% Libération d'un véhicule
liberer_vehicule(ID) :-
    retract(vehicule(ID, occupe)),
    assertz(vehicule(ID, libre)),
    format('🚛 Véhicule ~w libéré et disponible~n', [ID]).

% Affichage du journal des opérations
afficher_journal :-
    format('~n📋 JOURNAL DES OPÉRATIONS~n'),
    format('=========================~n'),
    forall(operation_log(Type, Conteneur, Time), 
           format('• ~w: ~w à ~w~n', [Type, Conteneur, Time])),
    format('=========================~n').

% ===============================================================================
% MENU INTERACTIF PRINCIPAL
% ===============================================================================

% Affichage du menu principal
afficher_menu :-
    format('~n╔════════════════════════════════════════════════════════╗~n'),
    format('║        SYSTÈME EXPERT - MODULE 2 DÉCHARGEMENT         ║~n'),
    format('║              Port Autonome de Kribi                    ║~n'),
    format('╠════════════════════════════════════════════════════════╣~n'),
    format('║ 1. Afficher l\'état du système                          ║~n'),
    format('║ 2. Diagnostiquer le système                           ║~n'),
    format('║ 3. Décharger tous les conteneurs                      ║~n'),
    format('║ 4. Décharger un conteneur spécifique                  ║~n'),
    format('║ 5. Amarrer un navire                                  ║~n'),
    format('║ 6. Ajouter un nouveau navire                          ║~n'),
    format('║ 7. Libérer un véhicule                                ║~n'),
    format('║ 8. Afficher le journal des opérations                 ║~n'),
    format('║ 9. Réinitialiser le système                           ║~n'),
    format('║ 0. Quitter                                            ║~n'),
    format('╚════════════════════════════════════════════════════════╝~n'),
    format('Votre choix: ').

% Traitement des choix du menu
traiter_choix(1) :- afficher_etat_systeme.
traiter_choix(2) :- diagnostiquer_systeme.
traiter_choix(3) :- decharger_tous_conteneurs.
traiter_choix(4) :- 
    format('Entrez l\'ID du conteneur: '),
    read(ID),
    decharger_conteneur(ID).
traiter_choix(5) :- 
    format('Entrez l\'ID du navire à amarrer: '),
    read(ID),
    amarrer_navire(ID).
traiter_choix(6) :- 
    format('Entrez l\'ID du nouveau navire: '),
    read(ID),
    format('Nombre de conteneurs: '),
    read(Nb),
    ajouter_navire(ID, Nb).
traiter_choix(7) :- 
    format('Entrez l\'ID du véhicule à libérer: '),
    read(ID),
    liberer_vehicule(ID).
traiter_choix(8) :- afficher_journal.
traiter_choix(9) :- reinitialiser_systeme.
traiter_choix(0) :- 
    format('~n👋 Merci d\'avoir utilisé le système expert!~n'),
    format('🏁 Arrêt du système de gestion portuaire.~n').
traiter_choix(_) :- 
    format('❌ Choix invalide. Veuillez sélectionner une option valide.~n').

% Réinitialisation du système
reinitialiser_systeme :-
    format('🔄 Réinitialisation du système en cours...~n'),
    retractall(operation_log(_, _, _)),
    retractall(vehicule(_, occupe)),
    assertz(vehicule(v1, libre)),
    assertz(vehicule(v2, libre)),
    format('✅ Système réinitialisé avec succès!~n').

% Boucle principale du programme
demarrer_systeme :-
    format('🚀 DÉMARRAGE DU SYSTÈME EXPERT~n'),
    format('===============================~n'),
    format('Initialisation du module 2: Déchargement des conteneurs~n'),
    menu_principal.

menu_principal :-
    afficher_menu,
    read(Choix),
    traiter_choix(Choix),
    (   Choix = 0
    ->  true
    ;   format('~nAppuyez sur Entrée pour continuer...~n'),
        get_char(_),
        menu_principal
    ).

% ===============================================================================
% PRÉDICATS UTILITAIRES
% ===============================================================================

% Vérification de l'intégrité du système
verifier_integrite :-
    format('🔍 Vérification de l\'intégrité du système...~n'),
    
    % Vérifier que tous les conteneurs ont un navire valide
    forall(conteneur(C, N, _, _), 
           (navire(N, _, _) -> true ; 
            format('❌ Erreur: Conteneur ~w référence un navire inexistant ~w~n', [C, N]))),
    
    % Vérifier la cohérence des états
    forall(vehicule(V, occupe), 
           format('ℹ️  Véhicule ~w actuellement occupé~n', [V])),
    
    format('✅ Vérification terminée~n').

% Statistiques du système
afficher_statistiques :-
    format('~n📊 STATISTIQUES DU SYSTÈME~n'),
    format('===========================~n'),
    
    findall(N, navire(N, amarre, _), NaviresAmarres),
    length(NaviresAmarres, NbNaviresAmarres),
    
    findall(C, conteneur(C, _, _, intact), ConteneursSains),
    length(ConteneursSains, NbSains),
    
    findall(C, conteneur(C, _, _, endommage), ContenieursEndommages),
    length(ContenieursEndommages, NbEndommages),
    
    findall(V, vehicule(V, libre), VehiculesLibres),
    length(VehiculesLibres, NbLibres),
    
    format('• Navires amarrés: ~w~n', [NbNaviresAmarres]),
    format('• Conteneurs intacts: ~w~n', [NbSains]),
    format('• Conteneurs endommagés: ~w~n', [NbEndommages]),
    format('• Véhicules disponibles: ~w~n', [NbLibres]),
    format('===========================~n').

% ===============================================================================
% POINT D'ENTRÉE PRINCIPAL
% ===============================================================================

% Pour démarrer le système, utilisez: ?- demarrer_systeme.
% Pour des tests rapides: ?- decharger_tous_conteneurs.
% Pour diagnostiquer: ?- diagnostiquer_systeme.
