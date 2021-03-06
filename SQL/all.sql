DROP SCHEMA IF EXISTS projet CASCADE;

CREATE SCHEMA projet;CREATE SEQUENCE projet.id_power_mangeur;
CREATE SEQUENCE projet.id_archetype;
CREATE SEQUENCE projet.id_combat;
CREATE SEQUENCE projet.id_power_up;

CREATE TABLE projet.power_mangeurs
(
  id_pm            INTEGER PRIMARY KEY   DEFAULT NEXTVAL('projet.id_power_mangeur'),
  nom              VARCHAR(100) NOT NULL UNIQUE CHECK (length(btrim(nom)) >= 3),
  couleur          CHAR(6)      NOT NULL UNIQUE,
  mot_de_passe     VARCHAR(150) NOT NULL CHECK (mot_de_passe <> ''),
  vie              INTEGER      NOT NULL DEFAULT 10 CHECK (vie >= 0 AND vie <= 10),
  puissance        INTEGER      NOT NULL DEFAULT 30 CHECK (puissance >= 30),
  date_inscription TIMESTAMP    NOT NULL DEFAULT LOCALTIMESTAMP,
  date_deces       TIMESTAMP,
  CHECK (date_inscription < date_deces)
);

CREATE TABLE projet.archetypes
(
  id_archetype INTEGER PRIMARY KEY DEFAULT NEXTVAL('projet.id_archetype'),
  nom          VARCHAR(100) NOT NULL UNIQUE CHECK (nom <> ''),
  puissance    INTEGER      NOT NULL CHECK (puissance >= 0)
);

CREATE TABLE projet.combats
(
  id_combat    INTEGER PRIMARY KEY DEFAULT NEXTVAL('projet.id_combat'),
  id_pm        INTEGER   NOT NULL REFERENCES projet.power_mangeurs (id_pm),
  id_archetype INTEGER   NOT NULL REFERENCES projet.archetypes (id_archetype),
  date_debut   TIMESTAMP NOT NULL  DEFAULT LOCALTIMESTAMP CHECK (date_debut <= LOCALTIMESTAMP),
  date_fin     TIMESTAMP,
  est_gagne    BOOLEAN,
  CHECK (date_debut < date_fin)
);

CREATE TABLE projet.power_ups
(
  id_pu            INTEGER PRIMARY KEY   DEFAULT NEXTVAL('projet.id_power_up'),
  nom              VARCHAR(100) NOT NULL CHECK (nom <> ''),
  id_pm            INTEGER      NOT NULL REFERENCES projet.power_mangeurs (id_pm),
  date_attribution TIMESTAMP    NOT NULL DEFAULT LOCALTIMESTAMP CHECK (date_attribution <= LOCALTIMESTAMP),
  facteur          INTEGER      NOT NULL CHECK (facteur > 0),
  UNIQUE (nom, id_pm)
);

CREATE TABLE projet.utilisations
(
  id_combat        INTEGER   NOT NULL REFERENCES projet.combats (id_combat),
  id_pu            INTEGER   NOT NULL REFERENCES projet.power_ups (id_pu),
  date_utilisation TIMESTAMP NOT NULL DEFAULT LOCALTIMESTAMP CHECK (date_utilisation <= LOCALTIMESTAMP),
  PRIMARY KEY (id_combat, id_pu)
);

CREATE TABLE projet.statistiques
(
  id_pm              INTEGER NOT NULL REFERENCES projet.power_mangeurs (id_pm),
  id_archetype       INTEGER NOT NULL REFERENCES projet.archetypes (id_archetype),
  nb_combats_total   INTEGER NOT NULL DEFAULT 0,
  nb_victoires_total INTEGER NOT NULL DEFAULT 0 CHECK (nb_victoires_total >= 0),
  nb_combats_annee   INTEGER NOT NULL DEFAULT 0,
  nb_victoires_annee INTEGER NOT NULL DEFAULT 0 CHECK (nb_victoires_annee >= 0),
  PRIMARY KEY (id_pm, id_archetype),
  CHECK (nb_victoires_total <= nb_combats_total),
  CHECK (nb_victoires_annee <= nb_combats_annee),
  CHECK (nb_combats_annee <= nb_combats_total),
  CHECK (nb_victoires_annee <= nb_victoires_total)
);
-- ---------------------------------------------------------------------------------
--                                    Toriko
-- ---------------------------------------------------------------------------------

