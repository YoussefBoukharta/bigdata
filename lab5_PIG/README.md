# Lab 5: Apache PIG - Traitement de Données Massives

## Description

Ce laboratoire explore Apache Pig, un langage de haut niveau conçu pour le traitement de données massives dans l'écosystème Hadoop. Apache Pig permet d'écrire des scripts pour effectuer des opérations complexes sur des ensembles de données sans avoir à se plonger dans les détails de MapReduce.

## Objectifs

- Installer et configurer Apache Pig sur un cluster Hadoop avec Docker
- Maîtriser le langage Pig Latin pour l'analyse de données
- Réaliser des analyses sur différents types de données (texte, employés, films, vols)

---

## I. Installation Apache PIG

### 1. Accéder au conteneur master

```bash
docker exec -it hadoop-master bash
```

### 2. Télécharger et installer Apache Pig

```bash
# Télécharger Apache Pig
wget https://dlcdn.apache.org/pig/pig-0.17.0/pig-0.17.0.tar.gz

# Extraire l'archive
tar -zxvf pig-0.17.0.tar.gz

# Déplacer vers /usr/local/pig
mv pig-0.17.0 /usr/local/pig

# Supprimer l'archive
rm pig-0.17.0.tar.gz
```

### 3. Configurer les variables d'environnement

```bash
vim ~/.bashrc
```

Ajouter les lignes suivantes :

```bash
export PIG_HOME=/usr/local/pig
export PATH=$PATH:$PIG_HOME/bin
```

Appliquer les modifications :

```bash
source ~/.bashrc
```

### 4. Configurer Hadoop pour Pig

**Configuration HDFS** (`$HADOOP_CONF_DIR/hdfs-site.xml`) :

```xml
<property>
    <name>dfs.webhdfs.enabled</name>
    <value>true</value>
</property>
<property>
    <name>dfs.bytes-per-checksum</name>
    <value>512</value>
</property>
```

**Configuration YARN** (`$HADOOP_CONF_DIR/yarn-site.xml`) :

```xml
<property>
    <name>yarn.timeline-service.enabled</name>
    <value>true</value>
</property>
<property>
    <name>yarn.timeline-service.hostname</name>
    <value>localhost</value>
</property>
```

### 5. Démarrer les services

```bash
./start-hadoop
yarn timelineserver
mapred --daemon start historyserver
```

**Note :**
- **Timeline Server** : permet de suivre les jobs MapReduce issus de la traduction du script Pig Latin
- **History Server** : permet d'accéder aux données historiques après qu'un travail Pig soit terminé

---

## II. Premier Exemple - WordCount

### Lancer Pig en mode local

```bash
pig -x local
```

### Script Pig Latin interactif

```pig
-- Charger le fichier texte
lines = LOAD '/shared_volume/alice.txt';

-- Parser et nettoyer les données
words = FOREACH lines GENERATE FLATTEN(TOKENIZE((chararray)$0)) AS word;
clean_w = FILTER words BY word MATCHES '\\w+';

-- Grouper les mots
D = GROUP clean_w BY word;

-- Compter les occurrences
E = FOREACH D GENERATE group, COUNT(clean_w);

-- Sauvegarder le résultat
STORE E INTO '/shared_volume/pig_out/WORD_COUNT/';
```

### Script complet : `wordcount.pig`

Le fichier `wordcount.pig` contient une version optimisée avec :
- Chargement avec délimiteur de ligne
- Nettoyage des mots alphanumériques
- Comptage et sauvegarde au format CSV

**Exécution :**

```bash
pig -x local wordcount.pig
```

---

## III. Analyse des Employés d'une Entreprise

### Description des données

- **employees.txt** : ID, Nom, Prénom, Sexe, Salaire, DepNo, Ville, Pays (séparés par des virgules)
- **department.txt** : DepNo, Nom du département (séparés par des virgules)

### Préparation des données

```bash
# Créer le répertoire input dans HDFS
hdfs dfs -mkdir input

# Copier les fichiers sur HDFS
hdfs dfs -put employees.txt input/
hdfs dfs -put department.txt input/
```

### Questions traitées dans `employees.pig`

Le script `employees.pig` répond aux questions suivantes :

1. **Salaire moyen par département**
2. **Nombre d'employés par département**
3. **Liste des employés avec leurs départements** (jointure)
4. **Employés avec salaire > 60 000**
5. **Département avec le salaire le plus élevé**
6. **Départements sans employés**
7. **Nombre total d'employés**
8. **Employés à Paris**
9. **Salaire total par ville**
10. **Départements ayant des femmes employées** ✅ (résultat sauvegardé)

