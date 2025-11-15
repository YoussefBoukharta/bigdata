# Lab 6 — Apache Hive & Data Warehousing

📄 **Documentation complète disponible dans le fichier "YOUSSEF_BOUKHARTA_TP6_HIVE.pdf"**

## 🎯 Objectifs du TP

Ce laboratoire vise à :
- ✅ **Installation d'Apache Hive** : Déploiement via Docker avec HiveServer2
- ✅ **Première utilisation d'Apache Hive** : Manipulation de Beeline et interface JDBC
- ✅ **Réaliser des requêtes analytiques** : Jointures, agrégations, partitionnement et bucketing

### À propos d'Apache Hive

Apache Hive est un **software datawarehouse** conçu pour lire, écrire et gérer de grands ensembles de données extraits du système de fichiers distribué d'Apache Hadoop (HDFS).

**Caractéristiques principales :**
- 📊 Ne s'agit pas d'une base de données complète
- 🗄️ Stocke uniquement les **métadonnées** (les données sont dans HDFS)
- 🔄 Chaque requête est convertie en code **MapReduce**
- 📈 Utilisable comme système **OLAP** (Online Analytical Processing)
- 🔌 Fourni avec **HiveServer2** et son client JDBC **Beeline**

## 🐳 Installation Apache Hive

### 1️⃣ Pull de l'image Docker

```bash
docker pull apache/hive:4.0.0-alpha-2
```

