-- CREATION DES LIAISONS

-- Création, remplissage de la colonne institution, déclaration de la foreign key

ALTER TABLE public.def_publication 
ADD COLUMN IF NOT EXISTS id_institution INTEGER;

UPDATE public.def_publication p
SET id_institution = i.id
FROM public.def_table_institution i
WHERE p.universite = i.nom;

ALTER TABLE public.def_publication 
ADD CONSTRAINT fk_publication_institution 
FOREIGN KEY (id_institution) REFERENCES def_table_institution(id);


ALTER TABLE public.def_publication 
DROP COLUMN universite;

-- Création remplissage de la colonne id_auteur, déclaration de la foreign key

ALTER TABLE public.def_publication 
ADD COLUMN IF NOT EXISTS id_auteur INTEGER;

UPDATE public.def_publication p
SET id_auteur = a.id
FROM public.def_auteur a
WHERE p.auteur_nom = a.auteur_nom 
  AND p.auteur_prenom = a.auteur_prenom;

ALTER TABLE public.def_publication 
ADD CONSTRAINT fk_publication_auteur 
FOREIGN KEY (id_auteur) REFERENCES def_auteur(id);


ALTER TABLE public.def_publication 
DROP COLUMN auteur_nom,
DROP COLUMN auteur_prenom;

-- Déclaration de la foreign key pour les sujets

ALTER TABLE public.def_liaison_sujets 
ADD CONSTRAINT fk_liaison_publication 
FOREIGN KEY (id_publication) REFERENCES def_publication(id);*/

/*
Nous faisons face à de gros soucis pour relier les tables wikidata 
à notre table de liaison car une foreign key ne peut pas être liée à plusieurs tables
*/
