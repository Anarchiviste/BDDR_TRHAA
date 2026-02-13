SET search_path TO public;

-- Destruction préventive des tables à créer de manière préventive.

DROP table if exists public.work_sujet;
drop table if exists public.work_sujet_thesis;
drop table if exists public.work_liaison_sujets;
drop table if exists public.tmp_liaison_sujets;
drop table if exists public.tmp_table_auteurices;
drop table if exists public.tmp_table_reference;
drop table if exists public.def_table_institution;

create table public.work_liaison_sujets
(
	id varchar primary key,
	reconciliation_sujet varchar
);

create table public.tmp_liaison_sujets(
	id varchar primary key,
	qid varchar unique not null
);

-- création de la table de travail sujet
CREATE TABLE public.work_sujet
(
    id VARCHAR PRIMARY KEY,
    sujet VARCHAR
);

-- puis création de la table de travail sujet_thesis
create table work_sujet_thesis
(
	id varchar primary key,
	sujet_thesis varchar
);

-- puis création de la table tmp_table_auteurices
CREATE TABLE public.tmp_table_auteurices
(
    id VARCHAR PRIMARY KEY,
    nom VARCHAR,
    prenom varchar,
    titre VARCHAR,
    all_date date
);

-- puis création de la table tmp_table_reference
CREATE TABLE public.tmp_table_reference
(
    id VARCHAR PRIMARY KEY,
    typologie VARCHAR,
    statut BOOL,
    editeur TEXT,
    linkAgorha VARCHAR,
    linkPublication VARCHAR,
    langue VARCHAR,
    pages INT,
    editionInstitution TEXT,
    universite TEXT
);

-- puis création de la table définitive des institutions
create table public.def_table_institution
(
id serial primary key,
nom text not null
);


