SET search_path TO public;

-- ========================================= --
-- Destruction préventive des tables à créer -- 
-- ========================================= --
--tables de travail-- 
DROP table if exists public.work_sujets;
drop table if exists public.work_sujets_thesis;
drop table if exists public.work_liaison_sujets;
-- tables temporaires-- 
drop table if exists public.tmp_liaison_sujets;
drop table if exists public.tmp_table_auteurices;
drop table if exists public.tmp_table_reference;
-- tables définitives--
drop table if exists public.def_table_institution;

-- ============================== --
-- création des tables de travail --
-- ============================== --
create table public.work_liaison_sujets
(
	id varchar primary key,
	reconciliation_sujet varchar
);

CREATE TABLE public.work_sujets
(
    id VARCHAR PRIMARY KEY,
    sujet VARCHAR
);

create table work_sujets_thesis
(
	id varchar primary key,
	sujet_thesis varchar
);

-- =============================== --
-- création des tables temporaires --
-- =============================== -- 
create table public.tmp_liaison_sujets(
	id varchar primary key,
	qid varchar unique not null
);

CREATE TABLE public.tmp_table_auteurices
(
    id VARCHAR PRIMARY KEY,
    nom VARCHAR,
    prenom varchar,
    titre VARCHAR,
    all_date date
);

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

-- =============================== -- 
-- création des tables définitives -- 
-- =============================== --
create table public.def_table_institution
(
id serial primary key,
nom text not null
);

