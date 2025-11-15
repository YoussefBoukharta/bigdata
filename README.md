# 🎓 Big Data Labs - Écosystème Hadoop

[![Java](https://img.shields.io/badge/Java-ED8B00?style=flat&logo=java&logoColor=white)](https://www.java.com)
[![Python](https://img.shields.io/badge/Python-3776AB?style=flat&logo=python&logoColor=white)](https://www.python.org)
[![Hadoop](https://img.shields.io/badge/Hadoop-66CCFF?style=flat&logo=apache-hadoop&logoColor=black)](https://hadoop.apache.org)
[![Kafka](https://img.shields.io/badge/Apache_Kafka-231F20?style=flat&logo=apache-kafka&logoColor=white)](https://kafka.apache.org)
[![HBase](https://img.shields.io/badge/HBase-FF0000?style=flat&logo=apache&logoColor=white)](https://hbase.apache.org)
[![Hive](https://img.shields.io/badge/Hive-FDEE21?style=flat&logo=apache-hive&logoColor=black)](https://hive.apache.org)

Collection complète de travaux pratiques sur l'écosystème Big Data : Hadoop, MapReduce, Kafka, HBase, Pig et Hive.

**Repository GitHub :** [github.com/YoussefBoukharta/bigdata](https://github.com/YoussefBoukharta/bigdata)

---

## 📚 Table des Matières

| Lab | Technologie | Description | Lien |
|-----|-------------|-------------|------|
| **Lab 0** | Docker Compose | Configuration de l'environnement | [📂 lab0/](./lab0) |
| **Lab 1-3** | Hadoop + Kafka | HDFS, MapReduce, Streaming | [📂 lab1,2,3/](./lab1,2,3) |
| **Lab 4** | HBase | Base de données NoSQL | [📂 lab4_hbase/](./lab4_hbase) |
| **Lab 5** | Apache Pig | Traitement de données massives | [📂 lab5_PIG/](./lab5_PIG) |
| **Lab 6** | Apache Hive | Data Warehousing & Analytics | [📂 lab6_Hive/](./lab6_Hive) |

---

## 🚀 Lab 0 : Configuration Docker

**Objectif :** Mise en place de l'environnement de développement Big Data avec Docker.

### Contenu
- `docker-compose.yaml` - Configuration du cluster Hadoop

### Technologies
- Docker & Docker Compose
- Cluster Hadoop (Master + Slaves)

[📖 Voir le Lab 0](./lab0)

---

## 📦 Lab 1-2-3 : Hadoop, HDFS, MapReduce & Kafka

**Objectif :** Maîtriser les fondamentaux de Hadoop et du streaming de données.

### Contenu Principal

#### 🔷 HDFS - Hadoop Distributed File System
- **HadoopFileStatus.jar** - Gestion des métadonnées de fichiers
- **HDFSInfo.jar** - Informations sur les blocs HDFS
- **HDFSWrite.jar** - Écriture dans HDFS
- **ReadHDFS.jar** - Lecture depuis HDFS

#### 🔷 MapReduce
- **WordCount.jar** - Comptage de mots (Java)
- **Python MapReduce** - WordCount avec Hadoop Streaming

#### 🔷 Apache Kafka
- **EventProducer** - Producteur de messages
- **EventConsumer** - Consommateur de messages
- **WordCountApp** - Kafka Streams

### Structure
```
lab1,2,3/
├── BigData/          # Code source Java (HDFS + MapReduce)
├── kafka_lab/        # Applications Kafka
├── python/           # MapReduce Python
├── datasets/         # Données de test
├── *.jar            # JARs précompilés
└── README.md
```

[📖 Voir les Labs 1-2-3](./lab1,2,3)

---

## 🗄️ Lab 4 : Apache HBase

**Objectif :** Manipulation d'une base de données NoSQL orientée colonnes sur Hadoop.

### Contenu
- Code source Java pour opérations CRUD sur HBase
- Dataset : `purchases_2.txt`
- Rapport : `rapport_HBase.docx.pdf`

### Fonctionnalités
- ✅ Connexion au cluster HBase
- ✅ Création de tables et familles de colonnes
- ✅ Opérations CRUD (Create, Read, Update, Delete)
- ✅ Scan et filtrage de données
- ✅ Requêtes avancées

### Technologies
- Apache HBase
- Java HBase Client API
- Hadoop HDFS (stockage)

[📖 Voir le Lab 4](./lab4_hbase)

---

## 🐷 Lab 5 : Apache Pig

**Objectif :** Traitement de données massives avec Pig Latin.

### Scripts Pig
- **wordcount.pig** - Comptage de mots
- **employees.pig** - Analyse d'employés
- **films.pig** - Analyse de films (JSON)
- **flights.pig** - Analyse de vols aériens

### Analyses Réalisées
1. **WordCount** - Comptage de mots dans un texte
2. **Employés** - Salaires, départements, jointures
3. **Films** - Base de données de films (acteurs, réalisateurs)
4. **Vols** - Top aéroports, retards, transporteurs

### Technologies
- Apache Pig (Pig Latin)
- Hadoop MapReduce (backend)
- PiggyBank (JSONLoader)

[📖 Voir le Lab 5](./lab5_PIG)

---

## 🐝 Lab 6 : Apache Hive

**Objectif :** Data Warehousing et requêtes analytiques avec HiveQL.

### Scripts HiveQL
- **Creation.hql** - Création de schémas et tables
- **Loading.hql** - Chargement des données
- **Queries.hql** - Requêtes analytiques

### Cas d'Étude : Réservations d'Hôtels
- Tables : `clients`, `hotels`, `reservations`
- Partitionnement dynamique (par date, par ville)
- Bucketing (clustering par client_id)

### Requêtes Analytiques
- ✅ Jointures complexes
- ✅ Agrégations (SUM, COUNT, AVG)
- ✅ Subqueries (requêtes imbriquées)
- ✅ Optimisations (partitions + buckets)

### Technologies
- Apache Hive 4.0.0-alpha-2
- HiveServer2 + Beeline (client JDBC)
- Derby Metastore

### Documentation
📄 **Rapport complet** : `YOUSSEF_BOUKHARTA_TP6_HIVE.pdf`

[📖 Voir le Lab 6](./lab6_Hive)

---

## 🛠️ Installation & Prérequis

### Docker
```bash
# Installer Docker Desktop
# https://www.docker.com/products/docker-desktop

# Vérifier l'installation
docker --version
docker-compose --version
```

### Java (JDK 8+)
```bash
java -version
```

### Maven (pour compilation)
```bash
mvn --version
```

---

## 🚀 Démarrage Rapide

### 1. Cloner le Repository
```bash
git clone https://github.com/YoussefBoukharta/bigdata.git
cd bigdata
```

### 2. Choisir un Lab
```bash
# Exemple : Lab 5 (Apache Pig)
cd lab5_PIG
cat README.md
```

### 3. Suivre les Instructions
Chaque lab contient son propre README avec :
- ✅ Instructions d'installation
- ✅ Commandes d'exécution
- ✅ Exemples de résultats
- ✅ Scripts prêts à l'emploi

---

## 📊 Technologies & Outils

### Big Data Core
- **Hadoop 3.2.0** - Framework distribué (HDFS + YARN + MapReduce)
- **Apache Kafka 3.5.1** - Streaming de données en temps réel
- **Apache HBase** - Base de données NoSQL orientée colonnes
- **Apache Pig 0.17.0** - Langage de traitement de données (Pig Latin)
- **Apache Hive 4.0.0** - Data Warehousing & SQL sur Hadoop

### Développement
- **Java 8** - Développement d'applications Big Data
- **Python 3** - Hadoop Streaming, scripts de traitement
- **Maven** - Gestion de dépendances et build

### Infrastructure
- **Docker** - Conteneurisation des services
- **Docker Compose** - Orchestration multi-conteneurs

---

## 📂 Structure Complète du Repository

```
bigdata/
├── lab0/                          # Configuration Docker
│   └── docker-compose.yaml
│
├── lab1,2,3/                      # Hadoop + Kafka
│   ├── BigData/                   # Code source HDFS + MapReduce
│   │   ├── src/main/java/
│   │   │   └── edu/ensias/
│   │   │       ├── bigdata/tp1/   # Applications HDFS
│   │   │       └── hadoop/        # MapReduce
│   │   └── pom.xml
│   ├── kafka_lab/                 # Code source Kafka
│   │   ├── src/main/java/
│   │   │   └── edu/ensias/kafka/
│   │   └── pom.xml
│   ├── python/                    # MapReduce Python
│   ├── datasets/                  # Données de test
│   ├── *.jar                      # JARs précompilés
│   └── README.md
│
├── lab4_hbase/                    # Apache HBase
│   ├── hbase-code/                # Code source Java
│   ├── purchases_2.txt            # Dataset
│   └── rapport_HBase.docx.pdf
│
├── lab5_PIG/                      # Apache Pig
│   ├── wordcount.pig
│   ├── employees.pig
│   ├── films.pig
│   ├── flights.pig
│   └── README.md
│
├── lab6_Hive/                     # Apache Hive
│   ├── Creation.hql
│   ├── Loading.hql
│   ├── Queries.hql
│   ├── YOUSSEF_BOUKHARTA_TP6_HIVE.pdf
│   └── README.md
│
└── README.md                      # Ce fichier
```

---

## 🎯 Objectifs Pédagogiques

### Compétences Développées

#### Architecture Big Data
- ✅ Comprendre l'écosystème Hadoop
- ✅ Maîtriser HDFS (stockage distribué)
- ✅ Utiliser MapReduce pour traitement parallèle

#### Traitement de Données
- ✅ Pig Latin pour transformations de données
- ✅ HiveQL pour requêtes analytiques (SQL-like)
- ✅ Kafka pour streaming temps réel

#### Bases de Données NoSQL
- ✅ HBase (orientée colonnes)
- ✅ Opérations CRUD à grande échelle

#### DevOps & Infrastructure
- ✅ Docker & conteneurisation
- ✅ Configuration de clusters distribués
- ✅ Gestion de volumes de données massifs

---

## 🎓 Progression Recommandée

### Pour Débutants
1. **Lab 0** → Configuration de l'environnement
2. **Lab 1-3** → Fondamentaux (HDFS + MapReduce)
3. **Lab 5** → Pig (plus simple que Java MapReduce)
4. **Lab 6** → Hive (SQL familier)

### Pour Utilisateurs Avancés
1. **Lab 1-3** → Kafka Streams
2. **Lab 4** → HBase (API Java)
3. **Lab 5** → Pig (optimisations avancées)
4. **Lab 6** → Hive (partitionnement + bucketing)

---

## 📝 Commandes Utiles

### Docker
```bash
# Démarrer tous les conteneurs
docker-compose up -d

# Arrêter tous les conteneurs
docker-compose down

# Voir les logs
docker-compose logs -f
```

### Hadoop (HDFS)
```bash
# Lister les fichiers
hadoop fs -ls /

# Copier vers HDFS
hadoop fs -put local.txt /input/

# Lire un fichier
hadoop fs -cat /output/part-00000
```

### Exécution des Labs
```bash
# Lab 1-3 : WordCount Java
hadoop jar WordCount.jar input/ output/

# Lab 5 : Script Pig
pig -x local wordcount.pig

# Lab 6 : Script Hive
beeline -u jdbc:hive2://localhost:10000 -f queries.hql
```

---

## 🤝 Contribution

Les contributions sont les bienvenues ! Pour contribuer :

1. Forkez le projet
2. Créez une branche (`git checkout -b feature/nouvelle-feature`)
3. Commitez vos changements (`git commit -m 'Ajout d'une feature'`)
4. Poussez vers la branche (`git push origin feature/nouvelle-feature`)
5. Ouvrez une Pull Request

---

## 📄 Licence

Ce projet est à des fins éducatives. Tous les codes et documentations sont fournis "tels quels" sans garantie.

---

## 👨‍💻 Auteur

**Youssef Boukharta**

- 🌐 GitHub: [@YoussefBoukharta](https://github.com/YoussefBoukharta)
- 📂 Repository: [bigdata](https://github.com/YoussefBoukharta/bigdata)
- 📧 Contact: [Votre email ici]

---

## 📚 Ressources

### Documentation Officielle
- [Apache Hadoop](https://hadoop.apache.org/)
- [Apache Kafka](https://kafka.apache.org/)
- [Apache HBase](https://hbase.apache.org/)
- [Apache Pig](https://pig.apache.org/)
- [Apache Hive](https://hive.apache.org/)

### Tutoriels
- [Hadoop Tutorial](https://hadoop.apache.org/docs/stable/)
- [Kafka Quickstart](https://kafka.apache.org/quickstart)
- [Pig Latin Basics](https://pig.apache.org/docs/latest/basic.html)
- [HiveQL Language Manual](https://cwiki.apache.org/confluence/display/Hive/LanguageManual)

---

<p align="center">
  <strong>⭐ Si ce repository vous a été utile, n'hésitez pas à lui donner une étoile ! ⭐</strong>
</p>

<p align="center">
  Made with ❤️ for Big Data enthusiasts
</p>