-- Historique des combats d'un PM

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
/*
CREATE VIEW projet.classement_pm AS
  SELECT
    pm.nom,
    SUM(s.nb_victoires_annee) AS "victoires"
  FROM projet.statistiques s
    RIGHT JOIN projet.power_mangeurs pm ON s.id_pm = pm.id_pm
  WHERE pm.vie > 0
  GROUP BY nom
  HAVING SUM(s.nb_victoires_annee) IS NOT NULL
  ORDER BY victoires DESC;
*/
-- Liste des PM décédés sur l'année

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

-- Tire un monstro-nourriture au hasard

CREATE VIEW projet.monstre_au_hasard AS
	SELECT a.*
	FROM projet.archetypes a
	ORDER BY RANDOM()
	LIMIT 1;

-- Nombre monstres combattus/gagnés depuis début/année
/*
CREATE VIEW projet.statistiques_combats AS
  SELECT
    s.*,
    a.nom AS "nom_archetype"
  FROM projet.statistiques s
    INNER JOIN projet.archetypes a ON s.id_archetype = a.id_archetype;
*/

-- Historique d'utilisations de power ups

CREATE VIEW projet.historique_pu AS

	SELECT pu.id_pm, pu.nom, pu.facteur, u.date_utilisation
	FROM projet.power_ups pu
	INNER JOIN projet.utilisations u ON pu.id_pu=u.id_pu
	ORDER BY u.date_utilisation;

-- Si nouvelle année, mets les stats annuelles de tout le monde à zéro

CREATE FUNCTION projet.verifier_stats_annee() RETURNS VOID AS $$
DECLARE
	_dernier_combat TIMESTAMP;
BEGIN

  SELECT date_debut INTO _dernier_combat FROM projet.combats ORDER BY date_debut DESC LIMIT 1;
  IF (_dernier_combat IS NOT NULL AND EXTRACT(YEAR FROM _dernier_combat) < EXTRACT(YEAR FROM NOW())) THEN
    UPDATE projet.statistiques SET nb_combats_annee = 0, nb_victoires_annee = 0;
  END IF;

END;
$$ LANGUAGE plpgsql;

-- ---------------------------------------------------------------------------------------------------------------------
--                                                    Toriko
-- ---------------------------------------------------------------------------------------------------------------------


-- Inscription d'un PM

CREATE FUNCTION projet.inscrire_pm(VARCHAR(100), VARCHAR(150), CHAR(6)) RETURNS INTEGER AS $$
DECLARE
  _nom      ALIAS FOR $1;
  _mdp      ALIAS FOR $2;
  _couleur  ALIAS FOR $3;
  _id       INTEGER;
BEGIN

	INSERT INTO projet.power_mangeurs (nom, couleur, mot_de_passe) VALUES (_nom, _couleur, _mdp) RETURNING id_pm INTO _id;

	RETURN _id;

END;
$$ LANGUAGE plpgsql;

-- Ajout d'un archétype

CREATE FUNCTION projet.ajouter_archetype(VARCHAR(100), INTEGER) RETURNS INTEGER AS $$
DECLARE
	_nom			  ALIAS FOR $1;
	_puissance 	ALIAS FOR $2;
	_id			    INTEGER;
BEGIN

	INSERT INTO projet.archetypes (nom, puissance) VALUES (_nom, _puissance) RETURNING id_archetype INTO _id;

	RETURN _id;

END;
$$ LANGUAGE plpgsql;

-- Attribution d'un P-U

