-- Suppression ordonnée pour éviter violation des contraintes

DELETE FROM projet.utilisations;
DELETE FROM projet.combats;
DELETE FROM projet.power_ups;
DELETE FROM projet.archetypes;
DELETE FROM projet.power_mangeurs;

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


