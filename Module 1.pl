% ===============================================================================
% SYSTÈME EXPERT - MODULE 1: GESTION DES ARRIVAGES DE NAVIRES
% Port Autonome de Kribi - Version SWISH Compatible
% ===============================================================================

% Suppression des avertissements pour les prédicats dynamiques
:- dynamic(navire/7).
:- dynamic(quai/4).
:- dynamic(zone_empilage/3).
:- dynamic(manifeste/2).
:- dynamic(douane/2).
:- dynamic(meteo/2).
:- dynamic(pilote/2).
:- dynamic(remorqueur/2).
:- dynamic(reservation_quai/3).
:- dynamic(planning_log/4).
:- dynamic(compteur_timestamp/1).

% ===============================================================================
% BASE DE FAITS INITIALE
% ===============================================================================

% État des navires: navire(ID, Longueur, TirantEau, EVP, Destinations, Priorite, Statut)
navire(nav001, 280, 14, 2500, [douala, yaounde], 1, en_approche).
navire(nav002, 320, 16, 3200, [kribi], 2, signale).
navire(nav003, 180, 10, 1200, [douala], 1, en_rade).
navire(nav004, 400, 18, 4500, [bafoussam, douala], 3, en_attente).

% Configuration des quais: quai(ID, LongueurMax, ProfondeurMax, NbPortiques)
quai(quai_a, 350, 16, 4).
quai(quai_b, 200, 12, 2).
quai(quai_c, 450, 20, 6).
quai(quai_d, 300, 15, 3).

% Zones d'empilage: zone_empilage(ID, CapaciteEVP, Terminal)
zone_empilage(zone1, 2000, terminal1).
zone_empilage(zone2, 3000, terminal2).
zone_empilage(zone3, 5000, terminal3).
zone_empilage(zone4, 1500, terminal1).

% Manifestes des navires: manifeste(NavireID, ListeConteneurs)
manifeste(nav001, [
    conteneur(ctr001, 20, electronique, douala, normal),
    conteneur(ctr002, 40, textiles, douala, normal),
    conteneur(ctr003, 20, produits_alimentaires, yaounde, refrigere)
]).

manifeste(nav002, [
    conteneur(ctr004, 40, machines, kribi, lourd),
    conteneur(ctr005, 20, pieces_auto, kribi, normal)
]).

manifeste(nav003, [
    conteneur(ctr006, 20, medicaments, douala, fragile)
]).

% État douanier: douane(NavireID, Statut)
douane(nav001, valide).
douane(nav002, en_cours).
douane(nav003, valide).
douane(nav004, invalide).

% Conditions météorologiques: meteo(Date, Conditions)
meteo('2025-06-21', bon).
meteo('2025-06-22', venteux).
meteo('2025-06-23', tempete).

% Pilotes: pilote(ID, Statut)
pilote(pilote1, disponible).
pilote(pilote2, occupe).
pilote(pilote3, disponible).

% Remorqueurs: remorqueur(ID, Statut)
remorqueur(rem1, disponible).
remorqueur(rem2, maintenance).
remorqueur(rem3, disponible).

% Compteur pour les timestamps
compteur_timestamp(1000).

% ===============================================================================
% RÈGLES MÉTIER DU SYSTÈME EXPERT
% ===============================================================================

% Règle principale: Vérification de la compatibilité quai-navire
quai_compatible(NavireID, QuaiID) :-
    navire(NavireID, Longueur, TirantEau, _, _, _, _),
    quai(QuaiID, LongueurMax, ProfondeurMax, _),
    Longueur =< LongueurMax,
    TirantEau =< ProfondeurMax.

% Vérification des ressources nécessaires
ressources_suffisantes(NavireID, QuaiID) :-
    navire(NavireID, _, _, EVP, _, _, _),
    quai(QuaiID, _, _, NbPortiques),
    PortiquesRequis is ceil(EVP / 800),
    PortiquesRequis =< NbPortiques.