CREATE FUNCTION projet.attribuer_pu(VARCHAR(100), VARCHAR(100), INTEGER) RETURNS INTEGER AS $$
DECLARE
	_nom_pm		ALIAS FOR $1;
	_nom_pu		ALIAS FOR $2;
	_facteur_pu	ALIAS FOR $3;
	_id_pm		INTEGER;
	_id_pu		INTEGER;
BEGIN

	-- Vérifier l'existence du P-M
	SELECT id_pm INTO _id_pm FROM projet.power_mangeurs WHERE nom = _nom_pm;

	INSERT INTO projet.power_ups (nom, id_pm, facteur) VALUES (_nom_pu, _id_pm, _facteur_pu) RETURNING id_pu INTO _id_pu;

	RETURN _id_pu;

END;
$$ LANGUAGE plpgsql;

-- Classement Power Mangeur

CREATE FUNCTION projet.classer_pm() RETURNS TABLE(nom VARCHAR(100), victoires BIGINT) AS $$
DECLARE
	_dernier_combat	TIMESTAMP;
BEGIN

  PERFORM projet.verifier_stats_annee();


	RETURN QUERY SELECT
		 pm.nom,
		 COALESCE(SUM(s.nb_victoires_annee), 0) AS "victoires"
	 FROM projet.statistiques s
		 RIGHT JOIN projet.power_mangeurs pm ON s.id_pm = pm.id_pm
	 WHERE pm.vie > 0
	 GROUP BY pm.nom
	 ORDER BY victoires DESC;

END;
$$ LANGUAGE plpgsql;

-- ---------------------------------------------------------------------------------------------------------------------
--                                                   Power-Mangeurs
-- ---------------------------------------------------------------------------------------------------------------------


-- Débuter un combat

CREATE FUNCTION projet.debuter_combat(INTEGER, INTEGER) RETURNS INTEGER AS $$
DECLARE
	_id_pm		ALIAS FOR $1;
	_id_arch		ALIAS FOR $2;
	_id_combat	INTEGER;
BEGIN

	-- Vérifier si P-M est déjà en plein combat et lever une exception si c'est le cas
	IF EXISTS(SELECT * FROM projet.combats WHERE id_pm = _id_pm AND date_fin IS NULL) THEN
		RAISE 'Combat en cours.';
	END IF;

	INSERT INTO projet.combats (id_pm, id_archetype) VALUES (_id_pm, _id_arch) RETURNING id_combat INTO _id_combat;

	RETURN _id_combat;

END;
$$ LANGUAGE plpgsql;

-- Conclure un combat

CREATE OR REPLACE FUNCTION projet.conclure_combat(INTEGER,BOOLEAN) RETURNS BOOLEAN AS $$
DECLARE
	_id_pm			ALIAS FOR $1;
	_force_defaite		ALIAS FOR $2;
	_puissance_pm		INTEGER;
	_vie			INTEGER;
	_id_arch		INTEGER;
	_puissance_arch		INTEGER;
	_id_combat		INTEGER;
	_est_gagne		BOOLEAN;
BEGIN

	-- Vérifier que P-M est effectivement en plein combat et lever une exception si ce n'est pas le cas
	SELECT c.id_combat, c.id_archetype, pm.puissance, a.puissance
	INTO _id_combat, _id_arch, _puissance_pm, _puissance_arch
	FROM projet.combats c
	INNER JOIN projet.power_mangeurs pm ON c.id_pm = pm.id_pm
	INNER JOIN projet.archetypes a ON c.id_archetype = a.id_archetype
	WHERE c.id_pm = _id_pm AND c.date_fin IS NULL;

	IF (_id_combat IS NULL) THEN
		RAISE 'Pas de combat en cours.';
	END IF;

	IF (_force_defaite = TRUE) THEN
		_est_gagne:=FALSE;
	ELSE
		_est_gagne:=(_puissance_pm>_puissance_arch);
	END IF;

	-- Mettre à jour issue combat
	UPDATE projet.combats SET date_fin = LOCALTIMESTAMP, est_gagne = _est_gagne WHERE id_combat = _id_combat;

	-- Réinitialiser puissance P-M
	IF (_puissance_pm > 30) THEN
		UPDATE projet.power_mangeurs SET puissance = 30 WHERE id_pm = _id_pm;
	END IF;

	RETURN _est_gagne;

