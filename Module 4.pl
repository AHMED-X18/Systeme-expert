% Expert System for Container Administrative and Customs Processing

%  KNOWLEDGE BASE

% Acteurs du système
actor(douanes).
actor(transitaires).
actor(agent_maritimes).
actor(operateurs_logistiques).

% Types de documents
document(connaissement).
document(declaration_douaniere).

% Activités du processus
activity(verification_des_documents).
activity(inspection_physique).
activity(paiement_de_taxes_et_frais_portuaires).
activity(coordination_avec_transitaires).

% ===== SAMPLE DATA / DONNÉES D'EXEMPLE =====
% Ajout de quelques données d'exemple pour tester le système

% Conteneurs avec connaissement
a_connaissement(cnt001).
a_connaissement(cnt002).
a_connaissement(cnt003).

% Conteneurs avec déclaration douanière
a_declaration(cnt001).
a_declaration(cnt002).

% Validité des documents (fixed predicate name)
documents_valides(cnt001, document, valid).
documents_valides(cnt002, document, invalid).
documents_valides(cnt003, document, valid).

% Conteneurs scannés
scanne(cnt001).
scanne(cnt002).

% Statut des marchandises
pas_marchandises_illicites(cnt001).
marchandises_illicites(cnt002).

% Paiements
paiement(cnt001, complete).
paiement(cnt002, incomplete).

% Conteneurs bloqués
bloque(cnt002).

% ===== RÈGLES DE BASE / BASE RULES =====

% Vérification de la possession des documents requis
a_les_documents(Conteneur) :-
    a_connaissement(Conteneur),
    a_declaration(Conteneur).

% ===== RÈGLES DU PROCESSUS / PROCESS RULES =====

% Étape 1 : Vérification des documents
verifier_documents(Conteneur) :-
    a_les_documents(Conteneur),
    documents_valides(Conteneur, document, valid),
    format(' Les documents du conteneur ~w sont valides.~n', [Conteneur]).

verifier_documents(Conteneur) :-
    (\+ a_les_documents(Conteneur) ;
     documents_valides(Conteneur, document, invalid)),
    format(' Les documents du conteneur ~w sont incomplets ou invalides.~n', [Conteneur]).

% Étape 2 : Inspection (scanner ou physique)
inspecter_conteneur(Conteneur) :-
    scanne(Conteneur),
    pas_marchandises_illicites(Conteneur),
    format(' Le conteneur ~w a passé l\'inspection avec succès.~n', [Conteneur]).

inspecter_conteneur(Conteneur) :-
    scanne(Conteneur),
    marchandises_illicites(Conteneur),
    format(' ALERTE: Le conteneur ~w contient des marchandises illicites!~n', [Conteneur]).

inspecter_conteneur(Conteneur) :-
    \+ scanne(Conteneur),
    format('Le conteneur ~w n\'a pas encore été scanné.~n', [Conteneur]).

% Étape 3 : Paiement des frais
payer_taxes(Conteneur) :-
    paiement(Conteneur, complete),
    format('Les taxes et frais portuaires du conteneur ~w ont été réglés.~n', [Conteneur]).

payer_taxes(Conteneur) :-
    \+ paiement(Conteneur, complete),
    format('Les taxes du conteneur ~w n\'ont pas été payées.~n', [Conteneur]).

% Étape 4 : Coordination avec les transitaires
coordonner_transport(Conteneur) :-
    peut_etre_libere(Conteneur),
    format('Le transport terrestre du conteneur ~w est organisé avec le transitaire.~n', [Conteneur]).

coordonner_transport(Conteneur) :-
    \+ peut_etre_libere(Conteneur),
    format('Le conteneur ~w ne peut pas être coordonné - conditions non remplies.~n', [Conteneur]).

% Règle auxiliaire pour vérifier si un conteneur peut être libéré
peut_etre_libere(Conteneur) :-
    a_les_documents(Conteneur),
    documents_valides(Conteneur, document, valid),
    scanne(Conteneur),
    pas_marchandises_illicites(Conteneur),
    paiement(Conteneur, complete),
    \+ bloque(Conteneur).

% Étape finale : Libération du conteneur
liberer_conteneur(Conteneur) :-
    peut_etre_libere(Conteneur),
    format('AUTORISATION: Le conteneur ~w est autorisé à sortir ou à être transbordé.~n', [Conteneur]).

liberer_conteneur(Conteneur) :-
    \+ peut_etre_libere(Conteneur),
    format('REFUS: Le conteneur ~w ne peut pas être libéré.~n', [Conteneur]),
    afficher_problemes(Conteneur).

