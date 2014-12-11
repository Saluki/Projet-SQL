-- BEFORE INSERT combats
-- Vérifier si nouvelle année et mettre stats de l'année à zéro (pour tout le monde) si c'est le cas

CREATE FUNCTION projet.verifier_stats() RETURNS TRIGGER AS $$
DECLARE
	_dernier_combat TIMESTAMP;
BEGIN

	SELECT c.date_debut INTO _dernier_combat FROM projet.combats c ORDER BY c.date_debut DESC LIMIT 1;
	IF (EXTRACT(YEAR FROM _dernier_combat) < EXTRACT(YEAR FROM NEW.date_debut)) THEN
		UPDATE projet.statistiques SET nb_combats_annee = 0, nb_victoires_annee = 0;
	END IF;

	RETURN NEW;

END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER verifier_stats
  BEFORE INSERT ON projet.combats
  EXECUTE PROCEDURE projet.verifier_stats();

-- AFTER INSERT combats

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

-- AFTER UPDATE combats

-- Victoire

CREATE FUNCTION projet.ajouter_victoire() RETURNS TRIGGER AS $$
  BEGIN

    UPDATE projet.statistiques SET nb_victoires_total = nb_victoires_total+1, nb_victoires_annee = nb_victoires_annee+1 WHERE id_pm = NEW.id_pm AND id_archetype = NEW.id_arch;

    RETURN NULL;

  END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER ajouter_victoire 
	AFTER UPDATE OF est_gagne ON projet.combats
	FOR EACH ROW
	WHEN (OLD.est_gagne IS NULL AND NEW.est_gagne = TRUE)
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
	AFTER UPDATE OF est_gagne ON projet.combats
	FOR EACH ROW
	WHEN (OLD.est_gagne IS NULL AND NEW.est_gagne = FALSE)
	EXECUTE PROCEDURE projet.ajouter_defaite();