% Validation des conditions d'arrivée
peut_accoster(NavireID, Date) :-
    douane_valide(NavireID),
    conditions_meteo_acceptables(Date),
    pilote_disponible,
    remorqueur_disponible.

% Vérification douanière
douane_valide(NavireID) :-
    douane(NavireID, valide).

% Vérification météorologique
conditions_meteo_acceptables(Date) :-
    meteo(Date, Conditions),
    Conditions \= tempete,
    Conditions \= cyclone.

% Disponibilité des pilotes
pilote_disponible :-
    pilote(_, disponible).

% Disponibilité des remorqueurs
remorqueur_disponible :-
    remorqueur(_, disponible).

% Validation du manifeste
manifeste_valide(NavireID) :-
    navire(NavireID, _, _, _, Destinations, _, _),
    manifeste(NavireID, Conteneurs),
    forall(
        member(conteneur(_, _, _, DestConteneur, _), Conteneurs),
        member(DestConteneur, Destinations)
    ).

% Planification de l'empilage
planifier_empilage(NavireID, ZoneID) :-
    navire(NavireID, _, _, EVP, _, _, _),
    zone_empilage(ZoneID, Capacite, _),
    Capacite >= EVP.

% Inspection pré-arrivée
inspecter_pre_arrivee(NavireID) :-
    navire(NavireID, _, _, _, _, _, _),
    format('🔍 Inspection pré-arrivée du navire ~w~n', [NavireID]),
    
    % Vérification du manifeste
    (   manifeste_valide(NavireID)
    ->  format('   ✅ Manifeste cohérent~n')
    ;   format('   ❌ Manifeste incohérent - Vérification requise~n')
    ),
    
    % Vérification de la documentation
    (   douane_valide(NavireID)
    ->  format('   ✅ Documentation douanière valide~n')
    ;   format('   ⚠️  Documentation douanière à régulariser~n')
    ).

% Affectation des ressources
affecter_ressources(NavireID) :-
    pilote(PiloteID, disponible),
    remorqueur(RemID, disponible),
    !,
    retract(pilote(PiloteID, disponible)),
    assertz(pilote(PiloteID, occupe)),
    retract(remorqueur(RemID, disponible)),
    assertz(remorqueur(RemID, occupe)),
    format('👨‍✈️ Pilote ~w affecté au navire ~w~n', [PiloteID, NavireID]),
    format('🚢 Remorqueur ~w affecté au navire ~w~n', [RemID, NavireID]).

affecter_ressources(NavireID) :-
    format('❌ Ressources insuffisantes pour le navire ~w~n', [NavireID]).

% Réserver un quai
reserver_quai(NavireID, QuaiID, Date) :-
    \+ reservation_quai(QuaiID, _, Date),
    assertz(reservation_quai(QuaiID, NavireID, Date)),
    format('📋 Quai ~w réservé pour le navire ~w le ~w~n', [QuaiID, NavireID, Date]).

% Générateur de timestamp simple
generer_timestamp(Timestamp) :-
    retract(compteur_timestamp(Current)),
    Timestamp is Current + 1,
    assertz(compteur_timestamp(Timestamp)).

% Enregistrement dans le système de planification
enregistrer_planification(NavireID, Action) :-
    generer_timestamp(Timestamp),
    assertz(planning_log(arrivage, NavireID, Action, Timestamp)),
    format('📊 Action ~w enregistrée pour le navire ~w~n', [Action, NavireID]).