END;
$$ LANGUAGE plpgsql;

-- Utiliser un P-U

CREATE OR REPLACE FUNCTION projet.utiliser_pu(INTEGER, INTEGER) RETURNS INTEGER AS $$
DECLARE
	_id_pm					      ALIAS FOR $1;
	_id_pu					      ALIAS FOR $2;
	_id_combat				    INTEGER;
	_facteur							INTEGER;
	_derniere_utilisation	TIMESTAMP;
	_puissance	INTEGER;
BEGIN

  -- Vérifier que P-M est effectivement en plein combat et lever une exception si ce n'est pas le cas
	SELECT id_combat INTO _id_combat FROM projet.combats WHERE id_pm = _id_pm AND date_fin IS NULL;
	IF (_id_combat IS NULL) THEN
		RAISE 'Pas de combat en cours.';
	END IF;

	-- Vérifier que P-U n'a pas déjà été utilisé aujourd'hui
	SELECT date_utilisation INTO _derniere_utilisation FROM projet.utilisations WHERE id_pu = _id_pu ORDER BY date_utilisation DESC LIMIT 1;

	-- 1x/jour : date_trunc('day', _derniere_utilisation) < date_trunc('day', NOW())
	-- 1x/24h : (NOW()-_derniere_utilisation) > interval '1 day'
	IF (_derniere_utilisation IS NULL OR (NOW()-_derniere_utilisation) > interval '1 day') THEN

		-- Selectionner le facteur du Power Up
    SELECT facteur INTO _facteur FROM projet.power_ups WHERE id_pu = _id_pu;

		INSERT INTO projet.utilisations (id_combat, id_pu) VALUES (_id_combat, _id_pu);

		SELECT puissance INTO _puissance FROM projet.power_mangeurs WHERE id_pm = _id_pm;
		_puissance := _puissance+_puissance*_facteur/100;
		
		UPDATE projet.power_mangeurs SET puissance = _puissance WHERE id_pm = _id_pm;

	ELSE
		RAISE 'Ce Power-Up a déjà été utilisé aujourd''hui !';
	END IF;

	RETURN _puissance;

END;
$$ LANGUAGE plpgsql;

-- Encaisser un prix au JackPot

CREATE OR REPLACE FUNCTION projet.encaisser_jackpot(INTEGER) RETURNS INTEGER AS $$
DECLARE
	_id_pm		ALIAS FOR $1;
	_vie		INTEGER;
	_date_fin	TIMESTAMP;
BEGIN

	-- Selectionner le nombre de vies du PM et la date de son dernier combat
	SELECT date_fin INTO _date_fin
	FROM projet.combats
	WHERE id_pm = _id_pm AND date_fin IS NOT NULL
	ORDER BY date_fin DESC
	LIMIT 1;

	-- Controle qu'il existe un dernier combat
	IF _date_fin IS NULL THEN
		RAISE 'Combat en cours ou inexistant';
	END IF;

	-- Controle timing
	IF (LOCALTIMESTAMP - _date_fin) > (INTERVAL '5 minutes') THEN 
		RAISE 'JackPot seulement valable 5 minutes apres une fin de combat';
	END IF;
	
	-- Incremente les vies
	UPDATE projet.power_mangeurs SET vie = vie+1 WHERE id_pm = _id_pm RETURNING vie INTO _vie;

	-- Retourne le nombre de vies actuel
	RETURN _vie;

END;
$$ LANGUAGE plpgsql;

-- Visualiser l'historique du dernier combat

CREATE TYPE projet.liste_actions AS (date TIMESTAMP, action VARCHAR(255));

