# Check for Kafka-related files
Get-ChildItem -Recurse -Filter "*kafka*" -ErrorAction SilentlyContinue
Get-ChildItem -Recurse -Filter "EventProducer*" -ErrorAction SilentlyContinue
Get-ChildItem -Recurse -Filter "EventConsumer*" -ErrorAction SilentlyContinue

# Check for HDFSInfo
Get-ChildItem -Recurse -Filter "HDFSInfo*" -ErrorAction SilentlyContinue

# Check for Kafka config files
Get-ChildItem -Filter "connect-*.properties" -ErrorAction SilentlyContinue
Get-ChildItem -Filter "test*.txt" -ErrorAction SilentlyContinue

Write-Host "🧹 Starting cleanup..." -ForegroundColor Cyan
Write-Host ""

# Remove Kafka directories
Write-Host "Checking for Kafka directories..." -ForegroundColor Yellow
if (Test-Path "kafka_lab") {
    Remove-Item -Path "kafka_lab" -Recurse -Force
    Write-Host "✓ Removed kafka_lab/" -ForegroundColor Green
}

# Remove Kafka Java files
Write-Host "Checking for Kafka Java files..." -ForegroundColor Yellow
Get-ChildItem -Recurse -Filter "EventProducer.java" -ErrorAction SilentlyContinue | ForEach-Object {
    Remove-Item $_.FullName -Force
    Write-Host "✓ Removed $($_.Name)" -ForegroundColor Green
}
Get-ChildItem -Recurse -Filter "EventConsumer.java" -ErrorAction SilentlyContinue | ForEach-Object {
    Remove-Item $_.FullName -Force
    Write-Host "✓ Removed $($_.Name)" -ForegroundColor Green
}

# Remove Kafka JARs
Write-Host "Checking for Kafka JARs..." -ForegroundColor Yellow
@( "producer.jar", "consumer.jar", "wordcount-app.jar") | ForEach-Object {
    Get-ChildItem -Recurse -Filter $_ -ErrorAction SilentlyContinue | ForEach-Object {
        Remove-Item $_.FullName -Force
        Write-Host "✓ Removed $($_.Name)" -ForegroundColor Green
    }
}

# Remove config files
Write-Host "Checking for Kafka config files..." -ForegroundColor Yellow
Get-ChildItem -Filter "connect-*.properties" -ErrorAction SilentlyContinue | ForEach-Object {
    Remove-Item $_.FullName -Force
    Write-Host "✓ Removed $($_.Name)" -ForegroundColor Green
}
Get-ChildItem -Filter "test*.txt" -ErrorAction SilentlyContinue | ForEach-Object {
    Remove-Item $_.FullName -Force
    Write-Host "✓ Removed $($_.Name)" -ForegroundColor Green
}

# Remove HDFSInfo (not in lab)
Write-Host "Checking for HDFSInfo files..." -ForegroundColor Yellow
Get-ChildItem -Recurse -Filter "HDFSInfo.*" -ErrorAction SilentlyContinue | ForEach-Object {
    Remove-Item $_.FullName -Force
    Write-Host "✓ Removed $($_.Name)" -ForegroundColor Green
}

# Remove Kafka scripts
Write-Host "Checking for Kafka scripts..." -ForegroundColor Yellow
Get-ChildItem -Filter "*kafka*.sh" -ErrorAction SilentlyContinue | ForEach-Object {
    Remove-Item $_.FullName -Force
    Write-Host "✓ Removed $($_.Name)" -ForegroundColor Green
}

# Clean Maven target
Write-Host "Cleaning Maven build artifacts..." -ForegroundColor Yellow
if (Test-Path "BigData\target") {
    Remove-Item -Path "BigData\target" -Recurse -Force
    Write-Host "✓ Removed BigData/target/" -ForegroundColor Green
}

Write-Host ""
Write-Host "✅ Cleanup complete!" -ForegroundColor Green
Write-Host ""

# Show remaining Java files
Write-Host "📁 Remaining Java files:" -ForegroundColor Cyan
Get-ChildItem -Path "BigData\src" -Recurse -Filter "*.java" -ErrorAction SilentlyContinue | Select-Object FullName | Format-Table -AutoSize

# Check current package structure
Write-Host "Current package structure:" -ForegroundColor Cyan
Get-ChildItem -Path "BigData\src\main\java\edu\ensias" -Recurse -Directory | Select-Object FullName

# Navigate to BigData
cd BigData

# Create correct directory structure
New-Item -Path "src\main\java\edu\ensias\hadoop\hdfslab" -ItemType Directory -Force

# Move HDFS files to correct location
Move-Item -Path "src\main\java\edu\ensias\bigdata\tp1\HadoopFileStatus.java" -Destination "src\main\java\edu\ensias\hadoop\hdfslab\" -Force
Move-Item -Path "src\main\java\edu\ensias\bigdata\tp1\ReadHDFS.java" -Destination "src\main\java\edu\ensias\hadoop\hdfslab\" -Force
Move-Item -Path "src\main\java\edu\ensias\bigdata\tp1\HDFSWrite.java" -Destination "src\main\java\edu\ensias\hadoop\hdfslab\" -Force

# Remove old directory
Remove-Item -Path "src\main\java\edu\ensias\bigdata" -Recurse -Force

Write-Host "✅ Package structure reorganized!" -ForegroundColor Green

# Go back to root
cd ..

# Update HadoopFileStatus.java
$file = "src\main\java\edu\ensias\hadoop\hdfslab\HadoopFileStatus.java"
(Get-Content $file) -replace 'package edu.ensias.bigdata.tp1;', 'package edu.ensias.hadoop.hdfslab;' | Set-Content $file
Write-Host "✓ Updated HadoopFileStatus.java" -ForegroundColor Green

# Update ReadHDFS.java
$file = "src\main\java\edu\ensias\hadoop\hdfslab\ReadHDFS.java"
(Get-Content $file) -replace 'package edu.ensias.bigdata.tp1;', 'package edu.ensias.hadoop.hdfslab;' | Set-Content $file
Write-Host "✓ Updated ReadHDFS.java" -ForegroundColor Green

# Update HDFSWrite.java
$file = "src\main\java\edu\ensias\hadoop\hdfslab\HDFSWrite.java"
(Get-Content $file) -replace 'package edu.ensias.bigdata.tp1;', 'package edu.ensias.hadoop.hdfslab;' | Set-Content $file
Write-Host "✓ Updated HDFSWrite.java" -ForegroundColor Green

Write-Host ""
Write-Host "✅ Package declarations updated!" -ForegroundColor Green

# Show HDFS classes
Write-Host "HDFS Lab (edu.ensias.hadoop.hdfslab):" -ForegroundColor Yellow
Get-ChildItem -Path "BigData\src\main\java\edu\ensias\hadoop\hdfslab" -Filter "*.java" | Select-Object Name

Write-Host ""

# Show MapReduce classes
Write-Host "MapReduce Lab (edu.ensias.hadoop.mapreducelab):" -ForegroundColor Yellow
Get-ChildItem -Path "BigData\src\main\java\edu\ensias\hadoop\mapreducelab" -Filter "*.java" | Select-Object Name