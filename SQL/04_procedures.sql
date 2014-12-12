-- ----------------------------------------------------------------------------------------------------------------------
--                                                    Toriko
-- ----------------------------------------------------------------------------------------------------------------------


-- [X] Inscription P-M

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

-- -------------------------------------------------------------------------------------------------

-- [X] Ajout archétype

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

-- -------------------------------------------------------------------------------------------------

-- [X] Attribution P-U

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
	IF (_id_pm IS NULL) THEN
		RAISE '% n''existe pas !', _nom_pm USING ERRCODE = 'invalid_foreign_key';
	END IF;

	INSERT INTO projet.power_ups (nom, id_pm, facteur) VALUES (_nom_pu, _id_pm, _facteur_pu) RETURNING id_pu INTO _id_pu;

	RETURN _id_pu;

END;
$$ LANGUAGE plpgsql;

-- -------------------------------------------------------------------------------------------------

-- Vérification des statistiques de l'année courante

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

-- [X] Classement Power Mangeur

CREATE TYPE projet.classification_pm AS (nom VARCHAR(100), victoires INTEGER);

CREATE FUNCTION projet.classer_pm() RETURNS SETOF projet.classification_pm AS $$
DECLARE
	_dernier_combat	TIMESTAMP;
	sortie          projet.classification_pm;
BEGIN

  PERFORM projet.verifier_stats_annee();

	FOR sortie IN
		SELECT
			pm.nom,
			SUM(s.nb_victoires_annee) AS "victoires"
		FROM projet.statistiques s
			RIGHT JOIN projet.power_mangeurs pm ON s.id_pm = pm.id_pm
		WHERE pm.vie > 0
		GROUP BY nom
		HAVING SUM(s.nb_victoires_annee) IS NOT NULL
		ORDER BY victoires DESC
	LOOP
			RETURN NEXT sortie;
	END LOOP;

	RETURN;

END;
$$ LANGUAGE plpgsql;

-- ----------------------------------------------------------------------------------------------------------------------
--                                                   Power-Mangeurs
-- ----------------------------------------------------------------------------------------------------------------------


-- [X] Débuter combat

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

-- -------------------------------------------------------------------------------------------------

-- [X] Conclure combat

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

-- -------------------------------------------------------------------------------------------------

-- [X] Utiliser P-U

CREATE FUNCTION projet.utiliser_pu(INTEGER, INTEGER) RETURNS BOOLEAN AS $$
DECLARE
	_id_pm					      ALIAS FOR $1;
	_id_pu					      ALIAS FOR $2;
	_id_combat				    INTEGER;
	_facteur							INTEGER;
	_derniere_utilisation	TIMESTAMP;
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
		UPDATE projet.power_mangeurs SET puissance = puissance+puissance*_facteur/100 WHERE id_pm = _id_pm;

	ELSE
		RAISE 'Ce Power-Up a déjà été utilisé aujourd''hui !';
	END IF;

	RETURN TRUE;

END;
$$ LANGUAGE plpgsql;

-- -------------------------------------------------------------------------------------------------

-- [X] Encaisser un prix au JackPot

CREATE OR REPLACE FUNCTION projet.encaisser_jackpot(INTEGER) RETURNS INTEGER AS $$
DECLARE
	_id_pm		ALIAS FOR $1;
	_vie		INTEGER;
	_date_fin	TIMESTAMP;
BEGIN

	-- Selectionner le nombre de vies du PM
	SELECT vie INTO _vie FROM projet.power_mangeurs WHERE id_pm = _id_pm;

	-- Controle que le PM existe
	IF _vie IS NULL THEN
		RAISE 'Power Mangeur introuvable';
	END IF;

	-- Controle que la vie ne soit pas au maximum
	IF _vie>=10 THEN
		RAISE 'Vie est au maximum';
	END IF;

	-- Choper fin dernier combat
	SELECT c.date_fin INTO _date_fin FROM projet.combats c WHERE c.id_pm = _id_pm ORDER BY date_debut DESC LIMIT 1;

	-- Controle que combat soit bien termine
	IF _date_fin IS NULL THEN
		RAISE 'Combat en cours';
	END IF;

	-- Controle timing
	IF (LOCALTIMESTAMP - _date_fin) > (INTERVAL '5 minutes') THEN 
		RAISE 'JackPot seulement valable 5 minutes apres une fin de combat';
	END IF;
	
	-- Incremente les vies
	_vie := _vie + 1;
	UPDATE projet.power_mangeurs SET vie = _vie WHERE id_pm = _id_pm;

	-- Retourne le nombre de vies actuel
	RETURN _vie;

END;
$$ LANGUAGE plpgsql;

----------------------------------------------------------------------------------------------------

-- [X] Visualiser historique dernier combat

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

-- -------------------------------------------------------------------------------------------------

-- Statistiques PM

CREATE TYPE projet.ligne_stat AS (nom_archetype VARCHAR(100), nb_combats_total INTEGER, nb_victoires_total INTEGER, nb_combats_annee INTEGER, nb_victoires_annee INTEGER);

CREATE FUNCTION projet.stats_pm(INTEGER) RETURNS SETOF projet.ligne_stat AS $$
DECLARE
	sortie projet.ligne_stat;
BEGIN

  PERFORM projet.verifier_stats_annee();

	FOR sortie IN
		SELECT
			a.nom AS "nom_archetype",
			s.nb_combats_total,
			s.nb_victoires_total,
			s.nb_combats_annee,
			s.nb_victoires_annee
		FROM projet.statistiques s
			INNER JOIN projet.archetypes a ON s.id_archetype = a.id_archetype
	LOOP
			RETURN NEXT sortie;
	END LOOP;

	RETURN;

END;
$$ LANGUAGE plpgsql;

--  -------------------------------------------------------------------------------------------------

-- [X] Espérance de vie

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