CREATE OR REPLACE FUNCTION projet.visualiser_combat(INTEGER) RETURNS SETOF projet.liste_actions AS $$
DECLARE
	_id_pm			ALIAS FOR $1;
	_id_combat		INTEGER;
	_debut_combat	TIMESTAMP;
	_fin_combat		TIMESTAMP;
	_power_up		RECORD;
	_action			projet.liste_actions;
BEGIN

	SELECT id_combat, date_debut, date_fin INTO _id_combat, _debut_combat, _fin_combat FROM projet.combats WHERE id_pm = _id_pm ORDER BY date_fin DESC LIMIT 1;

	IF _id_combat IS NULL THEN
		RETURN;
	END IF;
	
	-- Retourner date début combat
	SELECT _debut_combat, 'Début du combat' INTO _action;
	RETURN NEXT _action;

	-- Retourner utilisations P-U
	FOR _power_up IN
		SELECT ut.date_utilisation, pu.nom FROM projet.utilisations ut INNER JOIN projet.power_ups pu ON ut.id_pu = pu.id_pu WHERE id_combat = _id_combat ORDER BY ut.date_utilisation ASC
	LOOP
		SELECT _power_up.date_utilisation, 'Activation du P-U ' || _power_up.nom INTO _action;
		RETURN NEXT _action;
	END LOOP;

	-- Retourner date fin combat
	SELECT _fin_combat, 'Fin du combat' INTO _action;
	RETURN NEXT _action;

	RETURN;

END;
$$ LANGUAGE plpgsql;

-- Statistiques PM

CREATE FUNCTION projet.stats_pm(INTEGER) RETURNS TABLE(nom_archetype VARCHAR(100), nb_combats_total INTEGER, nb_victoires_total INTEGER, nb_combats_annee INTEGER, nb_victoires_annee INTEGER) AS $$
DECLARE
	_id_pm ALIAS FOR $1;
BEGIN

  PERFORM projet.verifier_stats_annee();

  RETURN QUERY SELECT
		 a.nom AS "nom_archetype",
		 s.nb_combats_total,
		 s.nb_victoires_total,
		 s.nb_combats_annee,
		 s.nb_victoires_annee
	 FROM projet.statistiques s
		 INNER JOIN projet.archetypes a ON s.id_archetype = a.id_archetype
		WHERE id_pm = _id_pm;

END;
$$ LANGUAGE plpgsql;

-- Calculer l'espérance de vie

CREATE FUNCTION projet.esperance_vie(INTEGER) RETURNS INTERVAL AS $$
DECLARE
	_id					ALIAS FOR $1;
	_date_inscription	TIMESTAMP;
	_vie					INTEGER;
	_esperance			INTERVAL;
BEGIN

	SELECT date_inscription, vie INTO _date_inscription, _vie FROM projet.power_mangeurs WHERE id_pm = _id;

	IF (_vie = 0) THEN
		RAISE EXCEPTION 'Vous êtes mort !';
	ELSIF (_vie = 10) THEN
		RAISE WARNING 'Vous êtes invincible !';
		RETURN 0;
	END IF;

	_esperance:=_vie*(NOW()-_date_inscription)/(10-_vie);

	RETURN justify_interval(_esperance);

END;
$$ LANGUAGE plpgsql;
-- Appel màj stats annuelles

CREATE FUNCTION projet.verifier_stats() RETURNS TRIGGER AS $$
DECLARE
	_dernier_combat TIMESTAMP;
BEGIN

	PERFORM projet.verifier_stats_annee();

	RETURN NEW;

END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER verifier_stats
  BEFORE INSERT ON projet.combats
  FOR EACH ROW
  EXECUTE PROCEDURE projet.verifier_stats();

-- Combat

