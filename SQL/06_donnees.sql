DELETE FROM projet.power_mangeurs;

INSERT INTO projet.power_mangeurs (nom, mot_de_passe, couleur, vie, date_inscription, date_deces) VALUES
  ('Jean', 'jeanjean', 'C04AD1', DEFAULT, DEFAULT, NULL),
  ('Gérard', 'lambert', '930C48', DEFAULT, '2014-12-03 18:15:12', NULL),
  ('Charles', 'chapeau', '2E69A3', 3, '2014-09-02 14:30:20', NULL),
  ('Hubert', 'trululu', 'A8FF20', 0, '2014-08-15 17:03:20', '2014-11-30 11:20:54');

DELETE FROM projet.archetypes;

INSERT INTO projet.archetypes (nom, puissance) VALUES
  ('Couscous', 40),
  ('Yoagurth', 15);

DELETE FROM projet.power_ups;

INSERT INTO projet.power_ups (nom, id_pm, date_attribution, facteur) VALUES
  ('Orbe Bleue', 1, DEFAULT, 50);