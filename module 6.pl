% Expert System for Container Land Transport and Port Exit
% MODULE 6 - TRANSPORT TERRESTRE ET SORTIE DU PORT

% KNOWLEDGE BASE
% Acteurs du système
actor(chauffeurs).
actor(operateurs_ferroviaires).
actor(agents_de_securite).
actor(transitaires).
actor(operateurs_logistiques).

% Types de véhicules de transport
vehicule(camion).
vehicule(train).
vehicule(wagon).

% Types de documents de transport
document(bon_de_livraison).
document(lettre_de_voiture).
document(autorisation_sortie).
document(document_identite_chauffeur).

% Activités du processus
activity(coordination_transporteurs).
activity(chargement_conteneurs).
activity(controle_sortie_portes).
activity(gestion_flux_circulation).

% États des portes du port
porte(porte_nord).
porte(porte_sud).
porte(porte_est).

% ===== SAMPLE DATA / DONNÉES D'EXEMPLE =====

% Conteneurs prêts pour le transport
pret_transport(cnt001).
pret_transport(cnt002).
pret_transport(cnt003).

% Assignation des transporteurs
transporteur_assigne(cnt001, trans001).
transporteur_assigne(cnt002, trans002).
transporteur_assigne(cnt003, trans003).

% Types de transporteurs
type_transporteur(trans001, camion).
type_transporteur(trans002, train).
type_transporteur(trans003, camion).

% Disponibilité des transporteurs
disponible(trans001).
disponible(trans002).
indisponible(trans003).

% Documents de transport
a_bon_livraison(cnt001).
a_bon_livraison(cnt002).
a_lettre_voiture(cnt001).
a_lettre_voiture(cnt003).
a_autorisation_sortie(cnt001).
a_autorisation_sortie(cnt002).

% Identité des chauffeurs
chauffeur_identifie(trans001, chauffeur_001).
chauffeur_identifie(trans003, chauffeur_002).

% Chargement des conteneurs
charge(cnt001).
charge(cnt002).

% Contrôles de sécurité
controle_securite_ok(cnt001).
controle_securite_ok(cnt002).
controle_securite_echec(cnt003).

% Assignation des portes de sortie
porte_assignee(cnt001, porte_nord).
porte_assignee(cnt002, porte_sud).
porte_assignee(cnt003, porte_est).

% État des portes (ouvert/fermé)
porte_ouverte(porte_nord).
porte_ouverte(porte_sud).
porte_fermee(porte_est).

% Temps de sortie estimé (en minutes)
temps_sortie_estime(cnt001, 30).
temps_sortie_estime(cnt002, 45).
temps_sortie_estime(cnt003, 60).

% Conteneurs sortis du port
sorti_du_port(cnt001).

% ===== RÈGLES DE BASE / BASE RULES =====

% Vérification des documents de transport complets
documents_transport_complets(Conteneur) :-
    a_bon_livraison(Conteneur),
    a_lettre_voiture(Conteneur),
    a_autorisation_sortie(Conteneur).

% Vérification de l'identité du chauffeur
chauffeur_valide(Transporteur) :-
    chauffeur_identifie(Transporteur, _).

% Vérification de la disponibilité du transport
transport_disponible(Transporteur) :-
    disponible(Transporteur).

% ===== RÈGLES DU PROCESSUS / PROCESS RULES =====

% Étape 1 : Coordination avec les transporteurs
coordonner_transporteurs(Conteneur) :-
    transporteur_assigne(Conteneur, Transporteur),
    transport_disponible(Transporteur),
    format('Coordination réussie: Transporteur ~w assigné au conteneur ~w.~n', [Transporteur, Conteneur]).

coordonner_transporteurs(Conteneur) :-
    transporteur_assigne(Conteneur, Transporteur),
    \+ transport_disponible(Transporteur),
    format('PROBLÈME: Transporteur ~w non disponible pour le conteneur ~w.~n', [Transporteur, Conteneur]).

coordonner_transporteurs(Conteneur) :-
    \+ transporteur_assigne(Conteneur, _),
    format('ERREUR: Aucun transporteur assigné au conteneur ~w.~n', [Conteneur]).

