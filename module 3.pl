% ===============================================================================
% INTERFACE INTERACTIVE - MODULE 3: GESTION DE LA COUR DE STOCKAGE
% Système Expert pour Terminal à Conteneurs - Port Autonome de Kribi
% Compatible SWI-Prolog 8.x+
% ===============================================================================

:- dynamic(conteneur/6).
:- dynamic(bloc/5).
:- dynamic(grue_rtg/4).
:- dynamic(agv/4).
:- dynamic(tos/2).

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % BASE DE FAITS
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% conteneur(ID, type, zone_actuelle, bloc, position, statut).
conteneur(c001, standard, attente, -, -, attente).
conteneur(c002, reefer, attente, -, -, attente).
conteneur(c003, dangereux, attente, -, -, attente).
conteneur(c004, export, attente, -, -, attente).
conteneur(c005, standard, bloc_a1, a1, pos_1_2, stocke).

% bloc(ID, zone, capacite, occupation_actuelle, hauteur_max).
bloc(a1, zone_generale, 200, 45, 5).
bloc(a2, zone_generale, 200, 38, 5).
bloc(b1, zone_frigorifique, 100, 15, 4).
bloc(b2, zone_frigorifique, 100, 22, 4).
bloc(c1, zone_dangereuse, 80, 5, 3).
bloc(d1, zone_export, 150, 67, 5).
bloc(d2, zone_export, 150, 43, 5).

% grue_rtg(ID, bloc_assigne, statut, productivite_heure).
grue_rtg(rtg001, a1, operationnelle, 25).
grue_rtg(rtg002, a2, operationnelle, 25).
grue_rtg(rtg003, b1, operationnelle, 20).
grue_rtg(rtg004, b2, maintenance, 0).
grue_rtg(rtg005, c1, operationnelle, 15).
grue_rtg(rtg006, d1, operationnelle, 25).
grue_rtg(rtg007, d2, operationnelle, 25).

% agv(ID, position_actuelle, statut, conteneur_charge).
agv(agv001, quai, libre, -).
agv(agv002, bloc_a1, occupe, c005).
agv(agv003, zone_centrale, libre, -).

% systeme TOS
tos(actif, '2024-06-19 14:30:00').

% contraintes speciales
contrainte_electrique(reefer, connexion_obligatoire).
contrainte_securite(dangereux, isolation_requise).
contrainte_poids(standard, max_25_tonnes).

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % BASE DE CONNAISSANCES (REGLES)
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Compatibilite entre types de conteneurs et zones
compatible_zone(standard, zone_generale).
compatible_zone(reefer, zone_frigorifique).
compatible_zone(dangereux, zone_dangereuse).
compatible_zone(export, zone_export).
compatible_zone(export, zone_generale). % Fallback pour export

% Un conteneur peut etre stocke si conditions reunies
peut_stocker(Conteneur, Bloc) :-
    conteneur(Conteneur, Type, attente, _, _, attente),
    bloc(Bloc, Zone, Capacite, Occupation, _),
    compatible_zone(Type, Zone),
    Occupation < Capacite,
    grue_rtg(_, Bloc, operationnelle, _),
    tos(actif, _).

% Verification des contraintes speciales
respecte_contraintes(Conteneur, Bloc) :-
    conteneur(Conteneur, Type, _, _, _, _),
    bloc(Bloc, Zone, _, _, _),
    (   Type = reefer
    ->  (Zone = zone_frigorifique, connexion_disponible(Bloc))
    ;   Type = dangereux
    ->  Zone = zone_dangereuse
    ;   true
    ).

% Verification des connexions electriques pour reefers
connexion_disponible(Bloc) :-
    bloc(Bloc, zone_frigorifique, _, Occupation, _),
    Occupation < 80. % Limite des connexions disponibles

% Calcul de la position optimale d'empilage
position_optimale(Conteneur, Bloc, Position) :-
    peut_stocker(Conteneur, Bloc),
    respecte_contraintes(Conteneur, Bloc),
    calculer_position_empilage(Conteneur, Bloc, Position).

% Algorithme d'empilage strategique
calculer_position_empilage(Conteneur, Bloc, Position) :-
    conteneur(Conteneur, Type, _, _, _, _),
    bloc(Bloc, _, _, Occupation, _),
    (   Type = export
    ->  Position = acces_facile % Export = acces rapide
    ;   Occupation < 50
    ->  Position = niveau_bas % Remplissage progressif
    ;   Position = niveau_haut % Optimisation espace
    ).

