BEGIN;
	set search_path to public;

	drop table if exists public.work_sujets;
	drop table if exists public.work_sujets_thesis;
	drop table if exists public.work_liaison_sujets;
	drop table if exists public.work_thesis;

	drop table if exists public.tmp_table_auteurices;
	drop table if exists public.tmp_table_reference;
	drop table if exists public.tmp_liaison_sujets;
COMMIT;
