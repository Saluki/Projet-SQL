DELETE FROM projet.power_mangeurs;

INSERT INTO projet.power_mangeurs (nom, mot_de_passe, couleur) VALUES
	('Jean', 'jeanjean', 'C04AD1'),
	('Marc', 'moncul', '7D28B1'),
	('Charles', 'chapeau', '2E69A3'),
	('Hubert', 'trululu', 'A8FF20'),
	('Claude', 'fouillon', '4B783D'),
	('François', 'bouillon', 'D591B5'),
	('Gérard', 'lambert', '930C48'),
	('Roger', 'rototo', '16D93C');

SELECT * FROM projet.ajouter_archetype('Couscous', 45);
SELECT * FROM projet.ajouter_archetype('Concombre', 15);

