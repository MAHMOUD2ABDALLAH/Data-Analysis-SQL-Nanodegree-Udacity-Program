# Data Analysis SQL Nanodegree Udacity Program - SQL Joins

Learn how to execute core SQL commands to define, select, manipulate, control access, aggregate, and join data and data tables. Understand when and how to use subqueries, several window functions, and partitions to complete complex tasks. Clean data, optimize SQL queries and write select advanced JOINs to enhance analysis performance.

This branch focuses on combining data from multiple tables using SQL JOINs. All practice queries and solutions for this section can be found in the `sql_joins_queries.sql` file.

## SQL Joins Recap

### Primary and Foreign Keys
| Term | How to Use It | Other Details |
| :--- | :--- | :--- |
| `Primary Keys` | `id` | Unique for every row in a table. Generally the first column in the database. |
| `Foreign Keys` | `account_id` | The primary key appearing in another table, which allows the rows to be non-unique. |

### JOIN Types
| Statement | How to Use It | Other Details |
| :--- | :--- | :--- |
| `JOIN` | `JOIN Table2 ON Table1.id = Table2.id` | An INNER JOIN that only pulls data that exists in both tables. |
| `LEFT JOIN` | `LEFT JOIN Table2 ON ...` | Pulls all data that exists in both tables, as well as all rows from the table in the `FROM` even if they do not exist in the `JOIN`. |
| `RIGHT JOIN` | `RIGHT JOIN Table2 ON ...` | Pulls all data that exists in both tables, as well as all rows from the table in the `JOIN` even if they do not exist in the `FROM`. |
| `AS` | `FROM Table1 AS t1` | Used to alias tables and columns. Allows for efficiency and informative column headings. |

*Note: Advanced JOINs not covered in this lesson include UNION, UNION ALL, CROSS JOIN, and SELF JOIN.*

### Query Structure Best Practices
When writing JOIN queries, specify the table alias for each column to avoid ambiguity. The standard structure is:
