-- Toriko

-- Inscription P-M
DROP FUNCTION IF EXISTS projet.inscription_pm(VARCHAR(100), CHAR(6), VARCHAR(150)) CASCADE;

CREATE FUNCTION projet.inscription_pm(VARCHAR(100), CHAR(6), VARCHAR(150)) RETURNS INTEGER AS $$
DECLARE
	nom_pm 		ALIAS FOR $1;
	couleur_pm 	ALIAS FOR $2;
	mdp_pm 		ALIAS FOR $3;
	_id_pm		INTEGER;
BEGIN
	
INSERT INTO projet.power_mangeurs (nom, couleur, mot_de_passe) VALUES (nom_pm, couleur_pm, mdp_pm) RETURNING id_pm INTO _id_pm;

RETURN _id_pm;
	
END;
$$ LANGUAGE plpgsql;

-- Ajout archétype
DROP FUNCTION IF EXISTS projet.ajout_archetype(VARCHAR(100), INTEGER) CASCADE;

CREATE FUNCTION projet.ajout_archetype(VARCHAR(100), INTEGER) RETURNS INTEGER AS $$
DECLARE
	nom_arch 		ALIAS FOR $1;
	puissance_arch 	ALIAS FOR $2;
	_id_arch			INTEGER;
BEGIN

INSERT INTO projet.archetypes (nom, puissance) VALUES (nom_arch, puissance_arch) RETURNING id_archetype INTO _id_arch;

RETURN _id_arch;

END;
$$ LANGUAGE plpgsql;

-- Attribution P-U

-- P-M
-- Débuter combat
-- Conclure combat
-- Utiliser P-U