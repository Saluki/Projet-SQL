﻿
-- Table power_mangeurs

-- Controle que la date d'inscription soit inferieur a la date de deces
INSERT INTO projet.power_mangeurs (nom, couleur, mot_de_passe, date_inscription, date_deces) 
VALUES ('John', 'FFFFFF', '***', '2014-10-10 12:00:00', '2012-10-10 12:00:00');

-- Controle que le mot de passe ne soit pas vide
INSERT INTO projet.power_mangeurs (nom, couleur, mot_de_passe) 
VALUES ('John', 'FFFFFF', '');

-- Controle que le nom (trimme) ait au moins 3 caracteres
INSERT INTO projet.power_mangeurs (nom, couleur, mot_de_passe) 
VALUES ('  J  ', 'FFFFFF', '***');

-- Controle que la puissance soit au moins de 30 points
INSERT INTO projet.power_mangeurs (nom, couleur, mot_de_passe, puissance) 
VALUES ('John', 'FFFFFF', '***', 15);

-- Controle que le nombre de vies ne soit pas negatif
INSERT INTO projet.power_mangeurs (nom, couleur, mot_de_passe, vie) 
VALUES ('John', 'FFFFFF', '***', -4);

-- Controle que le nombre de vies ne soit pas superieur a 10
INSERT INTO projet.power_mangeurs (nom, couleur, mot_de_passe, vie) 
VALUES ('John', 'FFFFFF', '***', 11);

-- Table archetypes

-- Controle pour voir si le nom de l'archetype n'est pas vide
INSERT projet.archetypes (nom, puissance)
VALUES ('', 20);

-- Controle pour s'assurer que la puissance de l'archetype ne soit pas negative
INSERT projet.archetypes (nom, puissance)
VALUES ('Couscous', -10);

-- Table power_ups

-- Controle que la date d'attribution ne soit pas dans le futur
INSERT INTO projet.power_ups (nom, id_pm, date_attribution, facteur)
VALUES ('Spatule', 1, '2020-10-10 12:00:00', 50);

-- Controle pour voir que le facteur soit entierement positif
INSERT INTO projet.power_ups (nom, id_pm, facteur)
VALUES ('Spatule', 1, 0);

-- Controle pour voir que le nom ne soit pas vide
INSERT INTO projet.power_ups (nom, id_pm, facteur)
VALUES ('', 1, 50);

-- Table combats

-- Controle pour s'assurer que la date de fin soit strictement superieur a la date de debut
INSERT INTO projet.combats (id_pm, id_archetype, date_debut, date_fin) 
VALUES (1, 1, '2014-10-10 12:00:00', '2014-10-10 10:00:00');

-- Controle pour voir si la date de debut ne se situe pas dans le futur
INSERT INTO projet.combats (id_pm, id_archetype, date_debut) 
VALUES (1, 1, '2020-10-10 12:00:00');

-- Table utilisations

-- Controle que la date d'utilisation du power up ne se situe pas dans le futur
INSERT INTO projet.utilisations (id_combat, id_pu, date_utilisation) 
VALUES (1, 1, '2020-10-10 12:00:00');

-- Table statistiques

-- Controle que le nombres de victoires total soit inferieur ou egal au nombre de combats
INSERT INTO projet.statistiques (id_pm, id_archetype, nb_combats_total, nb_victoires_total, nb_combats_annee, nb_victoires_annee) 
VALUES (1, 1, 20, 21, 20, 10);

-- Controle que le nombres de victoires par annee soit inferieur ou egal au nombre de combats
INSERT INTO projet.statistiques (id_pm, id_archetype, nb_combats_total, nb_victoires_total, nb_combats_annee, nb_victoires_annee) 
VALUES (1, 1, 20, 10, 20, 21);

-- Controle que le nombre de victoires au total soit positif
INSERT INTO projet.statistiques (id_pm, id_archetype, nb_combats_total, nb_victoires_total, nb_combats_annee, nb_victoires_annee) 
VALUES (1, 1, 20, -5, 20, 10);

-- Controle que le nombre de victoires par annee soit positif
INSERT INTO projet.statistiques (id_pm, id_archetype, nb_combats_total, nb_victoires_total, nb_combats_annee, nb_victoires_annee) 
VALUES (1, 1, 20, 10, 20, -5);

-- Note: il est inutile de controler que le nombre de combats total ou par annee soit positif, 
-- car en controlant que le nombre de victoires ne puisse pas etre negatif, le nombre de combats 
-- devra etre aussi plus grand que le nombre de victoires.

-- Controle que le nombre de combats par annee soit inferieur au nombre total de combats
INSERT INTO projet.statistiques (id_pm, id_archetype, nb_combats_total, nb_victoires_total, nb_combats_annee, nb_victoires_annee) 
VALUES (1, 1, 20, 10, 30, 10);

-- Controle que le nombre de victoires par annee soit inferieur au nombre total de victoires
INSERT INTO projet.statistiques (id_pm, id_archetype, nb_combats_total, nb_victoires_total, nb_combats_annee, nb_victoires_annee) 
VALUES (1, 1, 20, 10, 20, 30);