CREATE FUNCTION projet.ajouter_combat() RETURNS TRIGGER AS $$
  BEGIN

    -- Créer ligne de stats si pas existante
	IF NOT EXISTS(SELECT * FROM projet.statistiques WHERE id_pm = NEW.id_pm AND id_archetype = NEW.id_archetype) THEN
		INSERT INTO projet.statistiques (id_pm, id_archetype) VALUES (NEW.id_pm, NEW.id_archetype);
	END IF;

	UPDATE projet.statistiques SET nb_combats_total = nb_combats_total+1, nb_combats_annee = nb_combats_annee+1 WHERE id_pm = NEW.id_pm AND id_archetype = NEW.id_archetype;

  RETURN NULL;

  END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER ajouter_combat
  AFTER INSERT ON projet.combats
  FOR EACH ROW
  EXECUTE PROCEDURE projet.ajouter_combat();

-- Victoire

CREATE FUNCTION projet.ajouter_victoire() RETURNS TRIGGER AS $$
  BEGIN

    UPDATE projet.statistiques SET nb_victoires_total = nb_victoires_total+1, nb_victoires_annee = nb_victoires_annee+1 WHERE id_pm = NEW.id_pm AND id_archetype = NEW.id_archetype;

    RETURN NULL;

  END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER ajouter_victoire 
	AFTER INSERT OR UPDATE OF est_gagne ON projet.combats
	FOR EACH ROW
	WHEN (NEW.est_gagne = TRUE)
	EXECUTE PROCEDURE projet.ajouter_victoire();

-- Défaite

CREATE FUNCTION projet.ajouter_defaite() RETURNS TRIGGER AS $$
DECLARE
	_vie		INTEGER;
BEGIN

	UPDATE projet.power_mangeurs SET vie = vie-1 WHERE id_pm = NEW.id_pm RETURNING vie INTO _vie;
	
	IF (_vie = 0) THEN
		UPDATE projet.power_mangeurs SET date_deces = LOCALTIMESTAMP WHERE id_pm = NEW.id_pm;
	END IF;

	RETURN NULL;

END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER ajouter_defaite 
	AFTER INSERT OR UPDATE OF est_gagne ON projet.combats
	FOR EACH ROW
	WHEN (NEW.est_gagne = FALSE)
	EXECUTE PROCEDURE projet.ajouter_defaite();
-- Suppression ordonnée pour éviter violation des contraintes

DELETE FROM projet.utilisations;
DELETE FROM projet.combats;
DELETE FROM projet.power_ups;
DELETE FROM projet.archetypes;
DELETE FROM projet.power_mangeurs;

ALTER SEQUENCE projet.id_combat RESTART;
ALTER SEQUENCE projet.id_power_up RESTART;
ALTER SEQUENCE projet.id_archetype RESTART;
ALTER SEQUENCE projet.id_power_mangeur RESTART;

-- Power Mangeurs

INSERT INTO projet.power_mangeurs (nom, mot_de_passe, couleur, vie, date_inscription, date_deces) VALUES
  ('Jean', '984facf29f1f1701b7f474f64e3ba3f0e14375947b0f22392272a44892cf64802a921728b5445920c0244675992da3ff0e3ab950c1d63d3c4a1d89ed9deee635', 'C04AD1', DEFAULT, DEFAULT, NULL),
  ('Gerard', '984facf29f1f1701b7f474f64e3ba3f0e14375947b0f22392272a44892cf64802a921728b5445920c0244675992da3ff0e3ab950c1d63d3c4a1d89ed9deee635', '930C48', 8, '2014-12-03 18:15:12', NULL),
  ('Charles', '984facf29f1f1701b7f474f64e3ba3f0e14375947b0f22392272a44892cf64802a921728b5445920c0244675992da3ff0e3ab950c1d63d3c4a1d89ed9deee635', '2E69A3', 3, '2014-09-02 14:30:20', NULL),
  ('Hubert', '984facf29f1f1701b7f474f64e3ba3f0e14375947b0f22392272a44892cf64802a921728b5445920c0244675992da3ff0e3ab950c1d63d3c4a1d89ed9deee635', 'A8FF20', 0, '2014-08-15 17:03:20', '2014-11-30 11:20:54');

