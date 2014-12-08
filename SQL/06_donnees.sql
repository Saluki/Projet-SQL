-- Suppression ordonne pour eviter violation des contraintes

DELETE FROM projet.utilisations;
DELETE FROM projet.combats;
DELETE FROM projet.power_ups;
DELETE FROM projet.archetypes;
DELETE FROM projet.power_mangeurs;

-- Power Mangeurs

INSERT INTO projet.power_mangeurs (id_pm, nom, mot_de_passe, couleur, vie, date_inscription, date_deces) VALUES
(1, 'Jean', '984facf29f1f1701b7f474f64e3ba3f0e14375947b0f22392272a44892cf64802a921728b5445920c0244675992da3ff0e3ab950c1d63d3c4a1d89ed9deee635', 'C04AD1', DEFAULT, DEFAULT, NULL),
(2, 'Gerard', '984facf29f1f1701b7f474f64e3ba3f0e14375947b0f22392272a44892cf64802a921728b5445920c0244675992da3ff0e3ab950c1d63d3c4a1d89ed9deee635', '930C48', DEFAULT, '2014-12-03 18:15:12', NULL),
(3, 'Charles', '984facf29f1f1701b7f474f64e3ba3f0e14375947b0f22392272a44892cf64802a921728b5445920c0244675992da3ff0e3ab950c1d63d3c4a1d89ed9deee635', '2E69A3', 3, '2014-09-02 14:30:20', NULL),
(4, 'Hubert', '984facf29f1f1701b7f474f64e3ba3f0e14375947b0f22392272a44892cf64802a921728b5445920c0244675992da3ff0e3ab950c1d63d3c4a1d89ed9deee635', 'A8FF20', 0, '2014-08-15 17:03:20', '2014-11-30 11:20:54');
        
-- Archetypes
       
SELECT * FROM projet.ajouter_archetype('Concombre', 15);
SELECT * FROM projet.ajouter_archetype('Couscous', 45);
        
-- Power Ups
        
INSERT INTO projet.power_ups (nom, id_pm, date_attribution, facteur) VALUES ('Orbe Bleue', 1, DEFAULT, 50);
INSERT INTO projet.power_ups (nom, id_pm, date_attribution, facteur) VALUES ('Supra Ketchup', 1, DEFAULT, 50);
