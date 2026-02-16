BEGIN;

SET search_path TO public;


-- DÉDUPLICATION DES TABLES WIKIDATA ET DECLARATION PK

-- Archaeological sites
DELETE FROM wikidata_archaeological_sites a
WHERE a.ctid NOT IN (
    SELECT MIN(ctid)
    FROM wikidata_archaeological_sites
    WHERE qid IS NOT NULL
    GROUP BY qid
);

-- Supprimer les lignes avec qid NULL si nécessaire
DELETE FROM wikidata_archaeological_sites WHERE qid IS NULL;

-- Ajouter la primary key
ALTER TABLE wikidata_archaeological_sites ADD PRIMARY KEY (qid);


-- Persons
DELETE FROM wikidata_persons a
WHERE a.ctid NOT IN (
    SELECT MIN(ctid)
    FROM wikidata_persons
    WHERE qid IS NOT NULL
    GROUP BY qid
);

DELETE FROM wikidata_persons WHERE qid IS NULL;

ALTER TABLE wikidata_persons ADD PRIMARY KEY (qid);


-- Places
DELETE FROM wikidata_places a
WHERE a.ctid NOT IN (
    SELECT MIN(ctid)
    FROM wikidata_places
    WHERE qid IS NOT NULL
    GROUP BY qid
);

DELETE FROM wikidata_places WHERE qid IS NULL;

ALTER TABLE wikidata_places ADD PRIMARY KEY (qid);


-- Organizations
DELETE FROM wikidata_organizations a
WHERE a.ctid NOT IN (
    SELECT MIN(ctid)
    FROM wikidata_organizations
    WHERE qid IS NOT NULL
    GROUP BY qid
);

DELETE FROM wikidata_organizations WHERE qid IS NULL;

ALTER TABLE wikidata_organizations ADD PRIMARY KEY (qid);


-- Concepts (avec colonne "0" comme identifiant)
DELETE FROM wikidata_concepts a
WHERE a.ctid NOT IN (
    SELECT MIN(ctid)
    FROM wikidata_concepts
    WHERE "0" IS NOT NULL
    GROUP BY "0"
);

DELETE FROM wikidata_concepts WHERE "0" IS NULL;

ALTER TABLE wikidata_concepts ADD PRIMARY KEY ("0");


-- Art movements (avec colonne "0" comme identifiant)
DELETE FROM wikidata_art_movements a
WHERE a.ctid NOT IN (
    SELECT MIN(ctid)
    FROM wikidata_art_movements
    WHERE "0" IS NOT NULL
    GROUP BY "0"
);

DELETE FROM wikidata_art_movements WHERE "0" IS NULL;

ALTER TABLE wikidata_art_movements ADD PRIMARY KEY ("0");


-- Time periods (avec colonne "0" comme identifiant)
DELETE FROM wikidata_time_periods a
WHERE a.ctid NOT IN (
    SELECT MIN(ctid)
    FROM wikidata_time_periods
    WHERE "0" IS NOT NULL
    GROUP BY "0"
);

DELETE FROM wikidata_time_periods WHERE "0" IS NULL;

ALTER TABLE wikidata_time_periods ADD PRIMARY KEY ("0");



-- AJOUT DES COLONNES À def_liaison_sujets

-- 1 colonne pour les non-matchés + 7 colonnes pour les matchs par table Wikidata
ALTER TABLE public.def_liaison_sujets 
ADD COLUMN IF NOT EXISTS qid_non_matche VARCHAR,
ADD COLUMN IF NOT EXISTS qid_archaeological_sites VARCHAR,
ADD COLUMN IF NOT EXISTS qid_persons VARCHAR,
ADD COLUMN IF NOT EXISTS qid_places VARCHAR,
ADD COLUMN IF NOT EXISTS qid_concepts VARCHAR,
ADD COLUMN IF NOT EXISTS qid_organizations VARCHAR,
ADD COLUMN IF NOT EXISTS qid_art_movements VARCHAR,
ADD COLUMN IF NOT EXISTS qid_time_periods VARCHAR;


-- REMPLISSAGE DE LA COLONNE NON-MATCHÉS

-- Marquer les lignes qui n'ont aucun match dans aucune table Wikidata
UPDATE public.def_liaison_sujets
SET qid_non_matche = rameau
WHERE qid IS NULL;