% Processus complet de planification d'arrivée
planifier_arrivee(NavireID, Date) :-
    peut_accoster(NavireID, Date),
    quai_compatible(NavireID, QuaiID),
    ressources_suffisantes(NavireID, QuaiID),
    planifier_empilage(NavireID, ZoneID),
    !,
    format('~n🚢 PLANIFICATION ARRIVÉE: Navire ~w~n', [NavireID]),
    format('==========================================~n'),
    inspecter_pre_arrivee(NavireID),
    affecter_ressources(NavireID),
    reserver_quai(NavireID, QuaiID, Date),
    enregistrer_planification(NavireID, planifie),
    format('~n📋 PLAN D\'ARRIVÉE VALIDÉ:~n'),
    format('   • Navire: ~w~n', [NavireID]),
    format('   • Quai attribué: ~w~n', [QuaiID]),
    format('   • Zone d\'empilage: ~w~n', [ZoneID]),
    format('   • Date programmée: ~w~n', [Date]),
    format('✅ Planification terminée pour le navire ~w~n', [NavireID]),
    format('==========================================~n').

planifier_arrivee(NavireID, Date) :-
    format('❌ Impossible de planifier l\'arrivée du navire ~w le ~w~n', [NavireID, Date]),
    format('   Vérifiez: conditions météo, documentation, disponibilité quais~n').

% Traitement de tous les navires en attente
planifier_tous_arrivages(Date) :-
    format('~n🚢 PLANIFICATION GLOBALE DES ARRIVAGES~n'),
    format('======================================~n'),
    findall(N, (navire(N, _, _, _, _, _, Statut), 
                member(Statut, [en_approche, signale, en_rade, en_attente])), 
            Navires),
    (   Navires = []
    ->  format('ℹ️  Aucun navire en attente d\'arrivée~n')
    ;   length(Navires, Nb),
        format('📋 ~w navires à planifier~n', [Nb]),
        forall(member(N, Navires), planifier_arrivee(N, Date))
    ),
    format('🏁 PLANIFICATION GLOBALE TERMINÉE~n'),
    format('======================================~n').

% ===============================================================================
% PRÉDICATS D'INTERFACE ET DE GESTION
% ===============================================================================

% Affichage de l'état complet du système
afficher_etat_systeme :-
    format('~n📊 ÉTAT ACTUEL DU SYSTÈME D\'ARRIVAGES~n'),
    format('=====================================~n'),
    
    % Navires
    format('🚢 NAVIRES:~n'),
    forall(navire(N, L, T, EVP, _, P, S), 
           format('   • ~w: ~wm, ~wm, ~w EVP, Priorité ~w, Statut: ~w~n', 
                  [N, L, T, EVP, P, S])),
    
    % Quais
    format('~n⚓ QUAIS:~n'),
    forall(quai(Q, L, P, Port), 
           format('   • ~w: ~wm×~wm, ~w portiques~n', [Q, L, P, Port])),
    
    % Zones d'empilage
    format('~n📦 ZONES D\'EMPILAGE:~n'),
    forall(zone_empilage(Z, Cap, Term), 
           format('   • ~w: ~w EVP, ~w~n', [Z, Cap, Term])),
    
    % Ressources
    format('~n👨‍✈️ PILOTES:~n'),
    forall(pilote(P, S), 
           format('   • ~w: ~w~n', [P, S])),
    
    format('~n🚢 REMORQUEURS:~n'),
    forall(remorqueur(R, S), 
           format('   • ~w: ~w~n', [R, S])),
    
    % Réservations
    format('~n📋 RÉSERVATIONS DE QUAIS:~n'),
    (   reservation_quai(_, _, _)
    ->  forall(reservation_quai(Q, N, D), 
               format('   • Quai ~w réservé par ~w pour le ~w~n', [Q, N, D]))
    ;   format('   • Aucune réservation active~n')
    ),
    
    format('~n=====================================~n').