**Source :** [Docker Hub - Apache Hive](https://hub.docker.com/r/apache/hive/tags)

### 2️⃣ Lancement du conteneur HiveServer2

```bash
docker run -v C:\Users\ahmed\hadoop_project:/shared_volume -d -p 10000:10000 -p 10002:10002 -p 9083:9083 --env SERVICE_NAME=hiveserver2 --name hiveserver2-standalone apache/hive:4.0.0-alpha-2
```

**Configuration :**
- **Port 10000** : HiveServer2 (connexion JDBC)
- **Port 10002** : Interface Web HiveServer2
- **Port 9083** : Metastore Service
- **Metastore** : Derby embedded (configuration rapide)

### 3️⃣ Accès à l'interface Web

Ouvrez votre navigateur à l'adresse : **http://localhost:10002**

### 4️⃣ Première utilisation de Beeline

#### Accéder au shell du conteneur
```bash
docker exec -it hiveserver2-standalone bash
```

#### Vérifier HDFS
```bash
hadoop fs -ls
```

#### Visualiser la configuration Hive
```bash
cat /opt/hive/conf/hive-site.xml
```

#### Connexion à Beeline
```bash
beeline -u jdbc:hive2://localhost:10000 -n scott -p tiger
```

**Credentials par défaut :**
- **Username** : `scott`
- **Password** : `tiger`

#### Afficher les bases de données
```sql
SHOW DATABASES;
```

## 🔧 Prérequis Techniques

### Configuration de l'Environnement

**Répertoire de données (hôte) :** `C:\Users\ahmed\hadoop_project\hive_data`

**Fichiers requis :**
- `clients.txt`
- `hotels.txt`
- `reservations.txt`

**Conteneur Hive :** Instance `hiveserver2-standalone` avec montage du volume hôte sur `/shared_volume`

### Vérifications Préalables

✅ Assurez-vous que tous les fichiers de données sont présents dans le répertoire hôte  
✅ Vérifiez le montage correct du volume dans le conteneur  
✅ Confirmez la disponibilité de HiveServer2 sur le port 10000  
✅ HDFS doit être opérationnel dans le conteneur

## 📁 Structure du Projet

```
lab6_Hive/
├── Creation.hql       # Schémas et définitions de tables
├── Loading.hql        # Scripts de chargement des données
├── Queries.hql        # Requêtes analytiques
├── clients.txt        # Données clients
├── hotels.txt         # Données hôtels
├── reservations.txt   # Données réservations
└── README.md          # Ce fichier
```

## 📊 Cas d'Étude : Analyse de Réservations d'Hôtels

Ce TP travaille sur un ensemble de données concernant les **réservations d'hôtels**. L'objectif est de manipuler, analyser et extraire des informations pertinentes sur les clients, les hôtels et leurs réservations.

**Données disponibles dans trois fichiers :**
1. **clients.txt** : Informations des clients (ID, nom, email, téléphone)
2. **hotels.txt** : Informations des hôtels (ID, nom, étoiles, ville)
3. **reservations.txt** : Réservations (ID, client_id, hotel_id, dates, prix)

## 🚀 Exécution des Scripts HiveQL

### ⚠️ Séquence d'Exécution (Ordre Obligatoire)

Les scripts doivent être exécutés **dans l'ordre** suivant pour reproduire le traitement complet :

### 1️⃣ Création des Schémas et Tables (`Creation.hql`)

```bash
docker exec -it hiveserver2-standalone bash -c "beeline -u 'jdbc:hive2://localhost:10000' -n scott -p tiger -f /shared_volume/lab6_hive/Creation.hql"
```

**Fonctionnalités :**
- ✨ Création de la base de données `hotel_booking`
- 📋 Définition des tables externes et managées
- 🔄 Configuration du partitionnement dynamique
- ⚡ Mise en place du bucketing pour optimisation
- ⚙️ Activation des propriétés Hive pour partitions et buckets

**Tables créées :**
- `clients` - Table des clients (TEXTFILE)
- `hotels` - Table des hôtels (TEXTFILE)
- `raw_reservations` - Table de staging pour réservations
- `reservations` - Table partitionnée par `date_debut`
- `hotels_partitioned` - Table partitionnée par `ville`
- `reservations_bucketed` - Table bucketed par `client_id` (4 buckets)

**Vérification :**
```bash
hadoop fs -ls /opt/hive/data/warehouse
```
Vous remarquerez la création du répertoire `hotel_booking.db`.

---

### 2️⃣ Chargement des Données (`Loading.hql`)

```bash
docker exec -it hiveserver2-standalone bash -c "beeline -u 'jdbc:hive2://localhost:10000' -n scott -p tiger -f /shared_volume/lab6_hive/Loading.hql"
```

**⚠️ IMPORTANT :** Avant d'exécuter cette étape, copiez tous les fichiers `.txt` dans `C:\Users\ahmed\hadoop_project\hive_data`.

**Actions effectuées :**
- 📥 Chargement avec `LOAD DATA LOCAL INPATH` depuis `/shared_volume/hive_data/`
- 🗂️ Population des tables partitionnées (insertion dynamique)
- 🔢 Chargement dans les buckets avec `DISTRIBUTE BY client_id`
- ✅ Vérifications de l'intégrité des données (`SHOW PARTITIONS`, `COUNT(*)`)

**Vérification :**
```bash
hadoop fs -ls /opt/hive/data/warehouse/hotel_booking.db/
```
Vous remarquerez les sous-répertoires pour les partitions (ex: `date_debut=2024-01-15/`) et les buckets.

---

### 3️⃣ Requêtes Analytiques (`Queries.hql`)

```bash
docker exec -it hiveserver2-standalone bash -c "beeline -u 'jdbc:hive2://localhost:10000' -n scott -p tiger -f /shared_volume/lab6_hive/Queries.hql"
```

**Analyses réalisées :**

#### 5️⃣ Requêtes Simples
- Lister tous les clients
- Lister tous les hôtels à Paris
- Lister toutes les réservations avec informations complètes (clients + hôtels)

#### 6️⃣ Requêtes avec Jointures
- 📊 **Nombre de réservations par client** 
- 🛏️ **Clients ayant réservé plus de 2 nuitées** 
- 🏨 **Hôtels réservés par chaque client** 
- 📈 **Hôtels avec plus d'une réservation** 
- ❌ **Hôtels sans réservation** 

#### 7️⃣ Requêtes Imbriquées (Subqueries)
- 👑 **Clients ayant réservé un hôtel > 4 étoiles** 
- 💰 **Total des revenus générés par chaque hôtel** 

#### 8️⃣ Agrégations avec Partitions/Buckets
- 🌆 **Revenus totaux par ville** (utilise tables partitionnées)
- 📉 **Nombre de réservations par client** (utilise tables bucketed)

#### 9️⃣ Nettoyage et Suppression
- Commandes DROP pour supprimer les tables et la base de données (commentées par défaut)

## 📊 Résultats & Validation

Le document PDF **"YOUSSEF_BOUKHARTA_TP6_HIVE.pdf"** présente les résultats en captures d'écran et contient :

✅ Captures d'écran des résultats de chaque requête  
⏱️ Métriques de performance (temps d'exécution)  
🔍 Analyse des plans d'exécution (EXPLAIN)  
⚡ Validation des optimisations appliquées (partitionnement, bucketing)  
📁 Exploration de la structure HDFS (`/opt/hive/data/warehouse/hotel_booking.db/`)

## 💡 Notes Techniques

### Optimisations Implémentées

#### 🗂️ Partitionnement
- Découpage logique des tables par colonnes clés
- Amélioration des performances pour les requêtes filtrées
- Réduction du volume de données scannées

**Exemple :**
```sql
PARTITIONED BY (date_debut STRING)
PARTITIONED BY (ville STRING)
```

#### 🔢 Bucketing (Clustering)
- Distribution uniforme des données dans des fichiers
- Optimisation des jointures (map-side joins)
- Amélioration du sampling et de l'échantillonnage

**Exemple :**
```sql
CLUSTERED BY (client_id) INTO 4 BUCKETS
```

### Bonnes Pratiques

#### 📝 Préparation des Données
⚠️ **CRITIQUE : Supprimer les en-têtes CSV avant le chargement**  
```bash
# Exemple de preprocessing (si nécessaire)
tail -n +2 clients.txt > clients_clean.txt
```
Alternative : Utiliser `TBLPROPERTIES ("skip.header.line.count"="1")`
- Vérifier l'encodage des fichiers (UTF-8 recommandé)
- Valider les délimiteurs de champs (virgule par défaut)
- S'assurer que les fichiers sont accessibles dans `/shared_volume/hive_data/`

#### 🗄️ Gestion des Métadonnées
- Les **tables externes** préservent les données sources après suppression
- Les **tables managées** (internes) suppriment les données avec `DROP TABLE`
- Utiliser `MSCK REPAIR TABLE` pour synchroniser les partitions

#### ⚡ Performance
```sql
-- Activer la vectorisation
SET hive.vectorized.execution.enabled = true;

-- Optimiser les jointures
SET hive.auto.convert.join = true;

-- Configuration pour partitions dynamiques
SET hive.exec.dynamic.partition = true;
SET hive.exec.dynamic.partition.mode = nonstrict;

-- Configuration pour bucketing
SET hive.enforce.bucketing = true;
```

**Recommandations :**
- Utiliser le format **ORC** ou **Parquet** pour les grandes volumétries
- Privilégier les partitions pour les colonnes à faible cardinalité
- Optimiser le nombre de buckets en fonction du volume de données

### 🔧 Commandes Utiles

#### Se connecter à Beeline manuellement
```bash
docker exec -it hiveserver2-standalone bash
beeline -u jdbc:hive2://localhost:10000 -n scott -p tiger
```

#### Vérifier les partitions
```sql
SHOW PARTITIONS reservations;
SHOW PARTITIONS hotels_partitioned;
```

#### Compter les enregistrements
```sql
SELECT COUNT(*) AS cnt_clients FROM clients;
SELECT COUNT(*) AS cnt_hotels FROM hotels;
SELECT COUNT(*) AS cnt_reservations FROM reservations;
```

#### Explorer la structure HDFS
```bash
# Dans le conteneur
hadoop fs -ls /opt/hive/data/warehouse
hadoop fs -ls /opt/hive/data/warehouse/hotel_booking.db/
hadoop fs -ls /opt/hive/data/warehouse/hotel_booking.db/reservations/
```

#### Analyser le plan d'exécution
```sql
EXPLAIN SELECT * FROM reservations WHERE date_debut = '2024-01-15';
EXPLAIN SELECT h.ville, SUM(r.prix_total) FROM reservations r 
        JOIN hotels h ON r.hotel_id = h.hotel_id 
        GROUP BY h.ville;
```

## 🧹 Nettoyage (Optionnel)

Pour supprimer toutes les tables et la base de données :

```sql
DROP TABLE IF EXISTS reservations_bucketed;
DROP TABLE IF EXISTS reservations;
DROP TABLE IF EXISTS raw_reservations;
DROP TABLE IF EXISTS hotels_partitioned;
DROP TABLE IF EXISTS hotels;
DROP TABLE IF EXISTS clients;
DROP DATABASE IF EXISTS hotel_booking CASCADE;
```

## 📝 Organisation du Code

Le traitement est organisé en **trois scripts HiveQL distincts** :

| Script | Description | Responsabilité |
|--------|-------------|----------------|
| **Creation.hql** | Création de schémas | Base de données, tables, partitions, buckets |
| **Loading.hql** | Chargement de données | LOAD DATA, INSERT INTO, vérifications |
| **Queries.hql** | Requêtes analytiques | Jointures, agrégations, requêtes imbriquées |

**Ordre d'exécution obligatoire :** `Creation.hql` → `Loading.hql` → `Queries.hql`

## 🎓 Compétences Développées

- ✅ Installation et configuration d'Apache Hive avec Docker
- ✅ Manipulation de Beeline (client JDBC)
- ✅ Création de tables avec partitionnement et bucketing
- ✅ Chargement de données en masse (LOAD DATA)
- ✅ Requêtes SQL complexes (jointures, agrégations, subqueries)
- ✅ Optimisation des performances (partitions, buckets)
- ✅ Analyse de données avec un système OLAP
- ✅ Compréhension de l'architecture Hive/HDFS/MapReduce

## 📚 Ressources Complémentaires

- [Documentation Apache Hive](https://hive.apache.org/)
- [LanguageManual HiveQL](https://cwiki.apache.org/confluence/display/Hive/LanguageManual)
- [Hive Performance Tuning](https://cwiki.apache.org/confluence/display/Hive/LanguageManual+Optimization)
- [Docker Hub - Apache Hive](https://hub.docker.com/r/apache/hive)

---

**Auteur :** Youssef Boukharta  