### Exécution

```bash
pig employees.pig
```

### Vérification des résultats

```bash
hdfs dfs -ls /user/root/pigout/employes_femmes/
hdfs dfs -cat /user/root/pigout/employes_femmes/part-r-00000
```

---

## IV. Analyse des Films

### Description des données

Deux fichiers JSON :

**films.json** - Structure :
```json
{
  "_id": "movie:1",
  "title": "Vertigo",
  "year": 1958,
  "genre": "drama",
  "summary": "...",
  "country": "USA",
  "director": { "_id": "artist:3" },
  "actors": [
    { "_id": "artist:15", "role": "John Ferguson" },
    { "_id": "artist:16", "role": "Madeleine Elster" }
  ]
}
```

**artists.json** - Structure :
```json
{
  "_id": "artist:15",
  "last_name": "Stewart",
  "first_name": "James",
  "birth_date": "1908"
}
```

### Préparation des données

```bash
# Charger les fichiers sur HDFS
hdfs dfs -put films.json /input/
hdfs dfs -put artists.json /input/
```

### Analyses réalisées dans `films.pig`

Le script `films.pig` effectue les opérations suivantes :

1. **Chargement des données JSON** avec JSONLoader (PiggyBank)
2. **Films américains groupés par année** (`mUSA_annee`)
3. **Films américains groupés par réalisateur** (`mUSA_director`)
4. **Triplets (idFilm, idActeur, role)** (`mUSA_acteurs`)
5. **Association film → description complète de l'acteur** (`moviesActors`)
6. **Description complète film + acteurs** (`fullMovies`) avec COGROUP
7. **ActeursRealisateurs** : pour chaque artiste, liste des films joués et dirigés ✅ (sauvegardé)

### Configuration préalable

```bash
# Enregistrer PiggyBank pour JSONLoader
REGISTER /path/to/piggybank.jar;
```

### Exécution

```bash
pig films.pig
```

### Vérification des résultats

```bash
hdfs dfs -ls /pigout/ActeursRealisateurs/
hdfs dfs -cat /pigout/ActeursRealisateurs/part-r-00000
```

---

## V. Analyse des Vols


### Analyses réalisées dans `flights.pig`

Le script `flights.pig` répond aux questions suivantes :

#### 1. Top 20 des aéroports par volume total de vols
- Calcul des vols entrants et sortants par aéroport
- Calcul du trafic total (in + out)
- Classement des 20 premiers

#### 2. Trafic par année, mois et jour
- Groupement et comptage par différentes granularités temporelles

#### 3. Popularité des transporteurs
- Volume logarithmique (base 10) des vols par transporteur et par année

#### 4. Proportion de vols retardés
- Un vol est considéré retardé si le retard > 15 minutes
- Calcul de la proportion par :
  - Année
  - Mois
  - Jour

#### 5. Retards par transporteur
- Proportion de vols retardés par transporteur (retard > 15 min)
- Analyse par année, mois et jour

#### 6. Itinéraires les plus fréquentés
- Paires non ordonnées d'aéroports (origine, destination)
- Comptage des fréquences
- Classement par popularité

### Préparation des données

```bash
# Copier le dataset des vols sur HDFS
hdfs dfs -put flights /input/
```

### Exécution

```bash
pig flights.pig
```

---

## Structure des Fichiers du Projet

```
lab5_PIG/
├── README.md                    # Ce fichier
├── wordcount.pig                # Exemple simple de comptage de mots
├── employees.pig                # Analyse des employés d'une entreprise
├── films.pig                    # Analyse de base de données de films
├── flights.pig                  # Analyse des vols aériens
└── yarn-site-config.xml         # Configuration YARN pour Pig
```

---

## Commandes Utiles

### Modes d'exécution de Pig

```bash
# Mode local (pour tests)
pig -x local script.pig

# Mode MapReduce (sur cluster Hadoop)
pig -x mapreduce script.pig

# Mode interactif (Grunt shell)
pig -x local
```

### Vérification des résultats sur HDFS

```bash
# Lister les fichiers de sortie
hdfs dfs -ls /output/path/

# Afficher le contenu
hdfs dfs -cat /output/path/part-*

# Télécharger les résultats localement
hdfs dfs -get /output/path/ ./local_output/
```

### Gestion du cluster

```bash
# Arrêter les conteneurs
docker stop hadoop-master hadoop-slave1 hadoop-slave2

# Redémarrer les conteneurs
docker start hadoop-master hadoop-slave1 hadoop-slave2

# Sortir du conteneur
exit
```

