--Vues utilisées : 
-- Quels sont les pays les plus traités dans les sujets en dehors de la France ? 

CREATE VIEW vw_pays_traites AS
(
SELECT wp.country,
COUNT(*) AS pays_les_plus_traites
FROM wikidata_places wp
JOIN def_liaison_sujets dls
ON wp.qid = dls.qid_places
WHERE wp.country IS NOT NULL
AND wp.country != 'France'
GROUP BY wp.country
ORDER BY pays_les_plus_traites DESC
);

--Pour requêter la vue : 
--SELECT * FROM vw_pays_traites ; 

-- Les mouvements les plus traités en fonction des universités ? 

CREATE VIEW vw_mouvements_traites_universites AS
(
SELECT dti.nom, wam."1",
COUNT(*) AS mouvements_traites_universites
FROM def_table_institution dti
JOIN def_publication dp
ON dti.id = dp.id_institution
JOIN def_liaison_sujets dls
ON dp.id = dls.id_publication
JOIN wikidata_art_movements wam
ON dls.qid_art_movements = wam."0"
GROUP BY dti.nom, wam."1"
ORDER BY dti.nom, wam."1" DESC
);

-- Pour requêter la vue : 
-- SELECT * FROM vw_mouvements_traites_universites;

--Les personnes les plus traitées 

create view vw_personnalites_traitees as 
(
SELECT wp."labelFr",
COUNT(*) AS personnalites_traitees,
ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS pourcentage
FROM wikidata_persons wp 
JOIN def_liaison_sujets dls 
ON wp.qid = dls.qid_persons
GROUP BY wp."labelFr"
ORDER BY personnalites_traitees desc 
) ;

-- Pour requêter la vue : 
-- SELECT * FROM vvw_personnalites_traitees;

