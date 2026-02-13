# BDDR_TRHAA

Le dossier csv doit être télécharger et installer depuis ce [lien](https://drive.proton.me/urls/GMHV6RR6X4#4xwlN38D7vdz) car trop lourd pour github. Un .gitignore a été créé et le dossier csv ne sera pas compris dans les commit et les push.

## Acquisition des données 

- Acquisition des données en format JSON et CSV envoyé part l'INHA. 
    - Ouverture du fichier references.csv de l'INHA : constat de l'impossibilité de l'utiliser. Le fichier est corrompu. Les cellules se décalent d'attribut au fur et à mesure et n'ont aucun sens. Cela provient du fait que le CSV utilise le symbole de paragraphe pour séparer les colonnes mais aussi pour séparer les éléments. De ce fait, les informations se décalent au fur et à mesure.
- Le problème ne vient pas d'un format ou d'une utilisation d'un caractère particulier pour séparer les valeurs.
- Le Json est plus propre et en apparence complet. Nous avons donc décidé de parser le json à l'aide du logiciel jq et de python. 

## Prise en main de la base de données

Le fichier json est un énorme objet json composé de pleins de sous objets, mais les ojets ne sont pas toujours cohérents entre eux. Certains possèdent des métadonnées liés aux sujets avec des thésaurus, d'autres possèdent des informations moins complêtes avec des informations stockées autre part. Un exemple parlant est la question de la récupération des dates, qui devraient être encodé dans un élément startDate ou endDate, 

### Parsing du Json avec JQ et création de json intermédiaires

Utilisation de requêtes `jq` pour créer des CSV. 
Utilisation de requêtes `jq` pour créer des plus petits Json convertis par la suite avec `pandas`. 
**Problèmes :** 
- Relation one-to-many au sein de du CSV 
- Difficulté à appréhender pandas. 

Utilisation d'une Regex pour extraire les dates de deux champs : `biblioref` et `display labelling`.
- `biblioref` comporte : Titre complet - nom de la personne - titre - personnes encadrante - date 
- `display labelling` comporte : version plus petite du titre, destinée à s'afficher. 

Voici un exemple de requête jq pour créer un json intermédiaire.

```jq
jq -r "{ "notices": [ .notices[] | {
 "id": .id,
 "sujet": .content.subjectInformation.subject[]?.rameau.thesaurus[]?.prefLabels[]?.value,
 "sujet_rameau": .content.subjectInformation.subject[]?.rameau.thesaurus[]?.ref,
 "sujet_thesis": .content.identificationInformation.thesis[]? | .domain.thesaurus[]? | .prefLabels[] | .value,
 "sujet_thesis_rameau": .content.identificationInformation.thesis[]? | .domain.thesaurus[]? | .ref
 } ] }" csv_trhaa > notices.json
```

Cette requête produit des produits cartésiens et nous donne un objet json intermédiaire que nous transformons en csv avec un scripte python avec pandas. 

```python
import pandas as pd
import json

with open('/content/theme_typologie_cartésien.json', 'r', encoding='utf-8') as f:
  json_objet = json.load(f)

notice_sujet_list = []
for i in json_objet["notices"]:
  notice_sujet_list.append(i)

resultats_df = pd.DataFrame(notice_sujet_list)
resultats_df.to_csv('sujet_typologie.csv', index=False)
```


Certains de nos json ont demander un véritable travail pour retrouver certaines données perdues. Par exemple la question des dates de publications des mémoires était très difficile à sortir des json. Il existe deux champs startDate et endDate qui ne sont souvent que peu utiliser. Par contre un champs nommé refLabel contenait une balise html avec le nom de l'auteur, le titre du mémoire et la date de publication. En matchant avec une regex la balise titre et la supprimant de la balise refLabel, nous avons été capable de récupérer un grand nombre de champs dates. 

Voici le scripte d'extraction des dates : 

```python
import pandas as pd
import re

df = pd.read_csv('/content/sample_data/comparator.csv', on_bad_lines ='warn')

n=0
resultats = []


for index, row in df.iterrows():
  """
  boucle récupère les colonnes label, ref et id
  transforme label et ref en str pour éviter les bug de type
  créer une regex qui match label
  si label est matché dans ref alors la string de label est supprimé de ref
  créer une deuxième regex qui match 4 chiffres à la suite
  si dans label une date est repérée, alors la date est extrait dans une variable et est stocké dans résultat avec l'id de son objet
  sinon le terme Null est écrit avec l'id de son objet
  """
  label = row['displayLabelLink']
  ref = row['biblioRef']
  id = row['id']
  n= n+1

  label = str(label)
  ref = str(ref)

  pattern_label = re.compile(re.escape(label))

  if pattern_label.search(ref):
    ref_clean = ref.replace(label,'')

    pattern_date = re.compile(r'\b\d{4}\b')
    match = pattern_date.search(ref_clean)

    if match:
        date = match.group()
        print(f"{n} {id} Date trouvée: {date}")
        resultats.append({
            'id': id,
            'date': date,
        })
  else:
    print(f"{n} {id} Date trouvée: Null")
    resultats.append({
      'id': id,
      'date': "Null",
    })
```


### Enrichissement des données

- Utilisation de OpenRefine : 
    - Nous lui avons donné un CSV avec les sujets. 
    - Vérification à la main et réconciliation avec wikidata 
    
# Traitement de la base de données après la réunion

## Nettoyage - Jules / Mélina

### Nettoyage table "auteurice"
Tentative de changer la type de données des colonnes "startDate" et "endDate" mais étant donné qu'il n'y a qu'une année et jamais de mois ou d'année, il n'est pas possible d'avoir une année seule considérée comme une donnée "date". Nous pourrions convertir ces intager en date en leur assignant un jour et un mois par défaut, par défaut le 1er janvier. Cela pose plusieurs problèmes :
- Il existe des dates plus précises pour ces informations, elles ne sont juste pas renseignée dans la base de données. Assignée un jour et un mois reviendrais à inventer des informations là où nous n'en avons pas besoin. 
- En effet, il n'est pas utile pour les traitements que nous avons prévu d'appliquer à notre base de données de transformer ces données en date. 

*AJOUTER* : Travail sur les dates par Jules

La colonne "authorName" contenait le nom puis le prénom, séparés par une virgule. Ces deux notions ont été déplacés vers la colonne nom et prenom à l'aide de la requête suivante. Dans un premier temps elle ajoute des virgules quand elle manquent puis elle divise la chaine de caractère grâce au dilimitateur "," ou "de" selon les circonstances. 

```SQL
with sans_virgule as --A l'issue de cette CTE j'ai une nouvelle colonne nommée "authorName_virgule_corrigee" où chaque nom est séparé d'une virgule de son prenom. J'en ai besoin parce que je sépare mes chaines de caractères grâce à cette virgule plus tard dans ma requête--
	(
	    select "id", "title", "startDate", "endDate", "authorName",
        case
            when "authorName" ~ '^[^ ]+ [^ ]+$' and "authorName" not like '%,%' --Quand "authorName" est une chaine de caractère composé d'une première chaine ne contenant pas d'espace, puis un espace, puis une nouvelle chaine sans espace--
            then replace("authorName", ' ', ', ') --L'espace est remplacé par une virgule avec un espace--
            else "authorName" --Reste "AuthorName"--
        end as authorName_virgule_corrigee
	    from table_auteurices
	)
select
	"id", "title",
    case --A l'issue de cette condition, je dispose d'une colonne "Nom" contenant tous les noms--
        when "authorName" like '% de %' and "authorName" not like '%, %' --Quand "authorName" contient "de" entouré de deux espace et qu'il ne contient pas de virgule suivie d'un espace--
        then  TRIM('de ' || split_part("authorName", ' de ', 2))--AuthorName, après que les espaces avant et après les chaines de caractère ait été supprimé, est divisée avec le délimiteur espace, on garde la seconde partie de cette chaine séparée en deux--
        when authorName_virgule_corrigee like '%,%' --Quand authorName contient une virgule | NB : Utilisation de la CTE crée précédemment--
        then TRIM(split_part(authorName_virgule_corrigee, ',', 1)) --Même action que le THEN précédent mais en utilisant la virgule comme délimitateur | NB : Cette fois nous gardons la 1ère partie car le nom se situe dans la première partie quand la particule "de" n'est pas utilisée--
        else null --Retourne une cellule "null" si aucune des conditions n'est remplie--
    end as nom, --Les résultats ressortent dans la colonne "nom"--
    case --A l'issue de cette condition, je dispose d'une colonne "prenom" contenant tous les prenoms--
        WHEN "authorName" LIKE '% de %' AND "authorName" NOT LIKE '%, %'
        THEN TRIM(split_part("authorName", ' ', 1))
        WHEN authorName_virgule_corrigee LIKE '%,%'
        THEN TRIM(split_part(authorName_virgule_corrigee, ',', 2))
        ELSE NULL
    END AS prenom,
    "startDate", "endDate"
FROM sans_virgule;
```