% Étape 2 : Chargement des conteneurs
charger_conteneur(Conteneur) :-
    pret_transport(Conteneur),
    transporteur_assigne(Conteneur, Transporteur),
    transport_disponible(Transporteur),
    charge(Conteneur),
    format('Conteneur ~w chargé avec succès sur le transporteur ~w.~n', [Conteneur, Transporteur]).

charger_conteneur(Conteneur) :-
    pret_transport(Conteneur),
    transporteur_assigne(Conteneur, Transporteur),
    transport_disponible(Transporteur),
    \+ charge(Conteneur),
    format('Chargement en cours pour le conteneur ~w.~n', [Conteneur]).

charger_conteneur(Conteneur) :-
    \+ pret_transport(Conteneur),
    format('ERREUR: Conteneur ~w pas prêt pour le transport.~n', [Conteneur]).

% Étape 3 : Contrôle de sortie aux portes
controler_sortie(Conteneur) :-
    documents_transport_complets(Conteneur),
    transporteur_assigne(Conteneur, Transporteur),
    chauffeur_valide(Transporteur),
    controle_securite_ok(Conteneur),
    porte_assignee(Conteneur, Porte),
    porte_ouverte(Porte),
    format('Contrôle de sortie réussi: Conteneur ~w autorisé à sortir par la ~w.~n', [Conteneur, Porte]).

controler_sortie(Conteneur) :-
    porte_assignee(Conteneur, Porte),
    porte_fermee(Porte),
    format('ATTENTE: La ~w est fermée pour le conteneur ~w.~n', [Porte, Conteneur]).

controler_sortie(Conteneur) :-
    controle_securite_echec(Conteneur),
    format('BLOCAGE: Échec du contrôle de sécurité pour le conteneur ~w.~n', [Conteneur]).

controler_sortie(Conteneur) :-
    \+ documents_transport_complets(Conteneur),
    format('REFUS: Documents de transport incomplets pour le conteneur ~w.~n', [Conteneur]).

% Étape 4 : Gestion des flux de circulation
gerer_flux(Conteneur) :-
    temps_sortie_estime(Conteneur, Temps),
    Temps =< 30,
    format('Flux optimal: Sortie rapide prévue en ~w minutes pour le conteneur ~w.~n', [Temps, Conteneur]).

gerer_flux(Conteneur) :-
    temps_sortie_estime(Conteneur, Temps),
    Temps > 30,
    Temps =< 60,
    format('Flux modéré: Sortie prévue en ~w minutes pour le conteneur ~w.~n', [Temps, Conteneur]).

gerer_flux(Conteneur) :-
    temps_sortie_estime(Conteneur, Temps),
    Temps > 60,
    format('Flux dense: Attente prolongée de ~w minutes pour le conteneur ~w.~n', [Temps, Conteneur]).

% Règle auxiliaire pour vérifier si un conteneur peut sortir du port
peut_sortir_port(Conteneur) :-
    pret_transport(Conteneur),
    transporteur_assigne(Conteneur, Transporteur),
    transport_disponible(Transporteur),
    documents_transport_complets(Conteneur),
    chauffeur_valide(Transporteur),
    charge(Conteneur),
    controle_securite_ok(Conteneur),
    porte_assignee(Conteneur, Porte),
    porte_ouverte(Porte).

% Étape finale : Sortie du port
sortir_du_port(Conteneur) :-
    peut_sortir_port(Conteneur),
    format('SUCCÈS: Le conteneur ~w a quitté le port avec succès.~n', [Conteneur]).

sortir_du_port(Conteneur) :-
    \+ peut_sortir_port(Conteneur),
    format('ÉCHEC: Le conteneur ~w ne peut pas sortir du port.~n', [Conteneur]),
    afficher_problemes_transport(Conteneur).

% ===== SYSTÈME D'INTERACTION UTILISATEUR / USER INTERACTION SYSTEM =====

% Menu principal
menu_principal :-
    nl,
    write('=== SYSTÈME DE TRANSPORT TERRESTRE ==='), nl,
    write('1. Vérifier un conteneur'), nl,
    write('2. Traiter transport complet'), nl,
    write('3. Lister les conteneurs en transport'), nl,
    write('4. Ajouter des données de transport'), nl,
    write('5. Diagnostic transport complet'), nl,
    write('6. Gérer les flux de circulation'), nl,
    write('7. Quitter'), nl,
    write('Choisissez une option (1-7): '),
    read(Choix),
    traiter_choix(Choix).