-- Archétypes

INSERT INTO projet.archetypes (nom, puissance) VALUES
  ('Tiramisu', 50),
  ('Couscous', 40),
  ('Poireau', 35),
  ('Concombre', 30),
  ('Courgette', 20),
  ('Yoagurth', 15);

-- Power-Ups

INSERT INTO projet.power_ups (nom, id_pm, date_attribution, facteur) VALUES
  ('Force obscure', 2, DEFAULT, 60),
  ('Orbe Rouge', 3, '2014-10-10 12:30:17', 70),
  ('Orbe Bleue', 3, '2014-11-29 19:08:20', 30),
  ('Mutantox', 4, '2014-08-22 09:48:25', 50);

-- Combats

INSERT INTO projet.combats (id_pm, id_archetype, date_debut, date_fin, est_gagne) VALUES
  (2, 3, DEFAULT, NULL, NULL),
  (3, 4, '2014-11-30 20:17:01', '2014-11-30 20:22:35', TRUE),
  (3, 4, '2014-10-15 15:31:44', '2014-10-15 15:39:26', TRUE),
  (3, 4, '2014-10-15 18:14:17', '2014-10-15 18:16:43', FALSE),
  (3, 5, '2014-10-17 10:09:36', '2014-10-17 10:13:34', TRUE),
  (3, 5, '2014-10-18 06:36:21', '2014-10-18 06:46:21', FALSE),
  (3, 1, '2014-10-29 14:50:13', '2014-10-29 14:59:20', TRUE);

-- Utilisations

INSERT INTO projet.utilisations (id_combat, id_pu, date_utilisation) VALUES
  (2, 3, '2014-11-30 20:19:28'),
  (3, 3, '2014-10-15 15:34:21'),
  (7, 3, '2014-10-29 14:53:45'),
  (7, 2, '2014-10-29 14:57:12');


﻿-- Table power_mangeurs

-- Controle que la date d'inscription soit inferieur a la date de deces
INSERT INTO projet.power_mangeurs (nom, couleur, mot_de_passe, date_inscription, date_deces) 
VALUES ('John', 'FFFFFF', '***', '2014-10-10 12:00:00', '2012-10-10 12:00:00');

-- Controle que le mot de passe ne soit pas vide
INSERT INTO projet.power_mangeurs (nom, couleur, mot_de_passe) 
VALUES ('John', 'FFFFFF', '');

-- Controle que le nom (trimme) ait au moins 3 caracteres
INSERT INTO projet.power_mangeurs (nom, couleur, mot_de_passe) 
VALUES ('  J  ', 'FFFFFF', '***');

-- Controle que la puissance soit au moins de 30 points
INSERT INTO projet.power_mangeurs (nom, couleur, mot_de_passe, puissance) 
VALUES ('John', 'FFFFFF', '***', 15);

-- Controle que le nombre de vies ne soit pas negatif
INSERT INTO projet.power_mangeurs (nom, couleur, mot_de_passe, vie) 
VALUES ('John', 'FFFFFF', '***', -4);

-- Controle que le nombre de vies ne soit pas superieur a 10
INSERT INTO projet.power_mangeurs (nom, couleur, mot_de_passe, vie) 
VALUES ('John', 'FFFFFF', '***', 11);

-- Table archetypes

-- Controle pour voir si le nom de l'archetype n'est pas vide
INSERT INTO projet.archetypes (nom, puissance)
VALUES ('', 20);

-- Controle pour s'assurer que la puissance de l'archetype ne soit pas negative
INSERT INTO projet.archetypes (nom, puissance)
VALUES ('Couscous', -10);

-- Table power_ups

-- Controle que la date d'attribution ne soit pas dans le futur
INSERT INTO projet.power_ups (nom, id_pm, date_attribution, facteur)
VALUES ('Spatule', 1, '2020-10-10 12:00:00', 50);

