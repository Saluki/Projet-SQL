DROP TABLE IF EXISTS projet.power_mangeurs;

CREATE TABLE projet.power_mangeurs
(
	id_pm 				INTEGER 			PRIMARY KEY DEFAULT NEXTVAL('projet.id_power_mangeur'),
	nom 					VARCHAR(100) 	NOT NULL UNIQUE CHECK (nom<>''),
	couleur 				CHAR(6) 			NOT NULL UNIQUE,
	mot_de_passe 		VARCHAR(150) 	NOT NULL CHECK (mot_de_passe<>''),
	vie 					INTEGER 			NOT NULL DEFAULT 10,
	date_inscription 	TIMESTAMP 		NOT NULL DEFAULT LOCALTIMESTAMP,
	date_deces 			TIMESTAMP		CHECK (date_deces>date_inscription)
);

DROP TABLE IF EXISTS projet.archetypes;

CREATE TABLE projet.archetypes
(
	id_archetype		INTEGER 			PRIMARY KEY DEFAULT NEXTVAL('projet.id_archetype'),
	nom				VARCHAR(100)		NOT NULL UNIQUE CHECK (nom<>''),
	puissance		INTEGER			NOT NULL CHECK (puissance>0),
	total_combat		INTEGER 			NOT NULL DEFAULT 0,
	total_victoires	INTEGER 			NOT NULL DEFAULT 0
);

DROP TABLE IF EXISTS projet.combats;

CREATE TABLE projet.combats
(
	id_combat		INTEGER		PRIMARY KEY DEFAULT NEXTVAL('projet.id_combat'),
	id_pm			INTEGER		NOT NULL REFERENCES projet.power_mangeurs (id_pm),
	id_archetype		INTEGER		NOT NULL REFERENCES projet.archetypes (id_archetype),
	date_debut		TIMESTAMP	NOT NULL DEFAULT LOCALTIMESTAMP,
	date_fin			TIMESTAMP	CHECK (date_fin>date_debut),
	a_gagne			BOOLEAN		
);

DROP TABLE IF EXISTS projet.power_ups;

CREATE TABLE projet.power_ups
(
	id_pu			INTEGER 			PRIMARY KEY DEFAULT NEXTVAL('projet.id_power_up'),
	nom				VARCHAR(100) 	NOT NULL UNIQUE CHECK (nom<>''),
	id_pm			INTEGER			NOT NULL REFERENCES projet.power_mangeurs (id_pm),
	date_attribution	TIMESTAMP 		NOT NULL DEFAULT LOCALTIMESTAMP,
	pourcentage		INTEGER 			NOT NULL CHECK (pourcentage>0)
);

DROP TABLE IF EXISTS projet.utilisations;

CREATE TABLE projet.utilisations
(
	id_combat			INTEGER 		NOT NULL REFERENCES projet.combats (id_combat),
	id_pu				INTEGER 		NOT NULL REFERENCES projet.power_ups (id_pu),
	date_utilisation		TIMESTAMP	NOT NULL DEFAULT LOCALTIMESTAMP,
	PRIMARY KEY (id_combat, id_pu)
);

DROP TABLE IF EXISTS projet.statistiques;

CREATE TABLE projet.statistiques
(
	id_pm				INTEGER	NOT NULL REFERENCES projet.power_mangeurs (id_pm),
	id_archetype			INTEGER NOT NULL REFERENCES projet.archetypes (id_archetype),
	total_combats		INTEGER	NOT NULL,
	total_victoires		INTEGER	NOT NULL,
	combats_annee		INTEGER	NOT NULL,
	victoires_annee		INTEGER	NOT NULL,
	PRIMARY KEY (id_pm, id_archetype)
);