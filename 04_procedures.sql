-- ---------------------------------------------------------------------------------
--                                    Toriko
-- ---------------------------------------------------------------------------------

-- Inscription P-M
DROP FUNCTION IF EXISTS projet.inscrire_pm(VARCHAR(100), CHAR(6), VARCHAR(150)) CASCADE;

CREATE FUNCTION projet.inscrire_pm(VARCHAR(100), CHAR(6), VARCHAR(150)) RETURNS INTEGER AS $$
DECLARE
	nom_pm 		ALIAS FOR $1;
	couleur_pm 	ALIAS FOR $2;
	mdp_pm 		ALIAS FOR $3;
	id			INTEGER;
BEGIN
	
	INSERT INTO projet.power_mangeurs (nom, couleur, mot_de_passe) VALUES (nom_pm, couleur_pm, mdp_pm) RETURNING id_pm INTO id;
	
	RETURN id;
	
END;
$$ LANGUAGE plpgsql;

-- Ajout archétype
DROP FUNCTION IF EXISTS projet.ajouter_archetype(VARCHAR(100), INTEGER) CASCADE;

CREATE FUNCTION projet.ajouter_archetype(VARCHAR(100), INTEGER) RETURNS INTEGER AS $$
DECLARE
	nom_arch 		ALIAS FOR $1;
	puissance_arch 	ALIAS FOR $2;
	id				INTEGER;
BEGIN
	
	INSERT INTO projet.archetypes (nom, puissance) VALUES (nom_arch, puissance_arch) RETURNING id_archetype INTO id;
	
	RETURN id;
	
END;
$$ LANGUAGE plpgsql;

-- Attribution P-U
DROP FUNCTION IF EXISTS projet.attribuer_pu(VARCHAR(100), VARCHAR(100), INTEGER) CASCADE;

CREATE FUNCTION projet.attribuer_pu(VARCHAR(100), VARCHAR(100), INTEGER) RETURNS INTEGER AS $$
DECLARE
	nom_pu		ALIAS FOR $1;
	nom_pm		ALIAS FOR $2;
	facteur_pu	ALIAS FOR $3;
	id_pm		INTEGER;
	id			INTEGER;
BEGIN
	
	-- Vérifier l'existence du P-M
	IF NOT EXISTS(SELECT id_pm FROM projet.power_mangeurs WHERE nom = nom_pm) THEN
		RAISE invalid_pm_name;
	END IF;
	
	INSERT INTO projet.power_ups (nom, id_pm, facteur) VALUES (nom_pu, id_pm, facteur_pu) RETURNING id_pu INTO id;
	
	RETURN id;
	
END;
$$ LANGUAGE plpgsql;

-- ---------------------------------------------------------------------------------
--                                Power-Mangeurs
-- ---------------------------------------------------------------------------------

-- Débuter combat
DROP FUNCTION IF EXISTS projet.debuter_combat(INTEGER, INTEGER) CASCADE;

CREATE FUNCTION projet.debuter_combat(INTEGER, INTEGER) RETURNS INTEGER AS $$
DECLARE
	_id_pm		ALIAS FOR $1;
	_id_arch		ALIAS FOR $2;
	_id			INTEGER;
BEGIN
	
	-- Vérifier si nouvelle année et mettre stats à zéro (pour tout le monde) si c'est le cas
		
	-- Vérifier si P-M n'est pas déjà en plein combat et lever une exception si c'est le cas
	IF EXISTS(SELECT * FROM projet.combats WHERE id_pm = _id_pm AND date_fin IS NULL) THEN
		RAISE battle_in_progress;
	END IF;
	
	-- Insérer un nouveau combat
	INSERT INTO projet.combats (id_pm, id_archetype) VALUES (_id_pm, _id_arch) RETURNING id_combat INTO _id;
	
	-- Créer ligne de stat si pas existante
	
	-- Incrémenter stats
	
	RETURN _id;
	
END;
$$ LANGUAGE plpgsql;

-- Conclure combat

-- Utiliser P-U

-- Espérance de vie
