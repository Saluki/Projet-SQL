-- ----------------------------------------------------------------------------------------------------------------------
--                                                    Toriko
-- ----------------------------------------------------------------------------------------------------------------------


-- [X] Inscription P-M

DROP FUNCTION IF EXISTS projet.inscrire_pm(VARCHAR(100), CHAR(6), VARCHAR(150)) CASCADE;

CREATE FUNCTION projet.inscrire_pm(VARCHAR(100), CHAR(6), VARCHAR(150)) RETURNS INTEGER AS $$
DECLARE
	_nom 		ALIAS FOR $1;
	_couleur 	ALIAS FOR $2;
	_mdp 		ALIAS FOR $3;
	_id			INTEGER;
BEGIN

	INSERT INTO projet.power_mangeurs (nom, couleur, mot_de_passe) VALUES (_nom, _couleur, _mdp) RETURNING id_pm INTO _id;

	RETURN _id;

END;
$$ LANGUAGE plpgsql;

-- -------------------------------------------------------------------------------------------------

-- [X] Ajout archétype

DROP FUNCTION IF EXISTS projet.ajouter_archetype(VARCHAR(100), INTEGER) CASCADE;

CREATE FUNCTION projet.ajouter_archetype(VARCHAR(100), INTEGER) RETURNS INTEGER AS $$
DECLARE
	_nom			ALIAS FOR $1;
	_puissance 	ALIAS FOR $2;
	_id			INTEGER;
BEGIN

	INSERT INTO projet.archetypes (nom, puissance) VALUES (_nom, _puissance) RETURNING id_archetype INTO _id;

	RETURN _id;

END;
$$ LANGUAGE plpgsql;

-- -------------------------------------------------------------------------------------------------

-- [X] Attribution P-U

DROP FUNCTION IF EXISTS projet.attribuer_pu(VARCHAR(100), VARCHAR(100), INTEGER) CASCADE;

CREATE FUNCTION projet.attribuer_pu(VARCHAR(100), VARCHAR(100), INTEGER) RETURNS INTEGER AS $$
DECLARE
	_nom_pu		ALIAS FOR $1;
	_nom_pm		ALIAS FOR $2;
	_facteur_pu	ALIAS FOR $3;
	_id_pm		INTEGER;
	_id_pu		INTEGER;
BEGIN

	-- Vérifier l'existence du P-M
	SELECT id_pm INTO _id_pm FROM projet.power_mangeurs WHERE nom = nom_pm;
	IF NOT EXISTS(_id_pm) THEN
		RAISE '% n\'existe pas !', _nom_pm USING ERRCODE = 'invalid_foreign_key';
	END IF;

	INSERT INTO projet.power_ups (nom, id_pm, facteur) VALUES (_nom_pu, _id_pm, _facteur_pu) RETURNING id_pu INTO _id_pu;

	RETURN _id_pu;

END;
$$ LANGUAGE plpgsql;

-- ----------------------------------------------------------------------------------------------------------------------
--                                                   Power-Mangeurs
-- ----------------------------------------------------------------------------------------------------------------------


-- [ ] Débuter combat

DROP FUNCTION IF EXISTS projet.debuter_combat(INTEGER, INTEGER) CASCADE;

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

-- [ ] Conclure combat


-- -------------------------------------------------------------------------------------------------

-- [ ] Utiliser P-U


-- -------------------------------------------------------------------------------------------------

-- [ ] Visualiser historique dernier combat

DROP TYPE IF EXISTS projet.liste_actions CASCADE;

CREATE TYPE projet.liste_actions AS (date TIMESTAMP, action VARCHAR(255));

DROP FUNCTION IF EXISTS projet.visualiser_combat(INTEGER) CASCADE;

CREATE FUNCTION projet.visualiser_combat(INTEGER) RETURNS SETOF projet.liste_actions AS $$
DECLARE
	_id_pm			ALIAS FOR $1;
	_id_combat		INTEGER;
	_debut_combat	TIMESTAMP;
	_fin_combat		TIMESTAMP;
	_power_up		RECORD;
	_action			projet.liste_actions;
BEGIN

	SELECT id_combat, date_debut, date_fin INTO _id_combat, _debut_combat, fin_combat FROM projet.combats WHERE id_pm = _id_pm ORDER BY date_fin DESC LIMIT 1;
	
	-- Retourner date début combat
	SELECT _debut_combat, 'Début du combat' INTO _action;
	RETURN NEXT _action;
	
	-- Retourner utilisations P-U
	FOR _power_up
	IN SELECT ut.date_utilisation, pu.nom FROM projet.utilisations ut INNER JOIN projet.power_ups pu ON ut.id_pu = pu.id_pu WHERE id_combat = _id_combat ORDER BY ut.date_utilisation ASC
	LOOP
		SELECT _power_up.date_utilisation, 'Activation du P-U ' || _power_up.nom INTO _action;
		RETURN NEXT _action;
	END LOOP;
	
	-- Retourner date fin combat
	SELECT _fin_combat, 'Fin du combat' INTO _action;
	RETURN NEXT _action;

END;
$$ LANGUAGE plpgsql;

-- -------------------------------------------------------------------------------------------------

-- [ ] Espérance de vie

DROP FUNCTION IF EXISTS projet.esperance_vie(INTEGER) CASCADE;

CREATE FUNCTION projet.esperance_vie(INTEGER) RETURNS INTERVAL AS $$
DECLARE
	_id					ALIAS FOR $1;
	_date_inscription	TIMESTAMP;
	_vie					INTEGER;
	_esperance			INTERVAL;
BEGIN

	SELECT date_inscription, vie INTO _date_inscription, _vie FROM projet.power_mangeurs WHERE id_pm = _id;

	IF (_vie==0) THEN
		RAISE EXCEPTION 'Vous êtes mort.';
	ELSIF (_vie==10) THEN
		RAISE WARNING 'Impossible de déterminer l\'espérance de vie pour l\'instant.';
		RETURN 0;
	END IF;

	_esperance:=_vie*(NOW()-_date_inscription)/(10-_vie);

	RETURN _esperance;

END;
$$ LANGUAGE plpgsql;