% Diagnostic du système d'arrivages
diagnostiquer_systeme :-
    format('~n🔍 DIAGNOSTIC DU SYSTÈME D\'ARRIVAGES~n'),
    format('====================================~n'),
    
    % Navires en attente
    findall(N, (navire(N, _, _, _, _, _, S), 
                member(S, [en_approche, signale, en_rade, en_attente])), 
            NaviresAttente),
    length(NaviresAttente, NbAttente),
    format('📊 Navires en attente: ~w~n', [NbAttente]),
    
    % Quais disponibles
    findall(Q, quai(Q, _, _, _), TousQuais),
    length(TousQuais, NbQuaisTotal),
    format('⚓ Quais disponibles: ~w~n', [NbQuaisTotal]),
    
    % Zones d'empilage
    findall(Z, zone_empilage(Z, _, _), ToutesZones),
    length(ToutesZones, NbZones),
    format('📦 Zones d\'empilage: ~w~n', [NbZones]),
    
    % Ressources humaines
    findall(P, pilote(P, disponible), PilotesLibres),
    length(PilotesLibres, NbPilotes),
    format('👨‍✈️ Pilotes disponibles: ~w~n', [NbPilotes]),
    
    findall(R, remorqueur(R, disponible), RemorqueursLibres),
    length(RemorqueursLibres, NbRemorqueurs),
    format('🚢 Remorqueurs disponibles: ~w~n', [NbRemorqueurs]),
    
    % Problèmes douaniers
    findall(N, douane(N, invalide), ProblemeDouane),
    length(ProblemeDouane, NbProblemes),
    (   NbProblemes > 0
    ->  format('⚠️  Problèmes douaniers: ~w navires~n', [NbProblemes])
    ;   format('✅ Aucun problème douanier~n')
    ),
    
    % Conditions météo
    meteo('2025-06-21', Conditions),
    (   member(Conditions, [bon, venteux])
    ->  format('✅ Conditions météo acceptables: ~w~n', [Conditions])
    ;   format('⚠️  Conditions météo défavorables: ~w~n', [Conditions])
    ),
    
    format('====================================~n').

% Gestion des priorités
traiter_priorites :-
    format('~n🎯 TRAITEMENT PAR PRIORITÉS~n'),
    format('===========================~n'),
    findall(P-N, (navire(N, _, _, _, _, P, S), 
                  member(S, [en_approche, signale, en_rade, en_attente])), 
            PrioriteNavires),
    keysort(PrioriteNavires, PrioritesTries),
    forall(member(P-N, PrioritesTries),
           format('   Priorité ~w: Navire ~w~n', [P, N])),
    format('===========================~n').

% Mise à jour du statut d'un navire
mettre_a_jour_statut(NavireID, NouveauStatut) :-
    retract(navire(NavireID, L, T, EVP, Dest, P, _)),
    assertz(navire(NavireID, L, T, EVP, Dest, P, NouveauStatut)),
    format('📝 Statut du navire ~w mis à jour: ~w~n', [NavireID, NouveauStatut]).

% Libération des ressources
liberer_ressources_navire(NavireID) :-
    format('🔄 Libération des ressources pour ~w~n', [NavireID]),
    % Libérer un pilote occupé (le premier trouvé)
    (   retract(pilote(PiloteID, occupe))
    ->  assertz(pilote(PiloteID, disponible)),
        format('👨‍✈️ Pilote ~w libéré~n', [PiloteID])
    ;   format('ℹ️  Aucun pilote à libérer~n')
    ),
    % Libérer un remorqueur occupé (le premier trouvé)
    (   retract(remorqueur(RemID, occupe))
    ->  assertz(remorqueur(RemID, disponible)),
        format('🚢 Remorqueur ~w libéré~n', [RemID])
    ;   format('ℹ️  Aucun remorqueur à libérer~n')
    ).

% Ajouter un nouveau navire
ajouter_navire(ID, Longueur, TirantEau, EVP, Destinations, Priorite) :-
    assertz(navire(ID, Longueur, TirantEau, EVP, Destinations, Priorite, signale)),
    assertz(douane(ID, en_cours)),
    format('🚢 Nouveau navire ~w ajouté au système~n', [ID]).

% Affichage du journal de planification
afficher_journal :-
    format('~n📋 JOURNAL DE PLANIFICATION~n'),
    format('============================~n'),
    (   planning_log(_, _, _, _)
    ->  forall(planning_log(Type, Navire, Action, Time), 
               format('• ~w ~w: ~w (ref: ~w)~n', [Type, Navire, Action, Time]))
    ;   format('• Aucune opération enregistrée~n')
    ),
    format('============================~n').

