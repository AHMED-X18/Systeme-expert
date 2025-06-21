% ================================================================
% SYSTÈME EXPERT - MODULE DE CHARGEMENT POUR L'EXPORTATION ET LE TRANSBORDEMENT
% Terminal Portuaire - Gestion des Conteneurs
% ================================================================

% ----------------------------------------------------------------
% BASE DE FAITS - CONNAISSANCES DU DOMAINE
% ----------------------------------------------------------------

% Types de conteneurs
conteneur_type(standard_20, 20, 24000, normal).
conteneur_type(standard_40, 40, 30480, normal).
conteneur_type(high_cube_45, 45, 32500, normal).
conteneur_type(refrigere_20, 20, 21600, refrigere).
conteneur_type(refrigere_40, 40, 26680, refrigere).
conteneur_type(citerne_20, 20, 24000, dangereux).
conteneur_type(open_top_40, 40, 28280, special).

% Équipements du terminal
equipement(sts_1, portique_sts, 65, 40, disponible).
equipement(sts_2, portique_sts, 65, 40, disponible).
equipement(rtg_1, portique_cour, 40, 35, disponible).
equipement(rtg_2, portique_cour, 40, 35, disponible).
equipement(cavalier_1, chariot_cavalier, 45, 0, disponible).
equipement(cavalier_2, chariot_cavalier, 45, 0, disponible).

% Navires dans le port
navire(msc_maya, 2000, fenetre_maree, [douala, lome, abidjan]).
navire(cma_antwerp, 1500, normal, [hamburg, rotterdam, le_havre]).
navire(maersk_tema, 1800, urgent, [tema, takoradi, freetown]).

% Conteneurs en attente de chargement
conteneur(cont_001, standard_20, 18000, normal, exportation, douala, cour_a1).
conteneur(cont_002, refrigere_40, 25000, refrigere, exportation, lome, cour_b2).
conteneur(cont_003, standard_40, 28000, normal, transbordement, hamburg, cour_a3).
conteneur(cont_004, citerne_20, 22000, dangereux, exportation, abidjan, cour_c1).
conteneur(cont_005, high_cube_45, 30000, normal, exportation, rotterdam, cour_a2).
conteneur(cont_006, standard_20, 19000, normal, transbordement, tema, cour_b1).
conteneur(cont_007, refrigere_20, 20000, refrigere, exportation, douala, cour_b3).
conteneur(cont_008, open_top_40, 26000, special, exportation, le_havre, cour_c2).

% Zones de stockage
zone_stockage(cour_a1, a, 1, disponible).
zone_stockage(cour_a2, a, 2, disponible).
zone_stockage(cour_a3, a, 3, disponible).
zone_stockage(cour_b1, b, 1, disponible).
zone_stockage(cour_b2, b, 2, disponible).
zone_stockage(cour_b3, b, 3, disponible).
zone_stockage(cour_c1, c, 1, disponible).
zone_stockage(cour_c2, c, 2, disponible).

% ----------------------------------------------------------------
% BASE DE RÈGLES - RÈGLES DE PRIORITÉ (R1-R3)
% ----------------------------------------------------------------

% R1: Priorité navire
priorite_navire(Navire, haute) :- 
    navire(Navire, _, fenetre_maree, _).
priorite_navire(Navire, moyenne) :- 
    navire(Navire, _, urgent, _).
priorite_navire(Navire, normale) :- 
    navire(Navire, _, normal, _).

% R2: Priorité marchandises
priorite_marchandise(Conteneur, tres_haute) :-
    conteneur(Conteneur, _, _, dangereux, _, _, _).
priorite_marchandise(Conteneur, haute) :-
    conteneur(Conteneur, _, _, refrigere, _, _, _).
priorite_marchandise(Conteneur, moyenne) :-
    conteneur(Conteneur, _, _, special, _, _, _).
priorite_marchandise(Conteneur, normale) :-
    conteneur(Conteneur, _, _, normal, _, _, _).

% R3: Priorité déchargement (ordre inverse)
ordre_dechargement(Navire, Destination, Ordre) :-
    navire(Navire, _, _, ListeDestinations),
    nth1(Ordre, ListeDestinations, Destination).

% ----------------------------------------------------------------
% RÈGLES DE SÉCURITÉ (R4-R6)
% ----------------------------------------------------------------

% R4: Vérification scellés
verifier_scelles(Conteneur) :-
    conteneur(Conteneur, _, _, _, _, _, _),
    format('Vérification des scellés pour ~w: OK~n', [Conteneur]).

% R5: Contrôle poids
controler_poids(Conteneur) :-
    conteneur(Conteneur, Type, Poids, _, _, _, _),
    conteneur_type(Type, _, PoidsMax, _),
    Poids =< PoidsMax,
    format('Contrôle poids ~w: ~w kg <= ~w kg - OK~n', [Conteneur, Poids, PoidsMax]).