% Allocation d'une grue RTG disponible
allouer_grue(Bloc, Grue) :-
    grue_rtg(Grue, Bloc, operationnelle, _).

% Allocation d'un AGV libre
allouer_agv(AGV) :-
    agv(AGV, _, libre, -).

% Execution du stockage complet
executer_stockage(Conteneur, Bloc, Position) :-
    position_optimale(Conteneur, Bloc, Position),
    allouer_grue(Bloc, Grue),
    allouer_agv(AGV),
    effectuer_mouvement(Conteneur, Bloc, Position, Grue, AGV),
    mettre_a_jour_tos(Conteneur, Bloc, Position),
    format('~w Conteneur ~w stocke dans ~w position ~w.~n',
           ['✓', Conteneur, Bloc, Position]).

% Simulation du mouvement physique
effectuer_mouvement(Conteneur, Bloc, Position, Grue, AGV) :-
    format('~w AGV ~w transporte ~w vers ~w.~n', ['→', AGV, Conteneur, Bloc]),
    format('~w Grue ~w place ~w en position ~w.~n', ['→', Grue, Conteneur, Position]),
    % Mise a jour des statuts
    retract(agv(AGV, _, libre, -)),
    assertz(agv(AGV, Bloc, occupe, Conteneur)),
    retract(conteneur(Conteneur, Type, attente, _, _, attente)),
    assertz(conteneur(Conteneur, Type, Bloc, Bloc, Position, stocke)).

% Mise a jour du systeme TOS
mettre_a_jour_tos(Conteneur, Bloc, Position) :-
    format('~w TOS mis à jour : ~w -> ~w (~w).~n',
           ['→', Conteneur, Bloc, Position]).

% Liberer un AGV apres operation
liberer_agv(AGV) :-
    retract(agv(AGV, _, occupe, _)),
    assertz(agv(AGV, zone_centrale, libre, -)),
    format('~w AGV ~w libéré.~n', ['→', AGV]).

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % INTERFACE INTERACTIVE
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% ===============================================================================
% MENU PRINCIPAL
% ===============================================================================

menu_principal :-
    nl,
    writeln('═══════════════════════════════════════════════════════════════════════════════'),
    writeln('                    SYSTÈME EXPERT - GESTION COUR DE STOCKAGE                 '),
    writeln('                         Module 3 - Port Autonome de Kribi                    '),
    writeln('═══════════════════════════════════════════════════════════════════════════════'),
    writeln(''),
    writeln('  1. Afficher l\'état de la cour'),
    writeln('  2. Lister les conteneurs'),
    writeln('  3. Afficher les équipements'),
    writeln('  4. Exécuter le stockage automatique'),
    writeln('  5. Traiter un conteneur spécifique'),
    writeln('  6. Ajouter un nouveau conteneur'),
    writeln('  7. Rechercher une position optimale'),
    writeln('  8. Équilibrer les blocs'),
    writeln('  9. Rapport complet'),
    writeln(' 10. Aide'),
    writeln('  0. Quitter'),
    writeln(''),
    writeln('═══════════════════════════════════════════════════════════════════════════════'),
    write('Votre choix (0-10) : '),
    read(Choix),
    traiter_choix(Choix).

% ===============================================================================
% TRAITEMENT DES CHOIX
% ===============================================================================

traiter_choix(0) :-
    nl,
    writeln('Fermeture du système expert...'),
    writeln('Merci d\'avoir utilisé le système de gestion de cour de stockage !'),
    !.

traiter_choix(1) :-
    afficher_etat_cour,
    attendre_entree,
    menu_principal.

traiter_choix(2) :-
    lister_conteneurs,
    attendre_entree,
    menu_principal.

traiter_choix(3) :-
    afficher_equipements,
    attendre_entree,
    menu_principal.

traiter_choix(4) :-
    executer_stockage_automatique,
    attendre_entree,
    menu_principal.

traiter_choix(5) :-
    traiter_conteneur_specifique,
    attendre_entree,
    menu_principal.

traiter_choix(6) :-
    ajouter_nouveau_conteneur,
    attendre_entree,
    menu_principal.

traiter_choix(7) :-
    rechercher_position_optimale,
    attendre_entree,
    menu_principal.

traiter_choix(8) :-
    equilibrer_blocs,
    attendre_entree,
    menu_principal.

traiter_choix(9) :-
    rapport_complet,
    attendre_entree,
    menu_principal.