% Réinitialisation du système
reinitialiser_systeme :-
    format('🔄 Réinitialisation du système en cours...~n'),
    retractall(planning_log(_, _, _, _)),
    retractall(reservation_quai(_, _, _)),
    % Réinitialiser les pilotes
    retractall(pilote(_, _)),
    assertz(pilote(pilote1, disponible)),
    assertz(pilote(pilote2, occupe)),
    assertz(pilote(pilote3, disponible)),
    % Réinitialiser les remorqueurs
    retractall(remorqueur(_, _)),
    assertz(remorqueur(rem1, disponible)),
    assertz(remorqueur(rem2, maintenance)),
    assertz(remorqueur(rem3, disponible)),
    % Réinitialiser le compteur
    retractall(compteur_timestamp(_)),
    assertz(compteur_timestamp(1000)),
    format('✅ Système réinitialisé avec succès!~n').

% ===============================================================================
% PRÉDICATS UTILITAIRES ET TESTS RAPIDES
% ===============================================================================

% Test rapide de planification
test_planification :-
    format('🧪 TEST RAPIDE DE PLANIFICATION~n'),
    format('===============================~n'),
    planifier_arrivee(nav001, '2025-06-21'),
    planifier_arrivee(nav003, '2025-06-21').

% Vérification de l'intégrité du système
verifier_integrite :-
    format('🔍 Vérification de l\'intégrité du système...~n'),
    
    % Vérifier la cohérence des manifestes
    forall(manifeste(N, _), 
           (navire(N, _, _, _, _, _, _) -> true ; 
            format('❌ Erreur: Manifeste pour navire inexistant ~w~n', [N]))),
    
    % Vérifier les réservations
    forall(reservation_quai(Q, N, _), 
           ((quai(Q, _, _, _), navire(N, _, _, _, _, _, _)) -> true ; 
            format('❌ Erreur: Réservation invalide ~w-~w~n', [Q, N]))),
    
    format('✅ Vérification terminée~n').

% Affichage des règles disponibles
afficher_aide :-
    format('~n📖 AIDE - COMMANDES DISPONIBLES~n'),
    format('================================~n'),
    format('• afficher_etat_systeme. - Voir l\'état complet~n'),
    format('• diagnostiquer_systeme. - Diagnostic rapide~n'),
    format('• planifier_tous_arrivages(\'2025-06-21\'). - Planifier tous~n'),
    format('• planifier_arrivee(nav001, \'2025-06-21\'). - Planifier un navire~n'),
    format('• test_planification. - Test rapide~n'),
    format('• traiter_priorites. - Voir les priorités~n'),
    format('• afficher_journal. - Voir le journal~n'),
    format('• verifier_integrite. - Vérifier le système~n'),
    format('• reinitialiser_systeme. - Remettre à zéro~n'),
    format('================================~n').

% ===============================================================================
% POINT D'ENTRÉE PRINCIPAL
% ===============================================================================

% Démarrage simplifié pour SWISH
demarrer_systeme :-
    format('🚀 SYSTÈME EXPERT - GESTION DES ARRIVAGES~n'),
    format('=========================================~n'),
    format('Port Autonome de Kribi - Module 1~n'),
    format('Version SWISH Compatible~n~n'),
    format('📋 Commandes disponibles:~n'),
    afficher_aide,
    format('~n🎯 Pour commencer, essayez: test_planification.~n').

% Point d'entrée alternatif
demo :-
    demarrer_systeme,
    format('~n🎮 DÉMONSTRATION AUTOMATIQUE~n'),
    format('============================~n'),
    afficher_etat_systeme,
    diagnostiquer_systeme,
    test_planification.

% ===============================================================================
% Pour utiliser le système dans SWISH:
% 1. ?- demarrer_systeme.
% 2. ?- test_planification.
% 3. ?- demo.
% ===============================================================================