% ===== SYSTÈME D'INTERACTION UTILISATEUR / USER INTERACTION SYSTEM =====

% Menu principal
menu_principal :-
    nl,
    write('=== SYSTÈME DOUANIER EXPERT ==='), nl,
    write('1. Vérifier un conteneur'), nl,
    write('2. Traiter un conteneur'), nl,
    write('3. Lister les conteneurs'), nl,
    write('4. Ajouter des données'), nl,
    write('5. Diagnostic complet'), nl,
    write('6. Quitter'), nl,
    write('Choisissez une option (1-6): '),
    read(Choix),
    traiter_choix(Choix).

% Traitement des choix du menu
traiter_choix(1) :-
    write('Entrez l\'ID du conteneur: '),
    read(Conteneur),
    verifier_conteneur_complet(Conteneur),
    menu_principal.

traiter_choix(2) :-
    write('Entrez l\'ID du conteneur: '),
    read(Conteneur),
    traiter_conteneur_complet(Conteneur),
    menu_principal.

traiter_choix(3) :-
    lister_conteneurs,
    menu_principal.

traiter_choix(4) :-
    ajouter_donnees,
    menu_principal.

traiter_choix(5) :-
    write('Entrez l\'ID du conteneur: '),
    read(Conteneur),
    diagnostic_complet(Conteneur),
    menu_principal.

traiter_choix(6) :-
    write('Au revoir!'), nl.

traiter_choix(_) :-
    write('Option invalide. Réessayez.'), nl,
    menu_principal.

% Vérification complète d'un conteneur
verifier_conteneur_complet(Conteneur) :-
    nl,
    format('=== VÉRIFICATION DU CONTENEUR ~w ===~n', [Conteneur]),
    verifier_documents(Conteneur),
    inspecter_conteneur(Conteneur),
    payer_taxes(Conteneur).

% Traitement complet d'un conteneur
traiter_conteneur_complet(Conteneur) :-
    nl,
    format('=== TRAITEMENT COMPLET DU CONTENEUR ~w ===~n', [Conteneur]),
    verifier_documents(Conteneur),
    inspecter_conteneur(Conteneur),
    payer_taxes(Conteneur),
    coordonner_transport(Conteneur),
    liberer_conteneur(Conteneur).

% Diagnostic complet
diagnostic_complet(Conteneur) :-
    nl,
    format('=== DIAGNOSTIC COMPLET DU CONTENEUR ~w ===~n', [Conteneur]),

    % Vérification des documents
    write('DOCUMENTS:'), nl,
    (a_connaissement(Conteneur) ->
        write(' Connaissement présent') ;
        write(' Connaissement manquant')
    ), nl,
    (a_declaration(Conteneur) ->
        write('  Déclaration douanière présente') ;
        write('  Déclaration douanière manquante')
    ), nl,
    (documents_valides(Conteneur, document, valid) ->
        write('  Documents valides') ;
        write('  Documents invalides')
    ), nl,

    % Statut d'inspection
    write('INSPECTION:'), nl,
    (scanne(Conteneur) ->
        write('  Conteneur scanné') ;
        write('  Conteneur non scanné')
    ), nl,
    (pas_marchandises_illicites(Conteneur) ->
        write('  Aucune marchandise illicite') ;
        (marchandises_illicites(Conteneur) ->
            write('  Marchandises illicites détectées') ;
            write('  Statut des marchandises inconnu'))
    ), nl,

    % Statut des paiements
    write('PAIEMENTS:'), nl,
    (paiement(Conteneur, complete) ->
        write('  Paiements effectués') ;
        write('  Paiements en attente')
    ), nl,

    % Statut de blocage
    write('BLOCAGE:'), nl,
    (bloque(Conteneur) ->
        write('  Conteneur bloqué') ;
        write('  Conteneur non bloqué')
    ), nl,

    % Statut final
    write('STATUT FINAL:'), nl,
    (peut_etre_libere(Conteneur) ->
        write(' CONTENEUR PEUT ÊTRE LIBÉRÉ') ;
        write(' CONTENEUR BLOQUÉ')
    ), nl.

% Affichage des problèmes
afficher_problemes(Conteneur) :-
    write('Problèmes détectés:'), nl,
    (\+ a_connaissement(Conteneur) ->
        write('Connaissement manquant'), nl ; true),
    (\+ a_declaration(Conteneur) ->
        write('Déclaration douanière manquante'), nl ; true),
    (\+ documents_valides(Conteneur, document, valid) ->
        write('Documents invalides'), nl ; true),
    (\+ scanne(Conteneur) ->
        write('Inspection non effectuée'), nl ; true),
    (marchandises_illicites(Conteneur) ->
        write('Marchandises illicites détectées'), nl ; true),
    (\+ paiement(Conteneur, complete) ->
        write('Paiements non effectués'), nl ; true),
    (bloque(Conteneur) ->
        write('Conteneur officiellement bloqué'), nl ; true).