traiter_choix(10) :-
    afficher_aide,
    attendre_entree,
    menu_principal.

traiter_choix(_) :-
    nl,
    writeln('Choix invalide ! Veuillez sélectionner un nombre entre 0 et 10.'),
    attendre_entree,
    menu_principal.

% ===============================================================================
% FONCTIONS D'AFFICHAGE
% ===============================================================================

afficher_etat_cour :-
    nl,
    writeln('═══════════════════════════════════════════════════════════════════════════════'),
    writeln('                            ÉTAT DE LA COUR DE STOCKAGE                       '),
    writeln('═══════════════════════════════════════════════════════════════════════════════'),
    nl,
    forall(bloc(ID, Zone, Capacite, Occupation, HauteurMax),
           (   Taux is round(Occupation / Capacite * 100),
               format('Bloc ~w (~w) : ~w/~w conteneurs (~w%) - Hauteur max: ~w~n',
                      [ID, Zone, Occupation, Capacite, Taux, HauteurMax])
           )),
    nl.

lister_conteneurs :-
    nl,
    writeln('═══════════════════════════════════════════════════════════════════════════════'),
    writeln('                               LISTE DES CONTENEURS                           '),
    writeln('═══════════════════════════════════════════════════════════════════════════════'),
    nl,
    writeln('Conteneurs en attente :'),
    forall(conteneur(ID, Type, attente, _, _, Statut),
           format('   • ~w (~w) - Statut: ~w~n', [ID, Type, Statut])),
    nl,
    writeln('Conteneurs stockés :'),
    forall(conteneur(ID, Type, Bloc, _, Position, stocke),
           format('   • ~w (~w) - Bloc: ~w, Position: ~w~n', [ID, Type, Bloc, Position])),
    nl.

afficher_equipements :-
    nl,
    writeln('═══════════════════════════════════════════════════════════════════════════════'),
    writeln('                                  ÉQUIPEMENTS                                 '),
    writeln('═══════════════════════════════════════════════════════════════════════════════'),
    nl,
    writeln('Grues RTG :'),
    forall(grue_rtg(ID, Bloc, Statut, Productivite),
           format('   ~w - Bloc: ~w, Statut: ~w, Productivité: ~w cont/h~n',
                  [ID, Bloc, Statut, Productivite])),
    nl,
    writeln('Véhicules AGV :'),
    forall(agv(ID, Position, Statut, Charge),
           format('   ~w - Position: ~w, Statut: ~w, Charge: ~w~n',
                  [ID, Position, Statut, Charge])),
    nl.

% ===============================================================================
% FONCTIONS DE TRAITEMENT
% ===============================================================================

executer_stockage_automatique :-
    nl,
    writeln('EXÉCUTION DU STOCKAGE AUTOMATIQUE'),
    writeln('═══════════════════════════════════════════════════════════════════════════════'),
    nl,
    findall(C, conteneur(C, _, attente, _, _, attente), ConteneursList),
    (   ConteneursList = []
    ->  writeln('Aucun conteneur en attente de stockage.')
    ;   writeln('Traitement des conteneurs en attente...'),
        nl,
        forall(member(Conteneur, ConteneursList),
               traiter_conteneur_auto(Conteneur)),
        nl,
        writeln('Stockage automatique terminé !')
    ).

traiter_conteneur_auto(Conteneur) :-
    (   executer_stockage(Conteneur, _, _)
    ->  liberer_agv_apres_stockage(Conteneur)
    ;   format('Impossible de stocker le conteneur ~w~n', [Conteneur])
    ).

liberer_agv_apres_stockage(Conteneur) :-
    (   agv(AGV, _, occupe, Conteneur)
    ->  liberer_agv(AGV)
    ;   true
    ).

traiter_conteneur_specifique :-
    nl,
    writeln('TRAITEMENT D\'UN CONTENEUR SPÉCIFIQUE'),
    writeln('═══════════════════════════════════════════════════════════════════════════════'),
    nl,
    writeln('Conteneurs disponibles en attente :'),
    forall(conteneur(ID, Type, attente, _, _, attente),
           format('   • ~w (~w)~n', [ID, Type])),
    nl,
    write('Entrez l\'ID du conteneur à traiter : '),
    read(ID),
    (   conteneur(ID, _, attente, _, _, attente)
    ->  (   executer_stockage(ID, Bloc, Position)
        ->  (   format('Conteneur ~w traité avec succès !~n', [ID]),
                format('   Stocké dans le bloc ~w, position ~w~n', [Bloc, Position]),
                liberer_agv_apres_stockage(ID)
            )
        ;   format('Impossible de traiter le conteneur ~w~n', [ID])
        )
    ;   format('Conteneur ~w non trouvé ou pas en attente~n', [ID])
    ).