-- Controle pour voir que le facteur soit entierement positif
INSERT INTO projet.power_ups (nom, id_pm, facteur)
VALUES ('Spatule', 1, 0);

-- Controle pour voir que le nom ne soit pas vide
INSERT INTO projet.power_ups (nom, id_pm, facteur)
VALUES ('', 1, 50);

-- Table combats

-- Controle pour s'assurer que la date de fin soit strictement superieur a la date de debut
INSERT INTO projet.combats (id_pm, id_archetype, date_debut, date_fin) 
VALUES (1, 1, '2014-10-10 12:00:00', '2014-10-10 10:00:00');

-- Controle pour voir si la date de debut ne se situe pas dans le futur
INSERT INTO projet.combats (id_pm, id_archetype, date_debut) 
VALUES (1, 1, '2020-10-10 12:00:00');

-- Table utilisations

-- Controle que la date d'utilisation du power up ne se situe pas dans le futur
INSERT INTO projet.utilisations (id_combat, id_pu, date_utilisation) 
VALUES (1, 1, '2020-10-10 12:00:00');

-- Table statistiques

-- Controle que le nombres de victoires total soit inferieur ou egal au nombre de combats
INSERT INTO projet.statistiques (id_pm, id_archetype, nb_combats_total, nb_victoires_total, nb_combats_annee, nb_victoires_annee) 
VALUES (1, 1, 20, 21, 20, 10);

-- Controle que le nombres de victoires par annee soit inferieur ou egal au nombre de combats
INSERT INTO projet.statistiques (id_pm, id_archetype, nb_combats_total, nb_victoires_total, nb_combats_annee, nb_victoires_annee) 
VALUES (1, 1, 20, 10, 20, 21);

-- Controle que le nombre de victoires au total soit positif
INSERT INTO projet.statistiques (id_pm, id_archetype, nb_combats_total, nb_victoires_total, nb_combats_annee, nb_victoires_annee) 
VALUES (1, 1, 20, -5, 20, 10);

-- Controle que le nombre de victoires par annee soit positif
INSERT INTO projet.statistiques (id_pm, id_archetype, nb_combats_total, nb_victoires_total, nb_combats_annee, nb_victoires_annee) 
VALUES (1, 1, 20, 10, 20, -5);

-- Note: il est inutile de controler que le nombre de combats total ou par annee soit positif, 
-- car en controlant que le nombre de victoires ne puisse pas etre negatif, le nombre de combats 
-- devra etre aussi plus grand que le nombre de victoires.

-- Controle que le nombre de combats par annee soit inferieur au nombre total de combats
INSERT INTO projet.statistiques (id_pm, id_archetype, nb_combats_total, nb_victoires_total, nb_combats_annee, nb_victoires_annee) 
VALUES (1, 1, 20, 10, 30, 10);

-- Controle que le nombre de victoires par annee soit inferieur au nombre total de victoires
INSERT INTO projet.statistiques (id_pm, id_archetype, nb_combats_total, nb_victoires_total, nb_combats_annee, nb_victoires_annee) 
VALUES (1, 1, 20, 10, 20, 30);
﻿
-- RESET DE TOUTES LES TABLES
-- Pour utilisation lors des tests de presentation

TRUNCATE projet.utilisations, projet.statistiques, projet.power_ups, 
projet.combats, projet.archetypes, projet.power_mangeurs CASCADE;

SELECT * FROM projet.inscrire_pm('Rouge', '984facf29f1f1701b7f474f64e3ba3f0e14375947b0f22392272a44892cf64802a921728b5445920c0244675992da3ff0e3ab950c1d63d3c4a1d89ed9deee635', 'FFFFFF');
SELECT * FROM projet.inscrire_pm('Bleu', '984facf29f1f1701b7f474f64e3ba3f0e14375947b0f22392272a44892cf64802a921728b5445920c0244675992da3ff0e3ab950c1d63d3c4a1d89ed9deee635', '000000');