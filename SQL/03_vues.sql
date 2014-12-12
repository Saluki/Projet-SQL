-- ---------------------------------------------------------------------------------
--                                    Toriko
-- ---------------------------------------------------------------------------------

-- Historique combats entre 2 dates / P-M

CREATE VIEW projet.historique_combats (nom_pm, nom_archetype, date_debut, date_fin, est_gagne) AS
  SELECT
    pm.nom AS "nom_pm",
    a.nom  AS "nom_archetype",
    c.date_debut,
    c.date_fin,
    c.est_gagne
  FROM projet.combats c
    INNER JOIN projet.power_mangeurs pm ON c.id_pm = pm.id_pm
    INNER JOIN projet.archetypes a ON c.id_archetype = a.id_archetype
  ORDER BY c.date_debut ASC;

-- Classement meilleurs P-M

CREATE VIEW projet.classement_pm AS
  SELECT
    pm.nom,
    SUM(s.nb_victoires_annee) AS "victoires"
  FROM projet.statistiques s
    RIGHT JOIN projet.power_mangeurs pm ON s.id_pm = pm.id_pm
  WHERE pm.vie > 0
  GROUP BY nom
  ORDER BY victoires DESC;

-- Liste P-M décédés

CREATE VIEW projet.liste_decedes AS
  SELECT
    pm.nom,
    pm.date_deces
  FROM projet.power_mangeurs pm
  WHERE pm.date_deces IS NOT NULL
        AND EXTRACT(YEAR FROM pm.date_deces) = EXTRACT(YEAR FROM NOW());

-- Autres...

-- ---------------------------------------------------------------------------------
--                                Power-Mangeurs
-- ---------------------------------------------------------------------------------

-- Monstro-nourriture tire au hasard

CREATE VIEW projet.monstre_au_hasard AS
	SELECT a.*
	FROM projet.archetypes a
	ORDER BY RANDOM()
	LIMIT 1;

-- Nombre monstres combattus/gagnés depuis début/année

CREATE VIEW projet.statistiques_combats AS
  SELECT
    s.*,
    a.nom AS "nom_archetype"
  FROM projet.statistiques s
    INNER JOIN projet.archetypes a ON s.id_archetype = a.id_archetype;

-- Historique power ups

CREATE VIEW projet.historique_pu AS

	SELECT pu.id_pm, pu.nom, pu.facteur, u.date_utilisation
	FROM projet.power_ups pu
	INNER JOIN projet.utilisations u ON pu.id_pu = u.id_pu
	ORDER BY u.date_utilisation;

