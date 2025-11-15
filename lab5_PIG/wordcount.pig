-- Charger le fichier texte
lines = LOAD '/shared_volume/alice.txt' USING PigStorage('\n') AS (line:chararray);

-- Découper chaque ligne en mots
words = FOREACH lines GENERATE FLATTEN(TOKENIZE(line)) AS word;

-- Nettoyer les mots (ne garder que les chaînes alphanumériques)
clean_words = FILTER words BY word MATCHES '\\w+';

-- Grouper par mot
grouped_words = GROUP clean_words BY word;

-- Compter le nombre d'occurrences de chaque mot
word_counts = FOREACH grouped_words GENERATE group AS word, COUNT(clean_words) AS count;

-- Sauvegarder le résultat dans HDFS ou local
STORE word_counts INTO '/shared_volume/pig_out/WORD_COUNT/' USING PigStorage(',');