% Lister tous les conteneurs connus
lister_conteneurs :-
    nl,
    write('=== CONTENEURS ENREGISTRÉS ==='), nl,
    findall(C, a_connaissement(C), Conteneurs),
    (Conteneurs = [] ->
        write('Aucun conteneur enregistré.'), nl ;
        forall(member(C, Conteneurs),
               (format('Conteneur: ~w', [C]),
                (peut_etre_libere(C) ->
                    write(' [LIBÉRABLE]') ;
                    write(' [BLOQUÉ]')
                ), nl))
    ).

% Ajouter des données
ajouter_donnees :-
    nl,
    write('=== AJOUT DE DONNÉES ==='), nl,
    write('1. Ajouter connaissement'), nl,
    write('2. Ajouter déclaration'), nl,
    write('3. Marquer comme scanné (sans problème)'), nl,
    write('4. Marquer comme scanné (avec marchandises illicites)'), nl,
    write('5. Marquer paiement comme complet'), nl,
    write('6. Valider documents'), nl,
    write('7. Bloquer conteneur'), nl,
    write('Choix: '),
    read(Type),
    ajouter_donnee_type(Type).

ajouter_donnee_type(1) :-
    write('ID du conteneur: '),
    read(C),
    assertz(a_connaissement(C)),
    format('Connaissement ajouté pour ~w~n', [C]).

ajouter_donnee_type(2) :-
    write('ID du conteneur: '),
    read(C),
    assertz(a_declaration(C)),
    format('Déclaration ajoutée pour ~w~n', [C]).

ajouter_donnee_type(3) :-
    write('ID du conteneur: '),
    read(C),
    assertz(scanne(C)),
    assertz(pas_marchandises_illicites(C)),
    format('Conteneur ~w marqué comme scanné (sans problème)~n', [C]).

ajouter_donnee_type(4) :-
    write('ID du conteneur: '),
    read(C),
    assertz(scanne(C)),
    assertz(marchandises_illicites(C)),
    format('Conteneur ~w marqué comme scanné (avec marchandises illicites)~n', [C]).

ajouter_donnee_type(5) :-
    write('ID du conteneur: '),
    read(C),
    assertz(paiement(C, complete)),
    format('Paiement marqué comme complet pour ~w~n', [C]).

ajouter_donnee_type(6) :-
    write('ID du conteneur: '),
    read(C),
    assertz(documents_valides(C, document, valid)),
    format('Documents validés pour ~w~n', [C]).

ajouter_donnee_type(7) :-
    write('ID du conteneur: '),
    read(C),
    assertz(bloque(C)),
    format('Conteneur ~w bloqué~n', [C]).

ajouter_donnee_type(_) :-
    write('Option invalide.'), nl.

% ===== COMMANDES RAPIDES / QUICK COMMANDS =====

% Commande pour démarrer le système
demarrer :-
    write('Bienvenue dans le Système Douanier Expert!'), nl,
    write('Données d\'exemple chargées: cnt001, cnt002, cnt003'), nl,
    menu_principal.

% Vérification rapide
quick_check(Conteneur) :-
    verifier_conteneur_complet(Conteneur).

% Traitement rapide
quick_process(Conteneur) :-
    traiter_conteneur_complet(Conteneur).

% Test rapide avec données d'exemple
test_systeme :-
    write('=== TEST DU SYSTÈME ==='), nl,
    write('Test avec cnt001 (devrait être libérable):'), nl,
    quick_process(cnt001), nl,
    write('Test avec cnt002 (devrait être bloqué):'), nl,
    quick_process(cnt002), nl,
    write('Test avec cnt003 (manque déclaration):'), nl,
    quick_process(cnt003).

% ===== INSTRUCTIONS D'UTILISATION =====
% Pour utiliser le système:
% 1. Chargez ce fichier dans SWI-Prolog
% 2. Tapez: demarrer.
% 3. Suivez le menu interactif
%
% Commandes rapides disponibles:
% - demarrer.
% - quick_check(ID_conteneur).
% - quick_process(ID_conteneur).
% - diagnostic_complet(ID_conteneur).
% - test_systeme.
%
% Données d'exemple disponibles: cnt001, cnt002, cnt003
