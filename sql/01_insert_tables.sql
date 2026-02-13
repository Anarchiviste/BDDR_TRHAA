SET search_path TO public;

-- ============================================= --
-- suppression préventive des données des tables --
-- ============================================= --
truncate table public.tmp_table_auteurices;

-- =============================================================== --
-- Insertion dans les tables temporaires et nettoyage des donnéees --
-- =============================================================== -- 
INSERT INTO tmp_table_auteurices (id, nom, prenom, titre, all_date)
WITH sans_virgule as --A l'issue de cette CTE j'ai une nouvelle colonne nommée "authorName_virgule_corrigee" où chaque nom est séparé d'une virgule de son prenom. J'en ai besoin parce que je sépare mes chaines de caractères grâce à cette virgule plus tard dans ma requête--
(
    SELECT
        ta.id,
        ta.nom,
        ta.titre,
        ta.date_debut,
        ta.date_fin,
        rnad."date" AS rnad_date,
        CASE
            WHEN ta.nom ~ '^[^ ]+ [^ ]+$' AND ta.nom NOT LIKE '%,%' --Quand "authorName" est une chaine de caractère composé d'une première chaine ne contenant pas d'espace, puis un espace, puis une nouvelle chaine sans espace--
            THEN REPLACE(ta.nom, ' ', ', ') --L'espace est remplacé par une virgule avec un espace--
            ELSE ta.nom
        END AS nom_virgule_corrigee
    FROM public.table_auteurices AS ta
    LEFT JOIN public.resultats_nettoyes_avec_dates rnad ON ta.id = rnad.id
)
SELECT
    sv.id,
    case --A l'issue de cette condition, je dispose d'une colonne "Nom" contenant tous les noms--
        WHEN sv.nom LIKE '% de %' AND sv.nom NOT LIKE '%, %' --Quand "authorName" contient "de" entouré de deux espace et qu'il ne contient pas de virgule suivie d'un espace--
        THEN TRIM(INITCAP('de ' || SPLIT_PART(sv.nom, ' de ', 2))) --AuthorName, après que les espaces avant et après les chaines de caractère ait été supprimé, est divisée avec le délimiteur espace, on garde la seconde partie de cette chaine séparée en deux--
        WHEN sv.nom_virgule_corrigee LIKE '%,%' --Quand authorName contient une virgule | NB : Utilisation de la CTE crée précédemment--
        THEN TRIM(INITCAP(SPLIT_PART(sv.nom_virgule_corrigee, ',', 1))) --Même action que le THEN précédent mais en utilisant la virgule comme délimitateur | NB : Cette fois nous gardons la 1ère partie car le nom se situe dans la première partie quand la particule "de" n'est pas utilisée--
        ELSE null --Retourne une cellule "null" si aucune des conditions n'est remplie--
    END AS nom, --Les résultats ressortent dans la colonne "nom"--
    case --A l'issue de cette condition, je dispose d'une colonne "prenom" contenant tous les prenoms--
        WHEN sv.nom LIKE '% de %' AND sv.nom NOT LIKE '%, %'
        THEN TRIM(INITCAP(SPLIT_PART(sv.nom, ' ', 1)))
        WHEN sv.nom_virgule_corrigee LIKE '%,%'
        THEN TRIM(INITCAP(SPLIT_PART(sv.nom_virgule_corrigee, ',', 2)))
        ELSE NULL
    END AS prenom,
    sv.titre,
    COALESCE( -- nous incorporons les dates récupérées du champs startDate, endDate, mais également les champs récupérés dans le hml du site grâce à un scripte et des regex. 
        make_date(sv.date_debut::integer, 1, 1),
        make_date(sv.date_fin::integer, 1, 1),
        make_date(sv.rnad_date::integer, 1, 1)
    ) AS all_date
FROM sans_virgule AS sv;

--supprime préventivement les données des tables pour réécrire de 0
truncate table public.tmp_table_reference;
--insertion dans la table référence
insert into tmp_table_reference
(
id,
typologie,
statut,
linkagorha,
linkpublication,
langue,
pages,
editioninstitution,
universite
)
select
a.id,
a.typologie,
CASE WHEN a.statut IN ('Publiée') THEN TRUE ELSE FALSE END AS statut,-- nous avons une colonne avec un texte "publiée" que nous modifions pour un booléen
a.lien_agorha,
(regexp_match(a.publication_online, '\[''(.*?)''\]'))[1] AS linkpublication, -- match le texte de publication_online et extrait les liens qui sont entre crochets et guillemets.
(regexp_match(a.langue, '\[''(.*?)''\]'))[1] AS langue, -- match le texte de langue et extrait le texte entre crochet et guillemets
(regexp_match(a.pages, '\d{3}'))[1]::integer AS pages, -- match 3 chiffres à la suite dans langue pour extraire les volumétries de pages.
(regexp_match(a.institution_edition , '\[''(.*?)''\]'))[1] AS editioninstitution, -- match le texte de publication_online et extrait les liens qui sont entre crochets et guillemets.
(regexp_matches(a.université, '''nom'':\s*\[''([^'']*?)''', 'g'))[1] AS universite -- match le pattern clé valeur de nom dans la colonne université et rend
from public.table_reference as a;

--supprime préventivement les données des tables pour réécrire de 0
truncate table public.def_table_institution;
ALTER SEQUENCE public.def_table_institution_id_seq RESTART WITH 1; -- Problème identifié ou le serial ne repart de 1 avec le truncate table, nous le remettons à 1 pour cette table.
-- remplissage de la table def_table_institution
insert into public.def_table_institution
(
nom
)
select distinct(ttr.universite)
from public.tmp_table_reference ttr;
