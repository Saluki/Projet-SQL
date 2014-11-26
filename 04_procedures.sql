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

-- -------------------------------------------------------------------------------------------------

-- [ ] Visualisation historique combats

DROP TYPE IF EXISTS liste_combats CASCADE;

CREATE TYPE liste_combats AS (nom_archetype VARCHAR(100), date_debut TIMESTAMP, date_fin TIMESTAMP, est_gagne BOOLEAN);

DROP FUNCTION IF EXISTS projet.visualiser_historique(VARCHAR(100), TIMESTAMP, TIMESTAMP) CASCADE;

CREATE FUNCTION projet.visualiser_historique(VARCHAR(100), TIMESTAMP, TIMESTAMP) RETURNS SETOF liste_combats AS $$
DECLARE
	_nom_pm		ALIAS FOR $1;
	_date_debut	ALIAS FOR $2;
	_date_fin	ALIAS FOR $3;
	_combat		liste_combats;
BEGIN

	-- Vérifier dates ?
	
	FOR _combat 
	IN SELECT nom_archetype, date_debut, date_fin, est_gagne
		FROM projet.historique_combats
		WHERE nom_pm = _nom_pm
			AND (date_debut BETWEEN _date_debut AND _date_fin
				OR date_fin BETWEEN _date_debut AND _date_fin)
	LOOP
		RETURN NEXT _combat;
	END LOOP;
	
	RETURN;
	
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

-- [ ] Espérance de vie

DROP FUNCTION IF EXISTS projet.esperance_vie(INTEGER) CASCADE;

CREATE FUNCTION projet.esperance_vie(INTEGER) RETURNS INTEGER AS $$
DECLARE
	_id					ALIAS FOR $1;
	_date_inscription	TIMESTAMP;
	_vie					INTEGER;
	_date_diff			INTEGER; -- Le nombre de jours écoulés depuis l'inscription
	_esperance			INTEGER:=0; -- L'espérance de vie en jours
BEGIN

	SELECT date_inscription, vie INTO _date_inscription, _vie FROM projet.power_mangeurs WHERE id_pm = _id;
	
	IF (_vie==0) THEN
		RAISE NOTICE 'Vous êtes mort.';
		RETURN 0;
	END IF;
	
	_date_diff:=cast(EXTRACT(DAY FROM (NOW()-_date_inscription)) as integer);
	
	IF (_date_diff==0) THEN
		RAISE NOTICE 'Impossible de déterminer l\'espérance de vie pour l\'instant.';
		RETURN 0;
	END IF;
	
	_esperance:=_vie*_date_diff/(10-_vie);
	
	RETURN _esperance;

END;
$$ LANGUAGE plpgsql;
