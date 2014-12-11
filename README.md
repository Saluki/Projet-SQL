Projet-SQL
==========

Plan
----

À compléter...

Plan	 | Semaine | Fini | Chargé 
:--------------------------------|:-----:|:-:|:---------------
I. DSD							| 1-5 	|   |				 
    1. Tables					| 1		| X | Badot & Dandoy 
    2. Vues						| 3		|   | Badot & Dandoy 
    3. Procédures				| 3-4	|   | Dandoy			
    4. Triggers					| 4		|   | Dandoy			
    5. Données test				| 5		|   | 				 
II. Application Java				| 4-5	|   | 				 
	1. Tomiko					| 		|   | 
		a. Inscription P-M		| 		|   | 
		b. Ajout Archétype		| 		|   | 
		c. Statistiques			| 		|   | 
		d. Historique			| 		|   | 
		e. Attribution P-U		| 		|   | 
	2. Power-mangeurs 			| 		|   | 
		a. Activation			| 		|   | 
			i. Débuter combat	| 		|   | 
			ii. Utiliser P-U		| 		|   | 
			iii. Conclure combat	| 		|   | 
		b. Historique			| 		|   | 
		c. Statistiques			| 		|   | 
III. Rapport						| 5		|   |
	1. Code SQL					| 		|   |
	2. Données test				| 		|   |
	3. Code Java					| 		|   |
	4. Justif. & explic.			| 		|   |
	5. Conclusion				| 		|   |


A faire
-------

- TRIGGERS
- Extension et stats perso
- Cryptage mdp
- GRANT

Questions
---------

- P-U : Utilisable 1x par jour ou par 24h ?

Remarques
---------

Snippets
--------

-- Vérifier l'existence du P-M

    SELECT id_pm FROM projet.power_mangeurs WHERE nom = nom_pm INTO _id_pm;
    IF NOT EXISTS(_id_pm) THEN
        RAISE '% n\'existe pas !', _nom_pm USING ERRCODE = 'invalid_foreign_key';
    END IF;

