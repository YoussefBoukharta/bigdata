# HBase Big Data Engineering - TP Lab Work

**Course**: Big Data Engineering  
**Academic Year**: 2025-2026  
**Date**: November 13, 2025

## Table of Contents
1. [HBase Installation](#1-hbase-installation)
2. [HBase Shell First Steps](#2-hbase-shell-first-steps)
3. [HBase Filters Exploration](#3-hbase-filters-exploration)
4. [HBase Java API](#4-hbase-java-api)
5. [Bulk Data Loading](#5-bulk-data-loading)
6. [Spark Data Processing](#6-spark-data-processing)
7. [Additional Activity](#7-additional-activity)

---

## 1. HBase Installation

### Environment Setup
- **Cluster**: Docker containers (hadoop-master, hadoop-slave1, hadoop-slave2)
- **HBase Version**: 1.4.12
- **Hadoop Version**: 3.2.0
- **Spark Version**: 3.2.4

### Commands Executed
```bash
# Start containers
docker start hadoop-master hadoop-slave1 hadoop-slave2

# Enter master container
docker exec -it hadoop-master bash

# Start Hadoop services
./start-hadoop.sh

# Start HBase
/usr/local/hbase/bin/start-hbase.sh

# Verify processes
jps
```

**Output**: All processes running (HMaster, HRegionServer, ZooKeeper)

---

## 2. HBase Shell First Steps

### Created Table: `sales_ledger`
- **Column Families**: `customer`, `sales`
- **Records**: 4 entries (customers 101-104)

### Commands Used
```bash
hbase shell
create 'sales_ledger','customer','sales'
list

# Insert data
put 'sales_ledger','101','customer:name','John White'
put 'sales_ledger','101','customer:city','Los Angeles, CA'
put 'sales_ledger','101','sales:product','Chairs'
put 'sales_ledger','101','sales:amount','$400.00'
# ... (similar for 102, 103, 104)

# Scan table
scan 'sales_ledger'

# Get specific value
get 'sales_ledger','102',{COLUMN => 'sales:product'}
```

**Result**: Successfully created and populated `sales_ledger` table with customer and sales data.

---

## 3. HBase Filters Exploration

### Filters Tested

#### 1. RowFilter
```bash
scan 'sales_ledger', {FILTER => "RowFilter(>, 'binary:102')"}
```
- **Purpose**: Filter rows by row key
- **Result**: Returns rows 103, 104
- **Note**: `binary:102` means binary comparison with string "102"

#### 2. FamilyFilter
```bash
scan 'sales_ledger', {FILTER => "FamilyFilter(=, 'binary:customer')"}
```
- **Purpose**: Filter by column family
- **Result**: Shows only customer data (name, city)

#### 3. QualifierFilter
```bash
scan 'sales_ledger', {FILTER => "QualifierFilter(=, 'binary:amount')"}
```
- **Purpose**: Filter by column qualifier
- **Result**: Returns only sales:amount values

#### 4. ValueFilter
```bash
scan 'sales_ledger', {FILTER => "ValueFilter(=, 'substring:Sofa')"}
```
- **Purpose**: Filter by cell value
- **Difference**: `substring` matches partial text, `binary` requires exact match

#### 5. SingleColumnValueFilter
```bash
scan 'sales_ledger', {FILTER => "SingleColumnValueFilter('sales', 'amount', =, 'binary:$450.00')"}
```
- **Purpose**: Filter rows based on specific column value
- **Parameters**: family, qualifier, comparator, value

#### 6. PrefixFilter
```bash
scan 'sales_ledger', {FILTER => "PrefixFilter('10')"}
```
- **Purpose**: Filter rows by key prefix
- **Result**: Returns all rows starting with '10' (101-104)

#### 7. PageFilter
```bash
scan 'sales_ledger', {FILTER => "PageFilter(2)"}
```
- **Purpose**: Limit number of rows returned
- **Result**: Returns only first 2 rows

---

## 4. HBase Java API

### Program: HelloHBase.java
**Location**: `hbase-code/out/HelloHBase.java`

**Functionality**:
1. Creates `user` table with 2 column families:
   - `PersonalData` (name, address, tel)
   - `ProfessionalData` (company, salary, profession)
2. Inserts 2 users (mohamed, dane)
3. Reads and displays user1's name

### Compilation & Execution
```bash
mkdir hbase-code
cd hbase-code
mkdir out

# Compile
javac -cp "/usr/local/hbase/lib/*" -d ./out ./HelloHBase.java

# Execute
java -cp "./out:/usr/local/hbase/lib/*" HelloHBase
```

**Output**:
```
connecting
Creating Table
Done......
Adding user: user1
Adding user: user2
reading data...
mohamed
```

---

## 5. Bulk Data Loading

### Dataset: purchases_2.txt
- **Size**: 243 MB
- **Records**: 4,138,476 transactions
- **Format**: Comma-separated text file
- **Columns**: date, time, town, product, price, payment

### Process

#### 1. HDFS Upload
```bash
# Create HDFS directory
hadoop fs -mkdir -p input

# Upload file
hadoop fs -put /shared_volume/purchases_2.txt input
```

#### 2. HBase Table Creation
```bash
hbase shell
create 'products','cf'
exit
```

#### 3. ImportTsv MapReduce Job
```bash
hbase org.apache.hadoop.hbase.mapreduce.ImportTsv \
  -Dimporttsv.separator=',' \
  -Dimporttsv.columns=HBASE_ROW_KEY,cf:date,cf:time,cf:town,cf:product,cf:price,cf:payment \
  -libjars /usr/local/hbase/lib/commons-lang-2.6.jar \
  products /user/root/input/purchases_2.txt
```

**Results**:
- **Duration**: ~90 seconds
- **Records Loaded**: 4,138,476
- **Job Status**: SUCCESS

#### 4. Data Verification
```bash
hbase shell
get 'products','8',{COLUMN => 'cf:town'}
scan 'products', {LIMIT => 5}
```

**Output**: Record #8 town = 'New York'

---

## 6. Spark Data Processing

### Exercise 6: Count Records

**Program**: `HbaseSparkProcess.java`

**Purpose**: Read the HBase `products` table and count total number of records using Spark RDD.

**Key Features**:
- Creates Spark context with local[4] execution mode
- Uses `TableInputFormat` to read from HBase
- Creates `JavaPairRDD<ImmutableBytesWritable, Result>` from HBase table
- Counts records using RDD.count() method

**Compilation & Packaging**:
```bash
javac -cp '/usr/local/spark/jars/*:/usr/local/hbase/lib/*' /tmp/HbaseSparkProcess.java
jar cvf processing-hbase.jar -C /tmp/ HbaseSparkProcess.class
```

**Execution**:
```bash
# Copy HBase libraries to Spark
cp -r $HBASE_HOME/lib/* $SPARK_HOME/jars

# Submit Spark job
spark-submit --class HbaseSparkProcess --master local[4] /root/processing-hbase.jar
```

**Output**:
```
nombre d'enregistrements: 4138476
```

**Performance**: ~20 seconds execution time

---

## 7. Additional Activity: Sales Sum Calculation

### Exercise 7: Total Sales Calculation

**Program**: `HbaseSparkProcessSales.java`

**Purpose**: Calculate the total sum of all sales from the `products` table using Spark transformations.

**Key Features**:
- Implements `Serializable` interface to avoid serialization errors
- Uses anonymous inner classes for Spark `map()` and `reduce()` operations
- Extracts `cf:price` column from each HBase Result object
- Applies `reduce()` to sum all prices
- Calculates average price per transaction

**Implementation Highlights**:
- Reads HBase table into `JavaPairRDD`
- Maps each Result to extract price as Double
- Reduces prices using sum aggregation
- Displays total sales, transaction count, and average price

**Compilation & Packaging**:
```bash
javac -cp '/usr/local/spark/jars/*:/usr/local/hbase/lib/*' /tmp/HbaseSparkProcessSales.java
cd /tmp
jar cvf /root/processing-hbase-sales.jar HbaseSparkProcessSales*.class
```

**Execution**:
```bash
spark-submit --class HbaseSparkProcessSales --master local[4] /root/processing-hbase-sales.jar
```

**Output**:
```
Nombre d'enregistrements: 4138476
===============================================
Somme totale des ventes: $1,034,457,953.26
Nombre de transactions: 4138476
Prix moyen par transaction: $249.96
===============================================
```

**Performance**: ~20 seconds execution time

---

## Project Structure

```
hbase-code/
├── HelloHBase.java              # Basic HBase Java API example
├── HbaseSparkProcess.java       # Spark record count program
├── HbaseSparkProcessSales.java  # Spark sales calculation program
├── processing-hbase.jar         # Compiled JAR for record count
├── processing-hbase-sales.jar   # Compiled JAR for sales sum
└── out/
    └── HelloHBase.class         # Compiled HelloHBase class
```

---

## Key Technologies Used

| Technology | Version | Purpose |
|------------|---------|---------|
| HBase | 1.4.12 | NoSQL distributed database |
| Hadoop | 3.2.0 | Distributed file system (HDFS) |
| Spark | 3.2.4 | Data processing framework |
| ZooKeeper | 3.6.2 | Cluster coordination |
| Java | 1.8.0_362 | Programming language |
| Docker | - | Container platform |

---

## Troubleshooting Solutions

### Issue 1: ClassNotFoundException for commons-lang
**Solution**: Add `-libjars /usr/local/hbase/lib/commons-lang-2.6.jar` to ImportTsv command

### Issue 2: HRegionServer Connection Refused
**Solution**: Restart HBase services with `start-hbase.sh` and wait 10-15 seconds

### Issue 3: Task Not Serializable (Spark)
**Solution**: Make class implement `Serializable` interface

### Issue 4: NoClassDefFoundError for Inner Classes
**Solution**: Package all inner class files using wildcard: `jar cvf *.jar HbaseSparkProcessSales*.class`

---

## Performance Metrics

| Operation | Records | Time | Throughput |
|-----------|---------|------|------------|
| ImportTsv (MapReduce) | 4,138,476 | ~90s | ~46K records/sec |
| Spark Count | 4,138,476 | ~20s | ~207K records/sec |
| Spark Sum Calculation | 4,138,476 | ~20s | ~207K records/sec |

---

## Business Insights

### Sales Analysis Results
- **Total Revenue**: $1,034,457,953.26 (over $1 billion)
- **Transaction Count**: 4,138,476 purchases
- **Average Transaction Value**: $249.96
- **Data Period**: One fiscal year
- **Store Chain**: Multi-location retail business

---

## Learning Outcomes

1. ✅ HBase installation and cluster management
2. ✅ HBase Shell commands and CRUD operations
3. ✅ Advanced filtering techniques (7 filter types)
4. ✅ Java API for programmatic HBase access
5. ✅ Bulk data loading with MapReduce (ImportTsv)
6. ✅ Spark-HBase integration for big data processing
7. ✅ Distributed computing performance optimization
8. ✅ Real-world sales data analysis

---

## References

- Apache HBase Documentation: https://hbase.apache.org/
- Apache Spark Documentation: https://spark.apache.org/
- Hadoop Documentation: https://hadoop.apache.org/

---

**Course Instructor**: YASSER EL MADANI EL ALAMI  
**Institution**: Big Data Engineering Program  
**Completion Date**: November 13, 2025
