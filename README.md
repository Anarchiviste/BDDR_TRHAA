# BDDR_TRHAA

Vous trouverez au sein de ce respository notre base de données construite dans le cadre de l'évaluation de l'UE3 - Traitement de la donnée. Elle est issue d'un jeu de données transmises par l'INHA. 

## Installation

Certains de nos CSV sont trop lourds pour être acceptés sur Github, il vous sera donc nécessaire de les télécharger en suivant ce [lien](https://drive.proton.me/urls/GMHV6RR6X4#4xwlN38D7vdz) et de les placer dans un dossier `csv` afin de faire fonctionner notre BDDR. 

Afin de garantir son bon fonctionnement, il est également nécessaire de lancer le script nommé `bdd_schema.sql` avant de lancer l'intégralité de nos scripts. 

Dans une volonté de fournir un READ ME complet, nous vous répétons les étapes indiquées dans le [github](https://github.com/Chamishe/TNAH_FILM_DB) duquel sont issus ces scripts. Vous pouvez éviter ces explications et consulter notre modèle logique [ici](#journal-de-bord). 

**Tout se passe (configuration, commandes dans le terminal) au sein de ce dossier dans lequel vous lisez ce fichier**

**Le projet doit s’exécuter avec `python run.py` sans aucune modification du code fourni, seuls le fichier .env doit être modifié.**

### Préparation de l'environnement de travail pour le script

#### 1. Créer un environnement virtuel

A créer dans ce dossier, à côté du `README.md` et du `run.py`

Pour rappel: `virtualenv env -p python3` ou `python -m venv env`

#### 2. Activer cet environnement

`source env/bin/activate` (ou `source env/Scripts/activate` pour Windows)

#### 3. Importer les bonnes dépendances dans l'environnement

`pip install -r requirements.txt`

---

### Étapes à suivre pour remplir la base

#### 1. Modifier le fichier `.env`
Le fichier doit contenir toutes les variables suivantes :
Le fichier est déjà pré remplie avec les informations de base mais vous devez y ajouter les informations d'utilisateur et de mot de passe de votre base de données PostgreSQL.

```env
pgDatabase=str
pgUser=str
pgPassword=str
pgPort=int
pgHost=str
pgSchemaImportsCsv=str
failOnFirstSqlError=bool
failOnFirstCsvError=bool
```

- `pgDatabase` : nom de la base à créer/utiliser  pour importer les données et jouer les scripts. Cette base est unique pour l'ensemble du projet.
- `pgUser` : utilisateur PostgreSQL avec lequel se connecter
- `pgPassword` : mot de passe PostgreSQL correspondant à l'utilisateur
- `pgHost` : adresse du serveur PostgreSQL
- `pgPort` : port du serveur PostgreSQL  
- `pgSchemaImportsCsv` : schéma où seront importés les CSV  sous forme de table (1 CSV = 1 table du nom du ficheir CSV)
- `failOnFirstSqlError` : si `True`, le script s’arrête dès qu’une requête SQL échoue  
- `failOnFirstCsvError` : si `True`, le script s’arrête dès qu’un import CSV dans la base de données échoue  

#### 2. Créer la base de données et le schéma
Dans DBeaver, exécuter deux requêtes qui permettront de créer une base de données et un schéma dédié. Les informations que vous transmettez à SQL doivent correspondre aux éléments `pgDatabase` et `pgSchemaImportsCsv` du fichier .env.

Créer une nouvelle base de données 
```sql
CREATE DATABASE {database_name} ;
```

Créer un nouveau schéma
```sql
CREATE SCHEMA {schema_name} ;
```

#### 3. Lancer le script principal
```bash
python run.py
```
ou selon la configuration :
```bash
python3 run.py
```

## Journal de bord

Comme convenu dans les modalités d'évaluation fournies en début d'année, notre journal de bord sera complété en envoyé le 23 février 2025. 

Nous vous fournissons cela dit les différentes évolutions de notre modèle logique ici même. Les différentes étapes de notre réflexion seront précisées dans notre journal de bord. 

