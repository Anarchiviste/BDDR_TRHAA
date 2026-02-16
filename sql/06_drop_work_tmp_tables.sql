BEGIN;
	set search_path to public;

	drop table if exists public.work_sujets;
	drop table if exists public.work_sujets_thesis;
	drop table if exists public.work_liaison_sujets;
	drop table if exists public.work_liaison_sujet;
	drop table if exists public.work_thesis;

	drop table if exists public.tmp_table_auteurices;
	drop table if exists public.tmp_table_reference;
	drop table if exists public.tmp_liaison_sujets;
	
	DROP TABLE IF EXISTS public.resultats_nettoyes_avec_dates;
	DROP TABLE IF EXISTS public.sujet_produit_cartésiens;
	DROP TABLE IF EXISTS public.sujet_thesis;
	DROP TABLE IF EXISTS public.sujet_typologie_temporaire;
	DROP TABLE IF EXISTS public.table_auteurices;
	DROP TABLE IF EXISTS public.table_reference;
	DROP TABLE IF EXISTS public.def_connexion_auteur_publication;
COMMIT;
