BEGIN;

SET search_path TO public;

-- ========================================= --
-- Destruction préventive des tables à créer -- 
-- ========================================= --
--tables de travail-- 
DROP table if exists public.work_sujets;
drop table if exists public.work_sujets_thesis;
drop table if exists public.work_liaison_sujet;
drop table if exists public.work_thesis;
-- tables temporaires-- 
drop table if exists public.tmp_table_auteurices;
drop table if exists public.tmp_table_reference;
drop table if exists public.tmp_liaison_sujets;
-- tables définitives--
drop table if exists public.def_table_institution;
drop table if exists public.def_liaison_sujets;
drop table if exists public.def_auteur;
drop table if exists public.def_publication;

-- ============================== --
-- création des tables de travail --
-- ============================== --
create table public.work_liaison_sujet
(
	id serial primary key,
	reference_id varchar, -- fk publication
	reconciliation_sujet varchar
);

CREATE TABLE public.work_sujets
(
    id serial PRIMARY key,
    reference_id varchar, -- fk publication
    sujet VARCHAR
);

create table work_thesis (
	id serial primary key,
    reference_id VARCHAR, -- fk publication
    sujet_thesis VARCHAR
);

create table public.work_sujets_thesis
(
	id varchar primary key,
	sujet_thesis varchar
);

-- =============================== --
-- création des tables temporaires --
-- =============================== -- 

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

create table public.def_liaison_sujets(
	id serial primary key,
	qid varchar, -- fk wikidata
	labelFr varchar, -- Label issu de wikidata
	rameau varchar, -- Label rameau
	id_publication varchar -- fk publication
);

create table public.def_auteur(
	id serial primary key,
	auteur_nom varchar,
	auteur_prenom varchar
	
);

create table public.def_publication(
	id varchar primary key,
	auteur_nom varchar,
	auteur_prenom varchar,
	typologie varchar,
	statut varchar,
	linkagorha varchar,
	linkpublication varchar,
	langue varchar,
	universite varchar
);

COMMIT;
