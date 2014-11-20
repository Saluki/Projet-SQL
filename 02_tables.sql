DROP TABLE IF EXISTS projet.power_mangeurs CASCADE;

CREATE TABLE projet.power_mangeurs
(
	id_pm 				INTEGER 			PRIMARY KEY DEFAULT NEXTVAL('projet.id_power_mangeur'),
	nom 					VARCHAR(100) 	NOT NULL UNIQUE CHECK (nom<>''),
	couleur 				CHAR(6) 			NOT NULL UNIQUE,
	mot_de_passe 		VARCHAR(150) 	NOT NULL CHECK (mot_de_passe<>''),
	vie 					INTEGER 			NOT NULL DEFAULT 10 CHECK (vie>=0),
	date_inscription 	TIMESTAMP 		NOT NULL DEFAULT LOCALTIMESTAMP,
	date_deces 			TIMESTAMP		,
	CHECK (date_inscription<date_deces)
);

DROP TABLE IF EXISTS projet.archetypes CASCADE;

CREATE TABLE projet.archetypes
(
	id_archetype		INTEGER 			PRIMARY KEY DEFAULT NEXTVAL('projet.id_archetype'),
	nom				VARCHAR(100)		NOT NULL UNIQUE CHECK (nom<>''),
	puissance		INTEGER			NOT NULL CHECK (puissance>=0),
	CHECK (nb_victoires<=nb_combats)
);

DROP TABLE IF EXISTS projet.combats CASCADE;

CREATE TABLE projet.combats
(
	id_combat		INTEGER		PRIMARY KEY DEFAULT NEXTVAL('projet.id_combat'),
	id_pm			INTEGER		NOT NULL REFERENCES projet.power_mangeurs (id_pm),
	id_archetype		INTEGER		NOT NULL REFERENCES projet.archetypes (id_archetype),
	date_debut		TIMESTAMP	NOT NULL DEFAULT LOCALTIMESTAMP,
	date_fin			TIMESTAMP	,
	est_gagne		BOOLEAN		,
	CHECK (date_debut<date_fin)
);

DROP TABLE IF EXISTS projet.power_ups CASCADE;

CREATE TABLE projet.power_ups
(
	id_pu			INTEGER 			PRIMARY KEY DEFAULT NEXTVAL('projet.id_power_up'),
	nom				VARCHAR(100) 	NOT NULL CHECK (nom<>''),
	id_pm			INTEGER			NOT NULL REFERENCES projet.power_mangeurs (id_pm),
	date_attribution	TIMESTAMP 		NOT NULL DEFAULT LOCALTIMESTAMP,
	facteur			INTEGER 			NOT NULL CHECK (facteur>0),
	UNIQUE (nom, id_pm)
);

DROP TABLE IF EXISTS projet.utilisations CASCADE;

CREATE TABLE projet.utilisations
(
	id_combat			INTEGER 		NOT NULL REFERENCES projet.combats (id_combat),
	id_pu				INTEGER 		NOT NULL REFERENCES projet.power_ups (id_pu),
	date_utilisation		TIMESTAMP	NOT NULL DEFAULT LOCALTIMESTAMP,
	PRIMARY KEY (id_combat, id_pu)
);

DROP TABLE IF EXISTS projet.statistiques CASCADE;

CREATE TABLE projet.statistiques
(
	id_pm				INTEGER	NOT NULL REFERENCES projet.power_mangeurs (id_pm),
	id_archetype			INTEGER NOT NULL REFERENCES projet.archetypes (id_archetype),
	nb_combats_total		INTEGER	NOT NULL DEFAULT 0 CHECK (nb_combats_total>=0),
	nb_victoires_total	INTEGER	NOT NULL DEFAULT 0 CHECK (nb_victoires_total>=0),
	nb_combats_annee		INTEGER	NOT NULL DEFAULT 0 CHECK (nb_combats_annee>=0),
	nb_victoires_annee	INTEGER	NOT NULL DEFAULT 0 CHECK (nb_victoires_annee>=0),
	PRIMARY KEY (id_pm, id_archetype),
	CHECK (nb_victoires_total<=nb_combats_total),
	CHECK (nb_victoires_annee<=nb_combats_annee)
);