BEGIN;

SET search_path TO public;

truncate def_auteur;
alter sequence public.def_auteur_id_seq RESTART WITH 1; 

-- Ici nous remplissons simplement nos tables définitives, nous aurions pu passer une partie de ces étapes car certaines de nos tables temporaires auraient pu être définitives mais nous avons préféré faire comme cela pour ne pas avoir a tout modifier et prendre des risques
insert into def_auteur (auteur_nom, auteur_prenom)
select distinct a.nom, a.prenom from tmp_table_auteurices a;

truncate def_publication;

-- Les étapes suivantes n'ont finalement pas été gardées à la fin car nous avons fait des foreign keys avec des ids
insert into def_publication (id, auteur_nom, auteur_prenom)
select distinct(id), nom, prenom from tmp_table_auteurices tta;

drop table if exists def_connexion_auteur_publication;

create table public.def_connexion_auteur_publication
(
	id serial primary key,
	id_auteur varchar,
	id_publication varchar
);

insert into def_connexion_auteur_publication(id_auteur, id_publication)
select da.id, dp.id from def_auteur da join def_publication dp on concat(da.auteur_nom, da.auteur_prenom) = concat(dp.auteur_nom, dp.auteur_prenom);

-- Nous avons préféré remplir la table def avec les données de la table tmp même si nous aurions pu simplement garder la table tmp
UPDATE def_publication dp
SET typologie = ttr.typologie,
    statut = ttr.statut,
    linkagorha = ttr.linkagorha,
    linkpublication = ttr.linkpublication,
    langue = ttr.langue,
    universite = ttr.universite
FROM tmp_table_reference ttr
WHERE dp.id = ttr.id;

COMMIT;