% Traitement des choix du menu
traiter_choix(1) :-
    write('Entrez l\'ID du conteneur: '),
    read(Conteneur),
    verifier_transport_conteneur(Conteneur),
    menu_principal.

traiter_choix(2) :-
    write('Entrez l\'ID du conteneur: '),
    read(Conteneur),
    traiter_transport_complet(Conteneur),
    menu_principal.

traiter_choix(3) :-
    lister_conteneurs_transport,
    menu_principal.

traiter_choix(4) :-
    ajouter_donnees_transport,
    menu_principal.

traiter_choix(5) :-
    write('Entrez l\'ID du conteneur: '),
    read(Conteneur),
    diagnostic_transport_complet(Conteneur),
    menu_principal.

traiter_choix(6) :-
    gerer_flux_global,
    menu_principal.

traiter_choix(7) :-
    write('Au revoir!'), nl.

traiter_choix(_) :-
    write('Option invalide. Réessayez.'), nl,
    menu_principal.

% Vérification transport d'un conteneur
verifier_transport_conteneur(Conteneur) :-
    nl,
    format('=== VÉRIFICATION TRANSPORT DU CONTENEUR ~w ===~n', [Conteneur]),
    coordonner_transporteurs(Conteneur),
    charger_conteneur(Conteneur),
    controler_sortie(Conteneur).

% Traitement transport complet d'un conteneur
traiter_transport_complet(Conteneur) :-
    nl,
    format('=== TRAITEMENT TRANSPORT COMPLET DU CONTENEUR ~w ===~n', [Conteneur]),
    coordonner_transporteurs(Conteneur),
    charger_conteneur(Conteneur),
    controler_sortie(Conteneur),
    gerer_flux(Conteneur),
    sortir_du_port(Conteneur).

% Diagnostic transport complet
diagnostic_transport_complet(Conteneur) :-
    nl,
    format('=== DIAGNOSTIC TRANSPORT COMPLET DU CONTENEUR ~w ===~n', [Conteneur]),
    
    % Statut de préparation
    write('PRÉPARATION AU TRANSPORT:'), nl,
    (pret_transport(Conteneur) ->
        write('  Conteneur prêt pour le transport') ;
        write('  Conteneur non prêt pour le transport')
    ), nl,
    
    % Assignation transporteur
    write('TRANSPORTEUR:'), nl,
    (transporteur_assigne(Conteneur, Transporteur) ->
        (format('  Transporteur assigné: ~w~n', [Transporteur]),
         (type_transporteur(Transporteur, Type) ->
            format('  Type de transport: ~w~n', [Type]) ;
            write('  Type de transport: non spécifié'), nl),
         (transport_disponible(Transporteur) ->
            write('  Transporteur disponible') ;
            write('  Transporteur non disponible')
         )) ;
        write('  Aucun transporteur assigné')
    ), nl,
    
    % Documents de transport
    write('DOCUMENTS DE TRANSPORT:'), nl,
    (a_bon_livraison(Conteneur) ->
        write('  Bon de livraison présent') ;
        write('  Bon de livraison manquant')
    ), nl,
    (a_lettre_voiture(Conteneur) ->
        write('  Lettre de voiture présente') ;
        write('  Lettre de voiture manquante')
    ), nl,
    (a_autorisation_sortie(Conteneur) ->
        write('  Autorisation de sortie présente') ;
        write('  Autorisation de sortie manquante')
    ), nl,
    
    % Chargement
    write('CHARGEMENT:'), nl,
    (charge(Conteneur) ->
        write('  Conteneur chargé') ;
        write('  Conteneur non chargé')
    ), nl,
    
    % Contrôle de sécurité
    write('CONTRÔLE DE SÉCURITÉ:'), nl,
    (controle_securite_ok(Conteneur) ->
        write('  Contrôle de sécurité réussi') ;
        (controle_securite_echec(Conteneur) ->
            write('  Contrôle de sécurité échoué') ;
            write('  Contrôle de sécurité non effectué'))
    ), nl,
    
    % Porte de sortie
    write('PORTE DE SORTIE:'), nl,
    (porte_assignee(Conteneur, Porte) ->
        (format('  Porte assignée: ~w~n', [Porte]),
         (porte_ouverte(Porte) ->
            write('  Porte ouverte') ;
            write('  Porte fermée')
         )) ;
        write('  Aucune porte assignée')
    ), nl,
    
    % Temps de sortie
    write('TEMPS DE SORTIE:'), nl,
    (temps_sortie_estime(Conteneur, Temps) ->
        format('  Temps estimé: ~w minutes~n', [Temps]) ;
        write('  Temps non estimé')
    ), nl,
    
    % Statut final
    write('STATUT FINAL:'), nl,
    (peut_sortir_port(Conteneur) ->
        write('  CONTENEUR PEUT SORTIR DU PORT') ;
        write('  CONTENEUR BLOQUÉ POUR LA SORTIE')
    ), nl.

