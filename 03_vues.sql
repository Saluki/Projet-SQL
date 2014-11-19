-- Toriko
-- Historique combats entre 2 dates / P-M
-- Statistiques : Classement P-M selon combat, Liste décédés, Autres...

-- P-M
-- Historique dernier combat
-- Statistiques : Nombre monstres combattus/gagnés depuis début/année, Espérance de vie, Autres...

-- Tomiko

DROP VIEW IF EXISTS projet.historique_combats CASCADE;

CREATE VIEW projet.historique_combats AS
	SELECT c.*, pm.nom AS "nom_pm", a.nom AS "nom_archetype"
	FROM projet.combats c
	INNER JOIN projet.power_mangeurs pm ON c.id_pm = pm.id_pm
	INNER JOIN projet.archetypes a ON c.id_archetype = a.id_archetype;


DROP VIEW IF EXISTS projet.classement_pm CASCADE;

CREATE VIEW projet.classement_pm AS
	SELECT s.id_pm, pm.nom AS "nom", SUM(s.nb_victoires_annee) AS "victoires"
	FROM projet.statistiques s
	INNER JOIN projet.power_mangeurs pm ON s.id_pm = pm.id_pm
	GROUP BY s.id_pm, nom
	ORDER BY victoires DESC;
	
DROP VIEW IF EXISTS projet.liste_decedes CASCADE;

CREATE VIEW projet.liste_decedes AS
	SELECT pm.id_pm, pm.nom, pm.date_deces
	FROM projet.power_mangeurs pm
	WHERE pm.date_deces IS NOT NULL
		AND EXTRACT( YEAR FROM pm.date_deces ) = EXTRACT( YEAR FROM NOW() );

-- Power-Mangeurs

DROP VIEW IF EXISTS projet.historique_dernier_combat CASCADE;

CREATE VIEW projet.historique_dernier_combat AS
	SELECT c.id_pm, pu.nom AS "nom_pu", u.date_utilisation, c.date_debut, c.date_fin
	FROM projet.combats c
	INNER JOIN projet.utilisations u ON c.id_combat = u.id_combat
	INNER JOIN projet.power_ups pu ON u.id_pu = pu.id_pu
	ORDER BY c.date_debut DESC
	LIMIT 1;
	
DROP VIEW IF EXISTS projet.statistiques_combats CASCADE;

CREATE VIEW projet.statistiques_combats AS
	SELECT s.*, pm.nom AS "nom_pm", a.nom AS "nom_archetype"
	FROM projet.statistiques s
	INNER JOIN projet.power_mangeurs pm ON s.id_pm = pm.id_pm -- Est-ce nécessaire ?
	INNER JOIN projet.archetypes a ON s.id_archetype = a.id_archetype;

-- TESTS

SELECT *
FROM projet.historique_combats
WHERE "id_pm" = 2
	AND "date_debut" = '2014-11-17 20:01:35'
	AND "date_fin" = '2014-11-17 20:06:25';
	
SELECT *
FROM projet.liste_decedes;
