# RDBMS

Lab programs for the RDBMS course, with the SQL and the output of each experiment.

**Name:** Chahek Sinha  
**Section:** AIML-4(D)  
**Roll number:** 26LBCS8301

The scripts use MySQL. Run experiments 1 and 2 in order, then experiments 3 to 6 in order. Experiments 7 to 10 each create their own database.

1. [Experiment 1](experiment-01/queries.sql)
2. [Experiment 2](experiment-02/queries.sql)
3. [Experiment 3](experiment-03/queries.sql)
4. [Experiment 4](experiment-04/queries.sql)
5. [Experiment 5](experiment-05/queries.sql)
6. [Experiment 6](experiment-06/queries.sql)
7. [Experiment 7](experiment-07/queries.sql)
8. [Experiment 8](experiment-08/queries.sql)
9. [Experiment 9](experiment-09/queries.sql)
10. [Experiment 10](experiment-10/queries.sql)

Experiments 1 and 2 use `college_db`. Experiments 3 to 6 use `company_db`.

## Experiments

### Experiment 1 — Data definition

Create `college_db` with Department, Student, and Course tables. The script sets primary keys, foreign keys, `UNIQUE`, `CHECK`, and `DEFAULT`, then adds a column, changes a column, and drops a temporary table.

- Program: [experiment-01/queries.sql](experiment-01/queries.sql)
- Output: [experiment-01/output](experiment-01/output)

### Experiment 2 — Insert, update, and delete

Insert departments, students, and courses into `college_db`. Update a CGPA, fill a missing phone number, change course credits, delete one course, and list the students whose CGPA is at least 8.

- Program: [experiment-02/queries.sql](experiment-02/queries.sql)
- Output: [experiment-02/output](experiment-02/output)

### Experiment 3 — Selection, projection, aggregates, and grouping

Create an Employee–Department–Project schema. Insert 30 employees, 5 departments, and 8 projects. The queries cover selection, projection, aggregate functions, `GROUP BY`, `HAVING`, `CASE`, and `ORDER BY`.

- Program: [experiment-03/queries.sql](experiment-03/queries.sql)
- Output: [experiment-03/output](experiment-03/output)

### Experiment 4 — Joins, subqueries, and execution plans

Using the Employee schema, the queries use `INNER JOIN`, `LEFT JOIN`, a self-join, a 3-way join, correlated subqueries, `EXISTS`, simulated `INTERSECT` and `EXCEPT`, and `EXPLAIN`.

- Program: [experiment-04/queries.sql](experiment-04/queries.sql)
- Output: [experiment-04/output](experiment-04/output)

### Experiment 5 — Views and a recursive CTE

Create a department salary summary view and an employee hierarchy view, test whether those views can be updated, and use a recursive CTE to show reporting chains.

- Program: [experiment-05/queries.sql](experiment-05/queries.sql)
- Output: [experiment-05/output](experiment-05/output)

### Experiment 6 — Stored procedure, triggers, and audit log

Create `transfer_employee(emp_id, new_dept_id)` with validation and error handling. Triggers check that salary is greater than zero and write salary changes to `salary_audit`.

- Program: [experiment-06/queries.sql](experiment-06/queries.sql)
- Output: [experiment-06/output](experiment-06/output)

### Experiment 7 — Normalization to BCNF

Start from a repeating registration table and decompose it through 1NF and 2NF to 3NF/BCNF. The script checks that joining the new tables rebuilds the original rows and that each functional dependency stays inside one table.

- Program: [experiment-07/queries.sql](experiment-07/queries.sql)
- Output: [experiment-07/output](experiment-07/output)

### Experiment 8 — Transactions, savepoints, and isolation

Use `BankingDB` to commit a transfer, roll back a debit that would make a balance negative, and undo only the failed half of a batch with `ROLLBACK TO SAVEPOINT`. The second half of the script is the two-session isolation run: dirty read, non-repeatable read, and a repeatable-read snapshot.

- Program: [experiment-08/queries.sql](experiment-08/queries.sql)
- Output: [experiment-08/output](experiment-08/output)

### Experiment 9 — Single-column and composite indexes

Load 5,000 railway bookings and compare `EXPLAIN` for a PNR lookup and a train/date/status filter before and after `idx_pnr` and `idx_train_date_status`.

- Program: [experiment-09/queries.sql](experiment-09/queries.sql)
- Output: [experiment-09/output](experiment-09/output)

### Experiment 10 — Query rewrite and covering indexes

Load 2,000 customers and 12,000 orders. Five queries show a non-sargable date function, a leading wildcard, `NOT IN`, an unindexed sort, and a join with `GROUP BY`. Each one is then rewritten or indexed, and `EXPLAIN` is recorded again.

- Program: [experiment-10/queries.sql](experiment-10/queries.sql)
- Output: [experiment-10/output](experiment-10/output)
