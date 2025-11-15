-- Charger les employés
employees = LOAD '/user/root/input/employees.txt'
            USING PigStorage(',')
            AS (id:int, nomprenom:chararray, sexe:chararray, salaire:double, depno:int, ville:chararray, pays:chararray);

-- Charger les départements
departements = LOAD '/user/root/input/department.txt'
               USING PigStorage(',')
               AS (depno:int, dep_name:chararray);

-- Salaire moyen par département
emp_group_dep = GROUP employees BY depno;
salaire_moyen = FOREACH emp_group_dep GENERATE group AS depno, AVG(employees.salaire) AS salaire_moyen;

-- Nombre d'employés par département
nb_employes = FOREACH emp_group_dep GENERATE group AS depno, COUNT(employees) AS nb_employes;

-- Jointure employés / départements
emp_dep = JOIN employees BY depno, departements BY depno;

-- Employés avec salaire > 60000
high_salary = FILTER employees BY salaire > 60000;

-- Département avec salaire le plus élevé (max)
max_salaire_dep = FOREACH (GROUP employees BY depno) GENERATE group AS depno, MAX(employees.salaire) AS max_salaire;

-- Départements sans employés
depart_sans_emp = FILTER departements BY NOT depno IN (FOREACH employees GENERATE depno);

-- Nombre total d'employés
total_employes = FOREACH (GROUP employees ALL) GENERATE COUNT(employees) AS total_employes;

-- Employés à Paris
emp_paris = FILTER employees BY ville == 'Paris';

-- Salaire total par ville
salaire_ville = FOREACH (GROUP employees BY ville) GENERATE group AS ville, SUM(employees.salaire) AS total_salaire;

-- Départements ayant des femmes
dep_femmes = DISTINCT (FOREACH (FILTER employees BY sexe == 'Female') GENERATE depno);

-- Sauvegarde du résultat
STORE dep_femmes INTO '/user/root/pigout/employes_femmes/' USING PigStorage(',');