% Affichage des problèmes de transport
afficher_problemes_transport(Conteneur) :-
    write('Problèmes de transport détectés:'), nl,
    (\+ pret_transport(Conteneur) ->
        write('  Conteneur pas prêt pour le transport'), nl ; true),
    (\+ transporteur_assigne(Conteneur, _) ->
        write('  Aucun transporteur assigné'), nl ; true),
    (transporteur_assigne(Conteneur, Transporteur), \+ transport_disponible(Transporteur) ->
        write('  Transporteur non disponible'), nl ; true),
    (\+ documents_transport_complets(Conteneur) ->
        write('  Documents de transport incomplets'), nl ; true),
    (transporteur_assigne(Conteneur, Transporteur), \+ chauffeur_valide(Transporteur) ->
        write('  Chauffeur non identifié'), nl ; true),
    (\+ charge(Conteneur) ->
        write('  Conteneur non chargé'), nl ; true),
    (controle_securite_echec(Conteneur) ->
        write('  Échec du contrôle de sécurité'), nl ; true),
    (porte_assignee(Conteneur, Porte), porte_fermee(Porte) ->
        write('  Porte de sortie fermée'), nl ; true),
    (\+ porte_assignee(Conteneur, _) ->
        write('  Aucune porte de sortie assignée'), nl ; true).

% Lister tous les conteneurs en transport
lister_conteneurs_transport :-
    nl,
    write('=== CONTENEURS EN TRANSPORT ==='), nl,
    findall(C, pret_transport(C), Conteneurs),
    (Conteneurs = [] ->
        write('Aucun conteneur prêt pour le transport.'), nl ;
        forall(member(C, Conteneurs),
               (format('Conteneur: ~w', [C]),
                (peut_sortir_port(C) ->
                    write(' [PEUT SORTIR]') ;
                    write(' [BLOQUÉ]')
                ),
                (sorti_du_port(C) ->
                    write(' [SORTI]') ; true
                ), nl))
    ).

% Gestion globale des flux
gerer_flux_global :-
    nl,
    write('=== GESTION DES FLUX DE CIRCULATION ==='), nl,
    findall(C, pret_transport(C), Conteneurs),
    forall(member(C, Conteneurs), gerer_flux(C)).

% Ajouter des données de transport
ajouter_donnees_transport :-
    nl,
    write('=== AJOUT DE DONNÉES DE TRANSPORT ==='), nl,
    write('1. Marquer conteneur prêt pour transport'), nl,
    write('2. Assigner transporteur'), nl,
    write('3. Ajouter bon de livraison'), nl,
    write('4. Ajouter lettre de voiture'), nl,
    write('5. Ajouter autorisation de sortie'), nl,
    write('6. Marquer conteneur comme chargé'), nl,
    write('7. Valider contrôle de sécurité'), nl,
    write('8. Assigner porte de sortie'), nl,
    write('9. Marquer conteneur comme sorti'), nl,
    write('Choix: '),
    read(Type),
    ajouter_donnee_transport_type(Type).

ajouter_donnee_transport_type(1) :-
    write('ID du conteneur: '),
    read(C),
    assertz(pret_transport(C)),
    format('Conteneur ~w marqué comme prêt pour le transport~n', [C]).

