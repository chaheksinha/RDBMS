# RDBMS

Lab programs for the RDBMS course, with the SQL and the output of each experiment.

**Name:** Chahek Sinha  
**Section:** AIML-4(D)  
**Roll number:** 26LBCS8301

The scripts use MySQL and the database `company_db`. Run them in this order, because each experiment uses the tables created before it:

1. [Experiment 3](experiment-03/queries.sql)
2. [Experiment 4](experiment-04/queries.sql)
3. [Experiment 5](experiment-05/queries.sql)
4. [Experiment 6](experiment-06/queries.sql)

## Experiments

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