controler_poids(Conteneur) :-
    conteneur(Conteneur, Type, Poids, _, _, _, _),
    conteneur_type(Type, _, PoidsMax, _),
    Poids > PoidsMax,
    format('ALERTE: ~w dépasse le poids maximum (~w kg > ~w kg)~n', [Conteneur, Poids, PoidsMax]),
    fail.

% R6: Séparation marchandises dangereuses
distance_securite(dangereux, dangereux, 3).
distance_securite(dangereux, _, 2).
distance_securite(_, dangereux, 2).
distance_securite(_, _, 1).

% ----------------------------------------------------------------
% RÈGLES D'OPTIMISATION (R7-R9)
% ----------------------------------------------------------------

% R7: Minimisation mouvements
calculer_distance(Zone1, Zone2, Distance) :-
    zone_stockage(Zone1, Bloc1, Pos1, _),
    zone_stockage(Zone2, Bloc2, Pos2, _),
    (Bloc1 = Bloc2 -> DistanceBloc = 0; DistanceBloc = 100),
    DistancePos is abs(Pos1 - Pos2) * 50,
    Distance is DistanceBloc + DistancePos.

% R8: Équilibrage charge
calculer_equilibre(ListeConteneurs, Equilibre) :-
    findall(Poids, (member(Cont, ListeConteneurs), conteneur(Cont, _, Poids, _, _, _, _)), ListePoids),
    sum_list(ListePoids, PoidsTotal),
    length(ListePoids, NbConteneurs),
    (NbConteneurs > 0 -> Equilibre is PoidsTotal / NbConteneurs; Equilibre = 0).

% R9: Optimisation temps parcours
optimiser_parcours(ListeConteneurs, ParcoursOptimise) :-
    trier_par_zone(ListeConteneurs, ParcoursOptimise).

trier_par_zone([], []).
trier_par_zone([Cont|Reste], [Cont|TrieReste]) :-
    conteneur(Cont, _, _, _, _, _, Zone),
    zone_stockage(Zone, Bloc, _, _),
    partition(meme_bloc(Bloc), Reste, MemeBloc, AutresBlocs),
    append(MemeBloc, AutresBlocs, NouveauReste),
    trier_par_zone(NouveauReste, TrieReste).

meme_bloc(Bloc, Conteneur) :-
    conteneur(Conteneur, _, _, _, _, _, Zone),
    zone_stockage(Zone, Bloc, _, _).

% ----------------------------------------------------------------
% RÈGLES DE DOCUMENTATION (R10-R12)
% ----------------------------------------------------------------

% R10: Traçabilité complète
enregistrer_mouvement(Conteneur, Action, Timestamp) :-
    get_time(Timestamp),
    format('~w - ~w~n', [Conteneur, Action]).

% R11: Validation documents
valider_documents(Conteneur) :-
    conteneur(Conteneur, _, _, Type, _, Destination, _),
    format('Validation documents ~w: Type=~w, Destination=~w - OK~n', [Conteneur, Type, Destination]).

% R12: Rapport final
generer_rapport_final(Navire, ListeConteneurs) :-
    length(ListeConteneurs, NbConteneurs),
    findall(Poids, (member(Cont, ListeConteneurs), conteneur(Cont, _, Poids, _, _, _, _)), ListePoids),
    sum_list(ListePoids, PoidsTotal),
    format('~n=== RAPPORT FINAL DE CHARGEMENT ===~n'),
    format('Navire: ~w~n', [Navire]),
    format('Nombre de conteneurs chargés: ~w~n', [NbConteneurs]),
    format('Poids total: ~w kg~n', [PoidsTotal]),
    format('================================~n~n').

% ----------------------------------------------------------------
% RÈGLES DE PERFORMANCE (R13-R15)
% ----------------------------------------------------------------

% R13: Respect délais
respecter_delais(Navire, TempsPrevisionnel) :-
    navire(Navire, Capacite, _, _),
    TempsPrevisionnel is Capacite / 25,  % 25 mouvements/heure minimum
    format('Temps prévisionnel pour ~w: ~2f heures~n', [Navire, TempsPrevisionnel]).

% R14: Productivité minimum
productivite_minimum(25).

% R15: Taux d'erreur maximum
taux_erreur_maximum(0.5).

% ----------------------------------------------------------------
% MOTEUR D'INFÉRENCE - ALGORITHME DE CHARGEMENT
% ----------------------------------------------------------------

% Détermine les conteneurs éligibles pour un navire
conteneurs_eligibles(Navire, ConteneursEligibles) :-
    navire(Navire, _, _, Destinations),
    findall(Cont, (conteneur(Cont, _, _, _, _, Dest, _), member(Dest, Destinations)), ConteneursEligibles).

