-- Vérifier si nouvelle année et mettre stats de l'année à zéro (pour tout le monde) si c'est le cas

/*
-- AFTER UPDATE combats

-- Victoire

CREATE FUNCTION projet.ajouter_victoire() RETURNS trigger AS $$
BEGIN

	UPDATE projet.statistiques SET nb_victoires_total = nb_victoires_total+1, nb_victoires_annee = nb_victoires_annee+1 WHERE id_pm = NEW.id_pm AND id_archetype = NEW.id_arch;
	
	RETURN NEW;

END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER ajouter_victoire 
	AFTER UPDATE OF est_gagne ON projet.combats
	FOR EACH ROW
	WHEN (OLD.est_gagne IS NULL AND NEW.est_gagne == TRUE)
	EXECUTE PROCEDURE projet.ajouter_victoire();

-- Défaite

CREATE FUNCTION projet.ajouter_defaite() RETURNS trigger AS $$
DECLARE
	_vie		INTEGER;
BEGIN

	UPDATE projet.power_mangeurs SET vie = vie-1 WHERE id_pm = NEW.id_pm RETURNING vie INTO _vie;
	
	IF (_vie == 0) THEN
		UPDATE projet.power_mangeurs SET date_deces = LOCALTIMESTAMP WHERE id_pm = NEW.id_pm;
	END IF;

	RETURN NEW;

END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER ajouter_defaite 
	AFTER UPDATE OF est_gagne ON projet.combats
	FOR EACH ROW
	WHEN (OLD.est_gagne IS NULL AND NEW.est_gagne == FALSE)
	EXECUTE PROCEDURE projet.ajouter_defaite();
*/