ajouter_nouveau_conteneur :-
    nl,
    writeln('AJOUT D\'UN NOUVEAU CONTENEUR'),
    writeln('═══════════════════════════════════════════════════════════════════════════════'),
    nl,
    writeln('Types disponibles : standard, reefer, dangereux, export'),
    write('Entrez l\'ID du conteneur : '),
    read(ID),
    write('Entrez le type du conteneur : '),
    read(Type),
    (   member(Type, [standard, reefer, dangereux, export])
    ->  (   assertz(conteneur(ID, Type, attente, -, -, attente)),
            format('Conteneur ~w (~w) ajouté avec succès !~n', [ID, Type])
        )
    ;   writeln('Type de conteneur invalide !')
    ).

rechercher_position_optimale :-
    nl,
    writeln('RECHERCHE DE POSITION OPTIMALE'),
    writeln('═══════════════════════════════════════════════════════════════════════════════'),
    nl,
    write('Entrez l\'ID du conteneur : '),
    read(ID),
    (   conteneur(ID, _, _, _, _, _)
    ->  (   findall(Bloc-Position, position_optimale(ID, Bloc, Position), Solutions),
            (   Solutions = []
            ->  format('Aucune position optimale trouvée pour ~w~n', [ID])
            ;   format('Positions optimales pour ~w :~n', [ID]),
                forall(member(B-P, Solutions),
                       format('   • Bloc ~w, Position ~w~n', [B, P]))
            )
        )
    ;   format('Conteneur ~w non trouvé~n', [ID])
    ).

equilibrer_blocs :-
    nl,
    writeln('ÉQUILIBRAGE DES BLOCS'),
    writeln('═══════════════════════════════════════════════════════════════════════════════'),
    nl,
    findall(Occ-Bloc,
            (   bloc(Bloc, Zone, Cap, Occ, _),
                Zone \= zone_dangereuse,
                TauxOcc is Occ / Cap,
                TauxOcc > 0.85
            ),
            BlocsSurcharges),
    (   BlocsSurcharges \= []
    ->  (   writeln('ALERTE : Blocs surchargés détectés :'),
            forall(member(O-B, BlocsSurcharges),
                   format('   • Bloc ~w : ~w conteneurs~n', [B, O])),
            nl,
            writeln('Recommandation : Redistribuer les conteneurs vers d\'autres blocs.')
        )
    ;   writeln('Répartition des blocs équilibrée.')
    ).

rapport_complet :-
    nl,
    writeln('═══════════════════════════════════════════════════════════════════════════════'),
    writeln('                              RAPPORT COMPLET                                 '),
    writeln('═══════════════════════════════════════════════════════════════════════════════'),
    afficher_etat_cour,
    writeln('───────────────────────────────────────────────────────────────────────────────'),
    lister_conteneurs,
    writeln('───────────────────────────────────────────────────────────────────────────────'),
    afficher_equipements,
    writeln('───────────────────────────────────────────────────────────────────────────────'),
    equilibrer_blocs,
    nl.

afficher_aide :-
    nl,
    writeln('═══════════════════════════════════════════════════════════════════════════════'),
    writeln('                                    AIDE                                      '),
    writeln('═══════════════════════════════════════════════════════════════════════════════'),
    nl,
    writeln('GUIDE D\'UTILISATION :'),
    nl,
    writeln('1. État de la cour : Visualise l\'occupation de tous les blocs'),
    writeln('2. Liste conteneurs : Affiche tous les conteneurs et leur statut'),
    writeln('3. Équipements : Montre l\'état des grues RTG et véhicules AGV'),
    writeln('4. Stockage auto : Traite automatiquement tous les conteneurs en attente'),
    writeln('5. Conteneur spécifique : Traite un conteneur particulier'),
    writeln('6. Nouveau conteneur : Ajoute un conteneur à la base de données'),
    writeln('7. Position optimale : Trouve les meilleures positions pour un conteneur'),
    writeln('8. Équilibrer blocs : Vérifie la répartition des charges'),
    writeln('9. Rapport complet : Génère un rapport détaillé de la cour'),
    nl,
    writeln('TYPES DE CONTENEURS SUPPORTÉS :'),
    writeln('   • standard : Conteneurs génériques (zone générale)'),
    writeln('   • reefer : Conteneurs frigorifiques (zone frigorifique + électricité)'),
    writeln('   • dangereux : Matières dangereuses (zone isolée)'),
    writeln('   • export : Conteneurs d\'export (zones export ou générale)'),
    nl,
    writeln('CONTRAINTES AUTOMATIQUES :'),
    writeln('   • Vérification de la compatibilité zone/conteneur'),
    writeln('   • Contrôle de la capacité des blocs'),
    writeln('   • Validation de la disponibilité des équipements'),
    writeln('   • Respect des contraintes spéciales (électricité, sécurité)'),
    nl.

