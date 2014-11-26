Projet-SQL
==========

Plan
----

À compléter...

Plan	 | Semaine | Fini | Chargé 
:--------------------------------|:-----:|:-:|:---------------
1. DSD							| 1-3 	|   |				 
    1. Tables					| 1		| X | Badot & Dandoy 
    2. Vues						| 3		|   | Badot & Dandoy 
    3. Procédures				| 3		|   | Badot & Dandoy 
    4. Triggers					| 		|   | 				 
    5. Données test				| 2		|   | 				 
2. Application Java				| 2-5	|   | 				 
	1. Tomiko					| 		|   | 
		1. Inscription P-M		| 		|   | 
		2. Ajout Archétype		| 		|   | 
		3. Statistiques			| 		|   | 
		4. Historique			| 		|   | 
		5. Attribution P-U		| 		|   | 
	2. Power-mangeurs 			| 		|   | 
		1. Activation			| 		|   | 
			1. Débuter combat	| 		|   | 
			2. Utiliser P-U		| 		|   | 
			3. Conclure combat	| 		|   | 
		2. Historique			| 		|   | 
		3. Statistiques			| 		|   | 
3. Rapport						| 5		|   |
	1. Code SQL					| 		|   |
	2. Données test				| 		|   |
	3. Code Java					| 		|   |
	4. Justif. & explic.			| 		|   |
	5. Conclusion				| 		|   |

Questions
---------

- [Combats] date_debut et/ou date_fin comme point de repère ?

Remarques
---------

Snippets
--------

-- Vérifier l'existence du P-M

    SELECT id_pm FROM projet.power_mangeurs WHERE nom = nom_pm INTO _id_pm;
    IF NOT EXISTS(_id_pm) THEN
        RAISE '% n\'existe pas !', _nom_pm USING ERRCODE = 'invalid_foreign_key';
    END IF;