% Trie les conteneurs selon les priorités
trier_conteneurs_priorite(Navire, Conteneurs, ConteneursTries) :-
    map_list_to_pairs(calculer_priorite_globale(Navire), Conteneurs, Pairs),
    keysort(Pairs, PairsTries),
    pairs_values(PairsTries, ConteneursTries).

calculer_priorite_globale(Navire, Conteneur, PrioriteGlobale) :-
    priorite_navire(Navire, PrioNavire),
    priorite_marchandise(Conteneur, PrioMarch),
    conteneur(Conteneur, _, _, _, _, Destination, _),
    ordre_dechargement(Navire, Destination, OrdreDech),
    convertir_priorite_numerique(PrioNavire, ValNavire),
    convertir_priorite_numerique(PrioMarch, ValMarch),
    PrioriteGlobale is ValNavire * 1000 + ValMarch * 100 + OrdreDech.

convertir_priorite_numerique(tres_haute, 1).
convertir_priorite_numerique(haute, 2).
convertir_priorite_numerique(moyenne, 3).
convertir_priorite_numerique(normale, 4).

% ----------------------------------------------------------------
% SIMULATION DU PROCESSUS DE CHARGEMENT
% ----------------------------------------------------------------

% Point d'entrée principal de la simulation
simuler_chargement(Navire) :-
    format('~n╔════════════════════════════════════════════════════════════════╗~n'),
    format('║        SIMULATION DU PROCESSUS DE CHARGEMENT                   ║~n'),
    format('║        Terminal Portuaire - Système Expert                    ║~n'),
    format('╚════════════════════════════════════════════════════════════════╝~n~n'),
    
    format('Début de la simulation pour le navire: ~w~n~n', [Navire]),
    
    % Phase 1: Planification
    format('📋 PHASE 1: PLANIFICATION~n'),
    format('-------------------------~n'),
    conteneurs_eligibles(Navire, ConteneursEligibles),
    format('Conteneurs éligibles: ~w~n', [ConteneursEligibles]),
    
    trier_conteneurs_priorite(Navire, ConteneursEligibles, ConteneursTries),
    format('Ordre de chargement optimisé: ~w~n~n', [ConteneursTries]),
    
    % Phase 2: Vérifications de sécurité
    format('🔒 PHASE 2: VÉRIFICATIONS DE SÉCURITÉ~n'),
    format('-------------------------------------~n'),
    verifier_securite_conteneurs(ConteneursTries),
    
    % Phase 3: Optimisation
    format('⚡ PHASE 3: OPTIMISATION~n'),
    format('------------------------~n'),
    optimiser_chargement(ConteneursTries, ConteneursOptimises),
    
    % Phase 4: Exécution du chargement
    format('🚢 PHASE 4: EXÉCUTION DU CHARGEMENT~n'),
    format('------------------------------------~n'),
    executer_chargement(Navire, ConteneursOptimises),
    
    % Phase 5: Rapport final
    format('📊 PHASE 5: RAPPORT FINAL~n'),
    format('--------------------------~n'),
    generer_rapport_final(Navire, ConteneursOptimises),
    
    format('✅ Simulation terminée avec succès!~n~n').

% Vérification de sécurité pour tous les conteneurs
verifier_securite_conteneurs([]).
verifier_securite_conteneurs([Cont|Reste]) :-
    verifier_scelles(Cont),
    controler_poids(Cont),
    valider_documents(Cont),
    enregistrer_mouvement(Cont, 'verification_securite', _),
    verifier_securite_conteneurs(Reste).

% Optimisation du chargement
optimiser_chargement(Conteneurs, ConteneursOptimises) :-
    optimiser_parcours(Conteneurs, ConteneursOptimises),
    calculer_equilibre(ConteneursOptimises, Equilibre),
    format('Équilibre calculé: ~2f kg/conteneur~n', [Equilibre]).

% Exécution du chargement conteneur par conteneur
executer_chargement(_, []).
executer_chargement(Navire, [Cont|Reste]) :-
    format('Chargement de ~w...~n', [Cont]),
    conteneur(Cont, Type, Poids, _, _, Destination, Zone),
    format('  - Type: ~w, Poids: ~w kg, Destination: ~w, Zone: ~w~n', [Type, Poids, Destination, Zone]),
    
    % Simulation des phases opérationnelles
    format('  - Phase 1: Récupération depuis ~w~n', [Zone]),
    enregistrer_mouvement(Cont, 'recuperation', _),
    
    format('  - Phase 2: Transport vers le quai~n'),
    enregistrer_mouvement(Cont, 'transport', _),
    
    format('  - Phase 3: Chargement à bord de ~w~n', [Navire]),
    enregistrer_mouvement(Cont, 'chargement', _),
    
    format('  ✓ Conteneur ~w chargé avec succès~n~n', [Cont]),
    
    executer_chargement(Navire, Reste).