ajouter_donnee_transport_type(2) :-
    write('ID du conteneur: '),
    read(C),
    write('ID du transporteur: '),
    read(T),
    write('Type de transport (camion/train): '),
    read(Type),
    assertz(transporteur_assigne(C, T)),
    assertz(type_transporteur(T, Type)),
    assertz(disponible(T)),
    format('Transporteur ~w (~w) assigné au conteneur ~w~n', [T, Type, C]).

ajouter_donnee_transport_type(3) :-
    write('ID du conteneur: '),
    read(C),
    assertz(a_bon_livraison(C)),
    format('Bon de livraison ajouté pour ~w~n', [C]).

ajouter_donnee_transport_type(4) :-
    write('ID du conteneur: '),
    read(C),
    assertz(a_lettre_voiture(C)),
    format('Lettre de voiture ajoutée pour ~w~n', [C]).

ajouter_donnee_transport_type(5) :-
    write('ID du conteneur: '),
    read(C),
    assertz(a_autorisation_sortie(C)),
    format('Autorisation de sortie ajoutée pour ~w~n', [C]).

ajouter_donnee_transport_type(6) :-
    write('ID du conteneur: '),
    read(C),
    assertz(charge(C)),
    format('Conteneur ~w marqué comme chargé~n', [C]).

ajouter_donnee_transport_type(7) :-
    write('ID du conteneur: '),
    read(C),
    assertz(controle_securite_ok(C)),
    format('Contrôle de sécurité validé pour ~w~n', [C]).

ajouter_donnee_transport_type(8) :-
    write('ID du conteneur: '),
    read(C),
    write('Porte (porte_nord/porte_sud/porte_est): '),
    read(Porte),
    assertz(porte_assignee(C, Porte)),
    assertz(porte_ouverte(Porte)),
    format('Porte ~w assignée au conteneur ~w~n', [Porte, C]).

ajouter_donnee_transport_type(9) :-
    write('ID du conteneur: '),
    read(C),
    assertz(sorti_du_port(C)),
    format('Conteneur ~w marqué comme sorti du port~n', [C]).

ajouter_donnee_transport_type(_) :-
    write('Option invalide.'), nl.

% ===== COMMANDES RAPIDES / QUICK COMMANDS =====

% Commande pour démarrer le système
demarrer :-
    write('Bienvenue dans le Système de Transport Terrestre!'), nl,
    write('Données d\'exemple chargées: cnt001, cnt002, cnt003'), nl,
    menu_principal.

% Vérification rapide
quick_check_transport(Conteneur) :-
    verifier_transport_conteneur(Conteneur).

% Traitement rapide
quick_process_transport(Conteneur) :-
    traiter_transport_complet(Conteneur).

% Test rapide avec données d'exemple
test_systeme_transport :-
    write('=== TEST DU SYSTÈME DE TRANSPORT ==='), nl,
    write('Test avec cnt001 (devrait pouvoir sortir):'), nl,
    quick_process_transport(cnt001), nl,
    write('Test avec cnt002 (problèmes possibles):'), nl,
    quick_process_transport(cnt002), nl,
    write('Test avec cnt003 (transporteur indisponible):'), nl,
    quick_process_transport(cnt003).

% ===== INITIALISATION =====
% Directive d'initialisation pour éviter l'erreur "no initial goal executed"
:- initialization(main).

% Point d'entrée principal
main :-
    write('Système de Transport Terrestre chargé avec succès!'), nl,
    write('Tapez "demarrer." pour commencer ou "test_systeme_transport." pour tester.'), nl.

% ===== INSTRUCTIONS D'UTILISATION =====
% Pour utiliser le système:
% 1. Chargez ce fichier dans SWI-Prolog
% 2. Le système se lance automatiquement
% 3. Tapez: demarrer. pour le menu interactif
%
% Commandes rapides disponibles:
% - demarrer.
% - quick_check_transport(ID_conteneur).
% - quick_process_transport(ID_conteneur).
% - diagnostic_transport_complet(ID_conteneur).
% - test_systeme_transport.
%
% Données d'exemple disponibles: cnt001, cnt002, cnt003