-- REMPLISSAGE DES COLONNES MATCHÉES

-- Archaeological sites
UPDATE public.def_liaison_sujets dls
SET qid_archaeological_sites = was.qid
FROM wikidata_archaeological_sites was
WHERE LOWER(TRIM(was."labelFr")) = LOWER(TRIM(dls.rameau))
  AND dls.qid IS NOT NULL;

-- Persons
UPDATE public.def_liaison_sujets dls
SET qid_persons = wp.qid
FROM wikidata_persons wp
WHERE LOWER(TRIM(wp."labelFr")) = LOWER(TRIM(dls.rameau))
  AND dls.qid IS NOT NULL;

-- Places
UPDATE public.def_liaison_sujets dls
SET qid_places = wpl.qid
FROM wikidata_places wpl
WHERE LOWER(TRIM(wpl."labelFr")) = LOWER(TRIM(dls.rameau))
  AND dls.qid IS NOT NULL;

-- Concepts (avec colonnes "0" et "1" selon votre script)
UPDATE public.def_liaison_sujets dls
SET qid_concepts = wc."0"
FROM wikidata_concepts wc
WHERE LOWER(TRIM(wc."1")) = LOWER(TRIM(dls.rameau))
  AND dls.qid IS NOT NULL;

-- Organizations
UPDATE public.def_liaison_sujets dls
SET qid_organizations = wo.qid
FROM wikidata_organizations wo
WHERE LOWER(TRIM(wo."labelFr")) = LOWER(TRIM(dls.rameau))
  AND dls.qid IS NOT NULL;

-- Art movements (avec colonnes "0" et "1" selon votre script)
UPDATE public.def_liaison_sujets dls
SET qid_art_movements = wam."0"
FROM wikidata_art_movements wam
WHERE LOWER(TRIM(wam."1")) = LOWER(TRIM(dls.rameau))
  AND dls.qid IS NOT NULL;

-- Time periods (avec colonnes "0" et "1" selon votre script)
UPDATE public.def_liaison_sujets dls
SET qid_time_periods = wtp."0"
FROM wikidata_time_periods wtp
WHERE LOWER(TRIM(wtp."1")) = LOWER(TRIM(dls.rameau))
  AND dls.qid IS NOT NULL;


-- PARTIE 5 : AJOUT DES FOREIGN KEYS 

ALTER TABLE public.def_liaison_sujets
ADD CONSTRAINT fk_archaeological_sites 
    FOREIGN KEY (qid_archaeological_sites) 
    REFERENCES wikidata_archaeological_sites(qid);

ALTER TABLE public.def_liaison_sujets
ADD CONSTRAINT fk_persons 
    FOREIGN KEY (qid_persons) 
    REFERENCES wikidata_persons(qid);

ALTER TABLE public.def_liaison_sujets
ADD CONSTRAINT fk_places 
    FOREIGN KEY (qid_places) 
    REFERENCES wikidata_places(qid);

ALTER TABLE public.def_liaison_sujets
ADD CONSTRAINT fk_concepts 
    FOREIGN KEY (qid_concepts) 
    REFERENCES wikidata_concepts("0");

ALTER TABLE public.def_liaison_sujets
ADD CONSTRAINT fk_organizations 
    FOREIGN KEY (qid_organizations) 
    REFERENCES wikidata_organizations(qid);

ALTER TABLE public.def_liaison_sujets
ADD CONSTRAINT fk_art_movements 
    FOREIGN KEY (qid_art_movements) 
    REFERENCES wikidata_art_movements("0");

ALTER TABLE public.def_liaison_sujets
ADD CONSTRAINT fk_time_periods 
    FOREIGN KEY (qid_time_periods) 
    REFERENCES wikidata_time_periods("0");

-- Petits rajouts que l'on avait oublié

alter table def_publication
add column date_publication text;


update public.def_publication dp 
set date_publication = public.resultats_nettoyes_avec_dates.date
from public.resultats_nettoyes_avec_dates
where dp.id = resultats_nettoyes_avec_dates.id;

UPDATE public.def_publication dp  
SET date_publication = MAKE_DATE(date_publication::integer, 1, 1);

alter table def_publication
add column titre text;


update public.def_publication dp 
set titre = public.table_auteurices.titre
from public.table_auteurices
where dp.id = table_auteurices.id;

alter table def_publication 
drop column universite;

COMMIT;