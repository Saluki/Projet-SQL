
-- RESET DE TOUTES LES TABLES
-- Pour utilisation lors des tests de presentation

TRUNCATE projet.utilisations, projet.statistiques, projet.power_ups, 
projet.combats, projet.archetypes, projet.power_mangeurs CASCADE;

SELECT * FROM projet.inscrire_pm('Rouge', '984facf29f1f1701b7f474f64e3ba3f0e14375947b0f22392272a44892cf64802a921728b5445920c0244675992da3ff0e3ab950c1d63d3c4a1d89ed9deee635', 'FFFFFF');
SELECT * FROM projet.inscrire_pm('Bleu', '984facf29f1f1701b7f474f64e3ba3f0e14375947b0f22392272a44892cf64802a921728b5445920c0244675992da3ff0e3ab950c1d63d3c4a1d89ed9deee635', '000000');