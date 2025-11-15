# Big Data - Hadoop & Kafka

[![Java](https://img.shields.io/badge/Java-85.9%25-orange)](https://github.com/YoussefBoukharta/bigdata)
[![Python](https://img.shields.io/badge/Python-14.1%25-blue)](https://github.com/YoussefBoukharta/bigdata)

Projet de traitement Big Data avec Hadoop MapReduce et Apache Kafka.

**Repository GitHub :** [github.com/YoussefBoukharta/bigdata](https://github.com/YoussefBoukharta/bigdata)

## 🚀 Installation Rapide

### 1. Télécharger l'image Docker
```bash
docker pull yassern1/hadoop-spark-jupyter:1.0.3
```

### 2. Créer le réseau
```bash
docker network create --driver=bridge hadoop
```

### 3. Lancer les conteneurs

**Master :**
```bash
docker run -itd -v C:\Users\pc\Documents\hadoop_project/:/shared_volume --net=hadoop -p 9870:9870 -p 8088:8088 -p 7077:7077 -p 19888:19888 --name hadoop-master --hostname hadoop-master yassern1/hadoop-spark-jupyter:1.0.3
```

**Slave 1 :**
```bash
docker run -itd -p 8040:8042 --net=hadoop --name hadoop-slave1 --hostname hadoop-slave1 yassern1/hadoop-spark-jupyter:1.0.3
```

**Slave 2 :**
```bash
docker run -itd -p 8041:8042 --net=hadoop --name hadoop-slave2 --hostname hadoop-slave2 yassern1/hadoop-spark-jupyter:1.0.3
```

### 4. Initialiser HDFS
```bash
docker exec -it hadoop-master bash
./start-hadoop.sh
hadoop fs -mkdir -p /user/root
hdfs dfs -mkdir input
```

### 5. Charger des données
```bash
hdfs dfs -put /shared_volume/datasets/fichier.txt input/
```


---

## 📂 Applications HDFS

**JARs précompilés disponibles dans le repository :**
- `HadoopFileStatus.jar` - Gestion des métadonnées de fichiers
- `HDFSWrite.jar` - Écriture dans HDFS
- `ReadHDFS.jar` - Lecture depuis HDFS
- `WordCount.jar` - MapReduce WordCount

### 1. Afficher les infos d'un fichier
```bash
hadoop jar /shared_volume/HadoopFileStatus.jar edu.ensias.bigdata.tp1.HadoopFileStatus /user/root/input purchases.txt nouveau_nom.txt
```

### 2. Voir les blocs HDFS
```bash
hadoop jar /shared_volume/HDFSInfo.jar edu.ensias.bigdata.tp1.HDFSInfo /user/root/input/fichier.txt
```

### 3. Lire un fichier
```bash
hadoop jar /shared_volume/ReadHDFS.jar edu.ensias.bigdata.tp1.ReadHDFS /user/root/input/purchases.txt
```

### 4. Écrire dans HDFS
```bash
hadoop jar /shared_volume/HDFSWrite.jar edu.ensias.bigdata.tp1.HDFSWrite /user/root/output/message.txt "Votre texte"
```

---

## 🔄 MapReduce - WordCount Java

### Compiler le projet
```bash
cd BigData
mvn clean package
```

### Exécuter WordCount
```bash
hadoop jar /shared_volume/WordCount.jar input/fichier.txt output/resultat
```

### Voir les résultats
```bash
hadoop fs -cat output/resultat/part-r-00000
```

**Note :** Supprimer le dossier de sortie s'il existe déjà :
```bash
hadoop fs -rm -r output/resultat
```

---

## 🐍 MapReduce - WordCount Python

### Tester localement
```bash
cd /shared_volume/python
cat alice.txt | python3 mapper.py
cat alice.txt | python3 mapper.py | sort | python3 reducer.py
```

### Exécuter sur Hadoop
```bash
chmod +x mapper.py reducer.py
hadoop fs -put alice.txt input/

hadoop jar /usr/local/hadoop/share/hadoop/tools/lib/hadoop-streaming-3.2.0.jar \
    -files /shared_volume/python/mapper.py,/shared_volume/python/reducer.py \
    -mapper "python3 mapper.py" \
    -reducer "python3 reducer.py" \
    -input input/alice.txt \
    -output output_python

hadoop fs -cat output_python/part-00000 | head -20
```

---

## 📨 Apache Kafka

### Démarrage
```bash
docker exec -it hadoop-master bash
./start-hadoop.sh
./start-kafka-zookeeper.sh
jps  # Vérifier que Kafka est démarré
```

### Créer un topic
```bash
kafka-topics.sh --create --bootstrap-server localhost:9092 --replication-factor 1 --partitions 1 --topic mon-topic
```

### Lister les topics
```bash
kafka-topics.sh --list --bootstrap-server localhost:9092
```

---

## 🔧 Kafka Producer/Consumer

### Compiler
```bash
cd kafka_lab
mvn clean package -DskipTests
cp target/*.jar /shared_volume/kafka/
```

### Lancer le Consumer
```bash
java -jar /shared_volume/kafka/consumer.jar mon-topic
```

### Lancer le Producer (autre terminal)
```bash
java -jar /shared_volume/kafka/producer.jar mon-topic
```

### Tester avec CLI
**Producer :**
```bash
kafka-console-producer.sh --bootstrap-server localhost:9092 --topic mon-topic
```

**Consumer :**
```bash
kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic mon-topic --from-beginning
```

---

## 🔗 Kafka Connect

### Configuration
```bash
cd $KAFKA_HOME
echo "plugin.path=/usr/local/kafka/libs/" >> config/connect-standalone.properties
```

### Créer le topic
```bash
kafka-topics.sh --create --bootstrap-server localhost:9092 --topic connect-test --partitions 1 --replication-factor 1
```

### Créer le fichier source
```bash
echo "Bonjour Kafka" > test.txt
echo "Bienvenue dans le streaming" >> test.txt
```

### Démarrer Connect
```bash
./bin/connect-standalone.sh \
    config/connect-standalone.properties \
    config/connect-file-source.properties \
    config/connect-file-sink.properties
```

### Vérifier
```bash
cat test.sink.txt
```

### Tester en temps réel
```bash
echo "Nouveau message" >> test.txt
cat test.sink.txt  # Doit afficher le nouveau message
```

---

## 📊 Kafka Streams - WordCount

### Créer les topics
```bash
kafka-topics.sh --create --bootstrap-server localhost:9092 --topic input-topic --partitions 1 --replication-factor 1
kafka-topics.sh --create --bootstrap-server localhost:9092 --topic output-topic --partitions 1 --replication-factor 1
```

### Lancer l'application
```bash
java -jar /shared_volume/kafka/wordcount-app.jar input-topic output-topic
```

### Envoyer des données (autre terminal)
```bash
kafka-console-producer.sh --broker-list localhost:9092 --topic input-topic
```
Taper :
```
Bonjour le monde
Kafka est formidable
Bonjour à tous
```

### Voir les résultats (autre terminal)
```bash
kafka-console-consumer.sh --topic output-topic --from-beginning --bootstrap-server localhost:9092 --property print.key=true
```

**Sortie attendue :**
```
bonjour	Mot: , Nombre: 2
le	Mot: , Nombre: 1
monde	Mot: , Nombre: 1
kafka	Mot: , Nombre: 1
...
```

---

## 🛠️ Commandes Utiles

### Cleanup Script (PowerShell)
Le repository inclut un script `cleanup_script.ps1` pour nettoyer l'environnement :
```powershell
.\cleanup_script.ps1
```

### HDFS
```bash
hadoop fs -ls /                    # Lister les fichiers
hadoop fs -rm -r /chemin          # Supprimer un dossier
hadoop fs -cat /fichier           # Afficher un fichier
hadoop fs -put local.txt hdfs/    # Copier vers HDFS
hadoop fs -get hdfs/file local/   # Récupérer depuis HDFS
```

### Kafka
```bash
jps                               # Processus Java actifs
kafka-topics.sh --list --bootstrap-server localhost:9092
kafka-topics.sh --describe --topic mon-topic --bootstrap-server localhost:9092
kafka-topics.sh --delete --topic mon-topic --bootstrap-server localhost:9092
```

### Docker
```bash
docker start hadoop-master hadoop-slave1 hadoop-slave2
docker stop hadoop-master hadoop-slave1 hadoop-slave2
docker exec -it hadoop-master bash
```

---

## 📌 Structure du Projet

```
bigdata/                      # Repository GitHub
├── BigData/                  # Code source Hadoop
│   ├── src/main/java/
│   │   └── edu/ensias/
│   │       ├── bigdata/tp1/  # Applications HDFS
│   │       │   ├── HadoopFileStatus.java
│   │       │   ├── HDFSInfo.java
│   │       │   ├── HDFSWrite.java
│   │       │   └── ReadHDFS.java
│   │       └── hadoop/mapreducelab/  # MapReduce
│   │           ├── TokenizerMapper.java
│   │           ├── IntSumReducer.java
│   │           └── WordCount.java
│   └── pom.xml
├── python/                   # MapReduce Python
│   ├── mapper.py
│   ├── reducer.py
│   └── alice.txt
├── datasets/                 # Données de test
│   ├── purchases.txt
│   ├── calls.txt
│   ├── alice.txt
│   └── coran_converted.txt
├── HadoopFileStatus.jar     # JARs précompilés
├── HDFSWrite.jar
├── ReadHDFS.jar
├── WordCount.jar
├── cleanup_script.ps1       # Script de nettoyage
├── README.md
└── info.txt
```

---

## 🎯 Technologies

- **Hadoop 3.2.0** - HDFS, MapReduce, YARN
- **Java 8** - Applications (85.9% du code)
- **Python 3** - Hadoop Streaming (14.1% du code)
- **Maven** - Build & Gestion des dépendances
- **Docker** - Conteneurisation (yassern1/hadoop-spark-jupyter:1.0.3)

---

## 🚀 Quick Start

### Cloner le repository
```bash
git clone https://github.com/YoussefBoukharta/bigdata.git
cd bigdata
```

### Utiliser les JARs précompilés
Les JARs sont déjà compilés et prêts à l'emploi. Copiez-les dans votre volume partagé :
```bash
# Sur Windows
copy *.jar C:\Users\pc\Documents\hadoop_project\

# Sur Linux/Mac
cp *.jar /path/to/shared_volume/
```

### Compiler depuis les sources (optionnel)
```bash
cd BigData
mvn clean package
```

---

## 📝 Notes

- **Volume partagé** : Ajustez le chemin selon votre configuration
- **Ports exposés** : 9870 (HDFS), 8088 (YARN), 8040-8041 (Slaves)
- **JARs précompilés** : Disponibles à la racine du repository
- **Datasets** : Fichiers de test fournis dans `/datasets`

---

## 👨‍💻 Auteur

**Youssef Boukharta**
- GitHub: [@YoussefBoukharta](https://github.com/YoussefBoukharta)
- Repository: [bigdata](https://github.com/YoussefBoukharta/bigdata)