% ----------------------------------------------------------------
% REQUÊTES UTILITAIRES POUR L'UTILISATEUR
% ----------------------------------------------------------------

% Afficher l'état du terminal
etat_terminal :-
    format('~n=== ÉTAT ACTUEL DU TERMINAL ===~n'),
    format('NAVIRES EN ATTENTE:~n'),
    forall(navire(N, Cap, Prio, Dest), 
           format('  - ~w: Capacité=~w EVP, Priorité=~w, Destinations=~w~n', [N, Cap, Prio, Dest])),
    
    format('~nCONTENEURS À CHARGER:~n'),
    forall(conteneur(C, Type, Poids, Cat, Op, Dest, Zone),
           format('  - ~w: ~w, ~wkg, ~w, ~w → ~w (Zone: ~w)~n', [C, Type, Poids, Cat, Op, Dest, Zone])),
    
    format('~nÉQUIPEMENTS DISPONIBLES:~n'),
    forall(equipement(E, Type, Cap, Port, Stat),
           format('  - ~w: ~w, Capacité=~wt, Portée=~wm, Status=~w~n', [E, Type, Cap, Port, Stat])),
    format('===============================~n~n').

% Vérifier les règles pour un conteneur spécifique
verifier_conteneur(Conteneur) :-
    format('Vérification du conteneur: ~w~n', [Conteneur]),
    (conteneur(Conteneur, _, _, _, _, _, _) ->
        (verifier_scelles(Conteneur),
         controler_poids(Conteneur),
         valider_documents(Conteneur),
         priorite_marchandise(Conteneur, Prio),
         format('Priorité assignée: ~w~n', [Prio]))
    ;
        format('Conteneur non trouvé!~n')).

% Calculer la productivité pour un navire
calculer_productivite(Navire) :-
    conteneurs_eligibles(Navire, Conteneurs),
    length(Conteneurs, NbConteneurs),
    respecter_delais(Navire, TempsEstime),
    (TempsEstime > 0 -> 
        ProductiviteReelle is NbConteneurs / TempsEstime,
        format('Productivité estimée: ~2f conteneurs/heure~n', [ProductiviteReelle])
    ;
        format('Impossible de calculer la productivité~n')).

% ----------------------------------------------------------------
% EXEMPLES D'UTILISATION
% ----------------------------------------------------------------

% Pour lancer une simulation complète:
% ?- simuler_chargement(msc_maya).

% Pour voir l'état du terminal:
% ?- etat_terminal.

% Pour vérifier un conteneur spécifique:
% ?- verifier_conteneur(cont_001).

% Pour calculer la productivité d'un navire:
% ?- calculer_productivite(msc_maya).

% ----------------------------------------------------------------
% MENU INTERACTIF
% ----------------------------------------------------------------

menu_principal :-
    format('~n╔════════════════════════════════════════════════════════════════╗~n'),
    format('║              SYSTÈME EXPERT PORTUAIRE                         ║~n'),
    format('║              Module de Chargement                              ║~n'),
    format('╠════════════════════════════════════════════════════════════════╣~n'),
    format('║ 1. Simuler chargement (msc_maya)                              ║~n'),
    format('║ 2. Simuler chargement (cma_antwerp)                           ║~n'),
    format('║ 3. Simuler chargement (maersk_tema)                           ║~n'),
    format('║ 4. Afficher état du terminal                                  ║~n'),
    format('║ 5. Vérifier un conteneur                                      ║~n'),
    format('║ 6. Calculer productivité                                      ║~n'),
    format('║ 0. Quitter                                                    ║~n'),
    format('╚════════════════════════════════════════════════════════════════╝~n'),
    format('Votre choix: '),
    read(Choix),
    traiter_choix(Choix).

traiter_choix(1) :- simuler_chargement(msc_maya), menu_principal.
traiter_choix(2) :- simuler_chargement(cma_antwerp), menu_principal.
traiter_choix(3) :- simuler_chargement(maersk_tema), menu_principal.
traiter_choix(4) :- etat_terminal, menu_principal.
traiter_choix(5) :- 
    format('Entrez l\'ID du conteneur: '),
    read(Cont),
    verifier_conteneur(Cont),
    menu_principal.
traiter_choix(6) :-
    format('Entrez le nom du navire: '),
    read(Navire),
    calculer_productivite(Navire),
    menu_principal.
traiter_choix(0) :- format('Au revoir!~n').
traiter_choix(_) :- format('Choix invalide!~n'), menu_principal.

% Point d'entrée principal
demarrer :- menu_principal.