% ===============================================================================
% FONCTIONS UTILITAIRES
% ===============================================================================

attendre_entree :-
    nl,
    write('Appuyez sur Entrée pour continuer...'),
    read(_).

% ===============================================================================
% PREDICATS DE GESTION AVANCEE
% ===============================================================================

% Gestion automatique de tous les conteneurs en attente
gerer_stockage_cour :-
    forall(conteneur(C, _, attente, _, _, attente),
           (   executer_stockage(C, _, _)
           ->  liberer_agv_apres_stockage(C)
           ;   format('Échec stockage conteneur ~w~n', [C])
           )).

% Recherche de tous les conteneurs d'un type donné
conteneurs_par_type(Type, Liste) :-
    findall(ID, conteneur(ID, Type, _, _, _, _), Liste).

% Calcul du taux d'occupation global
taux_occupation_global(Taux) :-
    findall(Occ-Cap, bloc(_, _, Cap, Occ, _), Donnees),
    sum_occupation(Donnees, TotalOcc, TotalCap),
    (   TotalCap > 0
    ->  Taux is round(TotalOcc / TotalCap * 100)
    ;   Taux = 0
    ).

sum_occupation([], 0, 0).
sum_occupation([Occ-Cap|Rest], TotalOcc, TotalCap) :-
    sum_occupation(Rest, RestOcc, RestCap),
    TotalOcc is Occ + RestOcc,
    TotalCap is Cap + RestCap.

% Vérification de la cohérence des données
verifier_coherence :-
    writeln('Vérification de la cohérence des données :'),
    % Vérifier que tous les conteneurs stockés ont un bloc valide
    forall(conteneur(ID, _, Bloc, _, _, stocke),
           (   bloc(Bloc, _, _, _, _)
           ->  true
           ;   format('ERREUR: Conteneur ~w référence un bloc inexistant ~w~n', [ID, Bloc])
           )),
    % Vérifier que les AGV occupés ont bien un conteneur
    forall(agv(AGV, _, occupe, Conteneur),
           (   conteneur(Conteneur, _, _, _, _, _)
           ->  true
           ;   format('ERREUR: AGV ~w référence un conteneur inexistant ~w~n', [AGV, Conteneur])
           )),
    writeln('Vérification terminée.').

% ===============================================================================
% POINT D'ENTRÉE PRINCIPAL
% ===============================================================================

% Lancement du système
demarrer :-
    writeln('Initialisation du système expert...'),
    verifier_coherence,
    nl,
    menu_principal.

% Alternative pour compatibilité
start :-
    demarrer.

% Initialisation automatique (commentée pour éviter l'exécution automatique)
% :- initialization(demarrer).

% ===============================================================================
% INSTRUCTIONS DE DÉMARRAGE
% ===============================================================================

:- multifile user:portray/1.

user:portray(system_ready) :-
    nl,
    writeln('═══════════════════════════════════════════════════════════════════════════════'),
    writeln('        SYSTÈME EXPERT CHARGÉ - MODULE 3 GESTION COUR DE STOCKAGE             '),
    writeln('═══════════════════════════════════════════════════════════════════════════════'),
    writeln(''),
    writeln('Pour démarrer l\'interface interactive, tapez :'),
    writeln(''),
    writeln('   ?- demarrer.'),
    writeln(''),
    writeln('ou bien :'),
    writeln(''),
    writeln('   ?- start.'),
    writeln(''),
    writeln('Pour une vérification de cohérence :'),
    writeln(''),
    writeln('   ?- verifier_coherence.'),
    writeln(''),
    writeln('═══════════════════════════════════════════════════════════════════════════════'),
    nl.
